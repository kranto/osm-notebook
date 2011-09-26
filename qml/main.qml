import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

PageStackWindow {
    id: appWindow

    showStatusBar: false

    initialPage: mainPage

    MainPage { id: mainPage }

    Binding {
    }

    Component { id: settingsComponent;
        Settings {
            onOrientationLockChanged: {
                screen.allowedOrientations =
                        (orientationLock == PageOrientation.Automatic)? (Screen.Portrait | Screen.Landscape):
                        (orientationLock == PageOrientation.LockPortrait)? Screen.Portrait: Screen.Landscape;
            }
        }
    }

    property Settings settings

    Component.onCompleted: {
        Storage.initialize();
        settings = settingsComponent.createObject(appWindow);
        refreshTracks();
    }

    function refreshTracks() {
        mainPage.loadTracks();
    }
}
