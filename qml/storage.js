//sorage.js
// Originally from http://www.developer.nokia.com/Community/Wiki/How-to_create_a_persistent_settings_database_in_Qt_Quick_%28QML%29
// First, let's create a short helper function to get the database connection
function getDatabase() {
     return openDatabaseSync("osm-notebook", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS state(key TEXT UNIQUE, value TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS tracks(id INTEGER UNIQUE, date INTEGER, name TEXT, description TEXT, duration INTEGER, length INTEGER)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS trackpoints(trackid INTEGER, lat FLOAT, lon FLOAT, ele FLOAT, time INTEGER)');
          });
    return db;
}

// This function is used to write a setting into the database
function setSetting(setting, value) {
   // setting: string representing the setting name (eg: “username”)
   // value: string representing the value of the setting (eg: “myUsername”)
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
              //console.log(rs.rowsAffected)
              if (rs.rowsAffected > 0) {
                res = "OK";
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}
// This function is used to retrieve a setting from the database
function getSetting(setting, defaultValue) {
    defaultValue = typeof(defaultValue) != 'undefined' ? defaultValue : 'unknown';
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = defaultValue;
        }
    })
    return res;
}

function setState(key, value) {
   var db = getDatabase();
   var res = false;
   db.transaction(function(tx) {
                      var rs = tx.executeSql('INSERT OR REPLACE INTO state VALUES (?,?);', [key, value]);
                      if (rs.rowsAffected > 0)
                          res = true;
                  });
  return res;
}

function getState(key, defaultValue) {
    defaultValue = typeof(defaultValue) != 'undefined' ? defaultValue : 'unknown';
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT value FROM state WHERE key=?;', [key]);
                       if (rs.rows.length > 0)
                           res = rs.rows.item(0).value;
                       else
                           res = defaultValue;
                   });
    console.log("getState: " + key + " " + defaultValue + " " + res);
    return res;
}

function storeTrackPoint(position) {
    var res = false;
    var db = getDatabase();
    db.transaction(function(tx) {
//        console.log(position.coordinate.latitude + " " + position.timestamp);
        var rs = tx.executeSql('INSERT INTO trackpoints VALUES (?,?,?,?,?);',
                               [currentTrack,
                                position.coordinate.latitude,
                                position.coordinate.longitude,
                                position.coordinate.altitude,
                                position.timestamp.getTime()]);
        if (rs.rowsAffected > 0)
            res = true;
        }
    );
    return res;
}

function printTrack(track) {
    console.log("Track: " + track.id + " " + " " + track.date + " " + track.name + " " + track.description);
    printTrackPoints(track.id);
}

function printTrackPoints(trackId) {
    var trackPoints = getTrackPoints(trackId);
    for (var i  = 0; i < trackPoints.length; i++) {
        var item = trackPoints[i]
        console.log(item.lat + "," + item.lon + "," + item.ele + "," + item.time);
    }
}

function getTrackInfo(trackId) {
    var db = getDatabase();
    var track = new Object();
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM tracks WHERE id=?;', [trackId]);
                       if (rs.rows.length > 0) {
                           track = rs.rows.item(0);
                       }
         });
    return track;
}

function getTrackPoints(trackId) {
    var db = getDatabase();
    var track = new Array();
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM trackpoints WHERE trackid=? ORDER BY time ASC', [trackId]);
                       track = new Array(rs.rows.length);
                       for (var i  = 0; i < rs.rows.length; i++) {
                           var item = rs.rows.item(i);
                           track[i] = item;
                       }
                   });
    return track;
}

var currentTrack = 0;

function newTrack() {
    var db = getDatabase();
    var trackId = new Date().getTime();
//    console.log("trackId: " + trackId);
    db.transaction(function(tx) {
               var rs = tx.executeSql('INSERT INTO tracks VALUES (?,?,?,?,?,?);',
                                      [trackId, new Date().getTime(), "", "", 0, 0]);
               if (rs.rowsAffected <= 0) {
                   trackId = -1;
               }
         });
    currentTrack = trackId;
    return trackId;
}

function getTracks() {
    var db = getDatabase();
    var tracks = new Array();
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT * FROM tracks ORDER BY date ASC;');
                       tracks = new Array(rs.rows.length);
                       for (var i = 0; i < rs.rows.length; i++) {
                           var item = rs.rows.item(i);
                           tracks[i] = item;
                       }
         });
    return tracks;
}
