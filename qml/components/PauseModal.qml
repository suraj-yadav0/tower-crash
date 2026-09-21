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
    color: "#E6080C10"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4), units.gu(32))
        height: contentColumn.height + units.gu(4.0)
        radius: units.gu(2.0)
        color: "#141A22"
        border.color: "#253344"
        border.width: units.gu(0.15)

        Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - units.gu(4.0)
            spacing: units.gu(1.4)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("PAUSED")
                font.pixelSize: units.gu(2.8)
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Resume Game")
                color: "#00b4d8"
                width: parent.width
                height: units.gu(4.5)
                onClicked: root.resumeRequested()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Restart Level")
                color: "#273240"
                width: parent.width
                height: units.gu(4.2)
                onClicked: root.restartRequested()
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1.2)
                width: parent.width

                Button {
                    width: (parent.width - units.gu(1.2)) / 2.0
                    height: units.gu(4.0)
                    text: root.soundEnabled ? i18n.tr("Sound: ON") : i18n.tr("Sound: OFF")
                    color: root.soundEnabled ? "#10B981" : "#374151"
                    onClicked: root.toggleSoundRequested()
                }

                Button {
                    width: (parent.width - units.gu(1.2)) / 2.0
                    height: units.gu(4.0)
                    text: root.hapticsEnabled ? i18n.tr("Vibe: ON") : i18n.tr("Vibe: OFF")
                    color: root.hapticsEnabled ? "#10B981" : "#374151"
                    onClicked: root.toggleHapticsRequested()
                }
            }
        }
    }
}
