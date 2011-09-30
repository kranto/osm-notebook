import QtQuick 1.1
import com.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.2
import "storage.js" as Storage


Page {
    id: mainPage
    anchors.fill:  parent

    orientationLock: settings != undefined? settings.orientationLock: PageOrientation.Automatic

    signal settingsRequested

    Component {
        id: mapPolylineComponent;
        MapPolyline {
            border.color: "red"
            border.width: 3
            z: 1
        }
    }

    property variant trackPolylines: []
    property variant currentTrackPolyline: mapPolylineComponent.createObject(mainPage)

    function showTracks(trackIds) {
        var polylines = trackPolylines;

        for (var i=0; i < polylines.length; i++)  {
            polylines[i].selected = false;
            for (var j = 0; j < trackIds.length; j++) {
                if (trackIds[j] == polylines[i].id)
                    polylines[i].selected = true;
            }
            if (polylines[i].selected) {
                if (polylines[i].polyline == undefined) {
                    polylines[i].polyline = loadTrackPolyline(polylines[i].id);
                }
                map.addMapObject(polylines[i].polyline);
            } else {
                if (polylines[i].polyline != undefined)
                    map.removeMapObject(polylines[i].polyline);
            }
        }
        trackPolylines = polylines;
    }

    function loadTracks() {
        var polylines = new Array();
        var tracks = Storage.getTracks();
        for (var i in tracks) {
            var o = tracks[i];
            o.selected = false;
            for (var j in trackPolylines) {
                if (trackPolylines[j].id == tracks[i].id)
                    o = trackPolylines[j];
            }
            polylines.push(o);
        }
        trackPolylines = polylines;
    }

    Component { id: polylineComponent; MapPolyline { border.width: 3; border.color: "magenta"; z: 0} }
    Component { id: coordinateComponent; Coordinate { } }

    function loadTrackPolyline(trackId) {
        var polyline = polylineComponent.createObject(mainPage);
        var track = Storage.getTrackPoints(trackId);
        for (var i = 0; i < track.length; i++) {
            var c = coordinateComponent.createObject(mainPage);
            c.latitude = track[i].lat;
            c.longitude = track[i].lon;
            c.altitude = (typeof track[i].ele == "string")? -1: track[i].ele;
            polyline.addCoordinate(c);
        }
        return polyline;
    }

    TrackSelectionDialog {
        id: trackSelectionDialog
        trackList: trackPolylines
        onTracksSelected: showTracks(trackIds);
    }

    ToolIcon {
         id: actionMenuIcon
         z: 10;
         anchors.bottom: parent.bottom;
         anchors.right: parent.right;
         platformIconId: "toolbar-view-menu";
         onClicked: (actionMenu.status == DialogStatus.Closed) ? actionMenu.open() : actionMenu.close()
    }

    Menu {
        id: actionMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "Settings" ; onClicked: { settingsRequested(); } }
            MenuItem { text: "GPS on"; visible: tracker.state == "" && !tracker.gpsOn; onClicked: { tracker.gpsOn = true; } }
            MenuItem { text: "GPS off"; visible: tracker.state == "" && tracker.gpsOn; onClicked: { tracker.gpsOn = false; } }

            MenuItem { text: "Start Tracker"; visible: tracker.state == ""; onClicked: { tracker.start(); } }
            MenuItem { text: "Pause Tracker"; visible: tracker.state == "running"; onClicked: { tracker.pause(); } }
            MenuItem { text: "Resume Tracker"; visible: tracker.state == "paused"; onClicked: { tracker.resume(); } }
            MenuItem { text: "Stop Tracker"; visible: tracker.state == "running" || tracker.state == "paused"; onClicked: { tracker.finish(); } }

            MenuItem { text: "Select GPS Tracks"; onClicked: { trackSelectionDialog.open(); } }

            MenuItem { text: "Export Tracks";
                onClicked: {
                    var tracks = Storage.getTracks();
                    for (var t = 0; t < tracks.length; t++) {
                        Storage.printTrack(tracks[t]);
                    }
                }
            }
        }
    }

    function moveTo(position) {
        if (jumpToAnimation.running)
            return;
        map.targetCoordinate = map.lockedToLocation? position.coordinate: map.center;
        moveToAnimation.circlePosition = position;
        moveToAnimation.restart();
    }

    function jumpTo(coord) {
        moveToAnimation.stop();
        map.targetCoordinate = coord;
        jumpToAnimation.restart();
    }

    InfoBanner{
	id: trackerStateChangeBanner
        text: tracker.latestMessage
	iconSource: ":/images/tracker_on.png"
	timerEnabled: true
	timerShowTime: 3000
	topMargin: 10
	leftMargin: 10
	z: 1000
    }

    Tracker {
        id: tracker
        onTrackFinished: appWindow.refreshTracks()
        onLatestPositionChanged: {
            if (latestPosition != undefined && latestPosition.latitudeValid && latestPosition.longitudeValid) {
                moveTo(latestPosition);
            }
        }
        onNewTrackPosition: {
            currentTrackPolyline.addCoordinate(position.coordinate);
        }
        onLatestMessageChanged: if (state != "") trackerStateChangeBanner.show();
        property string prevState: ""
        onTrackStarted: {
            console.log("track started");

            map.removeMapObject(currentTrackPolyline);
            currentTrackPolyline = mapPolylineComponent.createObject(mainPage);
            map.addMapObject(currentTrackPolyline);
        }
    }

    Item {
        id: pos

        property Position latestPosition: tracker.latestPosition
        property Coordinate latestCoordinate: latestPosition.coordinate
        property bool isLatestOnMap: true

        Item {
            property double lat: pos.latestCoordinate != undefined? pos.latestCoordinate.latitude: 0
            property double lon: pos.latestCoordinate != undefined? pos.latestCoordinate.longitude: 0
            onLatChanged: pos.isLatestOnMap = pos.calcIsLatestOnMap();
            onLonChanged: pos.isLatestOnMap = pos.calcIsLatestOnMap();
        }

        function calcIsLatestOnMap() {
            if (map.lockedToLocation)
                return true;
            var p = map.toScreenPosition(pos.latestCoordinate);
            return p.x >= 0 && p.x < map.width && p.y >= 0 && p.y < map.height;
        }
    }

    MultiMap {
        id: map
        anchors.fill:  parent

        property bool lockedToLocation: false
        property Coordinate latestCoordinate: Coordinate { latitude: 61.5; longitude: 23.7 }
        property Coordinate targetCoordinate: Coordinate { }
        center: latestCoordinate
        zoomLevel: zoomSlider.value

        function storeCenter() {
            Storage.setState("mapCenterLat", "" + center.latitude);
            Storage.setState("mapCenterLon", "" + center.longitude);
        }

        Component.onCompleted: {
            latestCoordinate.latitude = Storage.getState("mapCenterLat", 61.5);
            latestCoordinate.longitude = Storage.getState("mapCenterLon", 23.8);
            zoomSlider.value = Storage.getState("mapZoomLevel", 15);
            lockedToLocation = Storage.getState("lockedToLocation", true);
        }

        onTargetCoordinateChanged: storeCenter();

        onViewportChanges: {
            pos.isLatestOnMap = pos.calcIsLatestOnMap();
        }

        onZoomLevelChanged: {
            moveTo(pos.latestPosition);
            Storage.setState("mapZoomLevel", "" + zoomLevel);
        }

        onLockedToLocationChanged: Storage.setState("lockedToLocation", lockedToLocation);

        function setCenter(newCenter) {
            lockToLocation(false);
            jumpTo(newCenter);
        }

        function lockToLocation(lock) {
            if (lock)
                jumpTo(pos.latestPosition.coordinate);
            lockedToLocation = lock
        }

        maps: [
            Map {
                id: mmap0
                plugin: Plugin { name: "openstreetmap" }
                mapType: Map.StreetMap
            },

            Map {
                id: mmap1
                plugin: Plugin { name: "nokia" }
                mapType: Map.StreetMap
            },

            Map {
                id: mmap2
                plugin: Plugin { name: "nokia" }
                mapType: Map.SatelliteMapDay
            },

            Map {
                id: mmap3
                plugin: Plugin { name: "google" }
                mapType: Map.StreetMap
            }
        ]

        mapObjects: [
            MapCircle {
                id: myPosition
		border.color: tracker.positionAge < 5? "#a0108010": "#a0a0a000"
		border.width: 3
		color: tracker.positionAge < 5? "#3010ff10": "#30ffff00"
                center:  Coordinate { latitude: 61.5; longitude: 23.7 }
                z: 10
            }
        ]

        activeMap: maps[mapSwitcher.selectedIndex]

        PinchArea {
            anchors.fill: parent
            property real originalZoomLevel
            onPinchStarted: {
                originalZoomLevel = zoomSlider.value;
            }
            onPinchUpdated: {
                var newZoomLevel = originalZoomLevel + Math.log(pinch.scale)/Math.LN2;
                zoomSlider.value = newZoomLevel;
            }
            onPinchFinished: {
            }
        }

        MouseArea {
            id: panMouseArea
            anchors.fill:  parent
            property int x0
            property int y0
            property bool firstChange: false
            onPressed: {
                x0 = mouse.x
                y0 = mouse.y
                firstChange = true
            }
            onPositionChanged:  {
                if (!pressed)
                    return;
                var dx = mouse.x - x0;
                var dy = mouse.y - y0;

		if (firstChange && Math.abs(dx) + Math.abs(dy) > 300) // more than N pixels as first touch -> interpret as multitouch
                    return;
                firstChange = false;
                if (map.lockedToLocation) {
                    if (Math.abs(dx) + Math.abs(dy) < 40) // N pixels needed to unlock
                        return;
                    else
                        map.lockToLocation(false);
                }
                x0 = mouse.x
                y0 = mouse.y
                map.latestCoordinate = map.toCoordinate(Qt.point(map.width/2-dx, map.height/2-dy));
            }
            onReleased: {
                map.storeCenter();
            }

            onDoubleClicked: {
                var newCenter = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                zoomSlider.value += 1;
                map.latestCoordinate = newCenter;
                map.lockToLocation(false);
                map.storeCenter();
            }
        }
    }

    Item {
        id: mapSwitcher
        anchors.right: map.right
	anchors.top: lockButton.bottom
	anchors.topMargin: 20
        width: 80
        height: switcherColumn.height

        property int selectedIndex: 0

        Column {
            id: switcherColumn
            spacing: 5

            Repeater {
                model: map.maps.length - 1
                Rectangle {
                    width: mapSwitcher.width
                    height: 80
                    radius: 4
                    border.color: "gray"
                    border.width: 1
                    color: "gray"
                    opacity: switcherMouseArea.pressed? 0.8: 0.2
                    MouseArea {
                        id: switcherMouseArea
                        anchors.fill: parent
                        onPressed: mapSwitcher.selectedIndex = index + 1;
                        onReleased: mapSwitcher.selectedIndex = 0;
                    }
                }
            }
        }
    }


    Slider {
        id: zoomSlider
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:  parent.width
        minimumValue: 4 // map.minimumZoomLevel
        maximumValue: 20
        value: 15
        visible: false
    }

    Column {
        id: debugValueColumn
        width: parent.width
        Label {
            text: pos.latestCoordinate.latitude + " " + pos.latestCoordinate.longitude + " " + pos.latestPosition.speed
        }
        Label {
            text: map.center.latitude + " " + map.center.longitude
        }
        Label {
            text: Math.round(pos.latestPosition.horizontalAccuracy*100)/100 + " "
                  + Math.round(zoomSlider.value*100)/100 + " " + Math.round(map.activeMap.scale*100)/100
                  + " " + map.activeMap.width + " "  + map.activeMap.height + " " + currentTrackPolyline.path.length;
        }
        visible: settings.showDebug
    }

    Button {
        id: lockButton
        text: pos.isLatestOnMap? "Follow Track": "Where am I"
        font.pixelSize: 20
        width: 150
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.right:  parent.right
        onClicked: {
            if (map.center.distanceTo(pos.latestCoordinate) >
                    map.toCoordinate(Qt.point(0,0)).distanceTo(map.toCoordinate(Qt.point(map.width, map.height)))) {
                backButton.setLatestCenter(map.center);
            } else if (!pos.isLatestOnMap) {
                backButton.resetLatestCenter();
            }
            map.lockToLocation(true);
        }
        visible: !map.lockedToLocation && tracker.latestPosition.latitudeValid
        opacity: 0.6
    }

    Button {
        id: backButton
        property bool latestCenterSet: false
        property Coordinate latestCenter: Coordinate { }
        function setLatestCenter(coord) {
            latestCenter.latitude = coord.latitude;
            latestCenter.longitude = coord.longitude;
            latestCenterSet = true;
        }
        function resetLatestCenter() {
            latestCenterSet = false;
        }
        text: "Go Back"
        anchors.fill: lockButton
        onClicked: { map.setCenter(latestCenter); }
        visible: map.lockedToLocation && latestCenter != undefined && latestCenterSet
        opacity: 0.6
    }

    Image {
	id: name
	source: ":/images/tracker_on.png"
	anchors.top: parent.top
	anchors.left: parent.left
	visible: tracker.state == "running"
    }

    ParallelAnimation {
        id: moveToAnimation

        property Position circlePosition: Position { }

        PropertyAnimation {
            target: map
            property: "latestCoordinate.latitude"
            to: map.targetCoordinate.latitude
            easing.type: Easing.InOutCubic
            duration: 300
        }

        PropertyAnimation {
            target: map
            property: "latestCoordinate.longitude"
            to: map.targetCoordinate.longitude
            easing.type: Easing.InOutCubic
            duration: 300
        }

        PropertyAnimation {
            target: myPosition
            property: "radius"
            to: Math.max(moveToAnimation.circlePosition.horizontalAccuracy, 2 * Math.pow(2, 18 - map.zoomLevel))
            easing.type: Easing.InOutCubic
            duration: 300
        }

        PropertyAnimation {
            target: myPosition
            property: "center.latitude"
            to: moveToAnimation.circlePosition.coordinate.latitude
            easing.type: Easing.InOutCubic
            duration: 300
        }

        PropertyAnimation {
            target: myPosition
            property: "center.longitude"
            to: moveToAnimation.circlePosition.coordinate.longitude
            easing.type: Easing.InOutCubic
            duration: 300
        }
    }

    ParallelAnimation {
        id: jumpToAnimation

        PropertyAnimation {
            target: map
            property: "latestCoordinate.latitude"
            to: map.targetCoordinate.latitude
            easing.type: Easing.InOutCubic
            duration: 1000
        }

        PropertyAnimation {
            target: map
            property: "latestCoordinate.longitude"
            to: map.targetCoordinate.longitude
            easing.type: Easing.InOutCubic
            duration: 1000
        }
    }
}
