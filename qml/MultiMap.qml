import QtQuick 1.1
import QtMobility.location 1.2

Item {
    id: multiMap

    property alias maps: mapArea.children
    property list<Item> mapObjects
    property Map activeMap

    property Coordinate center
    property real zoomLevel: 15

    signal viewportChanges

    function toCoordinate(p) {
        var x = (p.x - width/2) / activeMap.scale + width/2
        var y = (p.y - height/2) / activeMap.scale + height/2
        return activeMap.toCoordinate(Qt.point(x,y));
    }

    function toScreenPosition(c) {
        if (activeMap == undefined)
            return Qt.point(-1,-1);
        var p = activeMap.toScreenPosition(c);
        var x = (p.x - width/2) * activeMap.scale + width/2;
        var y = (p.y - height/2) * activeMap.scale + height/2;
        return Qt.point(x, y);
    }

    onCenterChanged: {
        if (activeMap)
            activeMap.center = center;
        viewportChanges();
    }

    onZoomLevelChanged: {
        activeMap.zoomLevel = Math.min(activeMap.maximumZoomLevel, Math.floor(multiMap.zoomLevel));
        activeMap.scale = Math.pow(2, multiMap.zoomLevel - activeMap.zoomLevel);
        activeMap.transformOrigin = Item.Bottom;
        activeMap.transformOrigin = Item.Center;
        viewportChanges();
    }

    onWidthChanged: { activeMap.width = width; activeMap.size.width = width; activeMap.transformOrigin = Item.Bottom; activeMap.transformOrigin = Item.Center; viewportChanges(); }
    onHeightChanged: { activeMap.height = height; activeMap.size.height = height; activeMap.transformOrigin = Item.Bottom; activeMap.transformOrigin = Item.Center; viewportChanges(); }
    onXChanged: {activeMap.x = x; }
    onYChanged: {activeMap.y = y; }

    onActiveMapChanged: {
        activeMap.visible = true;
        activeMap.x = parent.x
        activeMap.y = parent.y
        activeMap.width = parent.width
        activeMap.height = parent.height
        activeMap.size.width = activeMap.width
        activeMap.size.height = activeMap.size.height
        activeMap.center = multiMap.center
        activeMap.zoomLevel = Math.min(activeMap.maximumZoomLevel, Math.floor(multiMap.zoomLevel));
        activeMap.scale = Math.pow(2, multiMap.zoomLevel - activeMap.zoomLevel);
        activeMap.transformOrigin = Item.Bottom;
        activeMap.transformOrigin = Item.Center;

        for (var i = 0;  i < maps.length; i++) {
            for (var j = 0; j < mapObjects.length; j++) {
                maps[i].removeMapObject(mapObjects[j]);
            }
            if (maps[i] != activeMap)
                maps[i].visible = false;
        }
        for (var j = 0; j < mapObjects.length; j++) {
            activeMap.addMapObject(mapObjects[j]);
        }
    }

    Item {
        id: mapArea
        anchors.fill: parent
    }
}
