import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import ps.helper 1.0


ApplicationWindow {
    id: main
    minimumWidth: 1290
    minimumHeight: minimumWidth * 9 / 16
    visible: true
    title: "Pardus" + " " + qsTr("Store")
    flags: Qt.FramelessWindowHint
    color: "transparent"
    property bool hasActiveFocus: false
    property bool cacheIsUpToDate: false
    property string popupText: ""
    property string popupHeaderText: qsTr("Something went wrong!")
    property variant screenshotUrls: []
    property bool isThereOnGoingProcess: false
    property bool errorOccured: false
    property bool openAppDetail: false
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
        qsTr("others"),
        qsTr("settings")]
    property variant categoryIcons: ["home",
        "all",
        "internet",
        "office",
        "development",
        "reading",
        "graphics",
        "game",
        "music",
        "system",
        "video",
        "chat",
        "others",
        "settings"]
    property variant specialApplications: ["gnome-builder", "xfce4-terminal"]

    property alias processingPackageName: bottomDock.packageName
    property alias processingCondition: bottomDock.condition
    property alias processOutputLabel: bottomDock.processOutput
    property alias busy: bottomDock.busyIndicator

    signal updateQueue()
    signal updateCacheFinished()
    signal updateStatusOfAppFromDetail(string appName)
    signal confirmationRemoval(string appName, string from)
    signal gotSurveyList(variant sl)
    signal surveyJoined()
    signal surveyJoinUpdated()

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

    SplashScreen {
        id: splashScreen
    }

    Pane {
        id: topDock
        width: parent.width * 20 / 21
        height: parent.height / 15
        z: 89
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
        z: 92
        height: main.height / 15
        width: topDock.width
        anchors {
            top: main.top
            right: main.right
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
        opacity: bottomDock.pageIndicator.currentIndex >= 1 ? 1.0 : 0.0
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
            swipeView.currentIndex -= 1
            //applicationModel.setFilterString("", true)
        }

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 300
            }
        }

    }

    QueueDialog {
        id: queueDialog
    }

    ConfirmationDialog {
        id: confirmationDialog
    }

    InfoDialog {
        id: infoDialog
    }

    BottomDock {
        id: bottomDock
    }

    SearchBar {
        id: searchBar
    }

    Helper {
        id: helper
        onProcessingFinished: {
            if(processQueue.length !== 0) {
                var s = processQueue[0].split(" ")
                var appName = s[0]
                var duty = s[1]
                var dutyText = ""
                if (duty === "true") {
                    dutyText = qsTr("removed")
                } else {
                    dutyText = qsTr("installed")
                }
                processingPackageName = appName
                processingCondition = dutyText
                lastProcess = processQueue.shift()
                updateQueue()
                isThereOnGoingProcess = false
                systemNotify(appName,
                             qsTr("Package process is complete"),
                             (appName.charAt(0).toUpperCase() + appName.slice(1)) +
                             " " + dutyText + " (Pardus " + qsTr("Store") + ")")
            } else {
                if(!cacheIsUpToDate) {
                    updateCacheFinished()
                    cacheIsUpToDate = true
                }
            }
        }

        onProcessingFinishedWithError: {
            processQueue.shift()
            errorOccured = true
            isThereOnGoingProcess = false
            processOutputLabel.opacity = 0.0
            popupText = output
            if(output.indexOf("not get lock") !== -1) {
                popupText = qsTr("Another application is using package manager. Please wait or discard the other application and try again.")
            } else if (output.indexOf("not open lock") !== -1) {
                popupText = qsTr("Pardus Store should be run with root privileges")
            }

            infoDialog.open()
        }

        onProcessingStatus: {
            if(condition === "pmstatus") {
                if(processingCondition === qsTr("removing")) {
                    busy.colorCircle = Material.color(Material.Red)
                } else if(processingCondition === qsTr("downloading")) {
                    busy.colorCircle = Material.color(Material.Green)
                    processingCondition = qsTr("installing")
                }

            } else if (condition === "dlstatus") {
                processingCondition = qsTr("downloading")
                busy.colorCircle = Material.color(Material.Blue)
            }

            busy.value = percent
        }

        onDescriptionReceived: {
            app.description = description
        }
        onScreenshotReceived: {
            screenshotUrls = urls
            if(urls.length === 0) {
                screenshotUrls = ["none"]
            }
        }
        onScreenshotNotFound: {
            screenshotUrls = ["none"]
            if(splashScreen.visible) {
                popupText = qsTr("Check your internet connection")
                infoDialog.open()
            }
        }
        onFetchingAppListFinished: {
            splashScreen.label.text = qsTr("Gathering local details.")
        }
        onGatheringLocalDetailFinished: {
            splashScreen.label.text = qsTr("Fetching survey data.")
            surveyCheck()
        }
        onSurveyListReceived: {
            gotSurveyList(list)
            if(splashScreen.visible) {
                splashScreen.label.text = qsTr("Done.")
                splashScreen.timer.start()
                splashScreen.busy.running = false
            }
        }
        onSurveyJoinSuccess: {
            surveyJoined()
            surveyCheck()
        }
        onSurveyJoinUpdateSuccess: {
            surveyJoinUpdated()
            surveyCheck()
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
        visible: splashScreen.opacity < 0.7
        onCurrentIndexChanged: {
            if (category !== qsTr("home")) {
                swipeView.currentIndex = 1
            } else {
                swipeView.currentIndex = 0
            }
        }
    }

    Settings {
        id: settings
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
                processingPackageName = appName
                if (duty === "true") {
                    processingCondition = qsTr("removing")
                    helper.remove(appName)
                } else {
                    processingCondition = qsTr("downloading")
                    helper.install(appName)
                }

                bottomDock.processingIcon.source = "image://application/" + getCorrectName(appName)
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
                main.close()
            }
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

    onClosing: {
        if(isThereOnGoingProcess) {
            popupHeaderText = qsTr("Warning!")
            popupText = "Pardus " + qsTr("Store") + " " + qsTr("can not be closed while a process is ongoing.")
            infoDialog.open()
            close.accepted = false
        } else {
            close.accepted = true
        }
    }

    onUpdateCacheFinished: {
        splashScreen.label.text = qsTr("Fetching application list.")
        helper.getAppList()
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
        applicationModel.setFilterString(category === qsTr("all") ? "" : categoryIcons[categories.indexOf(category)], false)
        if(category === qsTr("home")) {
            searchF = false
        }
    }

    onUpdateQueue: {
        queueDialog.repeater.model = processQueue
        queueDialog.height = queueDialog.repeater.count * 34 + queueDialog.title.height + 26
        if(processQueue.length == 0) {
            queueDialog.close()
        }
    }
}
