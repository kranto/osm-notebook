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
    }
}
