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

    property string category : navigationBar.selectedCategory

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

    Behavior on x {
        NumberAnimation {
            duration: 75
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

    NavigationBar {
        id: navigationBar

    }

    onCategoryChanged: {
        lm.clear()
        if(category == "all") {
            fill()
        } else {
            var list = helper.getApplicationsByCategory(category)
            var it = 0
            for (var i = 0; i < list.length; i++) {

                it = navigationBar.categories.indexOf(category)
                lm.append({
                              "name": list[i],
                              "version": "0.92.1-1",
                              "status": "installed",
                              "cathegory": category,
                              "color": navigationBar.categoryColors[it]
                          })
            }
        }

    }


    ListModel {
        id: lm

    }

    function fill() {
        var theList = helper.appList()
        var line = ""
        var name = ""
        var c = ""
        var it = 0
        for (var i = 0; i < theList.length; i++) {
            line = theList[i].split(" ")
            name = line[0]
            c = line[1]
            it = navigationBar.categories.indexOf(c)
            lm.append({
                          "name": name,
                          "version": "0.92.1-1",
                          "status": "installed",
                          "cathegory": c,
                          "color": navigationBar.categoryColors[it]
                      })
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

        delegate: Pane {
            id: applicationDelegateItem
            z: grown ? 5 : 0
            //Material.background: "#eeeeee"
            Material.elevation: 5
            width: grown ? gv.width - 10 : 220
            height: grown ? gv.height - 10 : 220

            property bool grown: false
            property int previousX
            property int previousY

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

            Pane {
                id:categoryBadge
                width: grown ? gv.width : 50
                height: grown ? gv.height / 5 : 50
                Material.background: color
                Material.elevation: 1
                anchors {
                    top: parent.top
                    right: parent.right

                }

                Behavior on width {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 350
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 350
                    }
                }
            }

            MouseArea {
                id: ma2
                anchors.fill: parent
                onClicked: {

                    applicationDelegateItem.grown = !applicationDelegateItem.grown
                    applicationDelegateItem.Material.elevation = 5

                    if (applicationDelegateItem.grown) {
                        applicationDelegateItem.previousX = applicationDelegateItem.x
                        applicationDelegateItem.previousY = applicationDelegateItem.y
                        applicationDelegateItem.x = 0
                        applicationDelegateItem.y = 0
                    } else {
                        applicationDelegateItem.x = applicationDelegateItem.previousX
                        applicationDelegateItem.y = applicationDelegateItem.previousY
                    }

                }
                onPressed: {
                    if(ma2.containsMouse) {
                        applicationDelegateItem.Material.elevation = 0
                    }
                }
                onReleased: {

                    applicationDelegateItem.Material.elevation = 5
                }
            }
            Column {
                anchors.centerIn: parent
                Label {
                    Material.foreground: "#000000"
                    text: name
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                }

                Label {
                    Material.foreground: "#000000"
                    text: "\n" + version + "\n" + status
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }


}
//

