import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

Item {
    id: tracker

    signal trackFinished

    property MapPolyline trackPolyline: MapPolyline { }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: tracker.state == "running"
        // nmeaSource: "nmealog.txt"
        property int skipFirst: 3
        property int prevSpeed: 0
        onPositionChanged: {
            if (position != undefined && position.latitudeValid && position.longitudeValid) {
                if (skipFirst > 0)
                    skipFirst--;
                if (skipFirst == 0 && position.speedValid && position.speed < 40)
                    // if we move over 3.6 kmh OR this is the first point OR we have crawled over 10 metres from the last point
                    if (position.speed > 1 || trackPolyline.path.length == 0
                            || position.coordinate.distanceTo(trackPolyline.path[trackPolyline.path.length -1 ]) > 10 ) {
                        if (!Storage.storeTrackPoint(position))
                            console.log("storage failed");
                        trackPolyline.addCoordinate(position.coordinate);
                    }
            }
        }
    }

    function start()  {
        Storage.newTrack();
        state = "running";
    }

    function pause() {
        state = "paused";
    }

    function resume() {
        state = "running";
    }

    function finish() {
        tracker.state = "";
        trackNameDialog.clearAndOpen();
    }

    TextEntryDialog {
        id: trackNameDialog; titleText: "Enter name for the track";
        placeHolderText: "<Enter name here>";
        acceptButtonText: "OK"

        function clearAndOpen() {
            text = "";
            open();
        }

        onAccepted: {
            Storage.finalizeCurrentTrack(text);
            tracker.trackFinished();
        }
        onRejected: {
            Storage.finalizeCurrentTrack("");
            tracker.trackFinished();
        }
    }

}
