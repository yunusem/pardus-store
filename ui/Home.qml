import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id:root
    color: "transparent"
    property string current: "home"
    property int animationSpeed: 200

    property string choice : helper.surveychoice
    property int selectedIndex: 0

    property real cellWidth: 308
    property real cellHeight: 150

    property double epaRating: 0.0
    property int epaDownloadCount: 0
    property string epaName: ""
    property string epaPrettyName: ""

    property double mdaRating: 0.0
    property int mdaDownloadCount: 0
    property string mdaName: ""
    property string mdaPrettyName: ""

    property double mraRating: 0.0
    property int mraDownloadCount: 0
    property string mraName: ""
    property string mraPrettyName: ""

    property bool form: true
    property string title: ""
    property string question: ""
    property variant surveyList : []
    property variant surveyCounts: []
    property int timestamp: 0
    property bool pending: false

    signal joined()
    signal updated()
    signal countsChanged()

    function fillSurveyList(f, t, q, sl, ts, p) {
        form = f
        title = t
        question = q
        timestamp = ts
        pending = p

        surveyList = []
        surveyCounts = []
        for(var i =0; i < sl.length; i++) {
            surveyList.push(sl[i].split(" ")[0].toString())
            surveyCounts.push(sl[i].split(" ")[1])
        }
        if(surveyRepeater.model) {
            if (surveyRepeater.model[0] !== surveyList[0]) {
                surveyRepeater.model = surveyList
            }
        }
        countsChanged()
    }

    function homeDetailsSlot(en, epn, ec, er, dn, dpn, dc, dr, rn, rpn, rc, rr) {
        epaName = en
        epaPrettyName = epn
        epaDownloadCount = ec
        epaRating = er

        mdaName = dn
        mdaPrettyName = dpn
        mdaDownloadCount = dc
        mdaRating = dr

        mraName = rn
        mraPrettyName = rpn
        mraDownloadCount = rc
        mraRating = rr
    }

    onJoined: {
        surveyBtn.enabled = true
    }

    onUpdated: {
        surveyBtn.enabled = true
    }

    Component.onCompleted: {
        helper.getHomeScreenDetails();
        gotSurveyList.connect(fillSurveyList)
        surveyJoined.connect(joined)
        surveyJoinUpdated.connect(updated)
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
                        selectedCategory = "all"
                        expanded = true
                        selectedMenu = "categories"
                        forceActiveFocus()
                        applicationModel.setFilterString(epaName, true)
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
                        selectedCategory = "all"
                        expanded = true
                        selectedMenu = "categories"
                        forceActiveFocus()
                        applicationModel.setFilterString(mdaName, true)
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
                        selectedCategory = "all"
                        expanded = true
                        selectedMenu = "categories"
                        forceActiveFocus()
                        applicationModel.setFilterString(mraName, true)
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

                Label {
                    id: surveyText
                    enabled: false
                    width: parent.width - 20
                    anchors {
                        top: surveyHText.bottom
                        topMargin: 10
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
                                    text = surveyCounts[index]
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
                                onCheckedChanged: {
                                    selectedIndex = index
                                }
                                ButtonGroup.group: surveyButtonGroup

                                checked: (modelData === choice)
                            }

                            Image {
                                id: surveyRadioIcon
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                width: height
                                source: "image://application/" + getCorrectName(modelData)
                                sourceSize.width: width
                                sourceSize.height: width
                                verticalAlignment: Image.AlignVCenter
                                fillMode: Image.PreserveAspectFit
                                smooth: true
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
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        surveyStackView.push(surveyDetail,{
                                                                 objectName: "surveydetail",
                                                                 "surveySelectedApp": modelData})
                                    }

                                    onHoveredChanged: {
                                        if(containsMouse) {
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

                Button {
                    id: surveyBtn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    enabled: false
                    Material.theme: dark ? Material.Dark : Material.Light
                    Material.background: primaryColor
                    width: surveyBtnLabel.width + 24
                    Label {
                        id: surveyBtnLabel
                        anchors.centerIn: parent
                        Material.foreground: "#e4e4e4"
                        text: (choice === "") ? qsTr("send") : qsTr("update")
                        fontSizeMode: Text.HorizontalFit
                        font.capitalization: Font.Capitalize
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        enabled = false
                        if(surveyBtnLabel.text === qsTr("send")) {
                            helper.surveyJoin(surveyList[selectedIndex],"join")
                        } else {
                            helper.surveyJoin(surveyList[selectedIndex],"update")
                        }
                    }
                }

                Button {
                    id: surveyFormBtn
                    visible: !pending
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: surveyBtn.top
                        bottomMargin: 12
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
            font.pointSize: 14
            font.bold: true
            color: textColor
            text: qsTr("Application Request From for Survey")
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
