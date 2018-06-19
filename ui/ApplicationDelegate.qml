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
            margins: 6
            fill: parent
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
                app.downloadSize = dsize
                app.installed = installed
                app.hasProcessing = inqueue
                app.category = category
                app.free = !nonfree
                app.description = description

                stackView.push(applicationDetail,
                               {objectName: "detail",
                                   "current": name,
                                   "previous": category})
                screenshotUrls = []
                helper.getAppDetails(name)
                //isSearching = false
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
                enabled: animate
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
                enabled: animate
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on width {
                enabled: animate
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on height {
                enabled: animate
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
            width: 16
            height: 16
            source: "qrc:/images/installed.svg"
            visible: installed
        }

        Label {
            id: downloadSize
            anchors {
                top: parent.top
                right: parent.right
                left: appIcon.right
                leftMargin: 3
                bottom: appNameLabel.top
                bottomMargin: downloadSize.font.pointSize / 2
            }

            Material.foreground: Material.Blue
            text: installed ? "" : (qsTr("Download size")+ "\n" + dsize)
            fontSizeMode: Text.VerticalFit
            font.pointSize: applicationList.cellWidth / 23
            font.capitalization: Font.Capitalize
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            //wrapMode: Text.WordWrap
            opacity: delegateMouseArea.containsMouse ? 1.0 : 0.0

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutExpo
                }
            }

        }

        Label {
            id: appNameLabel
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: delegateMouseArea.containsMouse ? - (appNameLabel.font.pointSize * 3 / 2) : 0
                right: parent.right
                left: appIcon.right
                leftMargin: 3
            }
            text: getPrettyName(name)
            font.pointSize: applicationList.cellWidth / 23
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize

            Behavior on anchors.verticalCenterOffset {
                enabled: animate
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutExpo
                }
            }
        }

        Label {
            id: nonFreeBadge
            property int offSetAdjuster: applicationList.cellWidth < 250 ? 2 : 0
            anchors {
                top: appNameLabel.bottom
                topMargin: nonFreeBadge.font.pointSize / 2 - nonFreeBadge.offSetAdjuster
                horizontalCenter: appNameLabel.horizontalCenter
            }
            font.pointSize: applicationList.cellWidth / 23
            Material.foreground: Material.Red
            text: nonfree ? "Non Free" : ""
            opacity: delegateMouseArea.containsMouse ? 1.0 : 0.0

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutExpo
                }
            }
        }
    }
}
