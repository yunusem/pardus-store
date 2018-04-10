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
    title: "Pardus" + " " + qsTr("Store")
    flags: Qt.FramelessWindowHint
    color: "transparent"
    property bool isThereOnGoingProcess: false
    property variant processQueue: []
    property string lastProcess: ""
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

    BottomDock {
        id: bottomDock

        BusyIndicator {
            id: busy
            running: isThereOnGoingProcess
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
        }

        Image {
            id: appIconProcess
            enabled: false
            anchors.centerIn: busy
            opacity: isThereOnGoingProcess ? 1.0 : 0.0
            width: 30
            height: 30

            Behavior on opacity {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }
        }

        Label {
            id: processOutputLabel
            anchors {
                verticalCenter: parent.verticalCenter
                left: busy.right
                leftMargin: 10
            }
            opacity: 1.0
            fontSizeMode: Text.HorizontalFit
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            enabled: false
            text: ""

            onTextChanged: {
                opacity = 1.0
            }

            Behavior on opacity {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }

            Timer {
                id: outputTimer
                interval: 8000
                repeat: true
                running: true
                onTriggered: {
                    if(!isThereOnGoingProcess) {
                        processOutputLabel.opacity = 0.0
                    }
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
        onProcessingFinished: {
            var s = processQueue[0].split(" ")
            var appName = s[0]
            var duty = s[1]
            var dutyText = ""
            if (duty === "true") {
                dutyText = qsTr("removed")
            } else {
                dutyText = qsTr("installed")
            }

            processOutputLabel.text = appName + " " + qsTr("is") + " " + dutyText + "."
            lastProcess = processQueue.shift()
            isThereOnGoingProcess = false
        }
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
                lm.append({
                              "name": line[0],
                              "version": line[1],
                              "status": line[2] === "yes" ? true: false,
                              "category": category
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
            lm.append({
                          "name": line[0],
                          "version": line[2],
                          "status": line[3] === "yes" ? true: false,
                          "category": line[1]

                      })
        }
    }

    function getCorrectName(appName) {
        var i = specialApplications.indexOf(appName)
        if (i != -1) {
            return appName.split("-")[1]
        }
        return appName
    }

    Timer {
        id:queueCleaner
        interval: 210
        running: true
        repeat: true
        onTriggered: {
            if(processQueue.length > 0 && !isThereOnGoingProcess) {
                isThereOnGoingProcess = true
                var s = processQueue[0].split(" ")
                var appName = s[0]
                var duty = s[1]
                var dutyText = ""
                if (duty === "true") {
                    dutyText = qsTr("removing")
                    busy.Material.accent = Material.Red
                    helper.remove(appName)
                } else {
                    dutyText = qsTr("installing")
                    busy.Material.accent = Material.Green
                    helper.install(appName)
                }

                processOutputLabel.text = dutyText + " " + appName + " ..."
                appIconProcess.source = "image://application/" + getCorrectName(appName)

            }
        }
    }

    Pane {
        id: minimizeBtn
        width: 32
        height: 32
        z: 100
        Material.background: "#2c2c2c"
        Material.elevation: 1
        Label {
            anchors.centerIn: parent
            Material.foreground: "white"
            text: "-"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 20
        }
        anchors {
            top: parent.top
            right: exitBtn.left
            rightMargin: 2
        }
        MouseArea {
            id: minimizeBtnMa
            width: 32
            height: 32
            anchors.centerIn: parent
            onPressed: {
                if (minimizeBtnMa.containsMouse) {
                    minimizeBtn.Material.elevation = 0
                }
            }
            onReleased: {
                minimizeBtn.Material.elevation = 2
            }
            onClicked: {
                main.showMinimized()
            }
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
            font.bold: true
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

