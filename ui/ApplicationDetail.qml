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

    property string description
    property string sections : "game, misc"
    property string maintainer: "Debian Games Team"
    property string website : "http://play0ad.com/"
    property string license : "GPLv3"
    property double rating: 3.666666666
    property int ratingTotal: 15

    property int length: urls.length    
    property int ssindex: indicator.index
    property int detailTextSize : 12
    property variant urls: screenshotUrls

    property string textPrimaryColor: Material.foreground
    property string textSecondaryColor: "#A9A9A9"

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
        description = desc
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
            height: appBanner.height
            width: height
            sourceSize.width: width
            sourceSize.height: width
            anchors {
                left: parent.left
                //leftMargin: 6
                verticalCenter: parent.verticalCenter
            }
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            visible: true
            source: selectedAppName === "" ? "": "image://application/" + getCorrectName(selectedAppName)
            smooth: true
        }

        Rectangle {
            id: appBannerNameContainer
            color: "transparent"
            height: parent.height * 4 / 7
            width: parent.width * 4 / 5 - appBannerIcon.width
            anchors {
                top: parent.top
                left: appBannerIcon.right
                leftMargin: 12
            }

            Column {
                anchors {
                    fill: parent
                }
                spacing: 6
                Label {
                    id: appNameLabel
                    text: selectedAppName
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.bold: true
                    font.pointSize:24
                }

                Label {
                    id: sectionsLabel
                    text: sections
                    color: textSecondaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize:11
                }
                Label {
                    id: maintainerLabel
                    text: maintainer
                    Material.foreground: "#ddffcb08"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize:9
                }
            }


        }

        Rectangle {
            id: appBanerRatingContainer
            color: "transparent"
            anchors {
                top: appBannerNameContainer.bottom
                topMargin: 12
                left: appBannerIcon.right
                leftMargin: 12
                bottom: parent.bottom
                right: parent.right
            }

            Label {
                id: ratingLabel
                text: rating.toFixed(1)
                color: textSecondaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.capitalization: Font.Capitalize
                font.weight: Font.DemiBold
                font.pointSize:20
                anchors {
                    left: parent.left
                    top: parent.top
                }
            }

            Rectangle {
                color: "#111111"
                width: 125
                height: width / 5
                anchors {
                    verticalCenter: ratingLabel.verticalCenter
                    left: ratingLabel.right
                    leftMargin: 6
                }

                Rectangle {
                    color: textSecondaryColor
                    height: parent.height
                    width: parent.width * rating / 5
                }

                Image {
                    source: "qrc:/images/rating-stars.svg"
                    anchors.fill: parent
                    sourceSize {
                        width: width
                        height: height
                    }
                    Component.onCompleted: console.log(width)
                }
            }

            Label {
                id: ratingTotalLabel
                text: ratingTotal + " " + qsTr("ratings")
                color: textSecondaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.capitalization: Font.Capitalize
                font.pointSize:10
                anchors {
                    left: parent.left
                    top: ratingLabel.bottom
                }
            }


            Pane {
                id: disclamer
                visible: appNonfree
                clip: true
                width: disclamerMa.containsMouse ? 500 : 150
                height: disclamerMa.containsMouse ? parent.height : disclamerText.height + 24
                Material.background: Material.accent
                Material.elevation: 3
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right

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
                    width: parent.width
                    Material.foreground: "#2B2B2B"
                    text: qsTr("Disclaimer") + (disclamerMa.containsMouse ? (" : " +
                                                                             qsTr("This application served from Pardus non-free package repositories, so that the OS has nothing to do with the health of the application. Install with caution.")) : " !")
                    //horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.HorizontalFit

                    wrapMode: Text.WordWrap
                    anchors.centerIn: parent
                }
            }
        }

        Rectangle {
            id: appBannerActionContainer
            color: "transparent"
            anchors {
                top: parent.top
                right: parent.right
                left:appBannerNameContainer.right
                leftMargin: 12
                bottom: appBannerNameContainer.bottom
            }

            Button {
                id: processButton
                width: parent.height

                enabled: !selectedAppInqueue
                Material.background: selectedAppInstalled ? "#F44336" : "#4CAF50"
                Material.foreground: "#FAFAFA"
                text: selectedAppInstalled ? qsTr("remove") : qsTr("install")

                anchors {
                    verticalCenter: parent.verticalCenter
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




        Column {
            width: parent.width
            anchors {
                top: parent.top
                bottom: parent.bottom
                bottomMargin: 24
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
                    text: description === "" ? qsTr("no description found"): description
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

