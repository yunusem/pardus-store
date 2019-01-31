import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id:root
    color: "transparent"
    property string current: "home"
    property string myChoice: ""
    property int animationSpeed: 200

    property real cellWidth: 308
    property real cellHeight: 150

    property double epaRating: 0.0
    property int epaDownloadCount: 0
    property string epaName: ""
    property string epaPrettyName: ""
    property string epaCategory: ""
    property string epaExec: ""
    property string epaVersion: ""
    property string epaDownloadSize: ""
    property bool epaInstalled: false
    property bool epaNonfree: false

    property double mdaRating: 0.0
    property int mdaDownloadCount: 0
    property string mdaName: ""
    property string mdaPrettyName: ""
    property string mdaCategory: ""
    property string mdaExec: ""
    property string mdaVersion: ""
    property string mdaDownloadSize: ""
    property bool mdaInstalled: false
    property bool mdaNonfree: false

    property double mraRating: 0.0
    property int mraDownloadCount: 0
    property string mraName: ""
    property string mraPrettyName: ""
    property string mraCategory: ""
    property string mraExec: ""
    property string mraVersion: ""
    property string mraDownloadSize: ""
    property bool mraInstalled: false
    property bool mraNonfree: false

    property bool form: true
    property string title: ""
    property string question: ""
    property variant surveyList : []
    property variant surveyCounts: []
    property int timestamp: 0
    property bool pending: false

    property string formApp: ""
    property string formReason: ""
    property string formWebsite: ""
    property string formMail: ""
    property string formExplanation: ""

    property int days: 0
    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property bool surveyFinished: false

    signal joined()
    signal countsChanged()

    function fillSurveyList(f, t, q, sl, ts, p) {
        form = f
        title = t
        question = q
        timestamp = ts
        pending = p
        surveyFinished = form
        surveyList = []
        surveyCounts = []
        for(var i =0; i < sl.length; i++) {
            surveyList.push(sl[i].split(" ")[0].toString())
            surveyCounts.push(sl[i].split(" ")[1])
        }

        if(surveyRepeater.model) {
            surveyRepeater.model = surveyList
        }
        countsChanged()
        surveyFlickableObject.contentHeight = (surveyText.height + 50 * surveyList.length)

        if(form) {
            countdownTimer.stop()
        } else {
            if(!countdownTimer.running && !surveyFinished) {
                countdownTimer.start()
            }
        }
    }

    function homeDetailsSlot(en, epn, ecat, ex, eins, ec, er, ev, es, enf,
                             dn, dpn, dcat, dx, dins, dc, dr, dv, ds, dnf,
                             rn, rpn, rcat, rx, rins, rc, rr, rv, rs, rnf) {
        epaName = en
        epaPrettyName = epn
        epaDownloadCount = ec
        epaRating = er
        epaCategory = ecat
        epaExec = ex
        epaVersion = ev
        epaDownloadSize = es
        epaInstalled = eins
        epaNonfree = enf

        mdaName = dn
        mdaPrettyName = dpn
        mdaDownloadCount = dc
        mdaRating = dr
        mdaCategory = dcat
        mdaExec = dx
        mdaVersion = dv
        mdaDownloadSize = ds
        mdaInstalled = dins
        mdaNonfree = dnf

        mraName = rn
        mraPrettyName = rpn
        mraDownloadCount = rc
        mraRating = rr
        mraCategory = rcat
        mraExec = rx
        mraVersion = rv
        mraDownloadSize = rs
        mraInstalled = rins
        mraNonfree = rnf
    }

    function choiceChanged(){
        myChoice = helper.surveychoice
    }

    function updateCountdown() {
        var target = new Date()
        var now = new Date()

        target.setTime(timestamp * 1000)
        var totalMilliSeconds = target.getTime() - now.getTime()

        if (totalMilliSeconds < 0) {
            surveyFinished = true
            days = 0
            hours = 0
            minutes = 0
            seconds = 0
            return
        }

        var totalSeconds = parseInt(totalMilliSeconds / 1000)
        seconds = totalSeconds % 60

        var totalMinutes = parseInt(totalSeconds / 60)
        minutes = totalMinutes % 60

        var totalHours = parseInt(totalMinutes / 60)
        hours = totalHours % 24

        var totalDays = parseInt(totalHours / 24)
        days = totalDays
    }

    Timer {
        id: countdownTimer
        repeat: true
        interval: 1000
        running: true
        triggeredOnStart: true
        onTriggered: {
            updateCountdown()
        }
    }

    onJoined: {
        helper.surveyCheck()
    }

    Component.onCompleted: {
        surveyMyChoiceChanged.connect(choiceChanged)
        gotSurveyList.connect(fillSurveyList)
        surveyJoined.connect(joined)
        homeDetailsReceived.connect(homeDetailsSlot)
    }

    Pane {
        id: banner
        width: parent.width - 96.375
        height: 375 * width / 1800
        Material.elevation: 5
        anchors {
            top: parent.top
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }

        ProgressBar {
            from: 0.0
            to: 1.0
            value: bannerImage.progress
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

        Image {
            id: bannerImage
            width: parent.width + 24
            height: parent.height + 24
            source: helper.getMainUrl() + "/files/screenshots/banner.png"
            anchors {
                centerIn: parent
            }
            layer.enabled: true
            layer.smooth: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: bannerImage.width
                    height: bannerImage.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: bannerImage.width
                        height: bannerImage.height
                        radius: 2
                    }

                }
            }
        }



        BusyIndicator {
            id: bannerBusy
            anchors.centerIn: parent
            running: bannerImage.progress < 1.0
        }

        Label {
            id: bannerText
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: font.pointSize
            }
            smooth: true
            text: qsTr("welcome")

            Material.foreground: "#E4E4E4"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            font.pointSize: banner.width / 30
            font.letterSpacing: 3
            font.family: pardusFont.name
        }
    }

    Item {
        id: suggester
        anchors {
            top: banner.bottom
            topMargin: 12
            left: banner.left
        }

        Pane {
            id: editorsApp
            Material.elevation: editorsAppMa.containsMouse ? 10 : 5
            Material.background: backgroundColor
            height: (root.height - banner.height - 60) / 3
            width: height * 2.45
            anchors {
                top: parent.top
                //topMargin: 12
                left: parent.left
            }

            MouseArea {
                id: editorsAppMa
                hoverEnabled: true
                anchors.centerIn: parent
                width: parent.width + 24
                height: parent.height + 24

                onClicked: {
                    if(epaPrettyName !== "") {
                        forceActiveFocus()
                        selectedAppName = epaName
                        selectedAppPrettyName = epaPrettyName

                        selectedAppDelegatestate = epaInstalled ? "installed" : "get"
                        selectedAppExecute = epaExec
                        selectedAppInstalled = epaInstalled
                        selectedAppInqueue = checkAppIntheQueue(epaName)                        
                        stackView.push(applicationDetail, {
                                           objectName: "detail",
                                           "current": epaName,
                                           "previous": "home",
                                           "appVersion": epaVersion,
                                           "appDownloadSize" : epaDownloadSize,
                                           "appCategory" : epaCategory,
                                           "appNonfree" : epaNonfree})
                    }
                }
                onPressed: {
                    if(containsMouse) {
                        editorsApp.Material.elevation = 0
                    }
                }
                onPressAndHold: {
                    if(containsMouse) {
                        editorsApp.Material.elevation = 0
                    }
                }
                onReleased: {
                    if(containsMouse) {
                        editorsApp.Material.elevation = 10
                    } else {
                        editorsApp.Material.elevation = 5
                    }
                }
            }


            Image {
                id:editorsAppImage
                source: "image://application/" + getCorrectName(epaName)
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }

                height: parent.height
                width: height
                fillMode: Image.PreserveAspectFit
                sourceSize {
                    width: width
                    height: height
                }
            }

            Label {
                id: epaTitle
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: parent.height > 100 ? parent.height / 13 : 10
                anchors {
                    top: parent.top
                    left: editorsAppImage.right
                    right: parent.right
                }

                color: accentColor
                text: qsTr("Editor's Pick")
            }

            Column {
                spacing: 6
                anchors {
                    top: epaTitle.bottom
                    topMargin: 12
                    left: editorsAppImage.right
                    right: parent.right
                    bottom: parent.bottom
                }

                Label {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    font.capitalization: Font.Capitalize
                    text: epaPrettyName === "" ? qsTr("no valid data found") : epaPrettyName
                    color: textColor
                    fontSizeMode: Text.HorizontalFit
                    font.pointSize: editorsApp.height > 100 ? editorsApp.height / 10 : 10
                }

                Rectangle {
                    width: parent.width
                    height: epaRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/star" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: epaRatingLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            color: textColor
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            text: epaRating.toFixed(1)
                            font.pointSize: editorsApp.height > 100 ? editorsApp.height / 12 : 10
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: epaRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/download" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: epaDownloadLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: textColor
                            text: epaDownloadCount
                            font.pointSize: editorsApp.height > 100 ? editorsApp.height / 12 : 10
                        }
                    }
                }
            }
        }

        Pane {
            id: mostDownloadedApp
            Material.elevation: mostDownloadedAppMa.containsMouse ? 10 : 5
            Material.background: backgroundColor
            height: (root.height - banner.height - 60) / 3
            width: height * 2.45
            anchors {
                top: editorsApp.bottom
                topMargin: 12
                left: parent.left
            }

            MouseArea {
                id: mostDownloadedAppMa
                hoverEnabled: true
                anchors.centerIn: parent
                width: parent.width + 24
                height: parent.height + 24

                onClicked: {
                    if(mdaPrettyName !== "") {
                        forceActiveFocus()
                        selectedAppName = mdaName
                        selectedAppPrettyName = mdaPrettyName

                        selectedAppDelegatestate = mdaInstalled ? "installed" : "get"
                        selectedAppExecute = mdaExec
                        selectedAppInstalled = mdaInstalled
                        selectedAppInqueue = checkAppIntheQueue(mdaName)
                        stackView.push(applicationDetail, {
                                           objectName: "detail",
                                           "current": mdaName,
                                           "previous": "home",
                                           "appVersion": mdaVersion,
                                           "appDownloadSize" : mdaDownloadSize,
                                           "appCategory" : mdaCategory,
                                           "appNonfree" : mdaNonfree})
                    }
                }
                onPressed: {
                    if(containsMouse) {
                        mostDownloadedApp.Material.elevation = 0
                    }
                }
                onPressAndHold: {
                    if(containsMouse) {
                        mostDownloadedApp.Material.elevation = 0
                    }
                }
                onReleased: {
                    if(containsMouse) {
                        mostDownloadedApp.Material.elevation = 10
                    } else {
                        mostDownloadedApp.Material.elevation = 5
                    }
                }
            }


            Image {
                id:mostDownloadedImage
                source: "image://application/" + getCorrectName(mdaName)
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }

                height: parent.height
                width: height
                fillMode: Image.PreserveAspectFit
                sourceSize {
                    width: width
                    height: height
                }
            }

            Label {
                id: mdaTitle
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: parent.height > 100 ? parent.height / 13 : 10
                anchors {
                    top: parent.top
                    left: mostDownloadedImage.right
                    right: parent.right
                }

                color: accentColor
                text: qsTr("Most Downloaded App")

            }

            Column {
                spacing: 6
                anchors {
                    top: mdaTitle.bottom
                    topMargin: 12
                    left: mostDownloadedImage.right
                    right: parent.right
                    bottom: parent.bottom
                }

                Label {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    font.capitalization: Font.Capitalize
                    text: mdaPrettyName  === "" ? qsTr("no valid data found") : mdaPrettyName
                    color: textColor
                    fontSizeMode: Text.HorizontalFit
                    font.pointSize: mostDownloadedApp.height > 100 ? mostDownloadedApp.height / 10 : 10
                }

                Rectangle {
                    width: parent.width
                    height: mdaRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/star" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: mdaRatingLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: textColor
                            text: mdaRating.toFixed(1)
                            font.pointSize: mostDownloadedApp.height > 100 ? mostDownloadedApp.height / 12 : 10
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: mdaRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/download" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: mdaDownloadLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: textColor
                            text: mdaDownloadCount
                            font.pointSize: mostDownloadedApp.height > 100 ? mostDownloadedApp.height / 12 : 10
                        }
                    }
                }
            }
        }

        Pane {
            id: mostRatedApp
            Material.elevation: mostRatedAppMa.containsMouse ? 10 : 5
            Material.background: backgroundColor
            height: (root.height - banner.height - 60) / 3
            width: height * 2.45
            anchors {
                top: mostDownloadedApp.bottom
                topMargin: 12
                left: parent.left
            }

            MouseArea {
                id: mostRatedAppMa
                hoverEnabled: true
                anchors.centerIn: parent
                width: parent.width + 24
                height: parent.height + 24

                onClicked: {
                    if(mraPrettyName  !== "") {
                        forceActiveFocus()
                        selectedAppName = mraName
                        selectedAppPrettyName = mraPrettyName

                        selectedAppDelegatestate = mraInstalled ? "installed" : "get"
                        selectedAppExecute = mraExec
                        selectedAppInstalled = mraInstalled
                        selectedAppInqueue = checkAppIntheQueue(mraName)
                        stackView.push(applicationDetail, {
                                           objectName: "detail",
                                           "current": mraName,
                                           "previous": "home",
                                           "appVersion": mraVersion,
                                           "appDownloadSize" : mraDownloadSize,
                                           "appCategory" : mraCategory,
                                           "appNonfree" : mraNonfree})
                    }
                }
                onPressed: {
                    if(containsMouse) {
                        mostRatedApp.Material.elevation = 0
                    }
                }
                onPressAndHold: {
                    if(containsMouse) {
                        mostRatedApp.Material.elevation = 0
                    }
                }
                onReleased: {
                    if(containsMouse) {
                        mostRatedApp.Material.elevation = 10
                    } else {
                        mostRatedApp.Material.elevation = 5
                    }
                }
            }


            Image {
                id:mostRatedAppImage
                source: "image://application/" + getCorrectName(mraName)
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }

                height: parent.height
                width: height
                fillMode: Image.PreserveAspectFit
                sourceSize {
                    width: width
                    height: height
                }
            }

            Label {
                id: mraTitle
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: parent.height > 100 ? parent.height / 13 : 10
                anchors {
                    top: parent.top
                    left: mostRatedAppImage.right
                    right: parent.right
                }

                color: accentColor
                text: qsTr("Most Rated App")

            }

            Column {
                spacing: 6
                anchors {
                    top: mraTitle.bottom
                    topMargin: 12
                    left: mostRatedAppImage.right
                    right: parent.right
                    bottom: parent.bottom
                }

                Label {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    font.capitalization: Font.Capitalize
                    text: mraPrettyName  === "" ? qsTr("no valid data found") : mraPrettyName
                    font.pointSize: mostRatedApp.height > 100 ? mostRatedApp.height / 10 : 10
                    fontSizeMode: Text.HorizontalFit
                    color: textColor
                }

                Rectangle {
                    width: parent.width
                    height: mraRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/star" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: mraRatingLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: textColor
                            text: mraRating.toFixed(1)
                            font.pointSize: mostRatedApp.height > 100 ? mostRatedApp.height / 12 : 10
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: mraRatingLabel.contentHeight + 6
                    color: "transparent"
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Image {
                            height: parent.height - 6
                            width: height
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            source: "qrc:/images/download" + (dark ? ".svg" : "-dark.svg")
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        Label {
                            id: mraDownloadLabel
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.capitalization: Font.Capitalize
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: textColor
                            text: mraDownloadCount
                            font.pointSize: mostRatedApp.height > 100 ? mostRatedApp.height / 12 : 10
                        }
                    }
                }
            }
        }
    }

    Pane {
        id: survey
        height: parent.height - banner.height - 36
        width: banner.width > 900 ? 500 : 289.927
        Material.elevation: 3
        Material.background: backgroundColor
        anchors {
            top: banner.bottom
            topMargin: 12
            right: banner.right
        }

        StackView {
            id: surveyStackView
            anchors.fill: parent
            clip: true
            initialItem: Item {
                Label {
                    id: surveyHText
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: title
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    color: textColor
                    font.bold: true
                }

                Flickable {
                    id: surveyFlickableObject
                    width: parent.width
                    height: parent.height - surveyHText.height - 12 - surveyFormBtn.height
                    contentHeight: surveyText.contentHeight + 50 * surveyList.length
                    anchors {
                        top: surveyHText.bottom
                        topMargin: 12
                    }

                    flickableDirection: Flickable.AutoFlickIfNeeded
                    clip: true

                    Label {
                        id: surveyText
                        enabled: false
                        width: parent.width - 20
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        Material.theme: dark ? Material.Dark : Material.Light
                        text: question
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    ButtonGroup {
                        id: surveyButtonGroup
                    }

                    Column {
                        id: surveyContentColumn
                        anchors {
                            top: surveyText.bottom
                            topMargin: 12
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        Repeater {
                            id: surveyRepeater
                            model: surveyList
                            Row {
                                spacing: 6
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: surveyCounts[index]
                                    color: textColor
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter

                                    function updateValue() {
                                        if(typeof(surveyCounts) != "undefined") {
                                            text = surveyCounts[index]
                                        } else {
                                            text = 0
                                        }
                                    }

                                    Component.onCompleted: {
                                        countsChanged.connect(updateValue)
                                    }
                                }

                                RadioButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.capitalization: Font.Capitalize
                                    Material.theme: dark ? Material.Dark : Material.Light
                                    Material.accent: accentColor
                                    checked: myChoice === modelData
                                    onClicked: {
                                        if(checked) {
                                            helper.surveyJoin(surveyList[index], false)
                                        }
                                    }

                                    ButtonGroup.group: surveyButtonGroup
                                }

                                Image {
                                    id: surveyRadioIcon
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: parent.height
                                    width: height
                                    source: "image://application/" + getCorrectName(modelData)
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    visible: form
                                    //verticalAlignment: Image.AlignVCenter
                                    //fillMode: Image.PreserveAspectFit
                                    //smooth: true
                                }

                                Label {
                                    id: surveyRadioLabel
                                    anchors.verticalCenter: parent.verticalCenter
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.capitalization: Font.Capitalize
                                    font.pointSize: 13
                                    Material.foreground: textColor
                                    text: modelData
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: form ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        enabled: form
                                        onClicked: {
                                            if(form) {
                                                surveyStackView.push(surveyDetail,{
                                                                         objectName: "surveydetail",
                                                                         "surveySelectedApp": modelData})
                                            }
                                        }

                                        onHoveredChanged: {
                                            if(containsMouse && form) {
                                                surveyRadioLabel.font.underline = true
                                            } else {
                                                surveyRadioLabel.font.underline = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }

                Button {
                    id: surveyFormBtn
                    visible: !pending && form
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    width: surveyFormBtnLabel.width + 24
                    Material.theme: dark ? Material.Dark : Material.Light
                    Material.background: primaryColor

                    Label {
                        id: surveyFormBtnLabel
                        anchors.centerIn: parent
                        Material.foreground: "#e4e4e4"
                        text: qsTr("create option")
                        fontSizeMode: Text.HorizontalFit
                        font.capitalization: Font.Capitalize
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    onClicked: {
                        formPane.opacity = 1.0
                    }
                }

                Label {
                    id: countdownLabel
                    width: parent.width
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    Material.theme: dark ? Material.Dark : Material.Light
                    color: accentColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.HorizontalFit
                    font.pointSize: 10
                    text: countdownToString() + "\n" + qsTr("after survey will be ended")
                    visible: !surveyFinished

                    function countdownToString() {
                        var d = ""
                        var h = ""
                        var m = ""
                        var s = ""

                        if(!(days === 0)) {
                            d = days + " " + qsTr("days") + " "
                        }
                        if(!(hours === 0)) {
                            h = hours + " " + qsTr("hours") + " "
                        }
                        if(!(minutes === 0)) {
                            m = minutes + " " + qsTr("minutes") + " "
                        }
                        if(!(seconds === 0)) {
                            s = seconds + " " + qsTr("seconds")
                        }
                        return d + h + m + s
                    }
                }

            }

            pushEnter: Transition {
                enabled: animate
                XAnimator {
                    from: (surveyStackView.mirrored ? -1 : 1) * surveyStackView.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                enabled: animate
                XAnimator {
                    from: 0
                    to: (surveyStackView.mirrored ? -1 : 1) * - surveyStackView.width
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            popEnter: Transition {
                enabled: animate
                XAnimator {
                    from: (surveyStackView.mirrored ? -1 : 1) * - surveyStackView.width
                    to: 0
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                enabled: animate
                XAnimator {
                    from: 0
                    to: (surveyStackView.mirrored ? -1 : 1) * surveyStackView.width
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Pane {
        id: formPane
        visible: opacity > 0.1
        width : parent.width - 90
        height: parent.height - 24
        z: parent.z + 50
        anchors.centerIn: parent
        Material.elevation: 15
        Material.background: backgroundColor
        opacity: 0.0

        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 300
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
        }

        Label {
            id: formTitleLabel
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 15
            font.bold: true
            color: textColor
            text: qsTr("Application Request From for Survey")
        }

        Flickable {

            anchors {
                top: formTitleLabel.bottom
                topMargin: 24
                bottom: parent.bottom
            }
            clip: true
            width: parent.width
            contentHeight: nameInputContainer.height +
                           reasonInputContainer.height +
                           websiteInputContainer.height +
                           mailInputContainer.height +
                           expInputContainer.height + 4 * 18 + 2
            flickableDirection: Flickable.AutoFlickIfNeeded

            onContentHeightChanged: {
                if(contentHeight > height) {
                    contentY = contentHeight - height
                }
            }

            ScrollBar.vertical: ScrollBar {
                Material.theme: dark ? Material.Dark : Material.Light
                Material.accent: accentColor
                hoverEnabled: true
                active: hovered || pressed
                anchors.left: parent.left
                anchors.leftMargin: parent.width - 24
                anchors.right: parent.right
                anchors.rightMargin: -24
                anchors.bottom: parent.bottom
            }

            Column {
                id: contentColumn
                anchors.fill: parent
                spacing: 18
                Rectangle {
                    id: nameInputContainer
                    width: parent.width
                    height: Math.max(expAppName.contentHeight,titleAppNameContainer.height)
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 12
                        Label {
                            id: expAppName
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            color: secondaryTextColor
                            width: parent.width / 3
                            wrapMode: Label.WordWrap
                            text: qsTr("This property is going to be used for differentiate the options of the survey. Use \"-\" for separations between words instead of \" \" (space) because single line words will be accepted")
                        }


                        Column {
                            id: titleAppNameContainer
                            spacing: 12
                            width: parent.width / 2
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: textColor
                                font.pointSize: 12
                                font.bold: true
                                text: qsTr("Application Name")
                            }
                            TextField {
                                id: tfAppName
                                font.pointSize: 11
                                padding: 6
                                selectByMouse: true
                                color: textColor
                                Material.theme: dark ? Material.Dark : Material.Light
                                Material.accent: accentColor
                                verticalAlignment: Text.AlignVCenter
                                placeholderText: qsTr("e.g.:") + " " + "pardus-store"
                                background:  Rectangle {
                                    implicitWidth: 200
                                    height: 36
                                    color: "transparent"
                                    radius: 2
                                    border.color: parent.activeFocus ? accentColor : oppsiteBackgroundColor
                                }

                                onTextChanged: {
                                    formApp = text.toLowerCase().trim()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: reasonInputContainer
                    width: parent.width
                    height: Math.max(expReason.contentHeight,titleReasonContainer.height)
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 12
                        Label {
                            id: expReason
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            color: secondaryTextColor
                            width: parent.width / 3
                            wrapMode: Label.WordWrap
                            text: qsTr("Breafly describe why do we need this application in one sentence.")
                        }

                        Column {
                            id: titleReasonContainer
                            spacing: 12
                            width: parent.width / 2
                            Label {

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: textColor
                                font.pointSize: 12
                                font.bold: true
                                text: qsTr("Reason")
                            }

                            TextField {
                                id: tfReason
                                font.pointSize: 11
                                padding: 6
                                selectByMouse: true
                                color: textColor
                                Material.theme: dark ? Material.Dark : Material.Light
                                Material.accent: accentColor
                                verticalAlignment: Text.AlignVCenter
                                placeholderText: qsTr("e.g.:") + " " + qsTr("This application going to be usefull for highschools.")
                                background:  Rectangle {
                                    implicitWidth: 440
                                    height: 36
                                    color: "transparent"
                                    radius: 2
                                    border.color: parent.activeFocus ? accentColor : oppsiteBackgroundColor
                                }
                                onTextChanged: {
                                    formReason = text.trim()
                                }
                            }

                        }
                    }
                }

                Rectangle {
                    id: websiteInputContainer
                    width: parent.width
                    height: Math.max(expWebsite.contentHeight,titleWebsiteContainer.height)
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 12
                        Label {
                            id: expWebsite
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            color: secondaryTextColor
                            width: parent.width / 3
                            wrapMode: Label.WordWrap
                            text: qsTr("A working website that we can gather information from.")
                        }

                        Column {
                            id: titleWebsiteContainer
                            spacing: 12
                            width: parent.width / 2
                            Label {

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: textColor
                                font.pointSize: 12
                                font.bold: true
                                text: qsTr("Website")
                            }

                            TextField {
                                id: tfWebsite
                                font.pointSize: 11
                                padding: 6
                                selectByMouse: true
                                Material.theme: dark ? Material.Dark : Material.Light
                                Material.accent: accentColor
                                color: textColor
                                verticalAlignment: Text.AlignVCenter
                                placeholderText: qsTr("e.g.:") + " " + "https://www.google.com/search?q=pardus-store"
                                background:  Rectangle {
                                    implicitWidth: 400
                                    height: 36
                                    color: "transparent"
                                    radius: 2
                                    border.color: parent.activeFocus ? accentColor : oppsiteBackgroundColor
                                }
                                onTextChanged: {
                                    formWebsite = text.trim()
                                }
                            }

                        }
                    }
                }

                Rectangle {
                    id: mailInputContainer
                    width: parent.width
                    height: Math.max(expMail.contentHeight,titleMailContainer.height)
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 12
                        Label {
                            id: expMail
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            color: secondaryTextColor
                            width: parent.width / 3
                            wrapMode: Label.WordWrap
                            text: qsTr("We are going to use your e-mail address for communication. Dummy inputs will be banned automatically.")
                        }

                        Column {
                            id: titleMailContainer
                            spacing: 12
                            width: parent.width / 2
                            Label {

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: textColor
                                font.pointSize: 12
                                font.bold: true
                                text: qsTr("E-mail")
                            }

                            TextField {
                                id: tfMail
                                font.pointSize: 11
                                padding: 6
                                selectByMouse: true
                                color: textColor
                                Material.theme: dark ? Material.Dark : Material.Light
                                Material.accent: accentColor
                                verticalAlignment: Text.AlignVCenter
                                placeholderText: qsTr("e.g.:") + " " + "hayri42turk@gmail.com"
                                background:  Rectangle {
                                    implicitWidth: 300
                                    height: 36
                                    color: "transparent"
                                    radius: 2
                                    border.color: parent.activeFocus ? accentColor : oppsiteBackgroundColor
                                }
                                onTextChanged: {
                                    formMail = text.trim()
                                }
                            }

                        }
                    }
                }

                Rectangle {
                    id: expInputContainer
                    width: parent.width
                    height: Math.max(expExp.contentHeight,titleExpContainer.height)
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 12
                        Label {
                            id: expExp
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            color: secondaryTextColor
                            width: parent.width / 3
                            wrapMode: Label.WordWrap
                            text: qsTr("This property holds detailed explanations as rich text. You can paste prepared content here.")
                        }

                        Column {
                            id: titleExpContainer
                            spacing: 12
                            width: parent.width * 2 / 3 - 12
                            Label {

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: textColor
                                font.pointSize: 12
                                font.bold: true
                                text: qsTr("Explanation")
                            }

                            TextArea {
                                id: taExp
                                font.pointSize: 11
                                padding: 6
                                selectByMouse: true
                                color: textColor
                                textFormat: Text.AutoText
                                width: titleExpContainer.width - 12
                                wrapMode: TextArea.Wrap
                                Material.theme: dark ? Material.Dark : Material.Light
                                Material.accent: accentColor
                                placeholderText: qsTr("e.g.:") + "\n"
                                                 + qsTr("Title") + "\n"
                                                 + qsTr("paragraph") + "\n...\n"
                                                 + qsTr("Another title") + "\n"
                                                 + qsTr("paragraph")
                                background:  Rectangle {
                                    width: titleExpContainer.width - 12
                                    implicitHeight: 150
                                    color: "transparent"
                                    radius: 2
                                    border.color: taExp.activeFocus ? accentColor : oppsiteBackgroundColor
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton
                                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
                                }

                                onLinkActivated: {
                                    helper.openUrl(link)
                                }

                                onTextChanged: {
                                    formExplanation = text.trim()
                                }
                            }
                        }
                    }
                }
            }
        }

        Button {
            id: formSendButton
            width: formSendButtonLabel.width + 24
            height: 44
            visible: (formApp != "" && formReason != ""
                      && formWebsite != "" && formMail != ""
                      && formExplanation != "")
            Material.theme: dark ? Material.Dark : Material.Light
            Material.background: primaryColor
            anchors {
                top: parent.top
                topMargin: -6
                right: closeBtn.left
                rightMargin: 12
            }

            Label {
                id: formSendButtonLabel
                anchors.centerIn: parent
                Material.foreground: "#e4e4e4"
                text: qsTr("send")
                fontSizeMode: Text.HorizontalFit
                font.capitalization: Font.Capitalize
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: {
                confirmFormPopup.open()
            }
        }

        Popup {
            id: confirmFormPopup
            Material.theme: dark ? Material.Dark : Material.Light
            Material.background: backgroundColor
            width: 300
            implicitHeight: 200
            x: main.width/ 2 - width / 2 - navigationBarWidth
            y: parent.height / 2 - height / 2
            modal: animate
            signal accepted
            signal rejected
            closePolicy: Popup.NoAutoClose

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.ArrowCursor
            }

            Label {
                id: contentLabel
                anchors {
                    top: parent.top
                    bottom: buttonContainer.top
                    bottomMargin: 12
                }
                color: textColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
                text: qsTr("The content that you have filled, will be send to main server to be exemined. Any inappropriate content assumed as ban couse. Do you want to proceed ?")

            }

            Row {
                id: buttonContainer
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                Button {
                    id: acceptButton
                    text: qsTr("yes")
                    Material.background: backgroundColor
                    Material.foreground: textColor
                    onClicked: confirmFormPopup.accepted()
                }
                Button {
                    id: rejectButton
                    text: qsTr("no")
                    Material.background: backgroundColor
                    Material.foreground: textColor
                    onClicked: confirmFormPopup.rejected()
                }
            }

            onAccepted: {
                helper.surveyJoin(formApp,true,formReason, formWebsite, formMail, formExplanation)
                formPane.opacity = 0.0
                formApp = ""
                formReason = ""
                formWebsite = ""
                formMail = ""
                formExplanation = ""
                confirmFormPopup.close()
            }
            onRejected: {
                confirmFormPopup.close()
            }
        }


        Pane {
            id: closeBtn
            width: 32
            height: 32
            Material.background: primaryColor
            Material.elevation: 10
            anchors {
                right: parent.right
                top: parent.top
            }

            Label {
                anchors.centerIn: parent
                text: "X"
                color: "#e4e4e4"
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                width: 32
                height: 32
                hoverEnabled: true
                anchors.centerIn: parent
                onPressed: {
                    if (containsMouse) {
                        parent.Material.elevation = 0
                    }
                }
                onReleased: {
                    parent.Material.elevation = 2
                }
                onClicked: {
                    formPane.opacity = 0.0
                }
            }
        }
    }

    Component {
        id: surveyDetail
        SurveyDetail {

        }
    }

}
