import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id:root
    color: "transparent"
    property string current: "home"
    property int animationSpeed: 200
    property variant surveyList : []
    property variant surveyCounts: []
    property string surveySelectedApp: ""
    property string choice : helper.choice
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

    signal joined()
    signal updated()
    signal countsChanged()

    function fillSurveyList(sl) {
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
        width: parent.width - 96
        height: bannerImage.sourceSize.height * width / bannerImage.sourceSize.width
        Material.elevation: 5
        anchors {
            top: parent.top
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
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
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            running: !bannerImage.progress
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

    //    Item {
    //        id: middle
    //        anchors {
    //            left: suggester.right
    //            right: survey.left
    //            top: survey.top
    //            bottom: survey.bottom
    //            margins: 6
    //        }

    //        Image {
    //            id: middleBackgroundIcon
    //            source: "../images/icon.svg"
    //            width: parent.width * 2 / 3
    //            height: width
    //            fillMode: Image.PreserveAspectFit
    //            anchors.centerIn: parent
    //            opacity: 0.04
    //        }

    //        Column {
    //            anchors.centerIn: parent
    //            spacing: 24

    //            Label {
    //                text: qsTr("Source Code") + " : " +"<a href='https://github.com/yunusem/pardus-store'>GitHub</a>"
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text: qsTr("License") + " : " +"<a href='http://ozgurlisanslar.org.tr/gpl/gpl-v3/'>GPL v3</a>"
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text:qsTr("Version") + " : " + helper.version
    //            }

    //            Label {
    //                font.pointSize: 12
    //                horizontalAlignment: Text.AlignHCenter
    //                verticalAlignment: Text.AlignVCenter
    //                text: qsTr("Leave comments on") + " : " +"<a href='http://forum.pardus.org.tr/t/pardus-magaza-pardus-store'>Pardus Forum</a>"
    //                onLinkActivated: Qt.openUrlExternally(link)

    //                MouseArea {
    //                    anchors.fill: parent
    //                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
    //                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    //                }
    //            }
    //        }
    //    }


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
                    //text: qsTr("application survey")
                    text: qsTr("dynamic survey")
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
                    //text: qsTr("Which application should be added to the store in next week ?")
                    text: qsTr("Upgrading") + " ..."
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
                        //model: surveyList
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
                                        surveySelectedApp = modelData
                                        helper.getAppDetails(surveySelectedApp)
                                        surveyStackView.push(surveyDetail)
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

    Item {
        id: surveyDetail
        visible: false
        property string description
        function descriptionArrived(desc) {
            description = desc
        }

        Component.onCompleted: {
            appDescriptionReceived.connect(descriptionArrived)
        }

        Button {
            id: surveyBackButton
            z: 92
            height: 54
            width: height * 2 / 3
            Material.background: primaryColor
            anchors {
                top: parent.top
                topMargin: - 6
                left: parent.left
            }

            Image {
                width: parent.height - 24
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                sourceSize.width: width
                sourceSize.height: width
                smooth: true
                source: "qrc:/images/back.svg"
            }

            onClicked: {
                surveyStackView.pop(null)
            }
        }

        Column {
            anchors {
                left: surveyBackButton.right
                right: parent.right
                rightMargin: surveyBackButton.width - 9
                top: surveyBackButton.bottom
                bottom: parent.bottom
            }

            spacing: 24

            Row {
                id: surveyDetailHeader
                spacing: 12
                height: surveyBackButton.height
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id:surveyAppIcon
                    height: parent.height + 24
                    width: height
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    verticalAlignment: Image.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                    visible: true
                    source: surveySelectedApp !== "" ? "image://application/" + getCorrectName(surveySelectedApp) : "image://application/image-missing"
                    sourceSize.width: width
                    sourceSize.height: width
                    smooth: true
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: surveySelectedApp
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    font.bold: true
                    font.pointSize:24
                }
            }

            Flickable {
                id: surveyAppDescriptionFlick
                clip: true
                width: parent.width - 6


                //anchors.horizontalCenter: parent.horizontalCenter
                height: survey.height - surveyDetailHeader.height - 96
                //contentWidth: surveyAppDescription.width
                contentHeight: surveyAppDescription.height
                ScrollBar.vertical: ScrollBar { }
                flickableDirection: Flickable.VerticalFlick
                Label {
                    id:surveyAppDescription
                    //anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 12
                    wrapMode: Text.WordWrap
                    text: surveyDetail.description
                }
            }
        }
    }
}
