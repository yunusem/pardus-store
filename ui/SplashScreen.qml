import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Pane {
    id: splash
    anchors.fill: parent
    z: 91
    opacity: 1.0    
    property alias label: splashLabel
    property alias timer: splashTimer
    property alias busy: splashBusy    

    Material.background: backgroundColor

    Timer {
        id: splashTimer
        interval: 800
        onTriggered: {
            splash.opacity = 0.0
        }
    }
    Behavior on opacity {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 1000
        }
    }
    onOpacityChanged: {
        if(opacity === 0.0) {
            splash.visible = false
        }
    }

    Image {
        id: topImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        source: "qrc:/images/icon.svg"
        opacity: 0.0
        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.InExpo
                duration: 200
            }
        }
        Component.onCompleted: {
            opacity = 1.0
        }
        onOpacityChanged: {
            if(opacity === 1.0) {
                appNameLabel.opacity = 1.0
            }
        }
    }

    Label {
        id: appNameLabel
        text: main.title
        smooth: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        Material.foreground: accentColor
        font.pointSize: 42
        font.capitalization: Font.Capitalize
        font.family: pardusFont.name

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: 12

        opacity: 0.0
        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.InExpo
                duration: 200
            }
        }
    }

    Label {
        id: splashLabel
        font.pointSize: 12
        anchors{
            top: appNameLabel.bottom
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        Material.foreground: textColor
    }

    BusyIndicator {
        id: splashBusy
        height: splashLabel.height + 14
        width: height
        anchors.verticalCenter: splashLabel.verticalCenter
        anchors.left: splashLabel.right
        anchors.leftMargin: 20
        running: true
        Material.accent: accentColor
    }

    Component.onCompleted: {
        if(updateCache) {
            splashLabel.text = qsTr("Updating package manager cache.")
            helper.updateCache()
        } else {
            updateCacheFinished()
        }
    }
}
