import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Pane {
    Material.background: "#2c2c2c"
    Material.elevation: 3
    z: 92
    visible: category === qsTr("settings")
    height: swipeView.height - 12
    width: swipeView.width - 12
    anchors.centerIn: swipeView
    opacity: 0.0

    onVisibleChanged: {
        if(visible) {
            opacity = 1.0
            //backBtn.opacity = 1.0
        } else {
            opacity = 0.0
        }
    }

    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.horizontalCenter
            bottom: parent.bottom
        }

        Row {
            Label {
                text: qsTr("enable animations")
                font.capitalization: Font.Capitalize
                Material.foreground: "#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter

            }
            Switch {
                id: sw
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: {
                    animate = checked
                }

                Component.onCompleted: {
                    checked = animate
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 800
        }
    }
}
