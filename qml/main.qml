import QtQuick 1.1
import com.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    showStatusBar: !settings.fullScreen

    Component.onCompleted: {
        refreshTracks();
    }

    property Settings settings: Settings { }
//    Component { id: settingsComponent; Settings { } }
    Component { id: settingsPageComponent; SettingsPage { } }

    MainPage { id: mainPage; onSettingsRequested: { pageStack.push(settingsPageComponent); } }

    function refreshTracks() {
        mainPage.loadTracks();
    }
}
