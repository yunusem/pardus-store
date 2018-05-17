import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: dialog
    modal: true
    width: 300
    height: buttonContainer.height + imageContainer.height + 48
    closePolicy: Popup.NoAutoClose
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    Material.elevation: 2
    Material.background: "#2c2c2c"
    signal accepted
    signal rejected
    property alias content: contentLabel.text
    property string name: ""
    property string from: ""

    Label {
        id: contentLabel
        anchors {
            top: parent.top
            bottom: imageContainer.top
            bottomMargin: 12
        }
        Material.foreground: "#fafafa"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        width: parent.width

    }

    Row {

        id: imageContainer
        spacing: 12
            anchors { horizontalCenter: parent.horizontalCenter
            bottom: buttonContainer.top
            bottomMargin: 12
        }

        Image {
            id: icon
            width: 32
            height: 32
            smooth: true
            mipmap: true
            antialiasing: true
            source: dialog.name === "" ? "" : "image://application/" + getCorrectName(dialog.name)
        }

        Label {
            id: iconLabel
            Material.foreground: "#fafafa"
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.capitalization: Font.Capitalize
            text: getCorrectName(dialog.name)
        }
    }

    Row {
        id: buttonContainer
        spacing: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Button {
            id: acceptButton
            text: qsTr("yes")
            Material.background: "#3c3c3c"
            Material.foreground: "#fafafa"
            onClicked: dialog.accepted()
        }
        Button {
            id: rejectButton
            text: qsTr("no")
            Material.background: "#3c3c3c"
            Material.foreground: "#fafafa"
            onClicked: dialog.rejected()
        }
    }

    onAccepted: {
        confirmationRemoval(name, from)
        dialog.close()
    }
    onRejected: {
        dialog.close()
    }

    onClosed: {
        name = ""
        from = ""
    }

    Component.onCompleted: {
        content = qsTr("Are you sure you want to remove this application ?")
        dialog.height += contentLabel.height + 36
    }
}
