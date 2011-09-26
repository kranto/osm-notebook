import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: root

    property alias titleText: titleLabel.text
    property alias text: textInput.text
    property alias placeHolderText: textInput.placeholderText

    content: Item {
        anchors.fill: parent

        Column {
            width: parent.width
            Label {
                id: titleLabel
            }

            TextField {
                id: textInput
                width: parent.width
            }
        }
    }
}
