import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: dialog
    property bool settingsOrdered: false
    property bool settingsButtonOn: false
    width: parent.width / 3 - 48
    modal: animate
    closePolicy: Popup.CloseOnPressOutside
    y: parent.height / 2 - height / 2
    x: parent.width / 2 - width / 2
    Material.background: Material.background
    Material.elevation: 2

    Column {
        anchors.fill: parent
        spacing: 12
        Label {
            id: popupOutputHeader
            text: popupHeaderText
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            Material.foreground: "#fafafa"

            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
        }

        Label {
            id: popupOutput
            text: popupText
            width: parent.width

            Material.foreground: "#fafafa"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter

        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            Button {
                id: setBtn
                visible: settingsButtonOn
                width: setBtnLabel.width + 24
                Material.background: "#3c3c3c"
                Material.foreground: "#fafafa"
                Label {
                    id: setBtnLabel
                    text: qsTr("settings")
                    anchors.centerIn: parent
                    font.capitalization: Font.Capitalize
                }

                onClicked: {
                    settings.visible = true
                    //settings.z = 200
                    settingsOrdered = true
                    dialog.close()
                }
            }

            Button {
                id: closeBtn

                Material.background: "#3c3c3c"
                Material.foreground: "#fafafa"

                Label {
                    text: qsTr("close")
                    anchors.centerIn: parent
                    font.capitalization: Font.Capitalize
                }

                onClicked: {
                    dialog.close()
                }
            }
        }
    }

    onClosed: {
        popupHeaderText = qsTr("Something went wrong!")
        popupText = ""
        if(splashScreen.visible && !settingsOrdered) {
            main.close()
        }

        if(helper.corrected) {
            main.close()
        }
    }
}
