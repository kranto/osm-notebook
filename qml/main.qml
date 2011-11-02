import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

PageStackWindow {
    id: appWindow

    initialPage: loaderPage
    showStatusBar: !settings.fullScreen
    property variant mainPage

    Page {
        id: loaderPage
        anchors.fill: parent

        Image {
            id: loaderImage
            anchors.centerIn: parent
            source: "file:/usr/share/icons/hicolor/80x80/apps/osm-notebook.png"
            width: 160
            height: 160
        }
        onStatusChanged: {
            if (status == PageStatus.Active)
                timer.start();
        }

        Timer {
            id: timer
            interval: 1000
            onTriggered: {
                appWindow.pageStack.push(mainPageComponent);
                mainPage = appWindow.pageStack.currentPage;
                refreshTracks();
            }
        }
    }

    property Settings settings: Settings { }
    Component { id: settingsPageComponent; SettingsPage { } }

    Component { id: mainPageComponent
        MainPage { onSettingsRequested: { pageStack.push(settingsPageComponent); } }
    }

    function refreshTracks() {
        if (mainPage != undefined)
            mainPage.loadTracks();
    }
}
