import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.1

Pane {
    id: pane
    property string previous
    property string current
    property bool corrected: helper.corrected
    property int currentOption: 0
    property variant optionsModel: []
    Material.background: backgroundColor
    Material.elevation: 3
    z: 92
    visible: selectedMenu === "settings"
    width: stackView.width
    height: stackView.height
    anchors.centerIn: stackView
    opacity: 0.0

    onVisibleChanged: {
        if(visible) {
            opacity = 1.0
            //backBtn.opacity = 1.0
        } else {
            opacity = 0.0
        }
    }

    onCurrentOptionChanged: {
        exp.text = optionsModel[currentOption]
    }

    Behavior on opacity {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 800
        }
    }

    Column {
        id: column
        width: parent.width / 2
        height: parent.height
        anchors {
            right: parent.horizontalCenter
        }

        spacing: 12

        Row {
            id: row1
            spacing: 12
            Label {
                text: qsTr("enable animations")
                font.capitalization: Font.Capitalize
                Material.foreground: currentOption == 0 ? accentColor : textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row1Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(containsMouse) {
                            currentOption = 0                            
                        }
                    }
                }

            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: animate
                hoverEnabled: true
                onHoveredChanged: {
                    if(hovered) {
                        currentOption = 0
                    }
                }
                onCheckedChanged: {                    
                    animate = checked
                }
                Material.theme: dark ? Material.Dark : Material.Light
                Material.accent: accentColor
            }

        }

//        Row {
//            id: row2
//            spacing: 12
//            Label {
//                text: qsTr("Change application list column count")
//                font.capitalization: Font.Capitalize
//                Material.foreground: currentOption == 1 ? accentColor : textColor
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                anchors.verticalCenter: parent.verticalCenter
//                MouseArea {
//                    id: row2Ma
//                    anchors.fill: parent
//                    hoverEnabled: true
//                    onContainsMouseChanged: {
//                        if(containsMouse) {
//                            currentOption = 1
//                        }
//                    }
//                }
//            }

//            Slider {
//                id: slider
//                property int count: to - from + 1
//                Material.foreground: textColor
//                Material.accent: accentColor
//                anchors.top: parent.top
//                from: 2
//                to: 3
//                value: ratio
//                stepSize: 1
//                snapMode: Slider.SnapAlways
//                width: slider.count * 40
//                onValueChanged: {
//                    ratio = value
//                }

//                hoverEnabled: true

//                onHoveredChanged: {
//                    if(hovered) {
//                        currentOption = 1
//                    }
//                }

//                Rectangle {
//                    x: parent.leftPadding + parent.handle.width / 2
//                    y: parent.topPadding + slider.availableHeight * 3 / 4
//                    width: parent.availableWidth - parent.handle.width
//                    height: 1
//                    color: "transparent"

//                    Row {
//                        width: parent.width
//                        height: 3
//                        anchors.bottom: parent.bottom
//                        spacing: (parent.width - 3) / (slider.count - 1)
//                        Repeater {
//                            model: slider.count
//                            Rectangle {
//                                radius: 1
//                                height: 3
//                                width: 1

//                            }
//                        }

//                    }
//                }

//                Rectangle {
//                    x: parent.leftPadding + parent.handle.width / 2
//                    y: parent.topPadding - 2.5
//                    width: parent.availableWidth - parent.handle.width
//                    height: 1
//                    color: "transparent"

//                    Row {
//                        width: parent.width
//                        height: 3
//                        anchors.bottom: parent.bottom
//                        spacing: (parent.width - 3 - (slider.count -1) * 6) / (slider.count - 1)
//                        Repeater {
//                            id: r
//                            model: slider.count
//                            Label {
//                                height: contentHeight
//                                color: textColor
//                                text: index + slider.from
//                                font.pointSize: 7
//                                verticalAlignment: Text.AlignVCenter
//                                horizontalAlignment: Text.AlignHCenter
//                            }
//                        }

//                    }
//                }
//            }

