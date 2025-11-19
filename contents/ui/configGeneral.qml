import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts
import org.kde.kirigami 2.4 as Kirigami

Kirigami.Page {
    id: page

    property int cfg_refreshTime
    property int cfg_rotationTime
    property var cfg_serverList
    property string cfg_selectedServer
    property int cfg_refreshTimeDefault
    property int cfg_rotationTimeDefault
    property var cfg_serverListDefault
     property string cfg_selectedServerDefault

    function formatServerText(entry, html = true) {
        let [name, address] = entry.split(":").map(decodeURIComponent);

        if (html) {
            return `<b>${name}</b> (${address})`;
        } else {
            return `${name} (${address})`;
        }
    }

    function addRecord() {
        const newName = encodeURIComponent(serverName.text.trim());
        const newAddress = encodeURIComponent(serverAddress.text.trim());
        if (newName.length === 0 || newAddress.length === 0) return;

        const existingAddresses = (cfg_serverList || []).map(entry => entry.split(":")[1].toString());
        if (existingAddresses.includes(newAddress)) {
            serverName.text = "";
            serverAddress.text = "";
            return ;
        }

        cfg_serverList = (cfg_serverList || []).concat([`${newName}:${newAddress}`]);
        serverName.text = "";
        serverAddress.text = "";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Config")
            font.bold: true
        }

        RowLayout {
            QQC2.Label {
                text: i18n("Refresh Interval (seconds):")
            }

            QQC2.SpinBox {
                id: refreshTimeSpinBox
                from: 5
                to: 300
                stepSize: 1
                value: cfg_refreshTime / 1000
                onValueChanged: cfg_refreshTime = value * 1000
            }
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            RowLayout {
                QQC2.Label {
                    text: i18n("Rotation Interval (seconds):")
                }

                QQC2.SpinBox {
                    id: rotationTimeSpinBox
                    from: 0
                    to: 300
                    stepSize: 1
                    value: cfg_rotationTime / 1000
                    onValueChanged: cfg_rotationTime = value * 1000
                }
            }
            
            QQC2.Label {
                text: i18n("Note: set to 0 to disable server rotation.")
                font.pointSize: 8
                topInset: -4
            }
        }

        RowLayout {
            QQC2.Label {
                text: i18n("Selected Server:")
            }

            QQC2.ComboBox {
                id: selectedServerComboBox
                model: cfg_serverList.map(entry => {
                    return {value: entry.split(":")[1], text: formatServerText(entry, false)}
                })
                textRole: "text"
                valueRole: "value"
                currentValue: cfg_selectedServer
                onActivated: cfg_selectedServer = currentValue
                enabled: cfg_rotationTime < 1
            }
        }

        QQC2.Label {
            text: i18n("Minecraft Servers")
            font.bold: true
        }

        ListView {
            id: serverListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: cfg_serverList

            // Credit: https://github.com/aknari/plasma-newsticker
            delegate: QQC2.ItemDelegate {
                width: parent.width
                text: formatServerText(modelData);

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Kirigami.Units.largeSpacing

                    QQC2.Button {
                        icon.name: "go-up"
                        enabled: index > 0
                        onClicked: {
                            let temp = serverListView.model.slice();
                            const item = temp.splice(index, 1)[0];
                            temp.splice(index - 1, 0, item);
                            cfg_serverList = temp;
                        }
                    }

                    QQC2.Button {
                        icon.name: "go-down"
                        enabled: index < serverListView.count - 1
                        onClicked: {
                            let temp = serverListView.model.slice();
                            const item = temp.splice(index, 1)[0];
                            temp.splice(index + 1, 0, item);
                            cfg_serverList = temp;
                        }
                    }

                    QQC2.Button {
                        icon.name: "list-remove"
                        onClicked: {
                            let temp = serverListView.model.slice();
                            temp.splice(index, 1);
                            cfg_serverList = temp;
                        }
                    }

                }

            }

        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true

            QQC2.Label {
                text: "Server Name:"
            }

            QQC2.Label {
                text: "Server Address:"
            }

            Item {}

            QQC2.TextField {
                id: serverName

                Kirigami.FormData.label: i18n("Server Name:")
                placeholderText: i18n("My Minecraft Server")
                Layout.fillWidth: true
            }

            QQC2.TextField {
                id: serverAddress

                Kirigami.FormData.label: i18n("Server Address:")
                placeholderText: i18n("mc.example.com:25565")
                Layout.fillWidth: true
            }

            QQC2.Button {
                text: i18n("Add")
                enabled: serverName.text.length > 0 && serverAddress.text.length > 0
                onClicked: { addRecord() }
            }

        }

    }

}
