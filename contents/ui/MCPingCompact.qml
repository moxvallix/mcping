import QtNetwork as Network
import QtQuick 2.0
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    property string labelText
    signal scroll(int direction)

    Layout.leftMargin: Kirigami.Units.largeSpacing
    Layout.rightMargin: Kirigami.Units.largeSpacing

    PlasmaComponents.Label {
        id: mainLabelItem
        text: labelText
    }
}