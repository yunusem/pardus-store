import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ps.helper 1.0
import ps.condition 1.0

ApplicationWindow {
    id: main
    minimumWidth: 1024
    minimumHeight: 711
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
    property string selectedCategory: "all"
    property string selectedMenu: "home"
    property string previousMenu: ""

    property variant processQueue: []
    property variant menuList: {"home": qsTr("home"), "categories": qsTr("categories"), "settings": qsTr("settings")}
    property variant specialApplications: ["gnome-builder", "xfce4-terminal"]
    property variant categories: []

    property alias processingPackageName: navigationBar.packageName
    property alias processingCondition: navigationBar.condition
    property alias processOutputLabel: navigationBar.processOutput
    property alias animate: helper.animate
    property alias updateCache: helper.update
    property alias ratio: helper.ratio

    signal anApplicationDisQueued()
    signal terminateFromDialog(variant applicationName)

    signal updateQueue()
    signal updateCacheFinished()
    signal updateStatusOfAppFromDetail(string appName)
    signal confirmationRemoval(string appName, string from)
    signal gotSurveyList(variant isf, variant t, variant q, variant cs, variant t, variant p)
    signal surveyJoined()
    signal surveyJoinUpdated()
    signal errorOccured()
    signal categoriesFilled()
    signal appDetailsReceived(variant cl, variant ch, variant ct, variant cp,
                              variant desc, variant down, variant l,
                              variant mm, variant mn, variant ss, variant sec,
                              variant w)
    signal appRatingDetailsReceived(variant avg, variant ind, variant tot, variant rs)
    signal homeDetailsReceived(variant ename, variant epname, variant edc, variant er,
                               variant dname, variant dpname, variant ddc, variant dr,
                               variant rname, variant rpname, variant rdc, variant rr)

    signal surveyDetailsReceived(variant cnt, variant reas, variant ws, variant exp)

    property bool selectedAppInstalled
    property bool selectedAppInqueue
    property string selectedAppName
    property string selectedAppPrettyName
    property string selectedAppDelegatestate: "get"
    property string selectedAppExecute
    property string disqueuedAppName

    property alias dark: helper.usedark
    property string backgroundColor: dark ? "#2B2B2B" : "#F0F0F0"
    property string oppsiteBackgroundColor: "#6B6B6B"
    property string shadedBackgroundColor: dark ? "#17E4E4E4" : "#172B2B2B"
    property string primaryColor: "#464646"
    property string secondaryColor: "#686868"
    property string accentColor: dark ? "#FFCB08" : "#F4B43F"
    property string textColor: dark ? "#E4E4E4" : "#DD2B2B2B"
    property string secondaryTextColor: dark ? "#A9A9A9" : "#686868"
    property string oppositeTextColor: "#2B2B2B"
    property string seperatorColor: dark ? "#21ffffff" : "#21000000"

    Rectangle {
        id: mainBackground
        anchors {
            left: navigationBar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        color: backgroundColor
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
                var cond = Condition.Idle
                if (duty === "true") {
                    cond = Condition.Removed //qsTr("removed")
                } else {
                    cond = Condition.Installed //qsTr("installed")
                }
                processingPackageName = appName
                processingCondition = cond
                lastProcess = processQueue.shift()
                updateQueue()
                isThereOnGoingProcess = false
                appName = getCorrectName(appName)
                systemNotify(appName,
                             qsTr("Package process is complete"),
                             (appName.charAt(0).toUpperCase() + appName.slice(1)) +
                             " " + getConditionString(cond) + " (Pardus " + qsTr("Store") + ")")
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
                processingCondition = Condition.Idle
            }
        }

        onProcessingStatus: {
            if(condition === "pmstatus") {
                if(processingCondition === Condition.Downloading) {
                    processingCondition =  Condition.Installing //qsTr("Installing")
                }

            } else if (condition === "dlstatus") {
                processingCondition = Condition.Downloading
            }
            processingPercent = percent
        }

        onDetailsReceived: {
            appDetailsReceived(changeloglatest, changeloghistory, timestamp, copyright, description,
                               download, license, mmail, mname, screenshots, section, website)
        }

        onRatingDetailReceived: {
            appRatingDetailsReceived(average, individual, total, rates)
        }

        onHomeReceived: {
            homeDetailsReceived(ename, epname, ecount, erating,
                                dname, dpname, dcount, drating,
                                rname, rpname, rcount, rrating)
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
            gotSurveyList(isform,title,question,choices,timestamp,pending)
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

        onSurveyDetailReceived: {
            surveyDetailsReceived(count, reason, website, explanation)
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

        onCategorylistChanged: {
            categories.push("all")
            for(var i = 0; i < categorylist.length; i++){
                categories.push(categorylist[i])
            }
            categoriesFilled()
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
        visible: splashScreen.opacity < 0.9
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
                    processingCondition = Condition.Removing //qsTr("Removing")
                    helper.remove(appName)
                } else {
                    processingCondition = Condition.Downloading //qsTr("Downloading")
                    helper.install(appName)
                }
                updateQueue()
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

    function getConditionString(con) {
        switch (con) {
        case Condition.Installed: return qsTr("Installed")
        case Condition.Removed: return qsTr("Removed")
        case Condition.Downloading: return qsTr("Downloading")
        case Condition.Installing: return qsTr("Installing")
        case Condition.Removing: return qsTr("Removing")
        default: return ""
        }
    }

    function getConditionColor(con) {
        switch (con) {
        case Condition.Downloading: return "#03A9F4"
        case Condition.Installing: return "#4CAF50"
        case Condition.Removing: return "#F44336"
        default: return accentColor
        }
    }

    function disQueue(name) {
        for(var i = 0; i < processQueue.length; i++) {
            if(processQueue[i].split(" ")[0] === name) {
                processQueue.splice(i, 1).toString()
                disqueuedAppName = name
                anApplicationDisQueued()
            }
        }
        updateQueue()
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
        var m = selectedMenu
        var c = selectedCategory
        var current = stackView.currentItem.current
        var name = stackView.currentItem.objectName

        if(m !== "categories") {
            if(applicationModel.getFilterString() !== "") {
                applicationModel.setFilterString(selectedCategory === "all" ? "" : selectedCategory, false)
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
        applicationModel.setFilterString(selectedCategory === "all" ? "" : selectedCategory, false)
        if(stackView.currentItem.previous && stackView.currentItem.objectName === "detail") {
            stackView.pop()
        }
    }

    onUpdateQueue: {
        queueDialog.repeater.model = processQueue
        queueDialog.height = queueDialog.repeater.count * 34 + queueDialog.title.height + 26
        if(processQueue.length === 0) {
            queueDialog.close()
        }
    }

    onUpdateCacheFinished: {
        splashScreen.label.text = qsTr("Fetching application list.")
        helper.getAppList()
    }
}
