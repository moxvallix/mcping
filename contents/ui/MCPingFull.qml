import QtNetwork as Network
import QtQuick 2.0
import QtQuick.Layouts
import QtWebView
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaExtras.Representation {
    WebView {
        id: "mainWebView"

        anchors.fill: parent
        Component.onCompleted: {
            mainWebView.loadHtml('<img src="images/pack.png"></img>', Qt.resolvedUrl("../assets/"));
        }
    }

    Connections {
        function onExpandedChanged() {
            if (plasmoidRoot.expanded) {
                mainWebView.reload();
            }
        }

        target: plasmoidRoot
    }

}
