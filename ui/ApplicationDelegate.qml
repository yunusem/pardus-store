import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Pane {
    id: applicationDelegateItem
    z: grown ? 5 : 0
    //Material.background: "#eeeeee"
    Material.elevation: 5
    width: grown ? gv.width - 10 : 220
    height: grown ? gv.height - 10 : 220

    property bool grown: false
    property int previousX
    property int previousY

    Behavior on width {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Behavior on height {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Behavior on x {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Behavior on y {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Pane {
        id:categoryBadge
        width: grown ? gv.width - 35 : 25
        height: grown ? gv.height / 5 : 25
        Material.background: color
        Material.elevation: 1
        anchors {
            top: parent.top
            right: parent.right

        }

        Behavior on width {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 350
            }
        }

        Behavior on height {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 350
            }
        }
    }

    MouseArea {
        id: ma2
        anchors.fill: parent
        onClicked: {

            applicationDelegateItem.grown = !applicationDelegateItem.grown
            applicationDelegateItem.Material.elevation = 5
            applicationDelegateItem.forceActiveFocus()
            applicationDelegateItem.focus = true

            if (applicationDelegateItem.grown) {
                applicationDelegateItem.previousX = applicationDelegateItem.x
                applicationDelegateItem.previousY = applicationDelegateItem.y
                applicationDelegateItem.x = 0
                applicationDelegateItem.y = 0
            } else {
                applicationDelegateItem.x = applicationDelegateItem.previousX
                applicationDelegateItem.y = applicationDelegateItem.previousY
            }

        }
        onPressed: {
            if(ma2.containsMouse) {
                applicationDelegateItem.Material.elevation = 0
            }
        }
        onReleased: {

            applicationDelegateItem.Material.elevation = 5
        }
    }

    Button {
        id: processButton
        width: 100
        height: 50
        Material.background: status ? Material.DeepOrange : Material.Green
        //Material.elevation: 1
        anchors {
            bottom: parent.bottom
            right: parent.right

        }

        Label {
            id: processButtonLabel
            anchors.centerIn: parent
            //Material.foreground: "#000000"
            text: status ? qsTr("remove") : qsTr("install")
        }
    }

    Row {
        spacing: 10
        anchors {
            verticalCenter: parent.verticalCenter

        }
        Image {
            width: grown ? 128 : 64
            height: grown ? 128 : 64
            smooth: true
            mipmap: true
            antialiasing: true
            source: "image://application/" + name
        }

        Column {


            Label {
                //Material.foreground: "#000000"
                text: name
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
            }

            Label {
                visible: grown
                //Material.foreground: "#000000"
                text: version
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
