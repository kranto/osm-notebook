import QtQuick 1.0
import com.nokia.meego 1.0
import "storage.js" as Storage

QtObject {

    property bool fullScreen: Storage.getSetting("fullScreen", false)
    onFullScreenChanged: Storage.setSetting("fullScreen", fullScreen);

    property int orientationLock: Storage.getSetting("orientationLock", PageOrientation.Automatic)
    onOrientationLockChanged: Storage.setSetting("orientationLock", orientationLock);

    property int gpsOnInStartup: Storage.getSetting("gpsOnInStartup", 2)
    onGpsOnInStartupChanged: Storage.setSetting("gpsOnInStartup", gpsOnInStartup);

    property real zoomFactor: Storage.getSetting("zoomFactor", 1)
    onZoomFactorChanged: Storage.setSetting("zoomFactor", zoomFactor);

    property bool showMapSwitcher: Storage.getSetting("showMapSwitcher", false)
    onShowMapSwitcherChanged: Storage.setSetting("showMapSwitcher", showMapSwitcher);

    property bool showDebug: Storage.getSetting("showDebug", false)
    onShowDebugChanged: Storage.setSetting("showDebug", showDebug);
}
