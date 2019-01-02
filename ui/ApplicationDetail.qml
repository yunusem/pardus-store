import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id:appDetail
    property string previous
    property string current    
    property string appVersion
    property string appDownloadSize
    property string appCategory
    property bool appNonfree
    property string appDescription

    property int length: urls.length    
    property int ssindex: indicator.index
    property int detailTextSize : 12
    property variant urls: screenshotUrls

    function startRemoving(name, from) {
        if(name !== "" && name === selectedAppName && from === "detail") {
            updateStatusOfAppFromDetail(selectedAppName)
            processQueue.push(selectedAppName + " " + selectedAppInstalled)
        }
    }

    function errorHappened() {
        processButton.enabled = true
    }

    function appDescriptionSlot(desc) {
        appDescription = desc
    }

    color: "transparent"

    onLengthChanged: {
        lm.clear()
        for(var c=0; c < length; c++) {
            lm.append({"url" : urls[c]})
        }
    }

    Component.onCompleted: {
        confirmationRemoval.connect(startRemoving)
        errorOccured.connect(errorHappened)
        appDescriptionReceived.connect(appDescriptionSlot)
        helper.getAppDetails(selectedAppName)
    }

    Component.onDestruction: {
        selectedAppName = ""
        selectedAppInqueue = false
        selectedAppInstalled = false
        selectedAppDelegatestate = "get"
    }



    ListModel {
        id: lm
        ListElement {
            url : ""
        }
    }

    Pane {
        id:appBanner
        width: parent.width - 108
        height: 200
        Material.elevation: 3
        visible: true
        anchors {
            top: parent.top
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }


        Image {
            id:appBannerIcon
            height: appBanner.height - 12
            width: height
            sourceSize.width: width
            sourceSize.height: width
            anchors {
                left: parent.left
                leftMargin: 6
                verticalCenter: parent.verticalCenter
            }
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            visible: true
            source: selectedAppName === "" ? "": "image://application/" + getCorrectName(selectedAppName)
            smooth: true
        }

        DropShadow {
            id:dropShadowAppIcon
            anchors.fill: appBannerIcon
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8
            samples: 17
            color: "#80000000"
            source: appBannerIcon
            smooth: true            
        }

        Label {
            anchors.centerIn: parent
            text: getPrettyName(selectedAppName)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.bold: true
            font.pointSize:24
        }
    }

    Popup {
        id:popupImagePreview
        width: main.width - 12
        height: parent.height - 12
        modal: animate
        focus: true
        x: - navigationBarWidth + 6
        y: 6
        closePolicy: Popup.CloseOnPressOutside
        onClosed: {
            if (indicator.index == -1) {
                ssindex = length - 1
            } else {
                ssindex = indicator.index
            }

            popupImage.source = ""

        }
        onOpened: {
            if (indicator.index == -1) {
                ssindex = length - 1
            } else {
                ssindex = indicator.index
            }

            popupImage.source = urls[0] !== "none" && urls[0] ? urls[ssindex] : ""

        }


        Image {
            id:popupImage
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            width: (parent.width - 140) >= sourceSize.width ? sourceSize.width :  parent.width - 140
            height: parent.height >= sourceSize.height ? sourceSize.height : parent.height
            source: urls[0] !== "none" && urls[0] ? urls[ssindex] : ""

            BusyIndicator {
                id: imageBusyInPopup
                anchors.centerIn: parent
                running: urls[0] !== "none" ? 0 : !popupImage.progress
            }

            onSourceChanged: {
                if(animate) {
                    trans.start()
                }
            }

            NumberAnimation {
                id: trans
                target: popupImage
                property: "opacity"
                from: 0
                to: 1.0
                duration: 200
                easing.type: Easing.InExpo
            }

        }

        Rectangle {
            width:75
            height: parent.height * 5 / 6
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            opacity: nextMa.containsMouse ? 1.0 : 0.2

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:nextMa
                anchors.fill: parent

                hoverEnabled: true
                onClicked:{
                    ssindex=ssindex + 1
                    if (ssindex==length) {
                        ssindex = 0
                    }
                    popupImage.source = urls[ssindex]


                }
                onClipChanged: ssindex = indicator.index
            }
            Image {
                width: 64
                height: 64
                anchors.right: parent.right
                anchors.centerIn: parent
                source:"qrc:/images/front.svg"

            }
        }

        Rectangle {
            width:75
            height: parent.height * 5 / 6
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            opacity: prevMa.containsMouse ? 1.0 : 0.2

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:prevMa
                anchors.fill: parent

                hoverEnabled: true
                onClicked:{
                    ssindex= ssindex - 1
                    if (ssindex==-1) {

                        ssindex = length - 1
                    }
                    popupImage.source = urls[ssindex]
                }
            }

            Image {
                id:prev
                width: 64
                height: 64
                anchors.right: parent.right
                anchors.centerIn: parent
                source:"qrc:/images/back.svg"

            }
        }

        Pane {
            id: btnClose
            width: 32
            height: 32
            Material.background: Material.primary
            Material.elevation: 10

            anchors {
                right: parent.right
                top: parent.top
            }

            Label {
                anchors.centerIn: parent
                Material.foreground: "white"
                text: "X"
                font.weight: Font.DemiBold

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: closePopupBtnMa
                width: 32
                height: 32
                anchors.centerIn: parent
                onPressed: {
                    if (closePopupBtnMa.containsMouse) {
                        closePopupBtnMa.Material.elevation = 0
                    }
                }
                onReleased: {
                    closePopupBtnMa.Material.elevation = 2
                }
                onClicked: {
                    popupImagePreview.close()
                }
            }
        }
    }

    Pane {
        id: imagesPane
        Material.elevation : 3
        width: parent.width * 19 / 32
        height: parent.height - appBanner.height - 36
        y: appBanner.y + appBanner.height + 12
        x: 54
        Label {
            id: titleText
            height: 36
            anchors {
                left: parent.left
                top: parent.top
            }

            text: qsTr("screenshots")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.pointSize: 16
            font.bold: true
        }



        ListView {
            id: screenshotsLV

            interactive: animate
            spacing: 15
            clip: true
            orientation: Qt.Horizontal
            width: parent.width
            height: width * 9 / 16
            anchors.centerIn: parent

            model: lm
            snapMode: ListView.SnapOneItem
            delegate: Item {
                width: screenshotsLV.width - 10
                height: screenshotsLV.height - 10
                Image {
                    id:ss
                    visible: url != "none"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: url == "none" ? "" : url
                    MouseArea{
                        id:ssma
                        anchors.fill:parent

                        onClicked: {
                            popupImagePreview.open()
                        }

                    }
                }
                onChildrenChanged: ssindex = indicator.index



                DropShadow {
                    id:dropShadow
                    visible: ss.visible
                    anchors.fill: ss
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8
                    samples: 17
                    color: "#80000000"
                    source: ss
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("no screenshot found!")
                    visible: url == "none"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    enabled: false
                }

                BusyIndicator {
                    id: imageBusy
                    anchors.centerIn: parent
                    running: url == "none" ? 0 : !ss.progress
                }
            }

            onMovementEnded: {
                indicator.index = indexAt(contentX,contentY)

                if (indicator.index == -1) {
                    ssindex = length - 1
                } else {
                    ssindex = indicator.index
                }

                popupImage.source = urls[0] !== "none" && urls[0] ? urls[ssindex] : ""

            }
        }

        Label {
            id: indicator
            property int index: 0
            visible: urls[0] !== "none"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: screenshotsLV.bottom
                topMargin: 6
            }

            text: (index == -1 ? lm.count.toString() : index + 1) + "/" + lm.count
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            enabled: false
        }
    }

    Pane {
        id:textPane
        height: imagesPane.height
        width: appBanner.width - imagesPane.width - 12
        x: imagesPane.width + imagesPane.x + 12
        y: appBanner.height + 24
        clip: true        
        Rectangle {
            id: disclamer
            visible: appNonfree
            clip: true
            width: disclamerMa.containsMouse ? parent.width - processButton.width - 12 : processButton.width
            height: disclamerMa.containsMouse ? processButton.height * 3 + 18 : processButton.height - 12
            color: "#FFCB08"
            radius: 2
            z: 200
            anchors {
                bottom: parent.bottom
                bottomMargin: 6
                left: parent.left
            }

            MouseArea {
                id: disclamerMa
                width: parent.width + 24
                height: parent.height + 24
                anchors.centerIn: parent
                hoverEnabled: true
            }

            Behavior on height {
                enabled: animate
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 150
                }
            }

            Behavior on width {
                enabled: animate
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 50
                }
            }

            Label {
                id: disclamerText
                width: parent.width - 12
                //enabled: disclamerMa.containsMouse
                Material.foreground: Material.background
                text: qsTr("Disclaimer") + (disclamerMa.containsMouse ? (" : " +
                                                                         qsTr("This application served from Pardus non-free package repositories, so that the OS has nothing to do with the health of the application. Install with caution.")) : " !")
                //horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                wrapMode: Text.WordWrap
                anchors.centerIn: parent
                anchors.margins: 6

            }
        }

        Button {
            id: processButton
            width: parent.width / 3            

            enabled: !selectedAppInqueue
            Material.background: selectedAppInstalled ? "#F44336" : "#4CAF50"
            Material.foreground: "#FAFAFA"
            text: selectedAppInstalled ? qsTr("remove") : qsTr("install")

            anchors {
                bottom: parent.bottom
                right: parent.right
            }

            onClicked: {
                if(selectedAppInstalled) {
                    confirmationDialog.name = selectedAppName
                    confirmationDialog.from = "detail"
                    confirmationDialog.open()
                } else {
                    updateStatusOfAppFromDetail(selectedAppName)
                    processQueue.push(selectedAppName + " " + selectedAppInstalled)
                    updateQueue()
                }
            }
        }

        Column {
            width: parent.width
            anchors {
                top: parent.top
                bottom: processButton.top
                bottomMargin: 21
            }

            spacing: 3
            Label {
                id: labelVersion
                text:qsTr("version")+": " + appVersion
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }

            Label {
                id: labelDownloadSize
                visible: !selectedAppInstalled
                text:qsTr("Download size")+": " + appDownloadSize
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }

            Label {
                id: labelCategory
                text:qsTr("Category")+": " + categories[categoryIcons.indexOf(appCategory)]
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }
            Label {
                id: labelDescriptionTitle
                text:qsTr("Description")+": "
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }

            Flickable {
                id: flickable
                width: parent.width
                height: parent.height - labelVersion.height * 4
                contentWidth: labelDescription.width
                contentHeight: labelDescription.height
                clip: true
                ScrollBar.vertical: ScrollBar { }
                flickableDirection: Flickable.VerticalFlick

                Label {
                    id: labelDescription
                    width: textPane.width - 30
                    text: appDescription === "" ? qsTr("no description found"): appDescription
                    fontSizeMode: Text.VerticalFit
                    wrapMode: Text.WordWrap
                    font.pointSize: detailTextSize
                    verticalAlignment: Text.AlignTop
                    enabled: false
                }
            }

        }


    }

    Button {
        id: backBtn
        z: 92
        height: 54
        width: height * 2 / 3
        opacity: selectedCategory !== qsTr("home") ? 1.0 : 0.0
        Material.background: Material.background
        anchors {
            top: parent.top
            topMargin: 6
            left: parent.left
            leftMargin: 8

        }

        Image {
            id: backIcon
            width: parent.height - 24
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: true
            source: "qrc:/images/back.svg"
        }

        onClicked: {
            stackView.pop()

        }

        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 300
            }
        }

    }


}

