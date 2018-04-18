import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    width: applicationList.cellWidth
    height: applicationList.cellHeight

    property bool applicationStatus: status



    Pane {
        id: applicationDelegateItem
        z: ma.containsMouse ? 100 : 5        
        Material.elevation: ma.containsMouse ? 5 : 3        
        anchors {
            margins: 10
            fill: parent
        }
        property string lastProcess: main.lastProcess
        property bool error: main.errorOccured

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


        MouseArea {
            id: ma
            anchors.centerIn: parent
            hoverEnabled: true
            width: applicationDelegateItem.width
            height: applicationDelegateItem.height
            onClicked: {
                selectedApplication = name
                swipeView.currentIndex = 2
                screenshotUrls = []
                helper.getScreenShot(name)
                searchF = false
            }
            onPressed: {
                if(ma.containsMouse) {
                    applicationDelegateItem.Material.elevation = 0
                    dropShadow.opacity = 0.0
                }
            }
            onReleased: {
                if(ma.containsMouse) {
                    applicationDelegateItem.Material.elevation = 5
                } else {
                    applicationDelegateItem.Material.elevation = 3
                }

                dropShadow.opacity = 1.0
            }
        }

        onLastProcessChanged: {
            if(lastProcess.search(name) == 0) {
                var s = lastProcess.split(" ")
                if (s[1] === "true") {
                  applicationStatus = false
                } else {
                  applicationStatus = true
                }
                processButton.enabled = true
            }
        }


        onErrorChanged: {
            if(error) {
                processButton.enabled = true
            }
        }

        Image {
            id:appIcon
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                verticalCenterOffset: ma.containsMouse ? -27 : 0
            }
            width: 64
            height: 64
            smooth: true
            mipmap: true
            antialiasing: true
            source: "image://application/" + getCorrectName(name)

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }
        }

        DropShadow {
            id:dropShadow
            //opacity: ma.containsMouse ? 0.0 : 1.0
            anchors.fill: appIcon
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8
            samples: 17
            color: "#80000000"
            source: appIcon
        }

        Label {
            id: appNameLabel
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: ma.containsMouse ? -27 : 0
                right: parent.right
                left: appIcon.right
            }
            text: name.replace("-", " ")
            fontSizeMode: Text.HorizontalFit
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }
        }

        Button {
            id: processButton
            width: ma.containsMouse ? 210 : 80
            height: ma.containsMouse ? 50 : 40
            opacity: ma.containsMouse ? 1.0 : 0.0
            Material.background: applicationStatus ? Material.Red : Material.Green

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter

            }

            onEnabledChanged: {
                if(applicationDelegateItem.error && enabled) {
                    applicationDelegateItem.error = false
                }
            }

            onClicked: {
                processQueue.push(name + " " + applicationStatus)
                enabled = false
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }

            Label {
                id: processButtonLabel
                anchors.centerIn: parent
                //Material.foreground: "#000000"
                text: applicationStatus ? qsTr("remove") : qsTr("install")
            }
        }

        Image {
            id: installedIcon
            anchors {
                top: parent.top
                right: parent.right
            }
            mipmap: true
            smooth: true
            width: 15
            height: 15
            source: "qrc:/images/installed.svg"
            visible: applicationStatus
        }

        Label {
            id: nonFreeBadge
            anchors {
                top: appNameLabel.bottom
                topMargin: 5
                horizontalCenter: appNameLabel.horizontalCenter
            }
            Material.foreground: Material.Red
            //enabled: false
            text: nonfree ? "Non Free" : ""
            opacity: ma.containsMouse ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutExpo
                }
            }
        }


    }

}