//        }

        Row {
            id: row3
            spacing: 12
            Label {
                text: qsTr("update package manager cache on start")
                font.capitalization: Font.Capitalize
                Material.foreground: currentOption == 2 ? accentColor:textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row3Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(containsMouse) {
                            currentOption = 2
                        }
                    }
                }
            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: updateCache
                hoverEnabled: true
                onHoveredChanged: {
                    if(hovered) {
                        currentOption = 2
                    }
                }
                onCheckedChanged: {                    
                    updateCache = checked
                }
                Material.theme: dark ? Material.Dark : Material.Light
                Material.accent: accentColor
            }

        }

        Row {
            id: row4
            spacing: 12
            Label {
                text: qsTr("Correct package manager sources list")
                font.capitalization: Font.Capitalize
                Material.foreground: currentOption == 3 ? accentColor:textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row4Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(containsMouse) {
                            currentOption = 3
                        }
                    }
                }
            }
            Button {
                id: correctBtn
                anchors.verticalCenter: parent.verticalCenter
                Material.background: accentColor
                hoverEnabled: true
                enabled: !corrected
                width: correctBtnLabel.width + 24
                Label {
                    id: correctBtnLabel
                    anchors.centerIn: parent
                    text: corrected ? qsTr("corrected"): qsTr("correct")
                    font.bold: true
                    Material.foreground: oppositeTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.Capitalize
                }
                onClicked: {
                    popupConfirmCorrect.open()
                }
                onHoveredChanged: {
                    if(hovered) {
                        currentOption = 3
                    }
                }
            }
        }

        Row {
            id: row5
            spacing: 12
            Label {
                text: qsTr("use dark theme")
                font.capitalization: Font.Capitalize
                Material.foreground: currentOption == 4 ? accentColor : textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row5Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(containsMouse) {
                            currentOption = 4
                        }
                    }
                }
            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: dark
                hoverEnabled: true
                onHoveredChanged: {
                    if(hovered) {
                        currentOption = 4
                    }
                }
                onCheckedChanged: {
                    dark = checked
                }
                Material.theme: dark ? Material.Dark : Material.Light
                Material.accent: accentColor
            }

        }

    }

    Popup {
        id: popupConfirmCorrect
        modal: animate
        width: 300
        closePolicy: Popup.NoAutoClose
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        Material.elevation: 2
        Material.background: backgroundColor
        signal accepted
        signal rejected

        Column {
            anchors.fill: parent
            spacing: 12

            Label {
                text: qsTr("Informing");
                anchors.horizontalCenter: parent.horizontalCenter
                Material.foreground: textColor
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }

            Label {
                Material.foreground: textColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
                text: qsTr("I have carefully read the explanation on the right and agree to proceed.")
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Button {
                    text: qsTr("yes")
                    Material.background: backgroundColor
                    Material.foreground: textColor
                    onClicked: popupConfirmCorrect.accepted()
                }
                Button {
                    text: qsTr("no")
                    Material.background: backgroundColor
                    Material.foreground: textColor
                    onClicked: popupConfirmCorrect.rejected()
                }
            }
        }

        onAccepted: {
            helper.correctSourcesList()
            popupConfirmCorrect.close()
        }

        onRejected: {
            popupConfirmCorrect.close()
        }
    }

    Rectangle {
        anchors {
            left: parent.horizontalCenter
        }
        height: parent.height
        width: parent.width / 2
        radius: 2
        color: "transparent"
        border.width: 1
        border.color: accentColor

        Item {
            id: explanationHolder
            width: parent.width - 24
            height: parent.height
            anchors.centerIn: parent

            Column {
                width: parent.width
                anchors.centerIn: parent
                spacing: 24

                Label {
                    id: exp
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: contentHeight
                    Material.foreground: textColor
                    text: optionsModel[currentOption] ? optionsModel[currentOption] : ""
                    font.pointSize: 15
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

//                Item {
//                    id: explanationVisual
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width
//                    height: 100
//                    visible: currentOption === 1

//                    Row {
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        spacing: 24
//                        Repeater {
//                            model: slider.count

//                            Column {
//                                spacing: 12
//                                width: (explanationVisual.width - 48) / 3

//                                Label {
//                                    height: contentHeight
//                                    Material.foreground: (ratio - slider.from) === index ? accentColor : textColor
//                                    text: index + slider.from
//                                    anchors.horizontalCenter: parent.horizontalCenter
//                                    font.pointSize: 15
//                                    font.bold: (ratio - slider.from) === index ? true : false
//                                    verticalAlignment: Text.AlignVCenter
//                                    horizontalAlignment: Text.AlignHCenter
//                                }

//                                Rectangle {
//                                    property int count : index
//                                    width: (explanationVisual.width - 48) / 3
//                                    height: width * 3 / 4
//                                    border.color: (ratio - slider.from) === index ? accentColor : textColor
//                                    border.width: 1
//                                    radius: 2
//                                    color: "transparent"


//                                    GridView {
//                                        id: gv
//                                        clip: true
//                                        visible: true
//                                        interactive: false
//                                        anchors.fill: parent
//                                        anchors.margins: 2
//                                        cellWidth: width / (parent.count + slider.from)
//                                        cellHeight: cellWidth * 3 / 4
//                                        model: 10
//                                        delegate: Item {
//                                            visible: true
//                                            width: gv.cellWidth
//                                            height: gv.cellHeight
//                                            Rectangle {
//                                                width: parent.width - 3
//                                                height: parent.height - 3
//                                                anchors.centerIn: parent
//                                                color: textColor
//                                                radius: 2
//                                            }
//                                        }
//                                    }
//                                }

//                                Label {
//                                    height: contentHeight
//                                    width: parent.width
//                                    wrapMode: Text.WordWrap
//                                    visible: (ratio - slider.from) === index
//                                    Material.foreground: accentColor
//                                    text: qsTr("Currently selected")
//                                    anchors.horizontalCenter: parent.horizontalCenter
//                                    //font.pointSize: 9
//                                    verticalAlignment: Text.AlignVCenter
//                                    horizontalAlignment: Text.AlignHCenter
//                                }
//                            }
//                        }
//                    }
//                }

            }
        }

    }


    Component.onCompleted:  {
        optionsModel.push(qsTr("Controls the transitions animations. If you have low performance graphic card, disabling animation may give you more comfort."))
        optionsModel.push(qsTr("Controls the visual column count of applications list view."))
        optionsModel.push(qsTr("Checks the system package manager's cache when Pardus-Store is started. Disabling this could speed up the starting process but if you do not use Pardus-Store often you should enable this option."))
        optionsModel.push(qsTr("Corrects the system sources list that used by package manager. This process will revert all the changes have been done and will use Pardus Official Repository source addresses. Use with caution."))
        optionsModel.push(qsTr("Change theme"))

    }
}
