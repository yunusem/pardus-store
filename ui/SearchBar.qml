import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

Pane {
    id: searchPane
    width: searchFlag ? 500 : applicationListPage.cellWidth - 20
    height: searchFlag ? parent.height / 15 : 32
    Material.elevation: searchFlag ? 3 : 1
    property string prelist: ""
    property bool searchFlag: searchF

    visible: splashScreen.opacity < 0.7
    z: 100
    anchors {
        top: parent.top
        topMargin: searchFlag ? 0 : 10
        horizontalCenter: parent.horizontalCenter
        horizontalCenterOffset: parent.width / 40
    }

    Behavior on anchors.topMargin {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Behavior on width  {
        NumberAnimation {
            easing.type: Easing.OutCirc
            duration: 200
        }
    }

    Behavior on height {
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
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }
        Behavior on anchors.leftMargin {
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
        onPressed: {
            if (searchBtnMa.containsMouse) {
                searchBtnMa.Material.elevation = 0
            }
        }
        onReleased: {
            searchBtnMa.Material.elevation = 2
        }
        onClicked: {
            searchFlag = true
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
                    closeSearchBtnMa.Material.elevation = 0
                }
            }
            onReleased: {
                closeSearchBtnMa.Material.elevation = 2
            }
            onClicked: {
                searchFlag = false
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
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 1000
            }
        }

        Behavior on width {
            NumberAnimation {
                easing.type: Easing.OutCirc
                duration: 200
            }
        }


        onTextChanged: {
            applicationModel.setFilterString(searchField.text, true)
        }

    }   

    onSearchFlagChanged: {
        searchF = searchFlag
        if(!searchFlag) {
            searchField.text = ""
        }
    }
}



