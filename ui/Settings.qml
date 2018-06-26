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
    Material.background: "#2c2c2c"
    Material.elevation: 3
    z: 200
    visible: category === qsTr("settings")
    width: (main.width * 20 / 21) - 12
    height: (main.height * 13 / 15) - 12
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
                Material.foreground: row1Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row1Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row1Ma.containsMouse) {
                            currentOption = 0
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }

            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: animate
                onCheckedChanged: {
                    animate = checked
                }
            }

        }

        Row {
            id: row2
            spacing: 12
            Label {
                text: qsTr("Change application list column count")
                font.capitalization: Font.Capitalize
                Material.foreground: row2Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row2Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row2Ma.containsMouse) {
                            currentOption = 1
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }
            }

            Slider {
                id: slider
                Material.foreground: "#fafafa"
                anchors.top: parent.top
                from: 3
                to: 5
                value: ratio
                stepSize: 1
                snapMode: Slider.SnapAlways
                width: 120
                onValueChanged: {
                    ratio = value
                }

                hoverEnabled: true

                onHoveredChanged: {
                    if(hovered) {
                        currentOption = 1
                        exp.text = optionsModel[currentOption]
                    }
                }

                Rectangle {
                    x: parent.leftPadding + parent.handle.width / 2
                    y: parent.topPadding + slider.availableHeight * 3 / 4
                    width: parent.availableWidth - parent.handle.width
                    height: 1
                    color: "transparent"

                    Row {
                        width: parent.width
                        height: 3
                        anchors.bottom: parent.bottom
                        spacing: (parent.width - 3) / 2
                        Repeater {
                            model: 3
                            Rectangle {
                                radius: 1
                                height: 3
                                width: 1

                            }
                        }

                    }
                }

                Rectangle {
                    x: parent.leftPadding + parent.handle.width / 2
                    y: parent.topPadding - 2.5
                    width: parent.availableWidth - parent.handle.width
                    height: 1
                    color: "transparent"

                    Row {
                        width: parent.width
                        height: 3
                        anchors.bottom: parent.bottom
                        spacing: (parent.width -15) / 2
                        Repeater {
                            id: r
                            model: 3
                            Label {
                                height: contentHeight
                                Material.foreground: "#FAFAFA"
                                text: index + 3
                                //anchors.horizontalCenter: parent.horizontalCenter
                                font.pointSize: 7
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                    }
                }
            }

        }

        Row {
            id: row3
            spacing: 12
            Label {
                text: qsTr("update package manager cache on start")
                font.capitalization: Font.Capitalize
                Material.foreground: row3Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row3Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row3Ma.containsMouse) {
                            currentOption = 2
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }
            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: updateCache
                onCheckedChanged: {
                    updateCache = checked
                }
            }

        }
        Row {
            id: row4
            spacing: 12
            Label {
                text: qsTr("Correct package manager sources list")
                font.capitalization: Font.Capitalize
                Material.foreground: row4Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row4Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row4Ma.containsMouse) {
                            currentOption = 3
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }
            }
            Button {
                id: correctBtn
                anchors.verticalCenter: parent.verticalCenter
                Material.background: "#FFCB08"
                hoverEnabled: true
                enabled: ! corrected
                width: correctBtnLabel.width + 24
                Label {
                    id: correctBtnLabel
                    anchors.centerIn: parent
                    text: corrected ? qsTr("corrected"): qsTr("correct")
                    font.bold: true
                    Material.foreground: "#2c2c2c"
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
                        exp.text = optionsModel[currentOption]
                    }
                }
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
        Material.background: "#2c2c2c"
        signal accepted
        signal rejected

        Column {
            anchors.fill: parent
            spacing: 12

            Label {
                text: qsTr("Informing");
                anchors.horizontalCenter: parent.horizontalCenter
                Material.foreground: "#fafafa"
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }

            Label {
                Material.foreground: "#fafafa"
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
                    Material.background: "#3c3c3c"
                    Material.foreground: "#fafafa"
                    onClicked: popupConfirmCorrect.accepted()
                }
                Button {
                    text: qsTr("no")
                    Material.background: "#3c3c3c"
                    Material.foreground: "#fafafa"
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
        border.color: "#FFCB08"

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
                    Material.foreground: "#fafafa"
                    text: optionsModel[currentOption] ? optionsModel[currentOption] : ""
                    font.pointSize: 15
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Item {
                    id: explanationVisual
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 100
                    visible: currentOption === 1

                    Row {
                        width: parent.width
                        spacing: 24
                        Repeater {
                            model: 3

                            Column {
                                spacing: 12
                                width: (explanationVisual.width - 48) / 3

                                Label {
                                    height: contentHeight
                                    Material.foreground: (ratio - 3) === index ? "#FFCB08" : "#FAFAFA"
                                    text: index + 3
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pointSize: 15
                                    font.bold: (ratio - 3) === index ? true : false
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Rectangle {
                                    property int count : index
                                    width: (explanationVisual.width - 48) / 3
                                    height: width * 9 / 16
                                    border.color: (ratio - 3) === index ? "#FFCB08" : "#FAFAFA"
                                    border.width: 1
                                    radius: 2
                                    color: "transparent"

                                    GridView {
                                        id: gv
                                        clip: true
                                        visible: true
                                        interactive: false
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        cellWidth: width / (parent.count + 3)
                                        cellHeight: cellWidth * 3 / 5
                                        model: 10
                                        delegate: Item {
                                            visible: true
                                            width: gv.cellWidth
                                            height: gv.cellHeight
                                            Rectangle {
                                                width: parent.width - 3
                                                height: parent.height - 3
                                                anchors.centerIn: parent
                                                color: "#FAFAFA"
                                                radius: 2
                                            }
                                        }
                                    }
                                }

                                Label {
                                    height: contentHeight
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    visible: (ratio - 3) === index
                                    Material.foreground: "#FFCB08"
                                    text: qsTr("Currently selected")
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    //font.pointSize: 9
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }

    }


    Component.onCompleted:  {
        optionsModel.push(qsTr("Controls the transitions animations. If you have low performance graphic card, disabling animation may give you more comfort."))
        optionsModel.push(qsTr("Controls the visual column count of applications list view."))
        optionsModel.push(qsTr("Checks the system package manager's cache when Pardus-Store is started. Disabling this could speed up the starting process but if you do not use Pardus-Store often you should enable this option."))
        optionsModel.push(qsTr("Corrects the system sources list that used by package manager. This process will revert all the changes have been done and will use Pardus Official Repository source addresses. Use with caution."))

    }
}
