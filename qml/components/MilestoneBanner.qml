import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root

    property string text: ""
    property real bannerOpacity: 0.0

    anchors.centerIn: parent
    anchors.verticalCenterOffset: -units.gu(8.0)
    width: outerShell.width
    height: outerShell.height
    opacity: root.bannerOpacity
    visible: opacity > 0.01

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: innerCore.width + units.gu(1.2)
        height: innerCore.height + units.gu(1.2)
        radius: units.gu(2.4)
        color: "#E6241D09"
        border.color: "#F59E0B"
        border.width: units.gu(0.15)
        scale: Math.min(1.0, 0.85 + 0.15 * root.bannerOpacity)

        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: contentCol.width + units.gu(3.6)
            height: contentCol.height + units.gu(2.0)
            radius: units.gu(1.8)
            color: "#0F0C04"
            border.color: "#3D2E0B"
            border.width: units.gu(0.08)

            Column {
                id: contentCol
                anchors.centerIn: parent
                spacing: units.gu(0.3)

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: stageTag.width + units.gu(1.6)
                    height: units.gu(1.8)
                    radius: units.gu(0.9)
                    color: "#2E240D"

                    Label {
                        id: stageTag
                        anchors.centerIn: parent
                        text: i18n.tr("STAGE COMPLETED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: "#F59E0B"
                    }
                }

                Label {
                    id: bannerLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.text
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.Black
                    color: "#FFFFFF"
                }
            }
        }
    }
}
