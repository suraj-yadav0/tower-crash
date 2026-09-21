import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property string text: ""
    property real bannerOpacity: 0.0

    anchors.centerIn: parent
    anchors.verticalCenterOffset: -units.gu(8)
    width: bannerLabel.width + units.gu(4)
    height: units.gu(5)
    radius: units.gu(2.5)
    color: "#E6000000"
    border.color: "#FFD700"
    border.width: units.gu(0.2)
    opacity: root.bannerOpacity
    visible: opacity > 0

    Label {
        id: bannerLabel
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: units.gu(2.2)
        font.weight: Font.Bold
        color: "#FFD700"
    }
}
