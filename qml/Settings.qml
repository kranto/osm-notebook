import QtQuick 1.0
import com.nokia.meego 1.0
import "storage.js" as Storage

QtObject {

    property int orientationLock: Storage.getSetting("orientationLock", PageOrientation.Automatic)
    onOrientationLockChanged: Storage.setSetting("orientationLock", orientationLock);

    property int gpsOnInStartup: Storage.getSetting("gpsOnInStartup", 2)
    onGpsOnInStartupChanged: Storage.setSetting("gpsOnInStartup", gpsOnInStartup);
}
