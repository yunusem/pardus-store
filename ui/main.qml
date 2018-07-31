import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ps.helper 1.0


ApplicationWindow {
    id: main
    minimumWidth: 1150
    minimumHeight: minimumWidth * 3 / 5
    visible: true
    title: "Pardus" + " " + qsTr("Store")
    //flags: Qt.FramelessWindowHint
    color: "transparent"

    property bool hasActiveFocus: false
    property bool cacheIsUpToDate: false
    property string popupText: ""
    property string popupHeaderText: qsTr("Something went wrong!")
    property variant screenshotUrls: []
    property bool isThereOnGoingProcess: false
    property bool errorOccured: false

    property variant processQueue: []
    property string lastProcess: ""

    property string previousMenu: ""
    property bool isSearching: false

    property real navigationBarWidth: 215.625
    property bool expanded: false
    property string selectedCategory: qsTr("all")
    property string selectedMenu: qsTr("home")

    property variant menus: [qsTr("home"), qsTr("categories"), qsTr("settings")]
    property variant menuIcons: ["home", "categories", "settings"]
    property variant categories: [
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
    property variant categoryIcons: [
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
        "others"]
    property variant specialApplications: ["gnome-builder", "xfce4-terminal"]

    property alias processingPackageName: navigationBar.packageName
    property alias processingCondition: navigationBar.condition
    property alias processOutputLabel: navigationBar.processOutput
    property alias busy: navigationBar.busyIndicator
    property alias animate: helper.animate
    property alias updateCache: helper.update
    property alias ratio: helper.ratio

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
        property string downloadSize: ""
        property bool installed: false
        property string category: ""
        property bool free: true
        property string description: ""
        property bool hasProcessing: false

        onNameChanged: {
            if(name === "") {
                version = ""
                downloadSize: ""
                installed = false
                category = ""
                free = true
                description = ""
            }
        }
    }


    Pane {
        id: mainBackground
        anchors.fill: parent
        Material.background: "#4C4C4C"
        Material.elevation: 1        
    }


    SplashScreen {
        id: splashScreen
    }
/*
    Pane {
        id: topDock
        width: parent.width * 13 / 16
        height: parent.height / 15
        x: parent.width * 3 / 16
        y: ma.containsMouse ? 0 : - (height + 6)
        z: 89


        //color: "transparent"
        Material.elevation: 3

        Behavior on y {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }
    }
*/
//    MouseArea {
//        id: ma
//        property real cposx: 1.0
//        property real cposy: 1.0
//        hoverEnabled: true
//        property bool presure: false
//        z: 92
//        height: splashScreen.visible ? main.height : main.height / 15
//        width: splashScreen.visible ? main.width : topDock.width + 12
//        anchors {
//            top: main.top
//            right: parent.right
//        }

//        onPressed: {
//            cposx = mouse.x
//            cposy = mouse.y
//            cursorShape = Qt.SizeAllCursor
//            presure = true
//        }

//        onPositionChanged: {
//            if(presure) {
//                var delta = Qt.point(mouse.x - cposx, mouse.y - cposy);
//                main.x += delta.x;
//                main.y += delta.y;
//                cursorShape = Qt.SizeAllCursor
//            }
//        }

//        onReleased: {
//            presure = false
//            cursorShape = Qt.ArrowCursor
//        }
//    }

//    Button {
//        id: backBtn
//        z: 92
//        height: topDock.height
//        width: height * 2 / 3
//        opacity: category !== qsTr("home") ? 1.0 : 0.0
//        Material.background: "#fafafa"
//        anchors {
//            top: parent.top
//            left: navigationBar.right
//            leftMargin: 6

//        }

//        Image {
//            id: backIcon
//            width: parent.height - 24
//            anchors.centerIn: parent
//            fillMode: Image.PreserveAspectFit
//            mipmap: true
//            smooth: true
//            source: "qrc:/images/back.svg"
//        }

//        onClicked: {
//            var c = ""
//            var name = stackView.currentItem.objectName

//            if(name === "detail") {
//                c = stackView.currentItem.previous
//                stackView.pop()
//            } else if (category === qsTr("settings")) {
//                c = stackView.currentItem.current
//            } else {
//                c = "home"
//            }
//            category = categories[(categoryIcons.indexOf(c))]
//            if(isSearching) {
//                isSearching = false
//            }
//        }

//        Behavior on opacity {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutExpo
//                duration: 300
//            }
//        }

//    }

//    BottomDock {
//        id: bottomDock
//    }

    QueueDialog {
        id: queueDialog
    }

    ConfirmationDialog {
        id: confirmationDialog
    }

    InfoDialog {
        id: infoDialog
    }
/*
    SearchBar {
        id: searchBar
    }
*/
    FontLoader {
        id: pardusFont
        name: "Pardus"
        source: "qrc:/Pardus-Regular.otf"
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
            infoDialog.settingsButtonOn = true
            if(output.indexOf("not get lock") !== -1) {
                infoDialog.settingsButtonOn = false
                popupText = qsTr("Another application is using package manager. Please wait or discard the other application and try again.")
            } else if (output.indexOf("not open lock") !== -1) {
                infoDialog.settingsButtonOn = false
                popupText = qsTr("Pardus Store should be run with root privileges")
            } else if ((output.indexOf("404  Not Found") !== -1) || (output.indexOf("is not signed") !== -1)) {
                popupText = qsTr("Pardus Store detected some broken sources for the package manager.") + "\n\n"+qsTr("Please fix it manually or use Pardus Store's settings.")
            }
            infoDialog.open()
        }
        onProcessingStatus: {
            if(condition === "pmstatus") {
                if(processingCondition === qsTr("removing")) {
                    busy.colorCircle = "#EF9A9A" //Material.color(Material.Red)
                } else if(processingCondition === qsTr("downloading")) {
                    busy.colorCircle = "#A5D6A7" //Material.color(Material.Green)
                    processingCondition = qsTr("installing")
                }

            } else if (condition === "dlstatus") {
                processingCondition = qsTr("downloading")
                busy.colorCircle = "#90CAF9" //Material.color(Material.Blue)
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

        onCorrectingFinished: {
            settings.corrected = helper.corrected
            popupHeaderText = qsTr("Informing");
            popupText = qsTr("Correcting of system package manager sources list is done. You can now restart Pardus Store.")
            infoDialog.settingsButtonOn = false
            infoDialog.open()
        }
        onCorrectingFinishedWithError: {
            settings.corrected = helper.corrected
            popupText = qsTr("Show this result to the maintainer.") + "\n\n\"" + errorString + "\""
            infoDialog.settingsButtonOn = false
            infoDialog.open()
        }
    }

    StackView {
        id: stackView
        clip: true
        width: main.width - navigationBarWidth
        height: main.height //* 14 / 15
        anchors {
            verticalCenter: parent.verticalCenter
            //bottom: parent.bottom
            right: parent.right
        }

        initialItem: Home {}

        pushEnter: Transition {
            enabled: animate
            XAnimator {
                from: (stackView.mirrored ? -1 : 1) * stackView.width
                to: 0
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        pushExit: Transition {
            enabled: animate
            XAnimator {
                from: 0
                to: (stackView.mirrored ? -1 : 1) * - stackView.width
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        popEnter: Transition {
            enabled: animate
            XAnimator {
                from: (stackView.mirrored ? -1 : 1) * - stackView.width
                to: 0
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        popExit: Transition {
            enabled: animate
            XAnimator {
                from: 0
                to: (stackView.mirrored ? -1 : 1) * stackView.width
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    NavigationBar {
        id: navigationBar
        visible: splashScreen.opacity < 0.7
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

                navigationBar.processingIcon.source = "image://application/" + getCorrectName(appName)
            }
        }
    }

//    Pane {
//        id: minimizeBtn
//        width: 32
//        height: 32
//        opacity: ma.containsMouse ? 1.0 : 0.0
//        z: 100
//        Material.background: "#2c2c2c"
//        Material.elevation: 1

//        Label {
//            anchors {
//                horizontalCenter: parent.horizontalCenter
//                bottom: parent.verticalCenter
//                bottomMargin: -6
//            }

//            Material.foreground: "white"
//            text: "_"
//            verticalAlignment: Text.AlignTop
//            horizontalAlignment: Text.AlignHCenter
//            font.bold: true
//            font.pointSize: 18
//        }

//        anchors {
//            top: parent.top
//            right: maximizeBtn.left
//            rightMargin: 2
//        }

//        MouseArea {
//            id: minimizeBtnMa
//            width: 32
//            height: 32
//            anchors.centerIn: parent
//            onPressed: {
//                if (minimizeBtnMa.containsMouse) {
//                    minimizeBtn.Material.elevation = 0
//                }
//            }
//            onReleased: {
//                minimizeBtn.Material.elevation = 2
//            }
//            onClicked: {
//                main.showMinimized()
//            }
//        }

//        Behavior on opacity {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutExpo
//                duration: 300
//            }
//        }
//    }

//    Pane {
//        id: maximizeBtn
//        width: 32
//        height: 32
//        opacity: ma.containsMouse ? 1.0 : 0.0
//        z: 100
//        Material.background: "#2c2c2c"
//        Material.elevation: 1
//        Label {
//            smooth: true
//            anchors {
//                horizontalCenter: parent.horizontalCenter
//                bottom: parent.verticalCenter
//                bottomMargin: -13
//            }
//            Material.foreground: "white"
//            text: "▫"
//            verticalAlignment: Text.AlignTop
//            horizontalAlignment: Text.AlignHCenter
//            font.pointSize: 20
//        }

//        anchors {
//            top: parent.top
//            right: exitBtn.left
//            rightMargin: 2
//        }

//        MouseArea {
//            id: maximizeBtnMa
//            width: 32
//            height: 32
//            anchors.centerIn: parent
//            onPressed: {
//                if (maximizeBtnMa.containsMouse) {
//                    maximizeBtn.Material.elevation = 0
//                }
//            }
//            onReleased: {
//                maximizeBtn.Material.elevation = 2
//            }
//            onClicked: {
//                if(main.visibility == ApplicationWindow.Maximized) {
//                    main.showNormal()
//                } else {
//                    main.showMaximized()
//                }
//            }
//        }

//        Behavior on opacity {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutExpo
//                duration: 300
//            }
//        }
//    }

//    Pane {
//        id: exitBtn
//        width: 32
//        height: 32
//        opacity: ma.containsMouse ? 1.0 : 0.0
//        z: 100
//        Material.background: Material.Red
//        Material.elevation: 1

//        Label {
//            smooth: true
//            anchors.centerIn: parent
//            Material.foreground: "white"
//            text: "X"
//            verticalAlignment: Text.AlignVCenter
//            horizontalAlignment: Text.AlignHCenter
//            font.bold: true
//            font.pointSize: 13
//        }

//        anchors {
//            top: parent.top
//            right: parent.right
//        }

//        MouseArea {
//            id: exitBtnMa
//            width: 32
//            height: 32
//            anchors.centerIn: parent
//            onPressed: {
//                if (exitBtnMa.containsMouse) {
//                    exitBtn.Material.elevation = 0
//                }
//            }
//            onReleased: {
//                exitBtn.Material.elevation = 2
//            }
//            onClicked: {
//                main.close()
//            }
//        }

//        Behavior on opacity {
//            enabled: animate
//            NumberAnimation {
//                easing.type: Easing.OutExpo
//                duration: 300
//            }
//        }
//    }

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

    Component {
        id: applicationList
        ApplicationList {

        }
    }

    Component {
        id: applicationDetail
        ApplicationDetail {

        }
    }

    function getCorrectName(appName) {
        var i = specialApplications.indexOf(appName)
        if (i != -1) {
            return appName.split("-")[1]
        }
        return appName
    }

    function getPrettyName(appName) {
        switch(appName) {
        case "skypeforlinux":
            return "skype"
        case "gnome-boxes":
            return "boxes"
        case "gnome-builder":
            return "builder"
        case "slack-desktop":
            return "slack"
        case "spotify-client":
            return "spotify"
        case "virtualbox-5.1":
            return "virtualbox"
        default:
            return appName.replace("-", " ")
        }
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

    onSelectedMenuChanged: {
        var m = menuIcons[menus.indexOf(selectedMenu)]
        var c = categoryIcons[categories.indexOf(selectedCategory)]
        var current = stackView.currentItem.current
        var name = stackView.currentItem.objectName

        if(m === "home") {
            stackView.pop(null)
        } else if (m === "categories") {
            if(name === "detail") {
                stackView.pop()
            } else if((previousMenu !== "settings") || (previousMenu === "settings" && current === "home")) {
                stackView.push(applicationList,{objectName: "list", "current": c, "previous": previousMenu})
            }
        }
        previousMenu = m
    }

    onSelectedCategoryChanged: {
        applicationModel.setFilterString(selectedCategory === qsTr("all") ? "" : categoryIcons[categories.indexOf(selectedCategory)], false)
        if(stackView.currentItem.previous && stackView.currentItem.objectName === "detail") {

            stackView.pop()
        }
    }

    onUpdateQueue: {
        queueDialog.repeater.model = processQueue
        queueDialog.height = queueDialog.repeater.count * 34 + queueDialog.title.height + 26
        if(processQueue.length == 0) {
            queueDialog.close()
        }
    }

    onUpdateCacheFinished: {
        splashScreen.label.text = qsTr("Fetching application list.")
        helper.getAppList()
    }
}
