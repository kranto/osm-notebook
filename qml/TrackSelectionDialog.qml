import QtQuick 1.0
import com.meego 1.0
import "storage.js" as Storage

MultiSelectionDialog {
    id: trackSelectionDialog
    titleText: "Select Tracks"
    acceptButtonText: "OK"
    model: ListModel { }

    property variant trackList: [ ]

    signal tracksSelected(variant trackIds)

    onStatusChanged: {
        // tricks needed to overcome a bug in the list model
        // a dummy item is added and then removed
        if (status == PageStatus.Activating) {
            var l = trackList
            model.clear();
            model.append({"name": ""});
            var selected = new Array();
            for (var i in l) {
                model.insert(i, {"name": "Track "+l[i].id});
                if (l[i].selected)
                    selected.push(i);
            }
            model.remove(l.length);
        }

    }

    onAccepted: {
        var trackIds = new Array(selectedIndexes.length);
        for (var i in selectedIndexes) {
            trackIds[i] = trackList[selectedIndexes[i]].id;
        }
        tracksSelected(trackIds);
    }

}
