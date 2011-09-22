import QtQuick 1.0
import com.meego 1.0
import "storage.js" as Storage

Page {
    id: trackListPage
    tools: commonTools

    onStatusChanged: {
        if (status == PageStatus.Activating)
            listView.updateList();
    }

    ListView {
        id: listView
        anchors.fill: parent;

        function updateList() {
            model = Storage.getTracks();
        }

        delegate: Rectangle {
            height: 50
            width: parent.width

            Label {
                text: listView.model[index].id
            }

            MouseArea {
                anchors.fill: parent
            }
        }
    }

}
