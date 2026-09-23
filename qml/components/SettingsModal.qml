import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Rectangle {
    id: root

    property bool soundEnabled: true
    property real soundVolume: 0.85
    property bool hapticsEnabled: true
    property int speedMode: 1
    property int themeMode: 0
    property real touchSensitivityMultiplier: 1.0
    property int bestScore: 0
    property int totalRings: 0
    property var theme: null

    signal closeRequested()
    signal toggleSoundRequested()
    signal volumeChanged(real newVolume)
    signal toggleHapticsRequested()
    signal speedModeSelected(int newMode)
    signal touchSensitivitySelected(real newSensitivity)
    signal themeModeSelected(int newMode)

    anchors.fill: parent
    color: "#E608090A"
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
        height: Math.min(parent.height - units.gu(3.0), innerCore.height + units.gu(2.0))
        radius: units.gu(2.0)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
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
            height: Math.min(outerShell.height - units.gu(1.6), modalContent.height + units.gu(2.8))
            radius: units.gu(1.6)
            color: root.theme ? root.theme.cardInner : "#0D0E0F"
            border.color: root.theme ? root.theme.cardBorder : "#222428"
            border.width: units.gu(0.1)

            Flickable {
                anchors.fill: parent
                anchors.margins: units.gu(1.0)
                contentWidth: width
                contentHeight: modalContent.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: modalContent
                    width: parent.width
                    spacing: units.gu(1.1)

                // Eyebrow Tag
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.theme ? root.theme.accentBg : "#261E10"
                    border.color: root.theme ? root.theme.accentBorder : "#544020"
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: i18n.tr("INSTRUMENTATION")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accent : "#D99B26"
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("SETTINGS")
                    font.pixelSize: units.gu(2.4)
                    font.weight: Font.Black
                    color: "#F5F3EF"
                }

                // Theme Selection Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(8.8)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - units.gu(2.0)
                        spacing: units.gu(0.5)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("MATERIAL PALETTE")
                            font.pixelSize: units.gu(0.95)
                            font.weight: Font.Bold
                            color: "#848890"
                        }

                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 3
                            spacing: units.gu(0.5)

                            Repeater {
                                model: Themes.themeOptions
                                delegate: Rectangle {
                                    width: (parent.parent.width - units.gu(1.0)) / 3.0
                                    height: units.gu(2.7)
                                    radius: units.gu(1.35)
                                    color: root.themeMode === modelData.id
                                           ? (root.theme ? root.theme.accentBg : "#261E10")
                                           : (themeChipMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                    border.color: root.themeMode === modelData.id
                                                  ? (root.theme ? root.theme.accent : "#D99B26")
                                                  : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                    border.width: root.themeMode === modelData.id ? units.gu(0.12) : units.gu(0.08)
                                    scale: themeChipMouse.pressed ? 0.94 : 1.0

                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: units.gu(0.5)

                                        Rectangle {
                                            width: units.gu(0.75)
                                            height: units.gu(0.75)
                                            radius: width / 2
                                            color: modelData.previewColor
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Label {
                                            text: modelData.name
                                            font.pixelSize: units.gu(1.0)
                                            font.weight: root.themeMode === modelData.id ? Font.Bold : Font.DemiBold
                                            color: root.themeMode === modelData.id
                                                   ? (root.theme ? root.theme.accent : "#D99B26")
                                                   : "#8E929A"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: themeChipMouse
                                        anchors.fill: parent
                                        onClicked: root.themeModeSelected(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }

                // Fall Speed Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.6)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("FALL SPEED")
                            font.pixelSize: units.gu(0.95)
                            font.weight: Font.Bold
                            color: "#848890"
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: units.gu(0.6)

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: root.speedMode === 0
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (slowMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: root.speedMode === 0
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: slowMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Slow")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 0
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
                                }

                                MouseArea {
                                    id: slowMouse
                                    anchors.fill: parent
                                    onClicked: root.speedModeSelected(0)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: root.speedMode === 1
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (normalMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: root.speedMode === 1
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: normalMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Normal")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 1
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
                                }

                                MouseArea {
                                    id: normalMouse
                                    anchors.fill: parent
                                    onClicked: root.speedModeSelected(1)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: root.speedMode === 2
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (fastMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: root.speedMode === 2
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: fastMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Fast")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: root.speedMode === 2
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
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

                // Touch Sensitivity Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.6)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.5)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("TOUCH SENSITIVITY")
                            font.pixelSize: units.gu(0.95)
                            font.weight: Font.Bold
                            color: "#848890"
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: units.gu(0.6)

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: Math.abs(root.touchSensitivityMultiplier - 0.75) < 0.05
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (sensLowMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: Math.abs(root.touchSensitivityMultiplier - 0.75) < 0.05
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: sensLowMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Low")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: Math.abs(root.touchSensitivityMultiplier - 0.75) < 0.05
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
                                }

                                MouseArea {
                                    id: sensLowMouse
                                    anchors.fill: parent
                                    onClicked: root.touchSensitivitySelected(0.75)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: Math.abs(root.touchSensitivityMultiplier - 1.0) < 0.05
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (sensNormMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: Math.abs(root.touchSensitivityMultiplier - 1.0) < 0.05
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: sensNormMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("Normal")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: Math.abs(root.touchSensitivityMultiplier - 1.0) < 0.05
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
                                }

                                MouseArea {
                                    id: sensNormMouse
                                    anchors.fill: parent
                                    onClicked: root.touchSensitivitySelected(1.0)
                                }
                            }

                            Rectangle {
                                width: units.gu(8.2)
                                height: units.gu(2.7)
                                radius: units.gu(1.35)
                                color: Math.abs(root.touchSensitivityMultiplier - 1.35) < 0.05
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : (sensHighMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                                border.color: Math.abs(root.touchSensitivityMultiplier - 1.35) < 0.05
                                              ? (root.theme ? root.theme.accent : "#D99B26")
                                              : (root.theme ? root.theme.cardBorder : "#2A2C30")
                                border.width: units.gu(0.1)
                                scale: sensHighMouse.pressed ? 0.94 : 1.0

                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: i18n.tr("High")
                                    font.pixelSize: units.gu(1.15)
                                    font.weight: Font.Bold
                                    color: Math.abs(root.touchSensitivityMultiplier - 1.35) < 0.05
                                           ? (root.theme ? root.theme.accentText : "#0B0C0D")
                                           : "#8E929A"
                                }

                                MouseArea {
                                    id: sensHighMouse
                                    anchors.fill: parent
                                    onClicked: root.touchSensitivitySelected(1.35)
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
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: soundToggleMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.soundEnabled
                                      ? (root.theme ? root.theme.accent : "#D99B26")
                                      : (root.theme ? root.theme.cardBorder : "#2A2C30")
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
                                color: root.soundEnabled
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : "#555A64"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.soundEnabled ? i18n.tr("Audio ON") : i18n.tr("Audio OFF")
                                font.pixelSize: units.gu(1.2)
                                font.weight: Font.DemiBold
                                color: root.soundEnabled ? "#F5F3EF" : "#848890"
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
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: hapticsToggleMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.hapticsEnabled
                                      ? (root.theme ? root.theme.accent : "#D99B26")
                                      : (root.theme ? root.theme.cardBorder : "#2A2C30")
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
                                color: root.hapticsEnabled
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : "#555A64"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.hapticsEnabled ? i18n.tr("Haptic ON") : i18n.tr("Haptic OFF")
                                font.pixelSize: units.gu(1.2)
                                font.weight: Font.DemiBold
                                color: root.hapticsEnabled ? "#F5F3EF" : "#848890"
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

                // Sound Volume Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.8)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - units.gu(2.4)
                        spacing: units.gu(0.4)

                        Item {
                            width: parent.width
                            height: units.gu(1.5)

                            Label {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: i18n.tr("SOUND VOLUME")
                                font.pixelSize: units.gu(0.95)
                                font.weight: Font.Bold
                                color: "#848890"
                            }

                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: Math.round(root.soundVolume * 100) + "%"
                                font.pixelSize: units.gu(0.95)
                                font.weight: Font.Bold
                                color: root.soundEnabled ? (root.theme ? root.theme.accent : "#D99B26") : "#555A64"
                            }
                        }

                        Rectangle {
                            id: volTrack
                            width: parent.width
                            height: units.gu(1.8)
                            radius: units.gu(0.9)
                            color: root.theme ? root.theme.cardInner : "#0D0E0F"
                            border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                            border.width: units.gu(0.08)
                            clip: true

                            Rectangle {
                                width: Math.max(parent.radius * 2, parent.width * Math.max(0.0, Math.min(1.0, root.soundVolume)))
                                height: parent.height
                                radius: parent.radius
                                color: root.soundEnabled ? (root.theme ? root.theme.accent : "#D99B26") : "#3A3D44"
                                opacity: root.soundEnabled ? 1.0 : 0.4
                            }

                            MouseArea {
                                anchors.fill: parent
                                preventStealing: true
                                function updateVol(mx) {
                                    var fraction = Math.max(0.0, Math.min(1.0, mx / width));
                                    root.volumeChanged(fraction);
                                }
                                onPressed: updateVol(mouse.x)
                                onPositionChanged: if (pressed) updateVol(mouse.x)
                            }
                        }
                    }
                }

                // Player Stats Summary
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
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
                                    text: i18n.tr("BEST RECORD")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#848890"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.bestScore.toString()
                                    font.pixelSize: units.gu(1.4)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.ballMid : "#E6D7BA"
                                }
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: units.dp(1)
                            height: parent.height - units.gu(1.6)
                            color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        }

                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("TOTAL SMASHED")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#848890"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.totalRings.toString()
                                    font.pixelSize: units.gu(1.4)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.accent : "#D99B26"
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
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: doneMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#BF8419")
                           : (root.theme ? root.theme.accent : "#D99B26")
                    scale: doneMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Apply & Close")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
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
}
