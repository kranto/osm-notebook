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
        refreshTracks();
    }

    function refreshTracks() {
        mainPage.loadTracks();
    }
}
