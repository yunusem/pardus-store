import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: container
    width: 161.625
    height: 32
    property int searchBarBorderWidth: 1
    property int radiusValue: 3
    property int marginValue: 22
    property string textColor: "#fafafa"
    property string searchBarColor: "#4c4c4c"

    Rectangle {
        id: searchBarBorder
        width: parent.width
        height: parent.height
        radius: container.radiusValue
        color: searchText.focus ? "#FFCB08" : "#5C5C5C"

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


//import QtQuick 2.7
//import QtQuick.Controls 2.0
//import QtQuick.Layouts 1.0
//import QtQuick.Controls.Material 2.0
//import QtQuick.Controls.Styles 1.4
//import QtGraphicalEffects 1.0

//Pane {
//    id: searchPane
//    width: searchFlag ? 500 : stackView.width / 5 - 20
//    height: searchFlag ? topDock.height : topDock.height * 2 / 3
//    Material.elevation: searchFlag ? 3 : 1
//    property string prelist: ""
//    property bool searchFlag: isSearching

//    visible: splashScreen.opacity < 0.7
//    z: 100
//    anchors {
//        verticalCenter: topDock.verticalCenter
//        horizontalCenter: parent.horizontalCenter
//        horizontalCenterOffset: parent.width / 40
//    }

//    Behavior on anchors.topMargin {
//        enabled: animate
//        NumberAnimation {
//            easing.type: Easing.OutExpo
//            duration: 200
//        }
//    }

//    Behavior on width  {
//        enabled: animate
//        NumberAnimation {
//            easing.type: Easing.OutCirc
//            duration: 200
//        }
//    }

//    Behavior on height {
//        enabled: animate
//        NumberAnimation {
//            easing.type: Easing.OutCirc
//            duration: 200
//        }
//    }


//    Image {
//        id: searchIcon
//        width: searchFlag ? 36 : 24
//        height: width
//        anchors {
//            verticalCenter: parent.verticalCenter
//            left: parent.left
//            leftMargin: searchFlag ? 0 : -9
//        }
//        source: "qrc:/images/search.svg"

//        Behavior on width  {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutCirc
//                duration: 200
//            }
//        }
//        Behavior on anchors.leftMargin {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutCirc
//                duration: 200
//            }
//        }
//    }

//    DropShadow {
//        id:ds
//        visible: true
//        anchors.fill: searchIcon
//        horizontalOffset: 3
//        verticalOffset: 3
//        radius: 8
//        samples: 17
//        color: "#ff000000"
//        source: searchIcon
//    }


//    MouseArea {
//        id: searchBtnMa
//        width: 200
//        height: 32
//        anchors.centerIn: parent
//        onClicked: {
//            //searchFlag = true
//            isSearching = true
//            searchField.focus = true
//            searchField.forceActiveFocus()
//        }
//    }


//    Pane {
//        id: btnClose
//        width: 32
//        height: 32
//        Material.background: "#2c2c2c"
//        Material.elevation: 10
//        visible: searchFlag

//        anchors {
//            right: parent.right
//            top: parent.top
//        }

//        Label {
//            anchors.centerIn: parent
//            Material.foreground: "white"
//            text: "X"
//            verticalAlignment: Text.AlignVCenter
//            horizontalAlignment: Text.AlignHCenter
//        }

//        MouseArea {
//            id: closeSearchBtnMa
//            width: 32
//            height: 32
//            anchors.centerIn: parent
//            onPressed: {
//                if (closeSearchBtnMa.containsMouse) {
//                    btnClose.Material.elevation = 1
//                }
//            }
//            onReleased: {
//                btnClose.Material.elevation = 10
//            }
//            onClicked: {
//                isSearching = false
//            }
//        }
//    }


//    TextField {
//        id: searchField

//        width: searchPane.width / 2
//        height: 40
//        visible: searchFlag
//        opacity: searchFlag ? 1 : 0

//        placeholderText: qsTr("Search an application")
//        anchors.centerIn: parent


//        Behavior on y {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutCirc
//                duration: 200
//            }
//        }

//        Behavior on opacity {
//            enabled: animate
//            NumberAnimation {
//                duration: 1000
//            }
//        }

//        Behavior on width {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutCirc
//                duration: 200
//            }
//        }


//        onTextChanged: {
//            if(stackView.depth === 3) {
//                stackView.pop()
//            }

//            if(searchField.text !== "") {
//                applicationModel.setFilterString(searchField.text.trim(), true)
//            }
//        }
//    }

//    onSearchFlagChanged: {
//        var c = categoryIcons[categories.indexOf(category)]
//        if(searchFlag) {

//            category = categories[categoryIcons.indexOf("all")]

//            if(stackView.depth === 3) {
//                stackView.pop()
//            }
//        } else {
//            searchField.text = ""
//        }
//    }
//}



