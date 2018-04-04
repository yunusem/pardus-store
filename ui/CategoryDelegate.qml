import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Pane {
            id: categoryDelegateItem
            width: navi.width - 22
            height: navima.containsMouse ? navigationBarListView.unFoldHeight : navigationBarListView.foldHeight
            Material.background: color
            Material.elevation: 3
            Label {
                anchors.centerIn: parent
                opacity: navima.containsMouse ? 1.0 : 0.0
                color: name === selectedCategory ? "white" : Material.color(Material.BlueGrey)
                font.capitalization: Font.AllUppercase
                font.bold: true
                text: name

                Behavior on opacity {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 200
                    }
                }
            }

            Behavior on height {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }




            MouseArea {
                id: categoryDelegateItemMa
                anchors.centerIn: parent
                width: categoryDelegateItem.width
                height: categoryDelegateItem.height
                onClicked: {
                    selectedCategory = name
                    navigationBarListView.currentIndex = categories.indexOf(name)
                }
                onPressed: {
                    categoryDelegateItem.Material.elevation = 0

                }
                onReleased: {

                    categoryDelegateItem.Material.elevation = 3
                }
            }
        }
