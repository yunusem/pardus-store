import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import ps.helper 1.0

ApplicationWindow {
    id: test
    width: 400
    height: 300
    visible: true

    Helper {
        id: helper
        onProcessingFinished: {
            console.log("installing finished")
            btn.enabled = true
            btn2.enabled = true
        }
    }

    Column {
        anchors.centerIn: parent
        Button {
            id: btn

            text: "install"
            onClicked:  {
                btn.enabled = false
                btn2.enabled = false
                helper.install("htop")
            }
        }

        Button {
            id: btn2

            text: "remove"
            onClicked:  {
                btn2.enabled = false
                btn.enabled = false
                helper.remove("htop")
            }
        }
    }

    TextField {
        id: t
        anchors.right: parent.right
        onTextChanged: {
            var list = helper.getApplicationsByName(t.text)
            console.log(list)
        }
    }
}
