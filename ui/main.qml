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
    color: "transparent"
    property string category : selectedCategory
    property bool searchF: false
    property string selectedApplication: ""
    property string selectedCategory: qsTr("home")
    property variant categories:
        [qsTr("home"),
        qsTr("all"),
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

    property variant specialApplications:
        ["gnome-builder",
        "xfce4-terminal"]
    Pane {
        id: mainBackground
        anchors.fill: parent
        Material.elevation: 1

    }

    Pane {
        id: topDock
        width: parent.width * 20 / 21
        height: parent.height / 15
        z: 90
        anchors {
            top: parent.top
            right: parent.right
        }

        Material.elevation: 3




    }

    MouseArea {
        id: ma
        property real cposx: 1.0
        property real cposy: 1.0
        z: 91
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
        id: bottomDock
        width: parent.width * 20 / 21
        height: parent.height / 15
        z: 90
        anchors  {
            bottom: parent.bottom
            right: parent.right
        }

        Material.elevation: 3

        PageIndicator {
            id: indicator
            interactive: true
            count: selectedApplication === "" ? 2 : 3
            currentIndex: swipeView.currentIndex
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            onCurrentIndexChanged: {
                swipeView.currentIndex = indicator.currentIndex

                if(currentIndex == 1) {
                    if(navigationBar.currentIndex == 0) {
                        navigationBar.currentIndex = 1
                        selectedCategory = qsTr("all")
                        selectedApplication = ""
                    }
                } else if (currentIndex == 0) {
                    navigationBar.currentIndex = 0
                    selectedApplication = ""
                }
            }

        }
    }

    SearchBar {
        id: searchBar
        z: 100
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: main.width / 40

        }

    }

    Helper {
        id: helper
    }

    SwipeView {
        id: swipeView
        width: main.width * 20 / 21
        height: main.height * 13 / 15
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        currentIndex: 0
        Page {
            width: swipeView.width
            height: swipeView.height
            Home {
                id: homePage
            }
        }

        Page {
            width: swipeView.width
            height: swipeView.height
            ApplicationList {
               id: applicationListPage
            }
        }



        onCurrentIndexChanged: {

        }
    }

    Page {
        id: applicationDetailPage
        visible: selectedApplication === "" ? false : true
        width: swipeView.width
        height: swipeView.height
        ApplicationDetail {

        }
    }

    onSelectedApplicationChanged: {
        if(selectedApplication === "") {
            swipeView.removeItem(2)
        } else {
            swipeView.addItem(applicationDetailPage)
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

    Pane {
        id: exitBtn
        width: 32
        height: 32
        z: 100
        Material.background: Material.Red
        Material.elevation: 1
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


}
//

