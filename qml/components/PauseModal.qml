import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Progression.js" as Progression

Rectangle {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true
    property int speedMode: 1
    property int difficultyMode: 1
    property int currentCheckpoint: 1
    property var theme: null

    signal resumeRequested()
    signal restartRequested()
    signal restartCheckpointRequested()
    signal mainMenuRequested()
    signal toggleSoundRequested()
    signal toggleHapticsRequested()
    signal speedModeSelected(int newMode)

    anchors.fill: parent
    color: "#E608090A"

    onVisibleChanged: {
        if (visible) {
            pauseFlickable.contentY = 0;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(34))
        height: Math.min(parent.height - units.gu(2.4), modalContent.height + units.gu(3.2))
        radius: units.gu(2.0)
        color: root.theme ? root.theme.cardInner : "#0D0E0F"
        border.color: root.difficultyMode === 3 ? "#7A2E2E" : (root.theme ? root.theme.cardBorder : "#2A2C30")
        border.width: units.gu(0.12)
        scale: root.visible ? 1.0 : 0.88
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }
        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Flickable {
            id: pauseFlickable
            anchors.fill: parent
            anchors.margins: units.gu(1.4)
            contentWidth: width
            contentHeight: modalContent.height
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: modalContent
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: units.gu(1.2)

                // Eyebrow Tag
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.difficultyMode === 3 ? "#261010" : (root.theme ? root.theme.accentBg : "#261E10")
                    border.color: root.difficultyMode === 3 ? "#7A2E2E" : (root.theme ? root.theme.accentBorder : "#544020")
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: root.difficultyMode === 3 ? i18n.tr("INSANE • PERMADEATH") : i18n.tr("DESCENT SUSPENDED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: root.difficultyMode === 3 ? "#F87171" : (root.theme ? root.theme.accent : "#D99B26")
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("PAUSED")
                    font.pixelSize: units.gu(2.8)
                    font.weight: Font.Black
                    color: "#F5F3EF"
                }

                // Primary CTA: Resume Game
                Rectangle {
                    id: resumeBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(2.5)
                    color: resumeMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#BF8419")
                           : (root.theme ? root.theme.accent : "#D99B26")
                    scale: resumeMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(2.6)
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("Resume Descent")
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(3.4)
                        height: units.gu(3.4)
                        radius: units.gu(1.7)
                        color: "#1A000000"

                        Canvas {
                            id: resumeIconCanvas
                            anchors.centerIn: parent
                            width: units.gu(1.4)
                            height: units.gu(1.4)
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = root.theme ? root.theme.accentText : "#0B0C0D";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.2, height * 0.1);
                                ctx.lineTo(width * 0.85, height * 0.5);
                                ctx.lineTo(width * 0.2, height * 0.9);
                                ctx.closePath();
                                ctx.fill();
                            }
                            Connections {
                                target: root
                                function onThemeChanged() { resumeIconCanvas.requestPaint(); }
                            }
                        }
                    }

                    MouseArea {
                        id: resumeMouse
                        anchors.fill: parent
                        onClicked: root.resumeRequested()
                    }
                }

                // Secondary CTA: Restart from Checkpoint or Restart Run
                Rectangle {
                    id: restartCheckpointBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: restartCpMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.difficultyMode === 3 ? "#7A2E2E" : (root.theme ? root.theme.cardBorder : "#2A2C30")
                    border.width: units.gu(0.12)
                    scale: restartCpMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: (root.difficultyMode === 3)
                              ? i18n.tr("Restart Run (Level 1)")
                              : ((root.currentCheckpoint > 1)
                                 ? i18n.tr("Restart Stage %1 (%2)").arg(root.currentCheckpoint).arg(Progression.getZoneName(root.currentCheckpoint))
                                 : i18n.tr("Restart Stage"))
                        font.pixelSize: units.gu(1.35)
                        font.weight: Font.DemiBold
                        color: (root.difficultyMode === 3) ? "#F87171" : "#D6D5D2"
                        elide: Text.ElideRight
                        width: parent.width - units.gu(2.0)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        id: restartCpMouse
                        anchors.fill: parent
                        onClicked: {
                            if (root.difficultyMode === 3) {
                                root.restartRequested();
                            } else {
                                root.restartCheckpointRequested();
                            }
                        }
                    }
                }

                // Tertiary CTA: Restart from Level 1 (visible when past checkpoint 1 in non-permadeath modes)
                Rectangle {
                    id: restartFromBeginningBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    visible: root.difficultyMode !== 3 && root.currentCheckpoint > 1
                    color: restartBeginMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.12)
                    scale: restartBeginMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Restart from Stage 1")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.DemiBold
                        color: "#848890"
                    }

                    MouseArea {
                        id: restartBeginMouse
                        anchors.fill: parent
                        onClicked: root.restartRequested()
                    }
                }

                // Tertiary CTA: Main Menu
                Rectangle {
                    id: menuBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: menuMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.12)
                    scale: menuMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Main Menu")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.DemiBold
                        color: "#D6D5D2"
                    }

                    MouseArea {
                        id: menuMouse
                        anchors.fill: parent
                        onClicked: root.mainMenuRequested()
                    }
                }

                // Game Speed Setting Card
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
                                width: units.gu(7.8)
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
                                width: units.gu(7.8)
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
                                width: units.gu(7.8)
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

                // Settings Row: Sound & Haptics toggles
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.2)

                    Rectangle {
                        id: soundToggleBtn
                        width: (parent.width - units.gu(1.2)) / 2.0
                        height: units.gu(4.0)
                        radius: units.gu(2.0)
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
                        width: (parent.width - units.gu(1.2)) / 2.0
                        height: units.gu(4.0)
                        radius: units.gu(2.0)
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
            }
        }

        // Scroll Indicator Bar
        Rectangle {
            id: scrollIndicator
            anchors.right: parent.right
            anchors.rightMargin: units.gu(0.4)
            width: units.gu(0.3)
            height: Math.max(units.gu(2.0), (pauseFlickable.height / Math.max(1, pauseFlickable.contentHeight)) * (pauseFlickable.height - units.gu(2.0)))
            radius: width / 2
            color: root.theme ? root.theme.accent : "#D99B26"
            visible: pauseFlickable.contentHeight > pauseFlickable.height
            opacity: pauseFlickable.moving ? 0.75 : 0.25
            y: units.gu(1.0) + (pauseFlickable.contentHeight > pauseFlickable.height
               ? Math.max(0.0, Math.min(1.0, pauseFlickable.contentY / (pauseFlickable.contentHeight - pauseFlickable.height))) * (pauseFlickable.height - units.gu(2.0) - height)
               : 0)

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
