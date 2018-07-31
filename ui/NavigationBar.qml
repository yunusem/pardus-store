import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: navi
    width: navigationBarWidth
    height: parent.height
    z : 93
    color: "#2C2C2C"

    property alias currentIndex : menuListView.currentIndex
    property int categoryItemHeight: 30
    property int categoryItemListSpacing: 3
    property int menuItemHeight: 40
    property int menuItemListSpacing: 6


    property alias processOutput: processOutputLabel
    property alias packageName: processOutputLabel.packageName
    property alias condition: processOutputLabel.condition
    property alias busyIndicator: busy
    property alias processingIcon: appIconProcess

    ListModel {
        id: menuListModel
    }

    ListModel {
        id: categoryListModel
    }

    Component.onCompleted: {
        for (var i = 0; i < categories.length; i++) {
            categoryListModel.append({"name" : categories[i], "icon" : categoryIcons[i]})
        }
        for (i = 0; i < menus.length; i++) {
            menuListModel.append({"name" : menus[i], "icon" : menuIcons[i]})
        }
    }



    Component {
        id: categoryItemDelegate
        Item {
            id:categoryItemWrapper
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 3 / 4
            height: categoryItemHeight



            Image {
                id: categoryItemIcon
                source: "qrc:/images/" + icon + ".svg"
                fillMode: Image.PreserveAspectFit
                height: categoryItemHeight - anchors.topMargin * 2
                width: height
                anchors {
                    top: parent.top
                    topMargin: 2
                    left: parent.left
                    leftMargin: width / 2
                }
                mipmap: true
                smooth: true
                antialiasing: true
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
                color: name === selectedCategory ? "#FFCB08" : "#FAFAFA"
                font.capitalization: Font.Capitalize
                text: name
                fontSizeMode: Text.HorizontalFit
            }

            MouseArea {
                id: categoryMa
                anchors.fill: parent
                onClicked: {
                    selectedCategory = name
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
            state: ((name === qsTr("categories")) && expanded) ? "expanded" : ""


            Item {
                id: menuItem
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40

                Rectangle {
                    id: bgRect
                    color: "#4C4C4C"
                    visible: name === selectedMenu
                    width: parent.width
                    height: parent.height
                }

                Image {
                    id: menuItemIcon
                    source: "qrc:/images/" + icon + ".svg"
                    fillMode: Image.PreserveAspectFit
                    height: 36
                    width: height
                    anchors {
                        top: parent.top
                        topMargin: 2
                        left: parent.left
                        leftMargin: width / 2
                    }
                    mipmap: true
                    smooth: true
                    antialiasing: true
                }

                DropShadow {
                    id:ds
                    visible: true
                    anchors.fill: menuItemIcon
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8
                    samples: 17
                    color: "#ff000000"
                    source: menuItemIcon
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
                    color: name === selectedMenu ? "#FFCB08" : "#FAFAFA"
                    font.capitalization: Font.Capitalize
                    text: name
                    fontSizeMode: Text.HorizontalFit
                }

                MouseArea {
                    id: menuMa
                    anchors.fill: parent
                    onClicked: {
                        selectedMenu = name
                        if(selectedMenu === qsTr("categories")) {
                            expanded = !expanded
                            selectedCategory = qsTr("all")
                        } else {
                            expanded = false
                        }
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
                    spacing: 3
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
            topMargin: 12
        }
    }

    ListView {
        id: menuListView
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: searchBar.bottom
            topMargin: 12
            bottom: parent.bottom
        }

        delegate: menuItemDelegate
        model: menuListModel
        spacing: 6
    }


    ProgressBarCircle {
        id: busy
        width: 90
        height: width
        colorBackground: "#FAFAFA"
        thickness: 9
        visible: true
        opacity: isThereOnGoingProcess ? 1.0 : 0.0
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        onOpacityChanged: {
            if(opacity === 0.0) {
                value = 0
            }
        }
        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.InExpo
                duration: 600
            }
        }
    }

    Image {
        id: appIconProcess
        enabled: false
        anchors.centerIn: busy
        opacity: isThereOnGoingProcess ? 1.0 : 0.0
        width: 44
        height: width

        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.InExpo
                duration: 600
            }
        }
    }

    Label {
        id: processOutputLabel
        property string packageName: ""
        property string condition: ""
        anchors {
            verticalCenter: busy.verticalCenter
            left: busy.right
            right: parent.right
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
            if(condition === qsTr("installed") || condition === qsTr("removed")) {
                processOutputLabel.text = packageName + " " + qsTr("is") + " " + condition
            } else {
                processOutputLabel.text = condition + " " + packageName
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
                    //processingPackageName = ""
                    //processingCondition = ""
                }
            }
        }

    }

    MouseArea {
        id: outputMa
        height: busy.height
        width: parent.width
        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        hoverEnabled: true
        onContainsMouseChanged: {
            if(containsMouse && isThereOnGoingProcess) {
                queueDialog.open()
            }
        }
    }

}
