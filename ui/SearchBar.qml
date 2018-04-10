import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

Pane {
    id: searchPane
    width: 200
    height: 32
    //Material.background: "#2c2c2c"
    Material.elevation: 3

    property string prelist: ""

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
        width: 28
        height: 28
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: -10
        }
        source: "qrc:/images/search.svg"
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
            if (!main.searchF) {
                openSearch()
            }
        }
    }


    Pane {
        id: btnClose
        width: 32
        height: 32
        Material.background: Material.Red
        Material.elevation: 10
        visible: main.searchF

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
                closeSearch()
            }
        }
    }


    TextField {
        id: searchField

        width: searchPane.width / 2
        height: 40

        visible: main.searchF
        opacity: searchF ? 1 : 0

        //color: "white"

        placeholderText: "Search an application"
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

            if (searchField.text === "") {
                lm.clear()
                fill()

            } else {

                var list = helper.getApplicationsByName(searchField.text)

                var test = String(list)
                if (test === searchPane.prelist){
                } else {
                    lm.clear()
                    searchPane.prelist = test
                    var line = ""
                    var it = 0
                    for (var i = 0; i < list.length; i++) {
                        line = list[i].split(" ")

                        lm.append({
                                      "name": line[0],
                                      "version": line[2],
                                      "status": line[3] === "yes" ? true: false,
                                                                    "category": line[1],

                                  })
                    }
                }



            }

        }



    }


    //    function slideSearchField() {

    //        if (searchField.text === "") {
    //            slideDownSearchField()
    //        } else {
    //            slideUpSearchField()
    //        }
    //    }


    //    function slideDownSearchField() {
    //        searchField.y = searchPane.height / 2 - searchField.height / 2
    //        searchField.width = searchPane.width / 2
    //    }

    //    function slideUpSearchField() {
    //        searchField.y = 60
    //        searchField.width = searchPane.width - 80
    //    }


    function closeSearch() {
        searchPane.width = 200
        searchPane.height = 32
        searchField.text = ""
        main.searchF = false
    }


    function openSearch(){
        searchPane.width = 500
        searchPane.height = 40
        main.searchF = true
    }

}



