import QtQuick 1.1
import com.meego 1.0
import "storage.js" as Storage

Page {
    id: page
    anchors.fill:  parent

    tools: ToolBarLayout {
        ToolIcon {
            id: backButton
            visible: pageStack != null && pageStack.depth > 1
            iconId: "toolbar-back"
            onClicked: { pageStack.pop(); }
        }
    }

    Flickable {
        anchors.fill: parent

        Column {
            spacing: 10
            Row { Label { text: "OrientationLock"} Label { text: settings.orientationLock } }
            Column {
                Label { text: "Orientation Lock"}
                ButtonRow {
                    checkedButton: [b1, b2, b3][settings.orientationLock]
                    Button { id: b1; text: "Auto"; onClicked: settings.orientationLock = PageOrientation.Automatic; }
                    Button { id: b2; text: "Portrait"; onClicked: settings.orientationLock = PageOrientation.LockPortrait; }
                    Button { id: b3; text: "Landscape"; onClicked: settings.orientationLock = PageOrientation.LockLandscape; }
                }
            }
        }
    }
}
