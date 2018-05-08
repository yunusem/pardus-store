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

    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 800
        }
    }
}
