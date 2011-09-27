import QtQuick 1.1
import com.meego 1.0

Page {
    id: page
    anchors.fill:  parent
    orientationLock: settings != undefined? settings.orientationLock: PageOrientation.Automatic

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
        contentWidth: width;
        contentHeight: settingsColumn.height

        Label {
            anchors.top: parent.top
            anchors.topMargin: 10
            id: titleLabel; text: "Settings"; font.pixelSize: 32; font.bold: true;
        }

        Column {
            anchors.top: titleLabel.bottom
            anchors.topMargin: 30

            id: settingsColumn
            spacing: 30
            Column {
                spacing: 5
                Label { text: "Orientation Lock"; font.pixelSize: 28; }
                ButtonRow {
                    checkedButton: [b11, b12, b13][settings.orientationLock]
                    Button { id: b11; text: "Auto"; onClicked: settings.orientationLock = PageOrientation.Automatic; }
                    Button { id: b12; text: "Portrait"; onClicked: settings.orientationLock = PageOrientation.LockPortrait; }
                    Button { id: b13; text: "Landscape"; onClicked: settings.orientationLock = PageOrientation.LockLandscape; }
                }
            }
            Column {
                spacing: 5
                Label { text: "GPS on in Startup"; font.pixelSize: 28; }
                ButtonRow {
                    checkedButton: [b21, b22, b23][settings.gpsOnInStartup]
                    Button { id: b21; text: "Off"; onClicked: settings.gpsOnInStartup = 0; }
                    Button { id: b22; text: "On"; onClicked: settings.gpsOnInStartup = 1; }
                    Button { id: b23; text: "Previous"; onClicked: settings.gpsOnInStartup = 2; }
                }
            }
        }
    }
}
