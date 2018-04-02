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
        onInstallingFinished: {
            console.log("installing finished")
            btn.enabled = true

        }
    }

    Button {
        id: btn
        anchors.centerIn: parent
        text: "install"
        onClicked:  {
            btn.enabled = false
            helper.startInstalling("thunderbird")
        }
    }

    Button {
        text: "Test"
        onClicked: {
            console.log("test")
        }
    }

    TextField {
        id: t
        onTextChanged: {
            var list = helper.getApplicationsByName(t.text)
            console.log(list)
        }
    }
}
