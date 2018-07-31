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
        width: 838.375
        height: 318.375
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
                verticalCenterOffset: - parent.height / 10
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width / 10
            }
            smooth: true
            text: qsTr("welcome")

            Material.foreground: "#fafafa"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.pointSize: 42
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
                RadioButton {
                    text: modelData
                    font.capitalization: Font.Capitalize
                    onCheckedChanged: {
                        selectedIndex = index
                    }

                    checked: (modelData === choice)

                    Image {
                        anchors {
                            left: parent.right
                        }

                        height: parent.height
                        width: height
                        source: "image://application/" + getCorrectName(text)
                    }

                    Label {
                        id: counterLabel
                        anchors.right: parent.left
                        anchors.rightMargin: 12
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
                }
            }
        }

        Button {
            id: surveyBtn
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            Material.background: "#2c2c2c"
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
}
