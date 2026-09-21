import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true

    signal resumeRequested()
    signal restartRequested()
    signal toggleSoundRequested()
    signal toggleHapticsRequested()

    anchors.fill: parent
    color: "#D90A0E12"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4), units.gu(32))
        height: units.gu(30)
        radius: units.gu(1.5)
        color: "#1c2228"
        border.color: "#2f3842"
        border.width: units.gu(0.15)

        Column {
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            spacing: units.gu(1.4)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("PAUSED")
                font.pixelSize: units.gu(3.0)
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Resume")
                color: "#00b4d8"
                width: units.gu(20)
                height: units.gu(4.2)
                onClicked: root.resumeRequested()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Restart")
                color: "#3b444f"
                width: units.gu(20)
                height: units.gu(4.2)
                onClicked: root.restartRequested()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.soundEnabled ? i18n.tr("Sound: ON") : i18n.tr("Sound: OFF")
                color: root.soundEnabled ? "#2ed573" : "#57606f"
                width: units.gu(20)
                height: units.gu(3.8)
                onClicked: root.toggleSoundRequested()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.hapticsEnabled ? i18n.tr("Vibration: ON") : i18n.tr("Vibration: OFF")
                color: root.hapticsEnabled ? "#2ed573" : "#57606f"
                width: units.gu(20)
                height: units.gu(3.8)
                onClicked: root.toggleHapticsRequested()
            }
        }
    }
}
