import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0


ApplicationWindow {
    id: main
    width: 1366
    height: 768
    visible: true
    title: qsTr("Pardus Store")
    flags: Qt.FramelessWindowHint

    property string selectedCathegory : "all"

    MouseArea{
        id: ma
        property real cposx: 1.0
        property real cposy: 1.0

        height: main.height / 15
        width: main.width
        anchors {
            top: main.top
        }

        onPressed: {
            cposx = mouse.x
            cposy = mouse.y
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x - cposx, mouse.y - cposy);
            main.x += delta.x;
            main.y += delta.y;

        }

        onReleased: {

        }
    }

    Behavior on x {
        NumberAnimation {
            duration: 75
        }
    }


    Pane {
        id: navi
        visible: true
        width: navima.containsMouse ? main.width / 7 : main.width / 21
        height: main.height
        z : 100
        Material.background: Material.BlueGrey
        Material.elevation: 8

        MouseArea {
            id: navima
            anchors.fill: parent
            hoverEnabled: true
        }

        Behavior on width {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }

        Column {
            id: naviColumn
            spacing: 10
            property int foldHeight: main.height / 20
            property int unFoldHeight: main.height / 10

            Pane {
                id: c_all
                width: navi.width - 22
                height: navima.containsMouse ? naviColumn.unFoldHeight : naviColumn.foldHeight
                Material.background: Material.Grey
                Material.elevation: 2
                Label {
                    anchors.centerIn: parent
                    visible: navima.containsMouse
                    color: "white"
                    text: "ALL"
                }

                Behavior on height {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 200
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedCathegory = "all"
                    }
                    onPressed: {
                        c_all.Material.elevation = 0

                    }
                    onReleased: {

                        c_all.Material.elevation = 2
                    }
                }
            }

            Pane {
                id: c_purple
                width: navi.width - 22
                height: navima.containsMouse ? naviColumn.unFoldHeight : naviColumn.foldHeight
                Material.background: Material.Purple
                Material.elevation: 2
                Label {
                    anchors.centerIn: parent
                    visible: navima.containsMouse
                    color: "white"
                    text: "PURPLE"
                }
                Behavior on height {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 200
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedCathegory = "purple"
                    }
                    onPressed: {
                        c_purple.Material.elevation = 0

                    }
                    onReleased: {

                        c_purple.Material.elevation = 2
                    }
                }
            }

            Pane {
                id: c_blue
                width: navi.width - 22
                height: navima.containsMouse ? naviColumn.unFoldHeight : naviColumn.foldHeight
                Material.background: Material.Blue
                Material.elevation: 2
                Label {
                    anchors.centerIn: parent
                    visible: navima.containsMouse
                    color: "white"
                    text: "BLUE"
                }
                Behavior on height {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 200
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedCathegory = "blue"
                    }
                    onPressed: {
                        c_blue.Material.elevation = 0

                    }
                    onReleased: {

                        c_blue.Material.elevation = 2
                    }
                }
            }
        }

    }

    onSelectedCathegoryChanged: {
        lm.clear()
        fill(selectedCathegory)
    }

    function fill(type) {

        if (type === "blue") {
            for (var i = 0; i < 9; i++) {
                lm.append({
                              "name": "Inkscape",
                              "version": "0.92.1-1",
                              "status": "installed",
                              "cathegory": "blue"
                          })
            }
        } else if (type === "purple") {

            for (var j = 0; j < 8; j++) {
                lm.append({
                              "name": "Inkscape",
                              "version": "0.92.1-1",
                              "status": "installed",
                              "cathegory": "purple"
                          })
            }
        } else {
            for (var i = 0; i < 9; i++) {
                lm.append({
                              "name": "Inkscape",
                              "version": "0.92.1-1",
                              "status": "installed",
                              "cathegory": "blue"
                          })
            }
            for (var j = 0; j < 8; j++) {
                lm.append({
                              "name": "Inkscape",
                              "version": "0.92.1-1",
                              "status": "installed",
                              "cathegory": "purple"
                          })
            }
        }

    }



    ListModel {
        id: lm
        Component.onCompleted:  {
            fill();


        }
    }

    GridView {
        id: gv
        clip: true
        cellWidth: gv.width / 5
        cellHeight: gv.cellWidth
        visible: true
        interactive: count > 15 ? true : false
        width: main.width * 19 / 22
        height: main.height * 13 / 15
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: main.width / 28
        }
        model: lm

        add: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 ; easing.type: Easing.OutExpo}
            }

        delegate:
            Pane {
            id: p
            z: grown ? 5 : 0
            visible: selectedCathegory === cathegory || selectedCathegory === "all" ? 1 : 0
            Material.elevation: 5
            width: grown ? gv.width - 10 : 220
            height: grown ? gv.height - 10 : 220

            property bool grown: false
            property int previousX
            property int previousY

            Component.onCompleted: {
                if(cathegory === "purple") {
                    Material.background = Material.Purple
                } else if(cathegory === "blue") {
                    Material.background = Material.Blue
                }
            }

            Behavior on width {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }

            Behavior on height {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }

            Behavior on x {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }

            Behavior on y {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }



            MouseArea {
                id: ma2
                anchors.fill: parent
                onClicked: {

                    p.grown = !p.grown
                    p.Material.elevation = 5

                    if (p.grown) {
                        p.previousX = p.x
                        p.previousY = p.y
                        p.x = 0
                        p.y = 0
                    } else {
                        p.x = p.previousX
                        p.y = p.previousY
                    }

                }
                onPressed: {
                    if(ma2.containsMouse) {
                        p.Material.elevation = 0
                    }
                }
                onReleased: {

                    p.Material.elevation = 5
                }
            }

            Label {
                Material.foreground: "#000000"
                anchors.centerIn: parent
                text: name + " " + version + " " + status
            }
        }
    }


}
//

