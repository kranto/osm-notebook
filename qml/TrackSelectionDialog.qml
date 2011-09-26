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

    function trackName(track) {
        var date = new Date();
        date.setTime(track.date);
        var name = date.toLocaleDateString();
        name += " - ";
        if (track.name != "")
            name += track.name;
        else
            name += "<no name>";

        return name;
    }

    // tricks needed to overcome a bug in the list model
    // a dummy item is added and then removed
    onTrackListChanged: {
        var l = trackList
        model.clear();
        model.append({"name": ""});
        var selected = new Array();
        for (var i in l) {
            model.insert(i, {"name": trackName(l[i])});
            if (l[i].selected)
                selected.push(i);
        }
        model.remove(l.length);
        selectedIndexes = selected;
    }

    onAccepted: {
        var trackIds = new Array(selectedIndexes.length);
        for (var i in selectedIndexes) {
            trackIds[i] = trackList[selectedIndexes[i]].id;
        }
        tracksSelected(trackIds);
    }

}
