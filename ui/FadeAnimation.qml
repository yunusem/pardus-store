import QtQuick 2.0

SequentialAnimation {
    id: fade
    property QtObject target
    property string child: "opacity"
    property int duration
    NumberAnimation {
        id: outAnimation
        target: fade.target
        property: fade.child
        duration: fade.duration / 2
        to: 0.0
    }
    PropertyAction { }
    NumberAnimation {
        id: inAnimation
        target: fade.target
        property: fade.child
        duration: fade.duration / 2
        to: 1.0
    }
}
