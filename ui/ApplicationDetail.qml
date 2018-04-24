import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Pane {
    id:appDetail
    anchors.centerIn: parent
    width: parent.width - 10
    height: parent.height - 10
    Material.elevation: 2
    property bool splashFlag: openAppDetail
    property variant urls: screenshotUrls
    property int length: urls.length
    property int ind: 0
    property int i: indicator.index
    property int detailTextSize : 15

    property string applicationName: app.name
    property bool applicationInTheQueue: app.hasProcessing


    ListModel {
        id: lm
        ListElement {
            url : ""
        }
    }

    Pane {
        id:appBanner
        width: parent.width
        height: parent.height / 5

        Material.elevation: 3
        visible: true
        opacity: splashFlag ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutExpo
            }
        }

        Image {
            id:appBannerIcon
            height: appBanner.height - 30
            width: height
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            visible: true
            source: applicationName == "" ? "": "image://application/" + getCorrectName(applicationName)
            mipmap: true
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
        }

        Label {
            anchors.centerIn: parent
            text: getCorrectName(applicationName)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.bold: true
            font.pointSize:24
        }
    }

    Popup {
        id:popupImagePreview
        width: parent.width
        height: parent.height
        modal: true
        focus: true
        y: -6
        x: -6
        closePolicy: Popup.CloseOnPressOutside
        onClosed: {
            i = indicator.index
        }
        onOpened: {
            i = indicator.index
        }


        Image {
            id:popupImage
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: urls[0] !== "none" && urls[0] ? urls[indicator.index] : ""

            BusyIndicator {
                id: imageBusyInPopup
                anchors.centerIn: parent
                running: urls[0] !== "none" ? 0 : !popupImage.progress
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
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:nextMa
                anchors.fill: parent

                hoverEnabled: true
                onClicked:{
                    i=i + 1
                    if (i==length) {
                        i = 0
                    }
                    popupImage.source = urls[i]


                }
                onClipChanged: i = indicator.index
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
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:prevMa
                anchors.fill: parent

                hoverEnabled: true
                onClicked:{
                    i= i - 1
                    if (i==-1) {

                        i = length - 1
                    }
                    popupImage.source = urls[i]
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
            Material.background: "#2c2c2c"
            Material.elevation: 10

            anchors {
                right: parent.right
                top: parent.top
            }

            Label {
                anchors.centerIn: parent
                Material.foreground: "white"
                text: "X"
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
        height: (width * 9 / 16) + indicator.height + titleText.height + 12
        y: parent.height - (imagesPane.height + 12)

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

        Label {
            id: indicator
            property int index: 0
            visible: urls[0] !== "none"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            text: (index == -1 ? lm.count.toString() : index + 1) + "/" + lm.count
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            enabled: false
        }

        ListView {
            id: screenshotsLV

            interactive: true
            spacing: 15
            clip: true
            orientation: Qt.Horizontal
            width: parent.width
            height: width * 9 / 16
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: indicator.top
            }

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
                onChildrenChanged: i = indicator



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

            }
        }
    }

    Pane {
        id:textPane
        opacity: splashFlag ? 1.0 : 0.0
        height: imagesPane.height
        width: appBanner.width - imagesPane.width - 12
        x: imagesPane.width + 12
        y: parent.height - (textPane.height + 3)

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InExpo
                duration: 1000
            }
        }

        Button {
            id: processButton
            width: parent.width / 3
            height: width / 3
            enabled: !applicationInTheQueue
            Material.background: app.installed ? Material.Red : Material.Green
            Material.foreground: "#fafafa"
            property bool error: main.errorOccured
            anchors {
                bottom: parent.bottom
                right: parent.right
            }

            onErrorChanged: {
                if(error) {
                    enabled = true
                }
            }

            onEnabledChanged: {
                if(error && enabled) {
                    error = false
                }
            }

            onClicked: {
                processingApplicationStatus = (applicationName + " " + true)
                processQueue.push(applicationName + " " + app.installed)
                updateQueue()
            }

            Label {
                id: processButtonLabel
                anchors.centerIn: parent
                text: app.installed ? qsTr("remove") : qsTr("install")
            }
        }

        Column {
            width: parent.width
            anchors {
                top: parent.top
                bottom: processButton.top
                bottomMargin: 12
            }

            spacing: 10
            Label {
                text:qsTr("version")+": " + app.version
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }
            Label {
                text:qsTr("Category")+": " + app.category
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }
            Label {
                text:qsTr("Non-Free")+": " + !app.free
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }
            Label {
                text:qsTr("Description")+": "
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.Capitalize
            }
            Label {
                text: app.description == "" ? "no description found": app.description
                font.pointSize: detailTextSize
                verticalAlignment: Text.AlignVCenter
                enabled: false
            }
        }


    }

    ParallelAnimation {
        id: detailAnimation

        NumberAnimation {
            target: appBanner
            property: "x"
            easing.type: Easing.OutExpo
            duration: 1000
            from: appBanner.width
            to : 0
        }

        NumberAnimation {
            target: imagesPane
            property: "y"
            easing.type: Easing.OutExpo
            duration: 1000
            from: appDetail.height
            to : appDetail.height - (imagesPane.height + 27)
        }

    }

    onSplashFlagChanged: {
        if(splashFlag) {
            detailAnimation.start()
        }
    }

    onApplicationNameChanged: {
        if(!detailAnimation.running) {
            detailAnimation.start()
        }
    }

    onLengthChanged: {
        lm.clear()
        for(var i=0; i < length; i++) {
            lm.append({"url" : urls[i]})
        }
    }

}

