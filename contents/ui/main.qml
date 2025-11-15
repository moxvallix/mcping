import "../src/data.mjs" as Data
import QtNetwork as Network
import QtQuick 2.0
import QtWebView
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: plasmoidRoot

    Component.onCompleted: {
        Data.onLoad(plasmoid);
    }

    Text {
        id: mainLabel

        text: ""
    }
}
