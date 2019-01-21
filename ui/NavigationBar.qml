import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
//import QtGraphicalEffects 1.0
import ps.condition 1.0

Rectangle {
    id: navi
    width: navigationBarWidth
    height: parent.height
    z : 93
    color: "#fa464646"

    property alias currentIndex : menuListView.currentIndex
    property int categoryItemHeight: 30
    property int categoryItemListSpacing: 3
    property int menuItemHeight: 40
    property int menuItemListSpacing: 3


    property alias processOutput: processOutputLabel
    property alias packageName: processOutputLabel.packageName
    property alias condition: processOutputLabel.condition

    function categoriesReceived() {
        for (var i = 0; i < categories.length; i++) {
            categoryListModel.append({"name" : categories[i]})
        }
    }

    ListModel {
        id: menuListModel
    }

    ListModel {
        id: categoryListModel
    }

    Component.onCompleted: {
        categoriesFilled.connect(categoriesReceived)
        var cnt = 0;
        var index = 1;
        for (var key in menuList) {
            index = (key === "home") ? cnt : 1
            menuListModel.append({"name" : key, "localname": menuList[key]})
            cnt = cnt + 1
        }
        menuListModel.move(index,0,1)
    }

    Component {
        id: categoryItemDelegate
        Rectangle {
            id:categoryItemWrapper
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 3 / 4
            height: categoryItemHeight
            color: categoryMa.containsMouse ? "#15ffffff" : "#00ffffff"
            radius: 2
            Image {
                id: categoryItemIcon
                asynchronous: true
                source: ((name === "all") ? "qrc:/images/" : (helper.getMainUrl() + "/files/categoryicons/")) + name + ".svg"
                fillMode: Image.PreserveAspectFit
                height: categoryItemHeight - anchors.topMargin * 2
                width: height
                sourceSize.width: width
                sourceSize.height: width
                smooth: true
                anchors {
                    top: parent.top
                    topMargin: 2
                    left: parent.left
                    leftMargin: width / 2
                }
                onStatusChanged: {
                    if(name == "test") {
                        if(status == Image.Error) {
                            console.log("Error occured")
                        }
                    }

                }
            }

            Label {
                id: categoryItemLabel
                anchors {
                    verticalCenter : categoryItemIcon.verticalCenter
                    left: categoryItemIcon.right
                    leftMargin: categoryItemIcon.width / 2
                    right: parent.right
                    rightMargin: 2
                }
                color: name === selectedCategory ? accentColor : "#E4E4E4"
                font.capitalization: Font.Capitalize
                text: name === "all" ? qsTr("all") :helper.getCategoryLocal(name)
                fontSizeMode: Text.HorizontalFit
            }

            MouseArea {
                id: categoryMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if(name === selectedCategory && applicationModel.getFilterString() !== "") {
                        applicationModel.setFilterString(selectedCategory === "all" ? "" : name, false)
                    }

                    selectedCategory = name
                    forceActiveFocus()
                }
                onPressed: {
                    categoryItemLabel.scale = 0.95
                }
                onPressAndHold: {
                    categoryItemLabel.scale = 0.95
                }
                onReleased: {
                    categoryItemLabel.scale = 1
                }
            }
        }
    }

    Component {
        id: menuItemDelegate
        Item {
            id: menuItemWrapper
            anchors.horizontalCenter: parent.horizontalCenter
            width: navi.width
            height: menuItemHeight
            state: ((name === "categories") && expanded) ? "expanded" : ""


            Item {
                id: menuItem
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40

                Rectangle {
                    id: bgRect
                    color: name === selectedMenu ? backgroundColor : "transparent"
                    visible: true
                    width: parent.width
                    height: parent.height
                }

                Image {
                    id: menuItemIcon
                    asynchronous: true
                    source: "qrc:/images/" + name + ((bgRect.color == "#f0f0f0") ? "-dark.svg" : ".svg")
                    fillMode: Image.PreserveAspectFit
                    height: 36
                    width: height
                    sourceSize.width: width
                    sourceSize.height: width
                    smooth: true
                    anchors {
                        top: parent.top
                        topMargin: 2
                        left: parent.left
                        leftMargin: width * 3 / 4
                    }
                }

                Label {
                    id: menuItemLabel
                    anchors {
                        verticalCenter : menuItemIcon.verticalCenter
                        left: menuItemIcon.right
                        leftMargin: menuItemIcon.width / 2
                        right: parent.right
                        rightMargin: 2
                    }
                    color: name === selectedMenu ? accentColor : "#E4E4E4"
                    font.bold: name === selectedMenu
                    font.capitalization: Font.Capitalize
                    text: localname
                    fontSizeMode: Text.HorizontalFit
                }

                MouseArea {
                    id: menuMa
                    anchors.fill: parent
                    onClicked: {
                        forceActiveFocus()
                        selectedMenu = name
                        if(selectedMenu === "categories") {
                            expanded = !expanded
                            selectedCategory = "all"
                        } else {
                            expanded = false
                        }
                    }
                    onPressed: {
                        menuItemLabel.scale = 0.95
                    }
                    onPressAndHold: {
                        menuItemLabel.scale = 0.95
                    }
                    onReleased: {
                        menuItemLabel.scale = 1
                    }
                }
            }

            Item {
                id: subListWrapper
                anchors {
                    top: menuItem.bottom
                    topMargin: 6
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right

                }

                ListView {
                    id: categoryListView
                    clip: true
                    interactive: false
                    spacing: categoryItemListSpacing
                    anchors.fill: parent
                    model: categoryListModel
                    delegate: categoryItemDelegate
                }
            }

            states: [
                State {
                    name: "expanded"
                    PropertyChanges { target: menuItemWrapper; height: menuItemHeight + categories.length * (categoryItemHeight + categoryItemListSpacing) + categoryItemListSpacing}
                }
            ]

            transitions: [
                Transition {
                    enabled: animate
                    NumberAnimation {
                        duration: 200
                        properties: "height" //,width,anchors.rightMargin,anchors.topMargin,opacity,contentY"
                    }
                }
            ]
        }
    }

    SearchBar {
        id: searchBar
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 21
        }
    }

    ListView {
        id: menuListView
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: searchBar.bottom
            topMargin: 21
            bottom: parent.bottom
        }

        delegate: menuItemDelegate
        model: menuListModel
        spacing: menuItemListSpacing
    }

    Item {
        id: userContainer
        width: parent.width
        height: width / 3 - 12
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: polContainer.top
            bottomMargin: 3
        }

        Rectangle {
            id: account
            width: parent.width * 3 / 4 + 24
            height: parent.height
            color: "transparent"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                id: accountMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.WhatsThisCursor
                ToolTip.text: qsTr("This section is under development")
                ToolTip.delay: 500
                ToolTip.visible: containsMouse
                ToolTip.timeout: 5000
            }

            Image {
                id: accountImage
                height: parent.height - 12
                width: height
                enabled: false
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 3
                }
                sourceSize {
                    width: width
                    height: height
                }

                source: "image://application/avatar-default"
            }

            Label {
                id: accountNameLabel
                enabled: false
                width: parent.width - accountImage.width -6
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 11
                wrapMode: Text.WordWrap
                Material.foreground: secondaryTextColor
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: accountImage.right
                    leftMargin: 6
                }
                text: qsTr("Anonymus Account")
            }
        }

    }

    Item {
        id: polContainer
        width: parent.width
        height: 24
        anchors.bottom: parent.bottom
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                if(containsMouse && isThereOnGoingProcess) {
                    queueDialog.open()
                }
            }
        }

        Label {
            id: processOutputLabel
            property string packageName: ""
            property int condition: Condition.Idle
            anchors {
                centerIn: parent
            }
            opacity: 1.0
            fontSizeMode: Text.VerticalFit
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            enabled: false
            text: ""

            onTextChanged: {
                opacity = 1.0
            }

            onConditionChanged: {
                if (condition === Condition.Idle) {
                    processOutputLabel.text = ""
                } else if(condition === Condition.Installed || condition === Condition.Removed) {
                    processOutputLabel.text = packageName + " " + qsTr("is") + " " + getConditionString(condition)
                } else {
                    processOutputLabel.text = getConditionString(condition) + " " + packageName
                }
            }

            Behavior on opacity {
                enabled: animate
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }

            Timer {
                id: outputTimer
                interval: 8000
                repeat: true
                running: true
                onTriggered: {
                    if(!isThereOnGoingProcess) {
                        processOutputLabel.opacity = 0.0
                    }
                }
            }
        }

    }
}
