import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Item {
    width: gridView.cellWidth
    height: gridView.cellHeight

    property bool applicationInstalled: installed
    property bool applicationInqueue: inqueue
    property string applicationDelegatestate: delegatestate
    property int animationDuration: 330
    property bool detailTextHovered: false
    property string condition: processingCondition
    property int percent: processingPercent
    property bool processing: isThereOnGoingProcess

    signal triggered

    onPercentChanged: {
        if(processingPackageName === name) {
            processBarItem.value = percent
        }
    }

    onTriggered: {
        inqueue = true
        processQueue.push(name + " " + installed)
        if((processingPackageName !== name) && isThereOnGoingProcess) {
            delegatestate = "inqueue"
            stopButton.visible = true
            stopButton.enabled = true
        }
    }

    onProcessingChanged: {
        if(processing) {
            if(processingPackageName === name) {
                delegatestate = "process"
            } else {
                if(inqueue) {
                    delegatestate = "inqueue"
                    stopButton.visible = true
                    stopButton.enabled = true
                }
            }
        }
    }


    onApplicationInqueueChanged: {
        if(name === selectedAppName) {
            selectedAppInqueue = applicationInqueue
        }
    }

    onApplicationInstalledChanged: {
        if(name === selectedAppName) {
            selectedAppInqueue = applicationInstalled
        }
    }

    onApplicationDelegatestateChanged: {
        if(name === selectedAppName) {
            selectedAppDelegatestate = applicationDelegatestate
        }
    }

    onConditionChanged: {
        if(processingPackageName === name) {
            if(condition === qsTr("removing")) {
                processBarItem.colorCircle = "#F44336" //Red
                stopButton.enabled = false
                stopButton.visible = false
            } else if(condition === qsTr("installing")) {
                processBarItem.colorCircle = "#4CAF50" //Green
                stopButton.enabled = false
                stopButton.visible = true

            } else if(condition === qsTr("downloading")) {
                processBarItem.colorCircle = "#03A9F4" //Blue
                stopButton.enabled = true
                stopButton.visible = true
            }
        }
    }

    function updateInQueue(appName) {
        if(appName !== "" && appName === name) {
            inqueue = true
            if((processingPackageName !== name) && isThereOnGoingProcess) {
                delegatestate = "inqueue"
                stopButton.visible = true
                stopButton.enabled = true
            }
        }
    }

    function operateRemoval(appName, from) {
        if(appName !== "" && appName === name && from === "delegate") {
            triggered()
        }
    }

    function errorHappened() {
        inqueue = false
        delegatestate = installed ? "installed" : "get"
    }

    Component.onCompleted: {
        updateStatusOfAppFromDetail.connect(updateInQueue)
        confirmationRemoval.connect(operateRemoval)
        errorOccured.connect(errorHappened)
    }


    Pane {
        id: applicationDelegateItem
        z: delegateMa.containsMouse ? 100 : 5
        Material.elevation: delegateMa.containsMouse ? 5 : 3
        anchors {
            margins: 8
            fill: parent
        }

        MouseArea {
            id: delegateMa
            width: parent.width + 24
            height: parent.height + 24
            anchors.centerIn: parent
            hoverEnabled: true
            cursorShape: detailTextHovered ? Qt.PointingHandCursor : Qt.ArrowCursor
            onPositionChanged: {
                var pos = detailsLabel.mapToItem(delegateMa,0,0)
                var horLine = pos.x + detailsLabel.width
                var verLine = pos.y + detailsLabel.height
                if(pos.x <= mouse.x &&
                        mouse.x <= horLine &&
                        pos.y <= mouse.y &&
                        mouse.y <= verLine) {
                    detailTextHovered = true
                } else {
                    detailTextHovered = false

                }
            }

            onClicked: {
                forceActiveFocus()

                selectedAppName = name
                selectedAppInstalled = installed
                selectedAppInqueue = inqueue
                selectedAppDelegatestate = delegatestate

                stackView.push(applicationDetail, {
                                   objectName: "detail",
                                   "current": name,
                                   "previous": categoryIcons[categories.indexOf(selectedCategory)],
                                   "appVersion":version,
                                   "appDownloadSize" : dsize,
                                   "appCategory" : category,
                                   "appNonfree" : nonfree})                                
            }
            onPressed: {
                if(delegateMa.containsMouse) {
                    applicationDelegateItem.Material.elevation = 0
                }
            }
            onReleased: {
                if(delegateMa.containsMouse) {
                    applicationDelegateItem.Material.elevation = 5
                } else {
                    applicationDelegateItem.Material.elevation = 3
                }
            }
        }

        Rectangle {
            id: mfButton
            width: 72
            height: width
            color: "transparent"
            state: delegatestate
            anchors {
                top: parent.top
                right: parent.right
            }

            MouseArea {
                id: mfbMa
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }

                width: parent.width + 12
                height: parent.height + 12
                hoverEnabled: true
                //enabled: false
                //propagateComposedEvents: true
                //acceptedButtons: Qt.NoButton
            }

            Timer {
                id: stateTimer
                interval: 3000
                onTriggered: {
                    delegatestate = installed ? "installed": "get"
                }
            }

            Button {
                id: actionButton
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -6
                }

                width: textLabel.width + 12
                height: parent.height / 3 + 18
                opacity: 0.0
                visible: opacity > 0.0
                Behavior on opacity {
                    enabled: animate
                    NumberAnimation { duration: animationDuration }
                }
                Behavior on width {
                    enabled: animate
                    NumberAnimation { duration: animationDuration / 2 }
                }
                Material.background: "#4CAF50"
                hoverEnabled: true

                property string lastprocessed: lastProcess

                onLastprocessedChanged: {
                    if(lastProcess.search(name) == 0) {
                        var s = lastProcess.split(" ")
                        if (s[1] === "true") {
                            installed = false
                        } else {
                            installed = true
                        }
                        inqueue = false
                        if(selectedAppName === name) {
                            selectedAppInqueue = inqueue
                            selectedAppInstalled = installed
                        }
                    }
                }

                onClicked: {
                    forceActiveFocus()
                    stateTimer.stop()
                    if(delegatestate == "get") {
                        delegatestate = "check"
                        stateTimer.start()
                    } else if(delegatestate == "check") {
                        triggered()
                    } else if (delegatestate == "installed") {
                        confirmationDialog.name = name
                        confirmationDialog.from = "delegate"
                        confirmationDialog.open()
                    }
                }

                Label {
                    id: textLabel
                    //font.weight: Font.DemiBold
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    Material.foreground: "#FAFAFA"
                    opacity: parent.opacity
                    visible: opacity > 0.0

                    Behavior on text {
                        enabled: animate
                        FadeAnimation {
                            duration: animationDuration
                            target: textLabel
                        }
                    }

                    font.pointSize: 10
                }

            }

            BusyIndicator {
                id: busyItem
                width: parent.width
                height: width
                anchors.centerIn: parent
                padding: 4
                smooth: true
                Material.accent: "#FFCB08"
                opacity: 0.0
                running: opacity > 0.0
                visible: opacity > 0.0 ? true : false
                Behavior on opacity {
                    enabled: animate
                    NumberAnimation { duration: animationDuration * 2 }
                }
            }

            ProgressBarCircle {
                id: processBarItem
                width: parent.width + 12
                height: width
                anchors.centerIn: parent
                colorBackground: "#111111"
                colorCircle: "#4CAF50"
                thickness: 5
                opacity: 0.0
                visible: opacity > 0.0
                onOpacityChanged: {
                    if(opacity === 0.0) {
                        value = 0
                    }
                }

                Behavior on opacity {
                    enabled: animate
                    NumberAnimation { duration: animationDuration * 2 }
                }
            }

            Button {
                id: stopButton
                anchors.centerIn: parent
                width: (parent.width - 12) / 3
                height: width + 12
                opacity: 0.0
                visible: opacity > 0.0
                Behavior on opacity {
                    enabled: animate
                    NumberAnimation { easing.type: Easing.InExpo; duration: animationDuration / 2 }
                }
                property string disqueuedApplication: ""
                onClicked: {
                    forceActiveFocus()
                    if(delegatestate === "inqueue") {
                        var i = processQueue.indexOf(name)
                        disqueuedApplication = processQueue.splice(i, 1).toString()
                        inqueue = false
                        delegatestate = installed ? "installed" : "get"
                    } else if (delegatestate === "process") {
                        if(condition === qsTr("downloading")) {
                            terminateProcessCalled = true
                            if(helper.terminate()) {
                                inqueue = false
                                installed = false
                            } else {
                                terminateProcessCalled = false
                                enabled = false
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "get"
                    PropertyChanges {
                        target: textLabel
                        text: qsTr("GET")
                    }

                    PropertyChanges {
                        target: actionButton
                        opacity: 1.0
                    }

                },

                State {
                    name: "check"
                    PropertyChanges {
                        target: textLabel
                        text: qsTr("INSTALL")

                    }
                    PropertyChanges {
                        target: actionButton
                        opacity: 1.0
                    }

                },

                State {
                    name: "inqueue"
                    PropertyChanges {
                        target: stopButton
                        opacity: 1.0
                    }
                    PropertyChanges {
                        target: busyItem
                        opacity:1.0
                    }
                },

                State {
                    name: "process"
                    PropertyChanges {
                        target: stopButton
                        opacity: 1.0
                    }
                    PropertyChanges {
                        target: processBarItem
                        opacity:1.0
                    }
                },

                State {
                    name: "installed"
                    PropertyChanges {
                        target: textLabel
                        text: qsTr("REMOVE")
                    }
                    PropertyChanges {
                        target: actionButton
                        opacity: 1.0
                        Material.background: "#F44336"
                    }
                }
            ]
        }

        Rectangle {
            id: openBtnContainer
            color: "transparent"
            width: visible ? runAppButton.width + 12 : 0
            height: 72
            visible: runAppButton.visible
            anchors {
                top: parent.top
                left: parent.left
            }

            Button {
                id: runAppButton
                Material.background: "#0784FC"
                enabled: false
                opacity: delegatestate === "installed" ? 1.0 : 0.0
                visible: false//opacity > 0.0
                width: runBtnText.width + 12
                height: parent.height / 3 + 18
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -6
                }

                Behavior on opacity {
                    enabled: animate
                    NumberAnimation { duration: animationDuration }
                }

                onClicked: {
                    helper.runCommand(exec)
                }

                Label {
                    id: runBtnText
                    //font.weight: Font.DemiBold
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    Material.foreground: "#FAFAFA"
                    opacity: parent.opacity
                    visible: opacity > 0.0

                    text: qsTr("OPEN")
                    font.pointSize: 10
                }
            }
        }

        Rectangle {
            id: appNameLabelContainer
            width: parent.width - mfButton.width - openBtnContainer.width
            height: mfButton.height - 12
            anchors {
                top: parent.top
                left: openBtnContainer.right
            }
            color: "transparent"
            Label {
                id: appNameLabel
                anchors.fill: parent
                text: getPrettyName(name)
                fontSizeMode: Text.Fit
                height: parent.height
                font.pointSize: 20
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
                //font.pointSize: Text.VerticalFit
            }
        }

        Rectangle {
            id: detailContainer
            width: parent.width - appIconContainer.width
            height: parent.height - mfButton.height
            anchors {
                right: parent.right
                rightMargin: -3
                bottom: parent.bottom
            }
            color: "transparent"
            opacity: delegateMa.containsMouse ? 1.0 : 0.0
            visible: opacity > 0.0
            Behavior on opacity {
                enabled: animate
                NumberAnimation { duration: animationDuration }
            }

            Column {
                anchors.centerIn: parent
                spacing: 12
                width: parent.width
                Label {
                    id: downloadSizeLabel
                    width: parent.width
                    Material.foreground: "#03A9F4"
                    text: installed ? "" : (qsTr("Download size")+ "\n" + dsize)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pointSize: detailContainer.width / 12
                }

                Label {
                    id: nonFreeLabel
                    width: parent.width
                    Material.foreground: "#E91E63"
                    text: nonfree ? qsTr("Non Free") : ""
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pointSize: detailContainer.width / 12
                }

                Label {
                    id: detailsLabel
                    width: parent.width
                    Material.foreground: detailTextHovered ? "#FFBC08":"#EEEEEE"
                    text: qsTr("Click for details")
                    font.underline: detailTextHovered
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pointSize: detailContainer.width / 12
                }
            }



        }

        Rectangle {
            id: appIconContainer
            height: parent.height - appNameLabelContainer.height - 3
            width: height
            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: delegateMa.containsMouse ? - (parent.width - width) / 2 : 0
                bottom: parent.bottom
            }
            color: "transparent"
            Behavior on anchors.horizontalCenterOffset {
                enabled: animate
                NumberAnimation {
                    duration: animationDuration
                    easing.type: Easing.OutExpo
                }
            }

            Image {
                id: appIcon
                anchors.centerIn: parent
                asynchronous: true
                source: "image://application/" + getCorrectName(name)
                sourceSize {
                    width: parent.width
                    height: parent.height
                }
                smooth: true
            }
        }

    }
}
