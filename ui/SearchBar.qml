import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Item {
    id: container
    width: 161.625
    height: 32
    property int searchBarBorderWidth: 1
    property int radiusValue: 3
    property int marginValue: 22
    property string textColor: Material.foreground
    property string searchBarColor: Material.primary

    Rectangle {
        id: searchBarBorder
        width: parent.width
        height: parent.height
        radius: container.radiusValue
        color: searchText.focus ? "#FFCB08" : "#6B6B6B"

        anchors.centerIn: parent

        Rectangle {
            id: searchBar
            width: parent.width - container.searchBarBorderWidth * 2
            height: parent.height - container.searchBarBorderWidth * 2
            radius: container.radiusValue
            color: container.searchBarColor

            anchors.centerIn: parent

            MouseArea {
                id: searchBarMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton

            }

            TextInput {
                id: searchText
                width: parent.width - clearIcon.width - container.marginValue
                color: container.textColor
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: container.marginValue

                onActiveFocusChanged: {
                    if(activeFocus && searchBarMa.containsMouse) {
                        if(stackView.depth === 3) {
                            stackView.pop()
                        }
                        selectedMenu = qsTr("categories")
                        selectedCategory = qsTr("all")
                        expanded = true
                    }

                }

                Keys.onEscapePressed: {
                        text = ""
                        focus = false
                    }
                onTextChanged: {
                    applicationModel.setFilterString(searchText.text.trim(), true)
                }

            }

            Image {
                id: clearIcon                
                height: searchText.height
                width: height
                source: "qrc:/images/back.svg"
                smooth: true
                antialiasing: true
                mipmap: true
                visible: searchText.text

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.leftMargin: container.marginValue

                MouseArea {
                    id: maClear
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        searchText.text = ""
                    }

                }
            }
        }


        Image {
            id: searchIcon
            height: searchBar.height - 10
            width: height
            visible: !searchText.text
            source: "qrc:/images/search.svg"
            smooth: true
            mipmap: true
            antialiasing: true
            anchors{
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
        }

        Label {
            id: placeHolder
            enabled: false
            height: searchBar.height
            visible: !searchText.text
            text: qsTr("Search an application")
            fontSizeMode: Text.HorizontalFit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors {
                left: searchIcon.right
                leftMargin: 5
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }

    }
}
