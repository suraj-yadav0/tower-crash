import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true
    property int speedMode: 1
    property int bestScore: 0
    property int totalRings: 0

    signal closeRequested()
    signal toggleSoundRequested()
    signal toggleHapticsRequested()
    signal speedModeSelected(int newMode)

    anchors.fill: parent
    color: "#E604070A"
    visible: false
    z: 200

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(36))
        height: innerCore.height + units.gu(2.0)
        radius: units.gu(2.4)
        color: "#0E141C"
        border.color: "#223142"
        border.width: units.gu(0.15)
        scale: root.visible ? 1.0 : 0.88
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: outerShell.width - units.gu(1.6)
            height: modalContent.height + units.gu(3.6)
            radius: units.gu(1.8)
            color: "#080C10"
            border.color: "#16202C"
            border.width: units.gu(0.1)

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.4)

                // Eyebrow Tag
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: "#162230"
                    border.color: "#243447"
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: i18n.tr("PREFERENCES")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: "#00D2D3"
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("SETTINGS")
                    font.pixelSize: units.gu(2.6)
                    font.weight: Font.Black
                    color: "#FFFFFF"
                }

                // Fall Speed Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(6.0)
                    radius: units.gu(1.4)
                    color: "#0E141C"
                    border.color: "#223142"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.6)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("FALL SPEED")
                            font.pixelSize: units.gu(1.0)
                            font.weight: Font.Bold
                            color: "#64748B"
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: units.gu(0.6)

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.8)
                                radius: units.gu(1.4)
                                color: root.speedMode === 0 ? "#00D2D3" : (slowMouse.pressed ? "#1E2A3A" : "#121A24")
                                border.color: root.speedMode === 0 ? "#00D2D3" : "#253344"
                                border.width: units.gu(0.1)
                                scale: slowMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Slow")
                                    font.pixelSize: units.gu(1.2)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 0 ? "#04070A" : "#94A3B8"
                                }

                                MouseArea {
                                    id: slowMouse
                                    anchors.fill: parent
                                    onClicked: root.speedModeSelected(0)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.8)
                                radius: units.gu(1.4)
                                color: root.speedMode === 1 ? "#00D2D3" : (normalMouse.pressed ? "#1E2A3A" : "#121A24")
                                border.color: root.speedMode === 1 ? "#00D2D3" : "#253344"
                                border.width: units.gu(0.1)
                                scale: normalMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Normal")
                                    font.pixelSize: units.gu(1.2)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 1 ? "#04070A" : "#94A3B8"
                                }

                                MouseArea {
                                    id: normalMouse
                                    anchors.fill: parent
                                    onClicked: root.speedModeSelected(1)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.8)
                                radius: units.gu(1.4)
                                color: root.speedMode === 2 ? "#00D2D3" : (fastMouse.pressed ? "#1E2A3A" : "#121A24")
                                border.color: root.speedMode === 2 ? "#00D2D3" : "#253344"
                                border.width: units.gu(0.1)
                                scale: fastMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Fast")
                                    font.pixelSize: units.gu(1.2)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 2 ? "#04070A" : "#94A3B8"
                                }

                                MouseArea {
                                    id: fastMouse
                                    anchors.fill: parent
                                    onClicked: root.speedModeSelected(2)
                                }
                            }
                        }
                    }
                }

                // Audio & Haptics Toggles Row
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    Rectangle {
                        id: soundToggleBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.2)
                        radius: units.gu(2.1)
                        color: soundToggleMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.soundEnabled ? "#10B981" : "#223142"
                        border.width: units.gu(0.12)
                        scale: soundToggleMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.8)

                            Rectangle {
                                width: units.gu(0.8)
                                height: units.gu(0.8)
                                radius: units.gu(0.4)
                                color: root.soundEnabled ? "#10B981" : "#64748B"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.soundEnabled ? i18n.tr("Sound ON") : i18n.tr("Sound OFF")
                                font.pixelSize: units.gu(1.3)
                                font.weight: Font.DemiBold
                                color: root.soundEnabled ? "#FFFFFF" : "#64748B"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: soundToggleMouse
                            anchors.fill: parent
                            onClicked: root.toggleSoundRequested()
                        }
                    }

                    Rectangle {
                        id: hapticsToggleBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.2)
                        radius: units.gu(2.1)
                        color: hapticsToggleMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.hapticsEnabled ? "#10B981" : "#223142"
                        border.width: units.gu(0.12)
                        scale: hapticsToggleMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.8)

                            Rectangle {
                                width: units.gu(0.8)
                                height: units.gu(0.8)
                                radius: units.gu(0.4)
                                color: root.hapticsEnabled ? "#10B981" : "#64748B"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.hapticsEnabled ? i18n.tr("Vibe ON") : i18n.tr("Vibe OFF")
                                font.pixelSize: units.gu(1.3)
                                font.weight: Font.DemiBold
                                color: root.hapticsEnabled ? "#FFFFFF" : "#64748B"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: hapticsToggleMouse
                            anchors.fill: parent
                            onClicked: root.toggleHapticsRequested()
                        }
                    }
                }

                // Player Stats Summary
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.6)
                    radius: units.gu(1.4)
                    color: "#0E141C"
                    border.color: "#223142"
                    border.width: units.gu(0.1)

                    Row {
                        anchors.fill: parent

                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("BEST SCORE")
                                    font.pixelSize: units.gu(0.9)
                                    font.weight: Font.Bold
                                    color: "#64748B"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.bestScore.toString()
                                    font.pixelSize: units.gu(1.5)
                                    font.weight: Font.Black
                                    color: "#FFD166"
                                }
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: units.dp(1)
                            height: parent.height - units.gu(1.6)
                            color: "#1E2A3A"
                        }

                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("TOTAL RINGS")
                                    font.pixelSize: units.gu(0.9)
                                    font.weight: Font.Bold
                                    color: "#64748B"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.totalRings.toString()
                                    font.pixelSize: units.gu(1.5)
                                    font.weight: Font.Black
                                    color: "#00D2D3"
                                }
                            }
                        }
                    }
                }

                // Done CTA Button
                Rectangle {
                    id: doneBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.6)
                    radius: units.gu(2.3)
                    color: doneMouse.pressed ? "#00B4B5" : "#00D2D3"
                    scale: doneMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Done")
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.Bold
                        color: "#04070A"
                    }

                    MouseArea {
                        id: doneMouse
                        anchors.fill: parent
                        onClicked: root.closeRequested()
                    }
                }
            }
        }
    }
}
