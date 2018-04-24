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
    property bool hasActiveFocus: false
    property string popupText: ""
    property string popupHeaderText: qsTr("Something went wrong!")
    property variant screenshotUrls: []
    property bool isThereOnGoingProcess: false
    property bool errorOccured: false
    property bool openAppDetail: false
    property string processingApplicationStatus: ""
    property variant processQueue: []
    property string lastProcess: ""
    property string category : qsTr("home")
    property bool searchF: false
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
    property variant specialApplications: ["gnome-builder", "xfce4-terminal"]
    property alias application: app

    signal updateQueue()

    Item {
        id: app
        property string name: ""
        property string version: ""
        property bool installed: false
        property string category: ""
        property bool free: true
        property string description: ""
        property bool hasProcessing: false

        onNameChanged: {
            if(name === "") {
                swipeView.removeItem(2)
                openAppDetail = false
                version = ""
                hasProcessing = false
                installed = false
                category = ""
                free = true
                description = ""
            } else {
                swipeView.addItem(applicationDetailPage)
                openAppDetail = true
            }
        }
    }

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

    Button {
        id: backBtn
        z: 92
        height: topDock.height
        width: height * 2 / 3
        opacity: bottomDock.pageIndicator.currentIndex == 2 ? 1.0 : 0.0
        Material.background: "#fafafa"
        anchors {
            top: parent.top
            left: navigationBar.right
            leftMargin: 5

        }

        Image {
            id: backIcon
            width: parent.height - 24
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: true
            source: "qrc:/images/back.svg"
        }

        onClicked: {
            swipeView.currentIndex = 1
        }

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 300
            }
        }

    }

    Popup {
        id: queuePopup
        closePolicy: Popup.CloseOnPressOutside
        Material.background: "#2c2c2c"
        Material.elevation: 3
        width: busy.width + processOutputLabel.width
        //height: repeaterQueue.count * 20 + 24
        //visible: isThereOnGoingProcess

        z: 99
        x: parent.width / 21 + 24
        y: parent.height - queuePopup.height - bottomDock.height - 13

        Behavior on y {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 600
            }
        }

        Label {
            id: queuePopupTitle
            text: qsTr("queue")
            Material.foreground: "#ffcb08"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
        }

        Column {
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height - queuePopupTitle.height
            Repeater {
                id: repeaterQueue
                model: processQueue
                Item {
                    width: parent.width
                    height: 18
                    Text {
                        color: "white"
                        text: modelData.split(" ")[0]
                        verticalAlignment: Text.AlignVCenter
                        font.capitalization: Font.Capitalize
                    }

                    Rectangle {
                        id: cancelBtn
                        width: 16
                        height: height
                        radius: 3
                        color: "#ff0000"
                        visible: index != 0
                        anchors.right: parent.right
                        Text {
                            text: "X"
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        MouseArea {
                            id: cancelBtnMa
                            visible: true
                            anchors.fill: parent
                            onClicked: {
                                console.log("queue cancel clicked")
                            }
                        }
                    }

                }

                /*
                delegate: Item {
                    width: parent.width
                    Row {
                        spacing: 10
                        Image {
                            id: queueIcon
                            width: 16
                            height: width
                            smooth: true
                            mipmap: true
                            antialiasing: true
                            source: "image://application/" + getCorrectName(modelData.split(" ")[0])
                        }

                        Label {
                            id: queueLabel
                            text: modelData.split(" ")[0]
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.capitalization: Font.Capitalize
                            Material.foreground: "#fafafa"
                        }

                        Pane {
                            id: cancelBtn
                            width: 16
                            height: height
                            Material.background: Material.Red
                            Label {
                                anchors.centerIn: parent
                                text: "X"
                                Material.foreground: "white"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                */
            }
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

        MouseArea {
            id: outputMa
            height: main.height / 15
            width: height * 6
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            hoverEnabled: true
            onContainsMouseChanged: {
                if(containsMouse && isThereOnGoingProcess) {
                    queuePopup.open()
                }
            }
        }
    }

    SearchBar {
        id: searchBar
        z: 100
        anchors {
            top: parent.top
            topMargin: searchF ? 0 : 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: main.width / 40

        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
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
            updateQueue()
            isThereOnGoingProcess = false
        }

        onProcessingFinishedWithError: {
            processQueue.shift()
            errorOccured = true
            isThereOnGoingProcess = false
            popupText = output
            processOutputLabel.opacity = 0.0
            popup.open()
        }

        onScreenshotReceived: {
            screenshotUrls = urls
        }
        onScreenshotNotFound: {
            screenshotUrls = ["none"]

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
        visible: app.name === "" ? false : true
        width: swipeView.width
        height: swipeView.height
        ApplicationDetail {

        }
    }

    NavigationBar {
        id: navigationBar
        onCurrentIndexChanged: {
            if (category !== qsTr("home")) {
                swipeView.currentIndex = 1
            } else {
                swipeView.currentIndex = 0
            }
        }

    }

    ListModel {
        id: lm

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
                if(isThereOnGoingProcess) {
                    popupHeaderText = qsTr("Warning!")
                    popupText = "Pardus " + qsTr("Store") + " " + qsTr("can not be closed while a process is ongoing.")
                    popup.open()
                } else {
                    Qt.quit()
                }
            }
        }
    }

    Popup {
        id: popup
        width: parent.width / 3
        height: parent.height / 3
        modal: true
        closePolicy: Popup.CloseOnPressOutside
        y: parent.height / 2 - popup.height / 2
        x: parent.width / 2 - popup.width / 2
        Material.background: "#2c2c2c"

        Label {
            text: popupHeaderText
            anchors.horizontalCenter: parent.horizontalCenter
            Material.foreground: "#fafafa"

            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
        }

        Label {
            text: popupText
            width: parent.width
            anchors.centerIn: parent
            Material.foreground: "#fafafa"
            fontSizeMode: Text.HorizontalFit
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: doneBtn
            anchors.fill: parent

            onClicked: {
                popup.close()
            }
        }

        onClosed: {
            popupHeaderText = qsTr("Something went wrong!")
            popupText = ""
        }
    }

    Timer {
        id: focusController
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            try {
                hasActiveFocus = main.activeFocusItem.focus
            } catch (error) {
                hasActiveFocus = false
            }
        }
    }

    function getCorrectName(appName) {
        var i = specialApplications.indexOf(appName)
        if (i != -1) {
            return appName.split("-")[1]
        }
        return appName
    }

    onSearchFChanged: {
        searchBar.searchFlag = searchF
        if(searchF) {
            category = qsTr("all")
            swipeView.currentIndex = 1
        }
    }

    onCategoryChanged: {
        navigationBar.currentIndex = categories.indexOf(category)
        applicationModel.setFilterString(category === qsTr("all") ? "" : category, false)
    }

    onUpdateQueue: {
        repeaterQueue.model = processQueue
        queuePopup.height = repeaterQueue.count * 28 + queuePopupTitle.height + 12
        if(processQueue.length == 0) {
            queuePopup.close()
        }
    }
}


