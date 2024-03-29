import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

Item {
    id: tracker

    signal trackStarted
    signal trackFinished
    signal newTrackPosition(variant position)
    property string latestMessage

    property bool gpsOn: false
    property alias latestPosition: positionSource.position;
    property int positionAge: 0

    Component.onCompleted: {
	gpsOn = settings == undefined? true:
                settings.gpsOnInStartup == 2? Storage.getState("gpsOn", true):
                settings.gpsOnInStartup == 1;
    }

    Timer {
	id: ageTimer
	interval: 5000
	repeat: true
	onTriggered: tracker.positionAge += 5;
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: tracker.state != ""  || gpsOn
        property int skipFirst: 3
        property int prevSpeed: 0
        property variant prevCoordinate

        onPositionChanged: {
	    ageTimer.restart();
	    tracker.positionAge = 0;
            if (tracker.state == "running") {
                if (position != undefined && position.latitudeValid && position.longitudeValid) {
                    if (skipFirst > 0)
                        skipFirst--;
                    if (skipFirst == 0 && position.speedValid && position.speed < 40)
                        // if we move over 3.6 kmh OR this is the first point OR we have crawled over 10 metres from the last point
                        if (position.speed > 1
                                || prevCoordinate == undefined
                                || position.coordinate.distanceTo(prevCoordinate) > 10 ) {
                            if (!Storage.storeTrackPoint(position))
                                console.log("storage failed");
                            tracker.newTrackPosition(position);
                            prevCoordinate = position.coordinate
                        }
                }
            }
        }
    }

    onGpsOnChanged: {
        Storage.setState("gpsOn", gpsOn);
    }

    function start()  {
        Storage.newTrack();
        positionSource.prevCoordinate = undefined
        state = "running";
	latestMessage = "Tracker started";
        trackStarted();
    }

    function pause() {
        state = "paused";
	latestMessage = "Tracker paused";
    }

    function resume() {
        state = "running";
	latestMessage = "Tracker resumed";
    }

    function finish() {
        tracker.state = "";
        latestMessage ="Tracker stopped";
        trackFinished();
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
