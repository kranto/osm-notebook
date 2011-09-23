import QtQuick 1.0
import com.meego 1.0
import "storage.js" as Storage

Page {
    id: trackListPage
    tools: commonTools

    onStatusChanged: {
        if (status == PageStatus.Activating)
            listView.updateList();
	if (status == PageStatus.Deactivating) {
            var selected = new Array();
	    for (var i = 0; i < listView.model.length; i++) {
                if (listView.model[i].selected) {
                    selected.push(listView.model[i].id)
		}
	    }
            mainPage.showTracks(selected);
	}
    }

    Label {
	id: titleLabel
	text: "Select Tracks"
	font.pixelSize: 30
    }

    ListView {
        id: listView
	anchors.top: titleLabel.bottom
	anchors.topMargin: 30
	anchors.bottom: parent.bottom
	width: parent.width
	anchors.horizontalCenter: parent.horizontalCenter

        function updateList() {
            model = mainPage.trackPolylines;
        }

        delegate: Rectangle {
	    height: 80
            width: parent.width
            color: listView.model[index].selected? "lightblue": "white";

            Label {
                text: listView.model[index].id
            }

            MouseArea {
                anchors.fill: parent
		onClicked: {
		    var newModel = listView.model;
                    newModel[index].selected = !newModel[index].selected;
		    listView.model = newModel;
		}
            }
        }
    }

}
