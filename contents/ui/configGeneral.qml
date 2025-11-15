import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts
import org.kde.kirigami 2.4 as Kirigami

Kirigami.Page {
    id: page

    property int cfg_refreshTime
    property var cfg_serverList
    property int cfg_refreshTimeDefault
    property var cfg_serverListDefault

    function formatServerText(entry) {
        let [name, address] = entry.split(":").map(decodeURIComponent);

        return `<b>${name}</b> (${address})`;
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
                value: cfg_refreshTime
                onValueChanged: cfg_refreshTime = value
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
                onClicked: {
                    const newName = encodeURIComponent(serverName.text.trim());
                    const newAddress = encodeURIComponent(serverAddress.text.trim());
                    if (newName.length === 0 || newAddress.length === 0) return;

                    const existingAddresses = (cfg_serverList || []).map(entry => entry.split(":")[1].toString());
                    if (existingAddresses.includes(newAddress)) {
                        newName.text = "";
                        newAddress.text = "";
                        return ;
                    }

                    cfg_serverList = (cfg_serverList || []).concat([`${newName}:${newAddress}`]);
                    newName.text = "";
                    newAddress.text = "";
                }
            }

        }

    }

}
