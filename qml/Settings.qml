import QtQuick 1.0
import com.nokia.meego 1.0
import "storage.js" as Storage

QtObject {
    property int orientationLock: Storage.getSetting("orientationLock", PageOrientation.Automatic);
    onOrientationLockChanged: {
        console.log("orientationLockChanged " + orientationLock);
        Storage.setSetting("orientationLock", orientationLock);
        console.log("orientationLockChanged and stored " + orientationLock);
    }
}
