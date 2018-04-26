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
    //Material.background: "#2c2c2c"

    property variant surveyList : ["gimp", "webstorm", "discord"]

    property string surveySelectedApplication : ""
    property string editorsAppName: "chromium"
    property string mostAppName: "spotify-client"



    Pane {
        id: banner
        width: parent.width
        height: bannerImage.height > 0 ? bannerImage.height + 24 : 250
        Material.elevation: 2
        //Material.background: "#fafafa"
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        Image {
            id: bannerImage
            width: parent.width
            fillMode: Image.PreserveAspectFit
            source: "https://www.pardus.org.tr/wp-content/uploads/2017/07/pardus17-banner-1920.png"
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
            anchors.centerIn: parent
            text: qsTr("welcome to") +" Pardus "+ qsTr("Store")
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
        //Material.background: "#fafafa"
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
                    //category = qsTr("all")




                }
            }


            Image {
                id:appIcon
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                width: 64
                height: 64
                smooth: true
                mipmap: true
                antialiasing: true
                source: "image://application/" + getCorrectName(editorsAppName)


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
                    right: parent.right
                    left: appIcon.right
                }
                text: editorsAppName.replace("-", " ")
                fontSizeMode: Text.HorizontalFit
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize


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
                                duration: 250
                            }
                        }
                    }


                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    Behavior on radius {
                        NumberAnimation {
                            duration: 250
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
                }
                width: 64
                height: 64
                smooth: true
                mipmap: true
                antialiasing: true
                source: "image://application/" + getCorrectName(mostAppName)


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
                    right: parent.right
                    left: appIconMost.right
                }
                text: mostAppName.replace("-", " ")
                fontSizeMode: Text.HorizontalFit
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
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
                                duration: 250
                            }
                        }
                    }


                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    Behavior on radius {
                        NumberAnimation {
                            duration: 250
                        }
                    }

                }

            }

        }

    }


    Rectangle {
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
            opacity: 0.03
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
            Label{
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
                text: "Bu kısım geçicidir. Daha fazlası yakında gelecek..."
            }


        }




    }


    Pane {
        id: survey
        height: parent.height - banner.height - 15
        width: height
        Material.elevation: 2
        //Material.background: "#fafafa"
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
                centerIn: parent
            }

            Repeater {
                model: surveyList.sort()
                RadioButton {
                    text: modelData
                    font.capitalization: Font.Capitalize
                    onCheckedChanged: {
                        surveySelectedApplication = modelData
                    }

                    Image {
                        anchors {
                            left: parent.right
                        }

                        height: parent.height
                        width: height
                        source: "image://application/" + getCorrectName(text)
                    }
                }
            }
        }

    }

}
