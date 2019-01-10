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
    color: "transparent"

    property real navigationBarWidth: 215.625
    property real processingPercent: 0

    property bool hasActiveFocus: false
    property bool cacheIsUpToDate: false
    property bool isSearching: false
    property bool expanded: false
    property bool isThereOnGoingProcess: false
    property bool terminateProcessCalled: false

    property string popupText: ""
    property string popupHeaderText: qsTr("Something went wrong!")
    property string lastProcess: ""
    property string selectedCategory: qsTr("all")
    property string selectedMenu: qsTr("home")
    property string previousMenu: ""

    property variant processQueue: []
    property variant menus: [qsTr("home"), qsTr("categories"), qsTr("settings")]
    property variant menuIcons: ["home", "categories", "settings"]
    property variant specialApplications: ["gnome-builder", "xfce4-terminal"]
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

    property alias processingPackageName: navigationBar.packageName
    property alias processingCondition: navigationBar.condition
    property alias processOutputLabel: navigationBar.processOutput
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
    signal errorOccured()
    signal appDescriptionReceived(variant desc)
    signal appDetailsReceived(variant cl, variant ch, variant ct,
                              variant desc, variant down, variant l,
                              variant mm, variant mn, variant ss, variant sec,
                              variant w)
    signal appRatingDetailsReceived(variant avg, variant ind, variant tot)

    property bool selectedAppInstalled
    property bool selectedAppInqueue
    property string selectedAppName
    property string selectedAppPrettyName
    property string selectedAppDelegatestate: "get"
    property string selectedAppExecute

    Rectangle {
        id: mainBackground
        anchors.fill: parent
        color: Material.primary
    }

    SplashScreen {
        id: splashScreen
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
            isThereOnGoingProcess = false
            processOutputLabel.opacity = 0.0
            if(!terminateProcessCalled){
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
                errorOccured()
            } else {
                terminateProcessCalled = false
            }
        }

        onProcessingStatus: {
            if(condition === "pmstatus") {
                if(processingCondition === qsTr("removing")) {
                } else if(processingCondition === qsTr("downloading")) {
                    processingCondition = qsTr("installing")
                }

            } else if (condition === "dlstatus") {
                processingCondition = qsTr("downloading")
            }
            processingPercent = percent
        }

        onDetailsReceived: {
            appDetailsReceived(changeloglatest, changeloghistory, timestamp, description,
                               download, license, mmail, mname, screenshots, section, website)
        }

        onRatingDetailReceived: {
            appRatingDetailsReceived(average, individual, total)
        }

        onReplyError: {
            if(splashScreen.visible) {
                popupText = qsTr("Reason") + " : " + errorString +
                        " \n" + qsTr("Suggestion") + " : " +
                        qsTr("Check your internet connection")
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
        height: main.height
        anchors {
            verticalCenter: parent.verticalCenter
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
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(processQueue.length > 0 && !isThereOnGoingProcess) {
                var s = processQueue[0].split(" ")
                var appName = s[0]
                var duty = s[1]
                processingPackageName = appName
                isThereOnGoingProcess = true
                if (duty === "true") {
                    processingCondition = qsTr("removing")
                    helper.remove(appName)
                } else {
                    processingCondition = qsTr("downloading")
                    helper.install(appName)
                }
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

        if(m !== "categories") {
            if(applicationModel.getFilterString() !== "") {
                applicationModel.setFilterString(selectedCategory === qsTr("all") ? "" : categoryIcons[categories.indexOf(selectedCategory)], false)
            }
        }

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
