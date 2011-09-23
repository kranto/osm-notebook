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
	    var loaded = new Array();
	    for (var i = 0; i < listView.model.length; i++) {
		if (listView.model[i].loaded) {
		    loaded.push(listView.model[i].id)
		}
	    }

    	    mainPage.loadTracks(loaded);
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
	    var loaded = mainPage.loadedTracks;
	    var allTracks = Storage.getTracks();
	    for (var i = 0; i < allTracks.length; i++) {
		allTracks[i].loaded = false;
		for (var j = 0; j < loaded.length; j++) {
		    if (loaded[j] == allTracks[i].id)
			allTracks[i].loaded = true;
		}
	    }
	    listView.model = allTracks;
        }

        delegate: Rectangle {
	    height: 80
            width: parent.width
	    color: listView.model[index].loaded? "lightblue": "white";

            Label {
                text: listView.model[index].id
            }

            MouseArea {
                anchors.fill: parent
		onClicked: {
		    var newModel = listView.model;
		    newModel[index].loaded = !newModel[index].loaded;
		    listView.model = newModel;
		}
            }
        }
    }

}
