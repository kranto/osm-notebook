import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage


Page {
    id: mainPage
    anchors.fill:  parent

    Component.onCompleted: {
        var tracks = Storage.getTracks();
        for (var i = 0; i < tracks.length; i++) {
            console.log(tracks[i].id + " " + tracks[i].name)
        }
    }

    Loader { sourceComponent: actionMenuIconComponent; z: 10; anchors.bottom: parent.bottom; anchors.right: parent.right; }

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
//        jumpToAnimation.mapCenter = coord;
        jumpToAnimation.restart();
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: gpsToggleButton.checked
        // nmeaSource: "nmealog.txt"
        property int skipFirst: 3
        property int prevSpeed: 0
        onPositionChanged: {
            if (position != undefined && position.latitudeValid && position.longitudeValid) {
                moveTo(position);
                if (skipFirst > 0)
                    skipFirst--;
                if (!trackerToggleButton.checked)
                    return;
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

    Item {
        id: pos

        property Position latestPosition: positionSource.position
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
            MapPolyline {
                id: trackPolyline
                border.color: "red"
                border.width: 3
                z: 0
            },

            MapCircle {
                id: myPosition
                border.color: "blue"
                border.width: 3
                center:  Coordinate { latitude: 61.5; longitude: 23.7 }
                z: 10
            }
        ]

        activeMap: maps[mouseArea.selectedIndex]

        PinchArea {
            anchors.fill: parent
            property real originalZoomLevel
            onPinchStarted: {
//                console.log("pinch started " + pinch.scale + " " + panMouseArea.pressed);
                originalZoomLevel = zoomSlider.value;
            }
            onPinchUpdated: {
                var newZoomLevel = originalZoomLevel + Math.log(pinch.scale)/Math.LN2;
//                console.log("pinch updated " + newZoomLevel);
                zoomSlider.value = newZoomLevel;
            }
            onPinchFinished: {
//                console.log("pinch finished " + pinch.scale);
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
//                console.log("mouse pressed: " + x0 + " " + y0);
            }
            onPositionChanged:  {
                if (!pressed)
                    return;
                var dx = mouse.x - x0;
                var dy = mouse.y - y0;
//                console.log("dx " + dx + ", dy " + dy + ", fc " + firstChange);

                if (firstChange && Math.abs(dx) + Math.abs(dy) > 200) // more than N pixels as first touch -> interpret as multitouch
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
//                console.log("panning " + dx + " " + dy);
            }
            onReleased: {
                map.storeCenter();
            }

            onDoubleClicked: {
                var newCenter = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                zoomSlider.value += 1;
//                map.setCenter(newCenter);
                map.latestCoordinate = newCenter;
                map.lockToLocation(false);
                map.storeCenter();
//                jumpTo(newCenter);
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.top: map.top
        x: map.x
        width: map.width
        height:  50
        property int selectedIndex: 0
        onPressed:  {
            selectedIndex = 1 + Math.floor(mouse.x*(map.maps.length-1)/width);
        }
        onReleased: {
            selectedIndex = 0;
        }
    }


    // last one to be on top
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
        id: labelColumn
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
                  + " " + map.activeMap.width + " "  + map.activeMap.height + " " + trackPolyline.path.length;
        }
    }

    Button {
        id: lockButton
        text: pos.isLatestOnMap? "Follow Track": "Where am I"
        width: 200
        anchors.top: mouseArea.bottom
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
        visible: !map.lockedToLocation
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
        visible: !lockButton.visible && latestCenter != undefined && latestCenterSet
        opacity: 0.6
    }

    ToolButton {
        id: gpsToggleButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        iconSource: ""
        text: checked? "GPS On": "GPS Off"
        onCheckedChanged: Storage.setState("gpsOn", checked);
        checkable: true
        checked: Storage.getState("gpsOn", true)
        opacity: 0.6
    }

    ToolButton {
        id: trackerToggleButton
        anchors.left: gpsToggleButton.right
        anchors.bottom: parent.bottom
        iconSource: ""
        text: checked? "Tracker On": "Tracker Off"
        enabled: gpsToggleButton.checked
        checkable: true
        checked: false
        opacity: 0.6
        onCheckedChanged: {
            if (checked) {
                var trackId = Storage.newTrack();
            }
        }
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
