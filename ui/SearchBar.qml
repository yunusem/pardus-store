import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: container
    width: 180
    height: 30
    property int searchBarBorderWidth: 1
    property int radiusValue: 3
    property int marginValue: 15
    property string textColor: "#fafafa"
    property string borderColor: "#5c5c5c"
    property string searchBarColor: "#4c4c4c"
    property string placeholderText: "Bir Uygulama Ara"

    Rectangle {
        id: searchBarBorder
        width: parent.width
        height: parent.height
        radius: container.radiusValue
        color: container.borderColor

        anchors.centerIn: parent

        Rectangle {
            id: searchBar
            width: parent.width - container.searchBarBorderWidth * 2
            height: parent.height - container.searchBarBorderWidth * 2
            radius: container.radiusValue
            color: container.searchBarColor

            anchors.centerIn: parent

            TextInput {
                id: searchText
                width: parent.width - clearIcon.width - container.marginValue
                color: container.textColor
                horizontalAlignment: searchText.text ? Text.AlignHCenter : Text.AlignLeft
                clip: true

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: container.marginValue
            }

            Image {
                id: clearIcon
                width: searchText.height
                height: searchText.height
                source: "../images/back.svg"
                smooth: true
                visible: searchText.text

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.leftMargin: container.marginValue

                MouseArea {
                    id: maClear
                    anchors.fill: parent

                    onClicked: {
                        searchText.text = ""
                    }
                }
            }
        }

        Row {
            id: placeHolderRow
            anchors.centerIn: parent

            Image {
                id: searchIcon
                width: searchBar.height
                height: searchBar.height
                source: "../images/search.svg"
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                visible: !searchText.text
            }

            Text {
                id: placeHolder
                height: searchBar.height
                text: container.placeholderText
                verticalAlignment: Text.AlignVCenter
                color: container.textColor
                visible: !searchText.text
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



