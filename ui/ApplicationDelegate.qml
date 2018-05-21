import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    width: applicationList.cellWidth
    height: applicationList.cellHeight

    property bool applicationStatus: installed
    property bool applicationInQueue: inqueue

    onApplicationInQueueChanged: {
        if(app.name === name) {
            app.hasProcessing = inqueue
            processButton.enabled = !inqueue
        }
    }

    onApplicationStatusChanged: {
        if(name === app.name) {
            app.installed = installed
        }
    }

    function updateInQueue(appName) {
        if(appName !== "") {
            if(appName === name) {
                inqueue = true                
            }
        }
    }

    function operateRemoval(appName, from) {
        if(appName !== "" && appName === name && from === "delegate") {            
            processButton.enabled = false
            inqueue = true
            processQueue.push(name + " " + installed)
            updateQueue()
        }
    }

    Component.onCompleted: {
        updateStatusOfAppFromDetail.connect(updateInQueue)
        confirmationRemoval.connect(operateRemoval)
        app.name = ""
    }

    Pane {
        id: applicationDelegateItem
        z: delegateMouseArea.containsMouse ? 100 : 5
        Material.elevation: delegateMouseArea.containsMouse ? 5 : 3
        anchors {
            margins: 10
            fill: parent
        }

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
            id: delegateMouseArea
            anchors.centerIn: parent
            hoverEnabled: true
            width: applicationDelegateItem.width
            height: applicationDelegateItem.height
            onClicked: {
                app.name = name
                app.version = version
                app.installed = installed
                app.hasProcessing = inqueue
                app.category = category
                app.free = !nonfree
                app.description = description

                swipeView.currentIndex = 2
                screenshotUrls = []
                helper.getAppDetails(name)
            }
            onPressed: {
                if(delegateMouseArea.containsMouse) {
                    applicationDelegateItem.Material.elevation = 0
                    dropShadow.opacity = 0.0
                }
            }
            onReleased: {
                if(delegateMouseArea.containsMouse) {
                    applicationDelegateItem.Material.elevation = 5
                } else {
                    applicationDelegateItem.Material.elevation = 3
                }

                dropShadow.opacity = 1.0
            }
        }

        Image {
            id:appIcon
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                verticalCenterOffset: delegateMouseArea.containsMouse ? -27 : 0
            }
            height: (parent.height * 2 / 3 <= sourceSize.height * 3 / 2) ? parent.height * 2 / 3 : sourceSize.height * 3 / 2
            width: height
            fillMode: Image.PreserveAspectFit
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
                verticalCenterOffset: delegateMouseArea.containsMouse ? -27 : 0
                right: parent.right
                left: appIcon.right
                leftMargin: 6
            }
            text: getPrettyName(name)
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
            width: delegateMouseArea.containsMouse ? parent.width : parent.width / 3
            height: delegateMouseArea.containsMouse ? processButtonLabel.height + 24 : 24
            opacity: delegateMouseArea.containsMouse ? 1.0 : 0.0
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            Material.background: installed ? Material.Red : Material.Green
            Material.foreground: "#fafafa"

            enabled: !inqueue

            property bool error: main.errorOccured
            property string lastProcess: main.lastProcess
            onErrorChanged: {
                if(error) {
                    enabled = true
                }
            }

            onLastProcessChanged: {
                if(lastProcess.search(name) == 0) {
                    var s = lastProcess.split(" ")
                    if (s[1] === "true") {
                        installed = false
                    } else {
                        installed = true
                    }
                    enabled = true
                    inqueue = false
                    if(app.name === name) {
                        app.hasProcessing = inqueue
                        app.installed = installed
                    }
                }
            }

            onEnabledChanged: {
                if(error && enabled) {
                    error = false
                }
            }

            onClicked: {
                if (installed) {
                    confirmationDialog.name = name
                    confirmationDialog.from = "delegate"
                    confirmationDialog.open()
                } else {
                    name = name
                    processButton.enabled = false
                    inqueue = true
                    processQueue.push(name + " " + installed)
                    updateQueue()
                }
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
                text: installed ? qsTr("remove") : qsTr("install")
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
            visible: installed
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
            opacity: delegateMouseArea.containsMouse ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutExpo
                }
            }
        }

    }


}
