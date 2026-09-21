import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true
    property int speedMode: 1

    signal resumeRequested()
    signal restartRequested()
    signal toggleSoundRequested()
    signal toggleHapticsRequested()
    signal speedModeSelected(int newMode)

    anchors.fill: parent
    color: "#E604070A"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    // Outer Shell (Double-Bezel architecture)
    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(34))
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

        // Inner Core
        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: outerShell.width - units.gu(1.6)
            height: modalContent.height + units.gu(4.0)
            radius: units.gu(1.8)
            color: "#080C10"
            border.color: "#16202C"
            border.width: units.gu(0.1)

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.6)

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
                        text: i18n.tr("GAME SUSPENDED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: "#00D2D3"
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("PAUSED")
                    font.pixelSize: units.gu(2.8)
                    font.weight: Font.Black
                    color: "#FFFFFF"
                }

                // Primary CTA: Resume Game (Button-in-Button Pattern)
                Rectangle {
                    id: resumeBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(2.5)
                    color: resumeMouse.pressed ? "#00B4B5" : "#00D2D3"
                    scale: resumeMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(2.6)
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("Resume Game")
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.Bold
                        color: "#04070A"
                    }

                    // Trailing icon circle wrapper
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(3.4)
                        height: units.gu(3.4)
                        radius: units.gu(1.7)
                        color: "#1A000000"

                        Canvas {
                            anchors.centerIn: parent
                            width: units.gu(1.4)
                            height: units.gu(1.4)
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = "#04070A";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.2, height * 0.1);
                                ctx.lineTo(width * 0.85, height * 0.5);
                                ctx.lineTo(width * 0.2, height * 0.9);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    MouseArea {
                        id: resumeMouse
                        anchors.fill: parent
                        onClicked: root.resumeRequested()
                    }
                }

                // Secondary CTA: Restart Level
                Rectangle {
                    id: restartBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: restartMouse.pressed ? "#1E2A3A" : "#121A24"
                    border.color: "#223142"
                    border.width: units.gu(0.12)
                    scale: restartMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Restart Level")
                        font.pixelSize: units.gu(1.5)
                        font.weight: Font.DemiBold
                        color: "#E2E8F0"
                    }

                    MouseArea {
                        id: restartMouse
                        anchors.fill: parent
                        onClicked: root.restartRequested()
                    }
                }

                // Game Speed Setting Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.6)
                    radius: units.gu(1.4)
                    color: "#0E141C"
                    border.color: "#223142"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)

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

                            // Slow Option
                            Rectangle {
                                width: units.gu(7.8)
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

                            // Normal Option
                            Rectangle {
                                width: units.gu(7.8)
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

                            // Fast Option
                            Rectangle {
                                width: units.gu(7.8)
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

                // Settings Row: Sound & Haptics toggles
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.2)

                    // Sound Toggle Pill
                    Rectangle {
                        id: soundToggleBtn
                        width: (parent.width - units.gu(1.2)) / 2.0
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

                    // Haptics Toggle Pill
                    Rectangle {
                        id: hapticsToggleBtn
                        width: (parent.width - units.gu(1.2)) / 2.0
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
            }
        }
    }
}
