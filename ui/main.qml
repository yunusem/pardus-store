import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import ps.helper 1.0


ApplicationWindow {
    id: main
    minimumWidth: 1366
    minimumHeight: 768
    visible: true
    title: qsTr("Pardus Store")
    flags: Qt.FramelessWindowHint

    property string category : selectedCategory
    property bool searchF: false
    property string selectedCategory: qsTr("all")
    property variant categories:
        [qsTr("all"),
        qsTr("internet"),
        qsTr("office"),
        qsTr("development"),
        qsTr("reading"),
        qsTr("graphics"),
        qsTr("game"),
        qsTr("music"),
        qsTr("system"),
        qsTr("video"),
        qsTr("chat"),
        qsTr("others")]

    property variant categoryColors:
        ["#FFCB08",
        "#9E9E9E",
        "#795548",
        "#FF5722",
        "#8BC34A",
        "#FF9800",
        "#009688",
        "#E91E63",
        "#673AB7",
        "#03A9F4",
        "#9C27B0",
        "#8BC34A"]

    Helper {
        id: helper
    }

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

    Pane {
        id: exitBtn
        width: 32
        height: 32
        Material.background: Material.Red
        Material.elevation: 2
        Label {
            anchors.centerIn: parent
            Material.foreground: "white"
            text: "X"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        anchors {
            top: parent.top
            right: parent.right
        }
        MouseArea {
            id: exitBtnMa
            width: 32
            height: 32
            anchors.centerIn: parent
            onPressed: {
                if (exitBtnMa.containsMouse) {
                    exitBtn.Material.elevation = 0
                }
            }
            onReleased: {
                exitBtn.Material.elevation = 2
            }
            onClicked: {
                Qt.quit()
            }
        }
    }


    SearchBar {
        id: searchBar
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter

        }

    }

    NavigationBar {
        id: navigationBar

    }

    ListModel {
        id: lm

    }

    onCategoryChanged: {
        lm.clear()
        if(category == "all") {
            fill()
        } else {
            var list = helper.getApplicationsByCategory(category)
            var it = 0
            var line = ""
            for (var i = 0; i < list.length; i++) {
                line = list[i].split(" ")

                it = categories.indexOf(category)
                lm.append({
                              "name": line[0],
                              "version": line[1],
                              "status": line[2] === "yes" ? true: false,
                              "category": category,
                              "color": categoryColors[it]
                          })
            }
        }

    }




    function fill() {
        var theList = helper.appList()
        var line = ""
        var it = 0
        for (var i = 0; i < theList.length; i++) {
            line = theList[i].split(" ")
            it = categories.indexOf(line[1])
            lm.append({
                          "name": line[0],
                          "version": line[2],
                          "status": line[3] === "yes" ? true: false,
                          "category": line[1],
                          "color": categoryColors[it]
                      })
        }
    }

    GridView {
        id: gv
        clip: true
        cellWidth: gv.width / 5
        cellHeight: gv.cellWidth * 3 / 5
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

        delegate: ApplicationDelegate{

        }
    }


}
//

