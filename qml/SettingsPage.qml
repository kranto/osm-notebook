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

        Column {
            id: settingsColumn
            anchors.top: parent.top
            anchors.topMargin: 10
            width: parent.width
            spacing: 30

            Label {
                id: titleLabel; text: "Settings"; font.pixelSize: 32; font.bold: true;
            }

            Column {
                spacing: 5
                Label { text: "Full Screen"; font.pixelSize: 28; }
                ButtonRow {
                    checkedButton: settings.fullScreen? b02:  b01
                    Button { id: b01; text: "Off"; onClicked: settings.fullScreen = false; }
                    Button { id: b02; text: "On"; onClicked: settings.fullScreen = true; }
                }
            }

            Column {
                spacing: 5
		Label { text: "Orientation"; font.pixelSize: 28; }
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
            Column {
                width: parent.width
                spacing: 5
                Row {
                    spacing: 10
                    Label { id: zoomFactorLabel; text: "Zoom Factor"; font.pixelSize: 28; }
                    Label { anchors.baseline: zoomFactorLabel.baseline; text: Math.round(settings.zoomFactor * 100) + " %"; font.pixelSize: 20; }
                }
                Slider {
                    width: parent.width;
                    minimumValue: 1; maximumValue: 2.5; value: settings.zoomFactor;
                    stepSize: 0.1
                    valueIndicatorVisible: true;
                    valueIndicatorText: Math.round(100 * value) + " %"
                    onPressedChanged: if (!pressed) settings.zoomFactor = Math.round(value*100)/100;
                }
            }

            Column {
                spacing: 5
                Label { text: "Show Debug Values"; font.pixelSize: 28; }
                ButtonRow {
                    checkedButton: settings.showDebug? b32:  b31
                    Button { id: b31; text: "Off"; onClicked: settings.showDebug = false; }
                    Button { id: b32; text: "On"; onClicked: settings.showDebug = true; }
                }
            }

            Item {}
        }
    }
}
