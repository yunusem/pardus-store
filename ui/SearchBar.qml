import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

Pane {
    id: searchPane
    width: searchFlag ? 500 : stackView.width / 5 - 20
    height: searchFlag ? topDock.height : topDock.height * 2 / 3
    Material.elevation: searchFlag ? 3 : 1
    property string prelist: ""
    property bool searchFlag: isSearching

    visible: splashScreen.opacity < 0.7
    z: 100
    anchors {
        verticalCenter: topDock.verticalCenter
        horizontalCenter: parent.horizontalCenter
        horizontalCenterOffset: parent.width / 40
    }

    Behavior on anchors.topMargin {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Behavior on width  {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutCirc
            duration: 200
        }
    }

    Behavior on height {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutCirc
            duration: 200
        }
    }


    Image {
        id: searchIcon
        width: searchFlag ? 36 : 24
        height: width
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: searchFlag ? 0 : -9
        }
        source: "qrc:/images/search.svg"

        Behavior on width  {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }
        Behavior on anchors.leftMargin {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }
    }

    DropShadow {
        id:ds
        visible: true
        anchors.fill: searchIcon
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8
        samples: 17
        color: "#ff000000"
        source: searchIcon
    }


    MouseArea {
        id: searchBtnMa
        width: 200
        height: 32
        anchors.centerIn: parent
        onClicked: {
            //searchFlag = true
            isSearching = true
            searchField.focus = true
            searchField.forceActiveFocus()
        }
    }


    Pane {
        id: btnClose
        width: 32
        height: 32
        Material.background: "#2c2c2c"
        Material.elevation: 10
        visible: searchFlag

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
            id: closeSearchBtnMa
            width: 32
            height: 32
            anchors.centerIn: parent
            onPressed: {
                if (closeSearchBtnMa.containsMouse) {
                    btnClose.Material.elevation = 1
                }
            }
            onReleased: {
                btnClose.Material.elevation = 10
            }
            onClicked: {
                isSearching = false
            }
        }
    }


    TextField {
        id: searchField

        width: searchPane.width / 2
        height: 40
        visible: searchFlag
        opacity: searchFlag ? 1 : 0

        placeholderText: qsTr("Search an application")
        anchors.centerIn: parent


        Behavior on y {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }

        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                duration: 1000
            }
        }

        Behavior on width {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }


        onTextChanged: {
            if(stackView.depth === 3) {
                stackView.pop()
            }

            if(searchField.text !== "") {
                applicationModel.setFilterString(searchField.text.trim(), true)
            }
        }
    }

    onSearchFlagChanged: {
        var c = categoryIcons[categories.indexOf(category)]
        if(searchFlag) {

            category = categories[categoryIcons.indexOf("all")]

            if(stackView.depth === 3) {
                stackView.pop()
            }
        } else {
            searchField.text = ""
        }
    }
}



