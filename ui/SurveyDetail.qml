import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Item {
    visible: false
    property string surveySelectedApp: ""
    property int count
    property string reason
    property string website
    property string explanation

    function detailsReceived(c, r, w, e) {
        count = c
        reason = r
        website = w
        explanation = e
    }

    Component.onCompleted: {
        helper.getSurveyDetail(surveySelectedApp)
        surveyDetailsReceived.connect(detailsReceived)
    }

    Button {
        id: surveyBackButton
        z: 92
        height: 54
        width: height * 2 / 3
        Material.background: "#515151"
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

    Label {
        anchors {
            left: surveyBackButton.right
            leftMargin: 12
            right: parent.right
            top: surveyBackButton.top
            bottom: surveyBackButton.bottom
        }
        color: secondaryTextColor
        text: qsTr("Vote count") + " : " + count
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        font.pointSize:15
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
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
                height: parent.height
                width: height
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                visible: true
                source: surveySelectedApp !== "" ? "image://application/" + getCorrectName(surveySelectedApp) :
                                                   "image://application/image-missing"
                sourceSize.width: width
                sourceSize.height: height
                smooth: true
            }

            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                color: textColor
                text: surveySelectedApp
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
            width: parent.width
            height: survey.height - surveyDetailHeader.height - 96
            contentHeight: surveyAppDetailsColumn.height + 6
            ScrollBar.vertical: ScrollBar { }
            flickableDirection: Flickable.VerticalFlick

            Column {
                id:surveyAppDetailsColumn
                width: parent.width
                spacing: 12
                Label {
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Why we should vote for this ?")
                    color: textColor
                    font.pointSize: 11
                    font.bold: true
                }

                Label {
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: reason
                    color: secondaryTextColor
                }

                Seperator {
                    height: 5
                    lineColor: seperatorColor
                }

                Label {
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Detailed explanation")
                    color: textColor
                    font.pointSize: 11
                    font.bold: true
                }

                Label {
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: explanation
                    color: secondaryTextColor
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    onLinkActivated: {
                        helper.openUrl(link)
                    }
                }

                Seperator {
                    height: 5
                    lineColor: seperatorColor
                }

                Label {
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Where can we be more informed about this ?")
                    color: textColor
                    font.pointSize: 11
                    font.bold: true
                }

                Label {
                    width: parent.width - 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    text: website
                    color: surveyDetailWebsiteMa.containsMouse ? textColor : secondaryTextColor
                    elide: Text.ElideRight
                    font.underline: surveyDetailWebsiteMa.containsMouse
                    MouseArea {
                        id: surveyDetailWebsiteMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            helper.openUrl(website)
                        }
                    }
                }
            }
        }
    }
}
