import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

PageStackWindow {
    id: appWindow

    showStatusBar: false

    initialPage: mainPage

    MainPage { id: mainPage }

    Component.onCompleted: {
        Storage.initialize();
    }

    function pushPage(view) {
        var component = loadComponent(view + ".qml");
        if (component != null) {
            pageStack.push(component);
        }
    }

    function loadComponent(file) {
        var component = Qt.createComponent(file)

        if (component.status == Component.Ready)
            return component;
        else
            console.log("Error loading component:", component.errorString());
        return null;
    }


    Component {
        id: actionMenuIconComponent
        ToolIcon {
            platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (actionMenu.status == DialogStatus.Closed) ? actionMenu.open() : actionMenu.close()
        }
    }

    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon { id: backButton;
            visible: pageStack != null && pageStack.depth > 1;
            iconId: "toolbar-back";
            onClicked: { actionMenu.close(); pageStack.pop(); }  }

        Loader { sourceComponent: actionMenuIconComponent }
    }

    Component {
        id: coordinateComponent
        Coordinate { }
    }

    Menu {
        id: actionMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "GPS on/off";  }
            MenuItem { text: "Tracker on/off" }
            MenuItem { text: "Import Tracks"; onClicked: {
                    appWindow.pushPage("TrackList");

                    /*
                    var tracks = Storage.getTracks();
                    map.activeMap.removeMapObject(trackPolyline);
                    for (var t = 0; t < tracks.length; t++) {
                        var track = Storage.getTrackPoints(tracks[t].id);
                        for (var i = 0; i < track.length; i++) {
                            var c = coordinateComponent.createObject(mainPage);
                            c.latitude = track[i].lat;
                            c.longitude = track[i].lon;
                            c.altitude = (typeof track[i].ele == "string")? -1: track[i].ele;
                            trackPolyline.addCoordinate(c);
                        }
                    }
                    map.activeMap.addMapObject(trackPolyline);
                    */
                }
            }
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
}
