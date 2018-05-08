import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0


Pane {
    id:home

    anchors.centerIn: parent

    width: parent.width - 10
    height: parent.height - 10
    Material.elevation: 2    
    property int animationSpeed: 200
    property variant surveyList : []
    property variant surveyCounts: []
    property string choice : helper.choice
    property int selectedIndex: 0
    property string editorsAppName: "chromium"
    property string mostAppName: "spotify-client"

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
        width: parent.width
        height: bannerImage.height > 0 ? bannerImage.height + 24 : 250
        Material.elevation: 2       
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: bannerImage
            width: parent.width
            fillMode: Image.PreserveAspectFit
            source: "http://193.140.98.197:5000/screenshots/banner.png"
            anchors.centerIn: parent
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

            text: qsTr("welcome")
            Material.foreground: "#fafafa"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.bold: true
            font.pointSize: 32
        }
    }

    Pane {
        id: suggester
        height: parent.height - banner.height - 15
        width: height
        Material.elevation: 2        
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        // for one app
        Pane {
            id: editorApp
            Material.elevation: 2
            //clip: true
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.verticalCenter
                bottomMargin: 5
            }

            MouseArea {
                id: editorBadgeMa
                hoverEnabled: true
                anchors.fill: parent

                onClicked: {
                    swipeView.currentIndex = 1
                    applicationModel.setFilterString(editorsAppName, true)

                }
            }

            Image {
                id:appIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    verticalCenterOffset: editorBadgeMa.containsMouse ? 9 : 27
                }                
                height: parent.height * 2 / 3
                width: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true
                source: "image://application/" + getCorrectName(editorsAppName)

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation {
                        duration: animationSpeed
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
                    verticalCenterOffset: editorBadgeMa.containsMouse ? 9 : 27
                    left: appIcon.right
                    right: parent.right
                }
                text: editorsAppName.replace("-", " ")
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
                font.pointSize: 14

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation {
                        duration: animationSpeed
                        easing.type: Easing.OutExpo
                    }
                }
            }

            Rectangle {
                id: editorBadgeCover
                width: parent.width
                height: parent.height
                clip: true
                color: "transparent"

                Rectangle  {
                    id: editorBadge

                    width: parent.width * 3
                    height: width
                    radius:  editorBadgeMa.containsMouse ? 0 : height / 2
                    color: "#ffcb08"
                    //opacity: editorBadgeMa.containsMouse ? 0 : 0.5
                    opacity: 0.5


                    x: - editorBadge.width / 3
                    y:  editorBadgeMa.containsMouse ? - editorBadge.height + editorBadgeTxt.height + 10
                                                    : - editorBadge.height + editorBadgeCover.height / 2

                    Text {
                        id: editorBadgeTxt
                        text: qsTr("Editor's Pick")
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: editorBadgeMa.containsMouse ? 5 : 30

                        Behavior on anchors.bottomMargin {
                            NumberAnimation {
                                duration: animationSpeed
                                easing.type: Easing.OutExpo
                            }
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: animationSpeed
                            easing.type: Easing.OutExpo
                        }
                    }

                    Behavior on radius {
                        NumberAnimation {
                            duration: animationSpeed
                            easing.type: Easing.OutExpo
                        }
                    }

                }

            }

        }

        Pane {
            id: mostDownloadedApp
            Material.elevation: 2
            anchors {
                top: parent.verticalCenter
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 5
            }

            MouseArea {
                id: mostDownloadedAppMa
                hoverEnabled: true
                anchors.fill: parent

                onClicked: {
                    swipeView.currentIndex = 1
                    applicationModel.setFilterString(mostAppName, true)
                }
            }

            Image {
                id:appIconMost
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    verticalCenterOffset: mostDownloadedAppMa.containsMouse ? 9 : 27
                }
                height: parent.height * 2 / 3
                width: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true
                source: "image://application/" + getCorrectName(mostAppName)

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation {
                        duration: animationSpeed
                        easing.type: Easing.OutExpo
                    }
                }
            }

            DropShadow {
                id:dropShadowMost
                anchors.fill: appIconMost
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8
                samples: 17
                color: "#80000000"
                source: appIconMost
            }

            Label {
                id: appNameLabelMost
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: mostDownloadedAppMa.containsMouse ? 9 : 27
                    left: appIconMost.right
                    right: parent.right
                }
                text: mostAppName.replace("-", " ")
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
                font.pointSize: 14

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation {
                        duration: animationSpeed
                        easing.type: Easing.OutExpo
                    }
                }
            }

            Rectangle {
                id: mostDownloadedAppCover
                width: parent.width
                height: parent.height
                clip: true
                color: "transparent"

                Rectangle  {
                    id: mostDownloadedAppBadge                   
                    width: parent.width * 3
                    height: width
                    radius:  mostDownloadedAppMa.containsMouse ? 0 : height / 2
                    color: "#ffcb08"
                    opacity: 0.5


                    x: - mostDownloadedAppBadge.width / 3
                    y:  mostDownloadedAppMa.containsMouse ? - mostDownloadedAppBadge.height + mostDownloadedAppBadgeTxt.height + 10
                                                          : - mostDownloadedAppBadge.height + mostDownloadedAppCover.height / 2

                    Text {
                        id: mostDownloadedAppBadgeTxt
                        text: qsTr("Most Downloaded App")
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: mostDownloadedAppMa.containsMouse ? 5 : 30

                        Behavior on anchors.bottomMargin {
                            NumberAnimation {
                                duration: animationSpeed
                                easing.type: Easing.OutExpo
                            }
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: animationSpeed
                            easing.type: Easing.OutExpo
                        }
                    }

                    Behavior on radius {
                        NumberAnimation {
                            duration: animationSpeed
                            easing.type: Easing.OutExpo
                        }
                    }

                }

            }
        }
    }

    Item {
        id: middle
        anchors {
            left: suggester.right
            right: survey.left
            top: banner.bottom
            bottom: parent.bottom
            margins: 5
        }

        Image {
            id: middleBackgroundIcon
            source: "../images/icon.svg"
            width: parent.height
            height: width
            anchors.centerIn: parent
            opacity: 0.02
        }

        Column {
            anchors.centerIn: parent
            spacing: 24

            Label {
                text: qsTr("Source Code") + " : " +"<a href='https://github.com/yunusem/pardus-store'>GitHub</a>"
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("License") + " : " +"<a href='http://ozgurlisanslar.org.tr/gpl/gpl-v3/'>GPL v3</a>"
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text:qsTr("Version") + " : " + "alpha"
            }

            Label {
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Leave comments on") + " : " +"<a href='http://forum.pardus.org.tr/t/pardus-magaza-pardus-store'>Pardus Forum</a>"
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                enabled: false
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Bu kısım geçicidir. Daha fazlası yakında gelecek ..."
            }
        }
    }


    Pane {
        id: survey
        height: parent.height - banner.height - 15
        width: height
        Material.elevation: 2        
        anchors {
            bottom: parent.bottom
            right: parent.right
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

            Button {
                id: surveyBtn
                anchors {
                    horizontalCenter: parent.horizontalCenter
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
}
