import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id:root
    color: "transparent"
    property string current: "home"
    property int animationSpeed: 200
    property variant surveyList : []
    property variant surveyCounts: []
    property string surveySelectedApp: ""
    property string choice : helper.choice
    property int selectedIndex: 0
    property string editorsAppName: "chromium"
    property string mostAppName: "spotify-client"
    property real cellWidth: 308
    property real cellHeight: 150

    signal joined()
    signal updated()
    signal countsChanged()

    function fillSurveyList(sl) {
        surveyList = []
        surveyCounts = []
        for(var i =0; i < sl.length; i++) {
            surveyList.push(sl[i].split(" ")[0].toString())
            surveyCounts.push(sl[i].split(" ")[1])
        }
        if (surveyRepeater.model[0] !== surveyList[0]) {
            surveyRepeater.model = surveyList
        }
        countsChanged()
    }

    onJoined: {
        surveyBtn.enabled = true
    }

    onUpdated: {
        surveyBtn.enabled = true
    }

    Component.onCompleted: {
        gotSurveyList.connect(fillSurveyList)
        surveyJoined.connect(joined)
        surveyJoinUpdated.connect(updated)
    }


    Pane {
        id: banner
        width: parent.width - 96
        height: bannerImage.sourceSize.height * width / bannerImage.sourceSize.width
        Material.elevation: 5
        anchors {
            top: parent.top
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: bannerImage
            width: parent.width + 24
            height: parent.height + 24
            source: helper.getMainUrl() + "/screenshots/banner.png"
            anchors {
                centerIn: parent
            }
            layer.enabled: true
            layer.smooth: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: bannerImage.width
                    height: bannerImage.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: bannerImage.width
                        height: bannerImage.height
                        radius: 2
                    }

                }
            }
        }



        BusyIndicator {
            id: bannerBusy
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            running: !bannerImage.progress
        }

        Label {
            id: bannerText
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: font.pointSize
            }
            smooth: true
            text: qsTr("welcome")

            Material.foreground: "#fafafa"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.pointSize: banner.width / 30
            font.letterSpacing: 3
            font.family: pardusFont.name
        }
    }

    Item {
        id: suggester
        height: parent.height - banner.height - 12
        width: editorApp.width
        anchors {
            top: banner.bottom
            topMargin: 12
            left: banner.left
        }

        Pane {
            id: editorApp
            Material.elevation: editorBadgeMa.containsMouse ? 10 : 5
            width: editorsImage.width > 0 ? editorsImage.width : cellWidth
            height: editorsImage.height > 0 ? editorsImage.height : cellHeight
            anchors {
                top: parent.top
                left: parent.left
            }

            Behavior on Material.elevation {
                enabled: animate
                NumberAnimation {
                    duration: 33
                }
            }

            MouseArea {
                id: editorBadgeMa
                hoverEnabled: true
                anchors.centerIn: parent
                width: parent.width + 24
                height: parent.height + 24

                onClicked: {
                    selectedCategory = qsTr("all")
                    expanded = true
                    selectedMenu = qsTr("categories")
                    forceActiveFocus()
                    applicationModel.setFilterString(editorsAppName, true)

                }

                onPressed: {
                    if(editorBadgeMa.containsMouse) {
                        editorApp.Material.elevation = 0
                    }
                }
                onPressAndHold: {
                    if(editorBadgeMa.containsMouse) {
                        editorApp.Material.elevation = 0
                    }
                }
                onReleased: {
                    if(editorBadgeMa.containsMouse) {
                        editorApp.Material.elevation = 10
                    } else {
                        editorApp.Material.elevation = 5
                    }
                }
            }

            Image {
                id:editorsImage
                source: helper.getMainUrl() + "/screenshots/editor.png"
                anchors {
                    centerIn: parent
                }
                layer.enabled: true
                layer.smooth: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: editorsImage.width
                        height: editorsImage.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: editorsImage.width
                            height: editorsImage.height
                            radius: 2
                        }
                    }
                }
            }

            Label {
                id: editorsLabel
                enabled: editorBadgeMa.containsMouse
                Material.foreground: "#ffcb08"
                text: qsTr("Editor's Pick")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
            }
        }

        Pane {
            id: mostDownloadedApp
            Material.elevation: mostDownloadedAppMa.containsMouse ? 10 : 5
            width: mostDownloadedImage.width > 0 ? mostDownloadedImage.width : cellWidth
            height: mostDownloadedImage.height > 0 ? mostDownloadedImage.height : cellHeight
            anchors {
                top: editorApp.bottom
                topMargin: 12
                left: parent.left
            }

            Behavior on Material.elevation {
                enabled: animate
                NumberAnimation {
                    duration: 33
                }
            }

            MouseArea {
                id: mostDownloadedAppMa
                hoverEnabled: true
                anchors.centerIn: parent
                width: parent.width + 24
                height: parent.height + 24

                onClicked: {
                    selectedCategory = qsTr("all")
                    expanded = true
                    selectedMenu = qsTr("categories")
                    forceActiveFocus()
                    applicationModel.setFilterString(mostAppName, true)
                }
                onPressed: {
                    if(mostDownloadedAppMa.containsMouse) {
                        mostDownloadedApp.Material.elevation = 0
                    }
                }
                onPressAndHold: {
                    if(mostDownloadedAppMa.containsMouse) {
                        mostDownloadedApp.Material.elevation = 0
                    }
                }
                onReleased: {
                    if(mostDownloadedAppMa.containsMouse) {
                        mostDownloadedApp.Material.elevation = 10
                    } else {
                        mostDownloadedApp.Material.elevation = 5
                    }
                }
            }


            Image {
                id:mostDownloadedImage
                source:  helper.getMainUrl() + "/screenshots/most.png"
                anchors {
                    centerIn: parent
                }
                layer.enabled: true
                layer.smooth: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: mostDownloadedImage.width
                        height: mostDownloadedImage.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: mostDownloadedImage.width
                            height: mostDownloadedImage.height
                            radius: 2
                        }
                    }
                }
            }

            Label {
                id: mostDownloadedAppLabel
                enabled: mostDownloadedAppMa.containsMouse
                Material.foreground: "#ffcb08"
                text: qsTr("Most Downloaded App")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
            }
        }
    }

    //    Item {
    //        id: middle
    //        anchors {
    //            left: suggester.right
    //            right: survey.left
    //            top: survey.top
    //            bottom: survey.bottom
    //            margins: 6
    //        }

    //        Image {
    //            id: middleBackgroundIcon
    //            source: "../images/icon.svg"
    //            width: parent.width * 2 / 3
    //            height: width
    //            fillMode: Image.PreserveAspectFit
    //            anchors.centerIn: parent
    //            opacity: 0.04
    //        }

    //        Column {
    //            anchors.centerIn: parent
    //            spacing: 24

    //            Label {
    //                text: qsTr("Source Code") + " : " +"<a href='https://github.com/yunusem/pardus-store'>GitHub</a>"
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text: qsTr("License") + " : " +"<a href='http://ozgurlisanslar.org.tr/gpl/gpl-v3/'>GPL v3</a>"
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text:qsTr("Version") + " : " + helper.version
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text: qsTr("Leave comments on") + " : " +"<a href='http://forum.pardus.org.tr/t/pardus-magaza-pardus-store'>Pardus Forum</a>"
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }
    //        }
    //    }


    Pane {
        id: survey
        height: parent.height - banner.height - 36
        width: 512.375
        Material.elevation: 3
        anchors {
            top: banner.bottom
            topMargin: 12
            right: banner.right
        }

        StackView {
            id: surveyStackView
            anchors.fill: parent
            clip: true
            initialItem: Item {
                Label {
                    id: surveyHText
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: qsTr("application survey")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    font.bold: true
                }

                Label {
                    id: surveyText
                    enabled: false
                    width: parent.width - 20
                    anchors {
                        top: surveyHText.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: qsTr("Which application should be added to the store in next week ?")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                ButtonGroup {
                    id: surveyButtonGroup
                }

                Column {
                    anchors {
                        top: surveyText.bottom
                        topMargin: 12
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }


                    Repeater {
                        id: surveyRepeater
                        model: surveyList
                        Row {
                            spacing: 6
                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                text: surveyCounts[index]
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter

                                function updateValue() {
                                    text = surveyCounts[index]
                                }

                                Component.onCompleted: {
                                    countsChanged.connect(updateValue)
                                }
                            }

                            RadioButton {
                                anchors.verticalCenter: parent.verticalCenter
                                font.capitalization: Font.Capitalize
                                onCheckedChanged: {
                                    selectedIndex = index
                                }
                                ButtonGroup.group: surveyButtonGroup

                                checked: (modelData === choice)
                            }

                            Image {
                                id: surveyRadioIcon
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                width: height
                                source: "image://application/" + getCorrectName(modelData)
                                sourceSize.width: width
                                sourceSize.height: width
                                verticalAlignment: Image.AlignVCenter
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Label {
                                id: surveyRadioLabel
                                anchors.verticalCenter: parent.verticalCenter
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.capitalization: Font.Capitalize
                                font.pointSize: 13
                                text: getPrettyName(modelData)
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        surveySelectedApp = modelData
                                        helper.getAppDetails(surveySelectedApp)
                                        surveyStackView.push(surveyDetail)
                                    }

                                    onHoveredChanged: {
                                        if(containsMouse) {
                                            surveyRadioLabel.font.underline = true
                                        } else {
                                            surveyRadioLabel.font.underline = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    id: surveyBtn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    Material.background: "#4C4C4C"
                    width: surveyBtnLabel.width + 24
                    Label {
                        id: surveyBtnLabel
                        anchors.centerIn: parent
                        Material.foreground: "#ffcb08"
                        text: (choice === "") ? qsTr("send") : qsTr("update")
                        fontSizeMode: Text.HorizontalFit
                        font.capitalization: Font.Capitalize
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        enabled = false
                        if(surveyBtnLabel.text === qsTr("send")) {
                            helper.surveyJoin(surveyList[selectedIndex],"join")
                        } else {
                            helper.surveyJoin(surveyList[selectedIndex],"update")
                        }
                    }
                }

            }

            pushEnter: Transition {
                enabled: animate
                XAnimator {
                    from: (surveyStackView.mirrored ? -1 : 1) * surveyStackView.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                enabled: animate
                XAnimator {
                    from: 0
                    to: (surveyStackView.mirrored ? -1 : 1) * - surveyStackView.width
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            popEnter: Transition {
                enabled: animate
                XAnimator {
                    from: (surveyStackView.mirrored ? -1 : 1) * - surveyStackView.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                enabled: animate
                XAnimator {
                    from: 0
                    to: (surveyStackView.mirrored ? -1 : 1) * surveyStackView.width
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Item {
        id: surveyDetail
        visible: false
        property string description
        function descriptionArrived(desc) {
            description = desc
        }

        Component.onCompleted: {
            appDescriptionReceived.connect(descriptionArrived)
        }

        Button {
            id: surveyBackButton
            z: 92
            height: 54
            width: height * 2 / 3
            Material.background: "#4C4C4C"
            anchors {
                top: parent.top
                topMargin: - 6
                left: parent.left
            }

            Image {
                width: parent.height - 24
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                sourceSize.width: width
                sourceSize.height: width
                smooth: true
                source: "qrc:/images/back.svg"
            }

            onClicked: {
                surveyStackView.pop(null)
            }
        }

        Column {
            anchors {
                left: surveyBackButton.right
                right: parent.right
                rightMargin: surveyBackButton.width - 9
                top: surveyBackButton.bottom
                bottom: parent.bottom
            }

            spacing: 24

            Row {
                id: surveyDetailHeader
                spacing: 12
                height: surveyBackButton.height
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id:surveyAppIcon
                    height: parent.height + 24
                    width: height
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    verticalAlignment: Image.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                    visible: true
                    source: surveySelectedApp !== "" ? "image://application/" + getCorrectName(surveySelectedApp) : "image://application/image-missing"
                    sourceSize.width: width
                    sourceSize.height: width
                    smooth: true
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: getPrettyName(surveySelectedApp)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    font.bold: true
                    font.pointSize:24
                }
            }

            Flickable {
                id: surveyAppDescriptionFlick
                clip: true
                width: parent.width - 6


                //anchors.horizontalCenter: parent.horizontalCenter
                height: survey.height - surveyDetailHeader.height - 96
                //contentWidth: surveyAppDescription.width
                contentHeight: surveyAppDescription.height
                ScrollBar.vertical: ScrollBar { }
                flickableDirection: Flickable.VerticalFlick
                Label {
                    id:surveyAppDescription
                    //anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    text: surveyDetail.description
                }
            }
        }
    }
}
