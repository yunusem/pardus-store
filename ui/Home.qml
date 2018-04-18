import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Pane {
    id:home

    anchors.centerIn: parent

    width: parent.width - 10
    height: parent.height - 10
    Material.elevation: 2
    //Material.background: "#2c2c2c"

    property variant surveyList : ["gimp", "webstorm", "discord"]

    property string surveySelectedApplication : ""

    Pane {
        id: banner
        width: parent.width
        height: bannerImage.height + 24
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
            BusyIndicator {
                id: bannerBusy
                anchors.centerIn: parent
                running: !bannerImage.progress
            }
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

        Pane {
            id: editorApp
            Material.elevation: 2
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.verticalCenter
                bottomMargin: 5
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
