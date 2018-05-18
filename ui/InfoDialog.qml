import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: dialog
    width: parent.width / 3 - 48
    height: popupOutputHeader.height + popupOutput.height + 36
    modal: true
    closePolicy: Popup.CloseOnPressOutside
    y: parent.height / 2 - height / 2
    x: parent.width / 2 - width / 2
    Material.background: "#2c2c2c"
    Material.elevation: 2

    Label {
        id: popupOutputHeader
        text: popupHeaderText
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        Material.foreground: "#fafafa"

        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
    }

    Item {
        id: popupOutputContainer
        width: parent.width
        //clip: true
        anchors {
            top: popupOutputHeader.bottom
            topMargin: 12
            bottom: parent.bottom
            bottomMargin: 12
        }
        Label {
            id: popupOutput
            text: popupText
            width: parent.width
            anchors {
                verticalCenter: parent.verticalCenter
            }
            Material.foreground: "#fafafa"
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.HorizontalFit
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: doneBtn
        anchors.fill: parent
        onClicked: {
            dialog.close()
        }
    }

    onClosed: {
        popupHeaderText = qsTr("Something went wrong!")
        popupText = ""
        if(splashScreen.visible) {
            Qt.quit()
        }
    }
}
