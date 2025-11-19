import "../src/data.mjs" as Data
import QtNetwork as Network
import QtQuick 2.0
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: plasmoidRoot

    property var serverData: {}
    property string mainLabel: ""
    property bool wasExpanded

    function updateServerData(data) {
        serverData = data;
        updateMainLabel();
    }

    function getSelectedServer() {
        const serverAddress = decodeURIComponent(plasmoid.configuration.selectedServer);

        if (!serverData) {
            return;
        }

        return serverData[serverAddress] || Object.values(serverData)[0];
    }

    function updateMainLabel() {
        const server = getSelectedServer();

        if (server) {
            mainLabel = server.summaryText();
            plasmoidRoot.toolTipSubText = server.playerInfo();
        } else {
            mainLabel = "No Server Configured";
            plasmoidRoot.toolTipSubText = Plasmoid.metaData.description;
        }
    }

    function rotateCurrentServer(direction) {
        if (!serverData) return;

        if (direction > 1) direction = 1;
        if (direction < -1) direction = -1;
        
        const currentData = getSelectedServer();

        const dataKeys = Object.keys(serverData);
        const dataValues = Object.values(serverData);

        const idx = dataValues.indexOf(currentData);
        if (idx < 0) return;

        const newIdx = idx + direction;
        if (newIdx > dataValues.length - 1) {
            plasmoid.configuration.selectedServer = encodeURIComponent(dataKeys[0]);
        } else if (newIdx < 0) {
            plasmoid.configuration.selectedServer = encodeURIComponent(dataKeys[(dataKeys.length - 1)]);
        } else {
            plasmoid.configuration.selectedServer = encodeURIComponent(dataKeys[newIdx]);
        }

        updateMainLabel();
    }

    Component.onCompleted: {
        const path = Qt.resolvedUrl("..").toString().replace("file://", "");
        Data.onLoad(plasmoid, plasmoidRoot, path);
        updateMainLabel();

        Data.BRIDGE.serverListUpdate.connect(data => {
            updateServerData(data);
            refreshTimer.restart();
        })
    }

    Connections {
        target: plasmoid.configuration
        function onValueChanged() {
            Data.onRefresh();
        }
    }

    activationTogglesExpanded: true
    compactRepresentation: compactComponent
    fullRepresentation: compactComponent
    // fullRepresentation: fullComponent

    // switchWidth: 400
    // switchHeight: 300

    Component {
        id: compactComponent

        MCPingCompact {
            labelText: mainLabel

            onScroll: direction => {
                rotateCurrentServer(direction);
                rotationTimer.restart();
            }
        }
    }

    Component {
        id: fullComponent

        MCPingFull {}
    }

    Timer {
        id: refreshTimer

        repeat: true
        interval: plasmoid.configuration.refreshTime
        running: true
        onTriggered: Data.onRefresh()
    }

    Timer {
        id:  rotationTimer

        repeat: true
        interval: plasmoid.configuration.rotationTime > 0 ? plasmoid.configuration.rotationTime : 5
        running: true
        onTriggered: {
            if (plasmoid.configuration.rotationTime < 1) return;
            if (Object.keys(Data.SERVER_INFO_DATA).length < 2) return;

            rotateCurrentServer(1);
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            const delta = (wheel.inverted ? 1 : -1) * (wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x);

            rotateCurrentServer(delta);
            rotationTimer.restart();
        }
        // onPressed: wasExpanded = plasmoidRoot.expanded
        // onClicked: plasmoidRoot.expanded = !wasExpanded

    }
}
