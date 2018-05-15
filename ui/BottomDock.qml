import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Pane {
    width: parent.width * 20 / 21
    height: parent.height / 15
    z: 89
    anchors  {
        bottom: parent.bottom
        right: parent.right
    }

    Material.elevation: 3
    property alias pageIndicator: indicator
    property alias processOutput: processOutputLabel
    property alias packageName: processOutputLabel.packageName
    property alias condition: processOutputLabel.condition
    property alias busyIndicator: busy
    property alias processingIcon: appIconProcess

    ProgressBarCircle {
        id: busy
        height: main.height / 15
        width: height
        colorBackground: "#aaaaaa"
        thickness: 5
        visible: true
        opacity: isThereOnGoingProcess ? 1.0 : 0.0
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        onOpacityChanged: {
            if(opacity === 0.0) {
                value = 0
            }
        }
        Behavior on opacity {
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
        width: 27
        height: width

        Behavior on opacity {
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
            verticalCenter: parent.verticalCenter
            left: busy.right
            leftMargin: 10
        }
        opacity: 1.0
        fontSizeMode: Text.HorizontalFit
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
                processOutputLabel.text = packageName + " " + qsTr("is") + " " + condition + "."
            } else {
                processOutputLabel.text = condition + " " + packageName + " ..."
            }
        }

        Behavior on opacity {
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
        height: main.height / 15
        width: height * 6
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        hoverEnabled: true
        onContainsMouseChanged: {
            if(containsMouse && isThereOnGoingProcess) {
                queueDialog.open()
            }
        }
    }

    PageIndicator {
        id: indicator
        interactive: true
        count: app.name === "" ? 2 : 3
        currentIndex: swipeView.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        onCurrentIndexChanged: {
            swipeView.currentIndex = indicator.currentIndex
            if (currentIndex == 1) {
                if(navigationBar.currentIndex == 0) {
                    category = qsTr("all")
                    app.name = ""
                }
            } else if (currentIndex == 0) {
                category = qsTr("home")
                app.name = ""
            }
        }

    }
}
