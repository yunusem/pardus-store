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
    property bool searchF: false

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

                it = navigationBar.categories.indexOf(category)
                lm.append({
                              "name": line[0],
                              "version": line[1],
                              "status": line[2] === "yes" ? true: false,
                                                            "category": category,
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
        var it = 0
        for (var i = 0; i < theList.length; i++) {
            line = theList[i].split(" ")
            it = navigationBar.categories.indexOf(line[1])
            lm.append({
                          "name": line[0],
                          "version": line[2],
                          "status": line[3] === "yes" ? true: false,
                                                        "category": line[1],
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
                width: grown ? gv.width - 35 : 25
                height: grown ? gv.height / 5 : 25
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
                    applicationDelegateItem.forceActiveFocus()
                    applicationDelegateItem.focus = true

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

            Button {
                id: processButton
                width: 100
                height: 50
                Material.background: status ? Material.DeepOrange : Material.Green
                //Material.elevation: 1
                anchors {
                    bottom: parent.bottom
                    right: parent.right

                }

                Label {
                    id: processButtonLabel
                    anchors.centerIn: parent
                    //Material.foreground: "#000000"
                    text: status ? qsTr("remove") : qsTr("install")
                }
            }

            Row {
                spacing: 10
                anchors {
                    verticalCenter: parent.verticalCenter

                }
                Image {
                    width: grown ? 128 : 64
                    height: grown ? 128 : 64
                    smooth: true
                    mipmap: true
                    antialiasing: true
                    source: "image://application/" + name
                }

                Column {


                    Label {
                        //Material.foreground: "#000000"
                        text: name
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.capitalization: Font.Capitalize
                    }

                    Label {
                        visible: grown
                        //Material.foreground: "#000000"
                        text: version
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }


}
//

