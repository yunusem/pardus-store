import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id:appDetail
    property string previous
    property string current
    property string appVersion
    property string appDownloadSize
    property string appCategory
    property bool appNonfree

    property string changelog : ""
    property string description : ""
    property string sections: ""
    property string maintainer: ""
    property string website: ""
    property string email: ""
    property string license: ""
    property double ratingAverage: 0.0
    property int rating: 0
    property int prevRating: 0
    property int ratingTotal: 0
    property int download: 0
    property bool voted: false

    property int infoCellHeight: 70
    //property int length: urls ? urls.length : 0
    property int ssindex
    property var urls

    property string textPrimaryColor: Material.foreground
    property string textSecondaryColor: "#A9A9A9"

    color: "transparent"

    function startRemoving(name, from) {
        if(name !== "" && name === selectedAppName && from === "detail") {
            updateStatusOfAppFromDetail(selectedAppName)
            processQueue.push(selectedAppName + " " + selectedAppInstalled)
        }
    }

    function errorHappened() {
        processButton.enabled = true
    }

    function appDetailsSlot(c, desc, down, l, mm, mn, ss, sec, w) {
        changelog = c
        description = desc
        download = down
        license = l
        if(l === "") {
            license = "GPLv2"
        }
        email = mm
        maintainer = mn
        if(ss.length === 0) {
            urls = ["none"]
        } else {
            urls = ss
        }
        sections = sec
        website = w
    }

    function appRatingSlot(a, i, t) {
        ratingAverage = a
        rating = i
        ratingTotal = t
        voted = false
        prevRating = rating
    }

    onUrlsChanged: {
        lm.clear()
        for(var c = 0; c < urls.length; c++) {
            lm.append({"url" : urls[c]})
        }
        screenshotsListView.update()
    }

    Component.onCompleted: {
        confirmationRemoval.connect(startRemoving)
        errorOccured.connect(errorHappened)
        appDetailsReceived.connect(appDetailsSlot)
        appRatingDetailsReceived.connect(appRatingSlot)
        helper.detailsopened = true
        helper.getAppDetails(selectedAppName)
        helper.ratingControl(selectedAppName)
    }

    Component.onDestruction: {
        helper.detailsopened = false
        popupImage.source = ""
        urls = ["none"]
        selectedAppName = ""
        selectedAppInqueue = false
        selectedAppInstalled = false
        selectedAppDelegatestate = "get"
    }



    ListModel {
        id: lm
        ListElement {
            url : ""
        }
    }

    Pane {
        id:appBanner
        width: parent.width - 108
        height: 200
        Material.elevation: 3
        visible: true
        anchors {
            top: parent.top
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }


        Image {
            id:appBannerIcon
            height: appBanner.height
            width: height
            sourceSize.width: width
            sourceSize.height: width
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            //asynchronous: true
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            visible: true
            source: selectedAppName === "" ? "": "image://application/" + getCorrectName(selectedAppName)
            smooth: true
        }

        Rectangle {
            id: appBannerNameContainer
            color: "transparent"
            height: parent.height * 4 / 7
            width: parent.width * 4 / 5 - appBannerIcon.width
            anchors {
                top: parent.top
                left: appBannerIcon.right
                leftMargin: 12
            }

            Column {
                anchors {
                    fill: parent
                }
                spacing: 6
                Label {
                    id: appNameLabel
                    text: selectedAppName
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.bold: true
                    font.pointSize:24
                }

                Label {
                    id: sectionsLabel
                    text: sections
                    color: textSecondaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize:11
                }
                Label {
                    id: maintainerLabel
                    text: maintainer
                    Material.foreground: "#ddffcb08"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize:9
                }
            }


        }

        Rectangle {
            id: appBanerRatingContainer
            color: "transparent"
            anchors {
                top: appBannerNameContainer.bottom
                topMargin: 12
                left: appBannerIcon.right
                leftMargin: 12
                bottom: parent.bottom
                right: parent.right
            }

            Label {
                id: ratingLabel
                text: ratingAverage.toFixed(1)
                color: textSecondaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.capitalization: Font.Capitalize
                //font.weight: Font.DemiBold
                font.pointSize:20
                anchors {
                    left: parent.left
                    top: parent.top
                }
            }

            Rectangle {
                id: ratingRect
                color: "#111111"
                width: 125
                height: width / 5
                anchors {
                    verticalCenter: ratingLabel.verticalCenter
                    left: ratingLabel.right
                    leftMargin: 6
                }

                Rectangle {
                    color: textSecondaryColor
                    height: parent.height
                    width: parent.width * ratingAverage / 5
                }

                Rectangle {
                    id: ratingHighLight
                    visible: false
                    height: parent.height
                    width: parent.width * rating / 5
                    color: Material.accent
                }

                Image {
                    source: "qrc:/images/rating-stars.svg"
                    anchors.fill: parent
                    sourceSize {
                        width: width
                        height: height
                    }
                    MouseArea {
                        id: ratingMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            prevRating = rating
                            ratingHighLight.visible = true
                        }

                        onPositionChanged: {
                            var mx = mouse.x
                            var w = ratingRect.width
                            if(mx <= w / 5) {
                                rating = 1
                            } else if (mx <= (w * 2 / 5)) {
                                rating = 2
                            } else if (mx <= (w * 3 / 5)) {
                                rating = 3
                            } else if (mx <= (w * 4 / 5)) {
                                rating = 4
                            } else if (mx <= w) {
                                rating = 5
                            }
                        }

                        onExited: {
                            if(!voted) {
                                rating = prevRating
                            }
                            ratingHighLight.visible = false
                        }
                        onClicked: {
                            if(selectedAppInstalled) {
                                voted = true
                                helper.ratingControl(selectedAppName,rating)
                                voted = false
                            } else {
                                popupHeaderText = qsTr("Reminder")
                                popupText = qsTr("First, you have to install") + " <strong>" +
                                        selectedAppName + "</strong>"+" <br>" + qsTr("Then, you can vote.")
                                infoDialog.singleButtonText = qsTr("ok")
                                infoDialog.open()
                            }
                        }
                    }
                }
            }

            Label {
                id: ratingTotalLabel
                text: ratingTotal + " " + qsTr("ratings")
                color: textSecondaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.capitalization: Font.Capitalize
                font.pointSize:8
                anchors {
                    left: parent.left
                    top: ratingLabel.bottom
                }
            }

            Label {
                id: ratingIndividual
                visible: rating > 0
                text: qsTr("Your rate")  + " : " + rating
                color: ratingIndividualMa.containsMouse ? Material.accent : textSecondaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font.capitalization: Font.Capitalize
                font.pointSize:8
                anchors {
                    right: ratingRect.right
                    top: ratingLabel.bottom
                }
                MouseArea {
                    id: ratingIndividualMa
                    hoverEnabled: true
                    anchors.fill: parent
                    onContainsMouseChanged: {
                        if(containsMouse) {
                            ratingHighLight.visible = true
                        } else {
                            ratingHighLight.visible = false
                        }
                    }
                }
            }


            Pane {
                id: disclamer
                visible: appNonfree
                clip: true
                width: disclamerMa.containsMouse ? 500 : 150
                height: disclamerMa.containsMouse ? parent.height : disclamerText.height + 24
                Material.background: Material.accent
                Material.elevation: 3
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right

                }

                MouseArea {
                    id: disclamerMa
                    width: parent.width + 24
                    height: parent.height + 24
                    anchors.centerIn: parent
                    hoverEnabled: true
                }

                Behavior on height {
                    enabled: animate
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 150
                    }
                }

                Behavior on width {
                    enabled: animate
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 50
                    }
                }

                Label {
                    id: disclamerText
                    width: parent.width
                    Material.foreground: "#2B2B2B"
                    text: qsTr("Disclaimer") + (disclamerMa.containsMouse ? (" : " +
                                                                             qsTr("This application served from Pardus non-free package repositories, so that the OS has nothing to do with the health of the application. Install with caution.")) : " !")
                    //horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.HorizontalFit

                    wrapMode: Text.WordWrap
                    anchors.centerIn: parent
                }
            }
        }

        Rectangle {
            id: appBannerActionContainer
            color: "transparent"
            anchors {
                top: parent.top
                right: parent.right
                left:appBannerNameContainer.right
                leftMargin: 12
                bottom: appBannerNameContainer.bottom
            }

            Button {
                id: processButton
                width: parent.height

                enabled: !selectedAppInqueue
                Material.background: selectedAppInstalled ? "#F44336" : "#4CAF50"
                Material.foreground: "#FAFAFA"
                text: selectedAppInstalled ? qsTr("remove") : qsTr("install")

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }

                onClicked: {
                    if(selectedAppInstalled) {
                        confirmationDialog.name = selectedAppName
                        confirmationDialog.from = "detail"
                        confirmationDialog.open()
                    } else {
                        updateStatusOfAppFromDetail(selectedAppName)
                        processQueue.push(selectedAppName + " " + selectedAppInstalled)
                        updateQueue()
                    }
                }
            }
        }

    }

    Pane {
        id: bottomBanner
        clip: true
        Material.elevation: 3
        width: parent.width - 108
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: appBanner.bottom
            bottom: parent.bottom
            margins: 12
        }

        Flickable {
            width: parent.width
            height: parent.height
            interactive: contentHeight > height
            contentHeight: screenshotsListView.height +
                           descriptionContainer.height +
                           moreLabel.height +
                           infoContainer.height +
                           reviewContainer.height +
                           changelogContainer.height + 48
            flickableDirection: Flickable.VerticalFlick
            clip: true

            ListView {
                id: screenshotsListView
                interactive: count > 2
                clip: true
                orientation: Qt.Horizontal
                width: parent.width
                height: width * 9 / 32 + 12
                anchors.top: parent.top
                snapMode: ListView.SnapToItem
                spacing: 12
                cacheBuffer: width * 5
                delegate: Item {
                    width: bottomBanner.width / 2 - 18
                    height: width * 9 / 16

                    Image {
                        id:ss
                        visible: true
                        anchors.fill: parent
                        source: url === "none" ? "" : url
                        fillMode: Image.PreserveAspectFit
                        MouseArea{
                            id:ssma
                            anchors.fill:parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(!screenshotsListView.moving) {
                                    popupImagePreview.open()
                                    ssindex = index
                                }
                            }
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("no screenshot found!")
                        visible: url === "none"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.capitalization: Font.Capitalize
                        font.pointSize: 12
                        enabled: false
                    }

                    BusyIndicator {
                        id: imageBusy
                        anchors.centerIn: parent
                        running: url === "none" ? false : !ss.progress
                    }
                }
                model: lm
            }

            Rectangle {
                id: descriptionContainer
                property bool expanded: false
                anchors {
                    top: screenshotsListView.bottom
                    topMargin: 12
                    left: parent.left
                }
                color: "transparent"
                width: parent.width * 5 / 7
                height:  expanded ? labelDescription.contentHeight : 82
                Behavior on height {
                    enabled: animate
                    NumberAnimation {
                        duration: 250
                    }
                }
                clip: true

                Label {
                    id: labelDescription
                    anchors.fill: parent
                    text: description === "" ? qsTr("no description found"): description
                    font.pointSize: 11
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignLeft
                    elide: descriptionContainer.expanded ? Text.ElideNone : Text.ElideRight
                    wrapMode: Text.WordWrap
                    onContentHeightChanged: {
                        if(descriptionContainer.expanded) {
                            descriptionContainer.height = contentHeight
                        }
                    }
                }
            }

            Label {
                id: moreLabel
                text: qsTr("more")
                color: Material.accent
                visible: labelDescription.truncated
                font.underline: moreMa.containsMouse
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    right: descriptionContainer.right
                    top: descriptionContainer.bottom
                    topMargin: 3
                }

                MouseArea {
                    id: moreMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        descriptionContainer.expanded = true
                    }
                }
            }


            Rectangle {
                id: linksContainer
                anchors {
                    top: screenshotsListView.bottom
                    topMargin: 12
                    right: parent.right
                    left: descriptionContainer.right
                    leftMargin: 12
                }
                color: "transparent"
                height: 82

                Rectangle {
                    id: websiteContainer
                    width: websiteLabel.width + homepageIcon.width + 12
                    height: 23
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    color: "transparent"

                    MouseArea {
                        id:websiteMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            helper.openUrl(website)
                        }
                    }

                    Image {
                        id: homepageIcon
                        height: parent.height - 3
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                        source: "qrc:images/website.svg"
                        sourceSize{
                            width: width
                            height: height
                        }
                    }

                    Label {
                        id: websiteLabel
                        property bool websiteVisible: false
                        font.weight: Font.DemiBold
                        text: qsTr("website")
                        color: textSecondaryColor
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: homepageIcon.left
                            rightMargin: 6
                        }

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        font.capitalization: Font.Capitalize
                        font.pointSize: 10
                    }
                }

                Rectangle {
                    id: mailContainer
                    width: mailLabel.width + mailIcon.width + 12
                    height: 23
                    anchors {
                        top: websiteContainer.bottom
                        topMargin: 6
                        right: parent.right
                    }
                    color: "transparent"

                    MouseArea {
                        id:mailMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            helper.openUrl("mailto:"+email)
                        }
                    }

                    Image {
                        id: mailIcon
                        height: parent.height - 3
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                        source: "qrc:images/email.svg"
                        sourceSize{
                            width: width
                            height: height
                        }
                    }

                    Label {
                        id: mailLabel
                        property bool websiteVisible: false
                        font.weight: Font.DemiBold
                        text: qsTr("e-mail")
                        color: textSecondaryColor
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: mailIcon.left
                            rightMargin: 6
                        }

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        font.capitalization: Font.Capitalize
                        font.pointSize: 10
                    }
                }

            }

            Rectangle {
                id: infoContainer
                color: "transparent"
                width: parent.width
                height: infoGrid.height + infoLabel.height + 24
                anchors {
                    top: descriptionContainer.bottom
                    topMargin: 24
                }

                Label {
                    id: infoLabel
                    text: qsTr("information")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize: 19
                    font.weight: Font.DemiBold
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }

                Grid {
                    id: infoGrid
                    width: parent.width
                    columns: 3
                    spacing: 12
                    anchors {
                        top: infoLabel.bottom
                        topMargin: 12
                    }

                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: qsTr("version")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: appVersion
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                text: qsTr("Download size")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: appDownloadSize
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: qsTr("type")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: appNonfree ? qsTr("non-free") : qsTr("open source")
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: qsTr("category")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                color: appCategoryMa.containsMouse ? Material.accent : Material.foreground
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: categories[categoryIcons.indexOf(appCategory)]
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                                MouseArea {
                                    id: appCategoryMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if(categoryIcons[categories.indexOf(selectedCategory)] === "all") {
                                            selectedCategory = categories[categoryIcons.indexOf(appCategory)]
                                        } else {
                                            stackView.pop()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: qsTr("license")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: license
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Item {
                        width: parent.width / 3 - 8
                        height: infoCellHeight
                        Column {
                            anchors.fill: parent
                            spacing: 3
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: qsTr("Download count")
                                color: textSecondaryColor
                                font.pointSize: 12
                            }
                            Label {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                font.capitalization: Font.Capitalize
                                text: download
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: reviewContainer
                color: "transparent"
                width: parent.width
                height: reviewLabel.height + comingSoonLabel.height + 24
                anchors {
                    top: infoContainer.bottom
                    topMargin: 24
                }

                Label {
                    id: reviewLabel
                    text: qsTr("reviews - ratings")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize: 19
                    font.weight: Font.DemiBold
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }

                Label {
                    id: comingSoonLabel
                    text: qsTr("coming soon") + " ..."
                    enabled: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    anchors {
                        top: reviewLabel.bottom
                        left: parent.left
                    }
                }
            }

            Rectangle {
                id: changelogContainer
                color: "transparent"
                width: parent.width
                height: newsLabel.height + comingSoonLabel2.height + 24
                anchors {
                    top: reviewContainer.bottom
                    topMargin: 24
                }

                Label {
                    id: newsLabel
                    text: qsTr("what is new")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    font.pointSize: 19
                    font.weight: Font.DemiBold
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                }

                Label {
                    id: comingSoonLabel2
                    text: qsTr("coming soon") + " ..."
                    enabled: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.capitalization: Font.Capitalize
                    anchors {
                        top: newsLabel.bottom
                        left: parent.left
                    }
                }
            }
        }

    }


    Popup {
        id:popupImagePreview
        width: main.width - 12
        height: parent.height - 12
        modal: animate
        focus: true
        x: - navigationBarWidth + 6
        y: 6
        closePolicy: Popup.CloseOnPressOutside
        onClosed: {
            popupImage.source = ""
        }
        onOpened: {
            popupImage.source = urls ? urls[ssindex] : ""
        }


        Image {
            id:popupImage
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: urls ? urls[ssindex] : ""

            BusyIndicator {
                id: imageBusyInPopup
                anchors.centerIn: parent
                running: urls ? false : !popupImage.progress
            }

            onSourceChanged: {
                if(animate) {
                    trans.start()
                }
            }

            NumberAnimation {
                id: trans
                target: popupImage
                property: "opacity"
                from: 0
                to: 1.0
                duration: 250
                easing.type: Easing.InExpo
            }

        }

        Rectangle {
            width:75
            height: parent.height * 5 / 6
            visible: lm.count > 1
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            opacity: nextMa.containsMouse ? 1.0 : 0.2

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:nextMa
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:{
                    ssindex=ssindex + 1
                    if (ssindex == lm.count) {
                        ssindex = 0
                    }
                    popupImage.source = urls[ssindex]


                }
                onClipChanged: ssindex = indicator.index
            }
            Image {
                width: 64
                height: 64
                anchors.right: parent.right
                anchors.centerIn: parent
                source:"qrc:/images/front.svg"
            }
        }

        Rectangle {
            width:75
            height: parent.height * 5 / 6
            visible: lm.count > 1
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            opacity: prevMa.containsMouse ? 1.0 : 0.2

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    duration: 200
                }
            }
            MouseArea {
                id:prevMa
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:{
                    ssindex= ssindex - 1
                    if (ssindex==-1) {

                        ssindex = lm.count - 1
                    }
                    popupImage.source = urls[ssindex]
                }
            }

            Image {
                id:prev
                width: 64
                height: 64
                anchors.right: parent.right
                anchors.centerIn: parent
                source:"qrc:/images/back.svg"

            }
        }

        Pane {
            id: btnClose
            width: 32
            height: 32
            Material.background: Material.primary
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
                id: closePopupBtnMa
                width: 32
                height: 32
                anchors.centerIn: parent
                onPressed: {
                    if (closePopupBtnMa.containsMouse) {
                        closePopupBtnMa.Material.elevation = 0
                    }
                }
                onReleased: {
                    closePopupBtnMa.Material.elevation = 2
                }
                onClicked: {
                    popupImagePreview.close()
                }
            }
        }
    }

    Button {
        id: backBtn
        z: 92
        height: 54
        width: height * 2 / 3
        opacity: selectedCategory !== qsTr("home") ? 1.0 : 0.0
        Material.background: Material.background
        anchors {
            top: parent.top
            topMargin: 6
            left: parent.left
            leftMargin: 8

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
            stackView.pop()

        }

        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 300
            }
        }

    }


}

