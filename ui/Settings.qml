import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Pane {
    property string previous
    property string current
    Material.background: "#2c2c2c"
    Material.elevation: 3
    z: 92
    visible: category === qsTr("settings")
    height: stackView.height - 12
    width: stackView.width - 12
    anchors.centerIn: stackView
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
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 800
        }
    }
}
