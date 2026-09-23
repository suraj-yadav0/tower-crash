import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int bestScore: 0
    property int totalRings: 0
    property int speedMode: 1
    property int selectedCheckpoint: 1
    property var unlockedCheckpoints: [1]
    property bool showingHowToPlay: false
    property var theme: null
    property string themeName: ""

    signal playRequested()
    signal checkpointSelected(int checkpoint)
    signal settingsRequested()
    signal themeCycleRequested()
    signal speedCycleRequested()

    anchors.fill: parent
    color: "#E608090A"
    visible: false
    z: 150

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(36))
        height: innerCore.height + units.gu(2.0)
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
            height: root.showingHowToPlay ? (howToPlayContent.height + units.gu(3.6)) : (menuContent.height + units.gu(3.6))
            radius: units.gu(1.6)
            color: root.theme ? root.theme.cardInner : "#0D0E0F"
            border.color: root.theme ? root.theme.cardBorder : "#222428"
            border.width: units.gu(0.1)

            Behavior on height {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }

            // Main Menu View
            Column {
                id: menuContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.3)
                visible: !root.showingHowToPlay

                // Mechanical Subtitle Badge
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: arcadeBadgeLabel.width + units.gu(2.2)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.theme ? root.theme.accentBg : "#261E10"
                    border.color: root.theme ? root.theme.accentBorder : "#544020"
                    border.width: units.gu(0.1)

                    Label {
                        id: arcadeBadgeLabel
                        anchors.centerIn: parent
                        text: i18n.tr("PRECISION DESCENT")
                        font.pixelSize: units.gu(0.95)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accent : "#D99B26"
                    }
                }

                // Title Banner
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(0.2)

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("TOWER CRASH")
                        font.pixelSize: units.gu(3.0)
                        font.weight: Font.Black
                        color: "#F5F3EF"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("TACTILE HELICAL DESCENT")
                        font.pixelSize: units.gu(1.05)
                        font.weight: Font.DemiBold
                        color: "#848890"
                    }
                }

                // Checkpoint Selector Bento Card
                Rectangle {
                    id: checkpointSelector
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Row {
                        anchors.fill: parent

                        // Previous Checkpoint Arrow Button
                        Rectangle {
                            id: prevCpBtn
                            width: units.gu(4.4)
                            height: parent.height
                            color: prevCpMouse.pressed ? "#1E2024" : "transparent"
                            radius: units.gu(1.4)
                            opacity: (root.unlockedCheckpoints && root.unlockedCheckpoints.indexOf(root.selectedCheckpoint) > 0) ? 1.0 : 0.25

                            Canvas {
                                id: prevArrowCanvas
                                anchors.centerIn: parent
                                width: units.gu(1.2)
                                height: units.gu(1.2)
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.fillStyle = root.theme ? root.theme.accent : "#D99B26";
                                    ctx.beginPath();
                                    ctx.moveTo(width * 0.75, height * 0.15);
                                    ctx.lineTo(width * 0.25, height * 0.5);
                                    ctx.lineTo(width * 0.75, height * 0.85);
                                    ctx.closePath();
                                    ctx.fill();
                                }
                                Connections {
                                    target: root
                                    onThemeChanged: prevArrowCanvas.requestPaint()
                                }
                            }

                            MouseArea {
                                id: prevCpMouse
                                anchors.fill: parent
                                enabled: root.unlockedCheckpoints && root.unlockedCheckpoints.indexOf(root.selectedCheckpoint) > 0
                                onClicked: {
                                    var idx = root.unlockedCheckpoints.indexOf(root.selectedCheckpoint);
                                    if (idx > 0) {
                                        root.checkpointSelected(root.unlockedCheckpoints[idx - 1]);
                                    }
                                }
                            }
                        }

                        // Center Label: Stage and Subtitle
                        Item {
                            width: parent.width - units.gu(8.8)
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.1)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("START: STAGE %1").arg(root.selectedCheckpoint)
                                    font.pixelSize: units.gu(1.3)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.accent : "#D99B26"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: (root.selectedCheckpoint === 1)
                                          ? i18n.tr("Initial Descent")
                                          : i18n.tr("Unlocked Checkpoint")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.DemiBold
                                    color: "#848890"
                                }
                            }
                        }

                        // Next Checkpoint Arrow Button
                        Rectangle {
                            id: nextCpBtn
                            width: units.gu(4.4)
                            height: parent.height
                            color: nextCpMouse.pressed ? "#1E2024" : "transparent"
                            radius: units.gu(1.4)
                            opacity: (root.unlockedCheckpoints && root.unlockedCheckpoints.indexOf(root.selectedCheckpoint) < root.unlockedCheckpoints.length - 1) ? 1.0 : 0.25

                            Canvas {
                                id: nextArrowCanvas
                                anchors.centerIn: parent
                                width: units.gu(1.2)
                                height: units.gu(1.2)
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.fillStyle = root.theme ? root.theme.accent : "#D99B26";
                                    ctx.beginPath();
                                    ctx.moveTo(width * 0.25, height * 0.15);
                                    ctx.lineTo(width * 0.75, height * 0.5);
                                    ctx.lineTo(width * 0.25, height * 0.85);
                                    ctx.closePath();
                                    ctx.fill();
                                }
                                Connections {
                                    target: root
                                    onThemeChanged: nextArrowCanvas.requestPaint()
                                }
                            }

                            MouseArea {
                                id: nextCpMouse
                                anchors.fill: parent
                                enabled: root.unlockedCheckpoints && root.unlockedCheckpoints.indexOf(root.selectedCheckpoint) < root.unlockedCheckpoints.length - 1
                                onClicked: {
                                    var idx = root.unlockedCheckpoints.indexOf(root.selectedCheckpoint);
                                    if (idx >= 0 && idx < root.unlockedCheckpoints.length - 1) {
                                        root.checkpointSelected(root.unlockedCheckpoints[idx + 1]);
                                    }
                                }
                            }
                        }
                    }
                }

                // Primary CTA: Play Game
                Rectangle {
                    id: playBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.2)
                    radius: units.gu(2.6)
                    color: playMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#BF8419")
                           : (root.theme ? root.theme.accent : "#D99B26")
                    scale: playMouse.pressed ? 0.96 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1.2)

                        Canvas {
                            id: playIconCanvas
                            width: units.gu(1.5)
                            height: units.gu(1.5)
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = root.theme ? root.theme.accentText : "#0B0C0D";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.15, height * 0.05);
                                ctx.lineTo(width * 0.9, height * 0.5);
                                ctx.lineTo(width * 0.15, height * 0.95);
                                ctx.closePath();
                                ctx.fill();
                            }
                            Connections {
                                target: root
                                onThemeChanged: playIconCanvas.requestPaint()
                            }
                        }

                        Label {
                            text: i18n.tr("ENTER TOWER")
                            font.pixelSize: units.gu(1.7)
                            font.weight: Font.Black
                            color: root.theme ? root.theme.accentText : "#0B0C0D"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        onClicked: root.playRequested()
                    }
                }

                // Secondary Action Row: Settings & How to Play
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    // Settings Button
                    Rectangle {
                        id: settingsBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.2)
                        radius: units.gu(2.1)
                        color: settingsMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.12)
                        scale: settingsMouse.pressed ? 0.95 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Label {
                            anchors.centerIn: parent
                            text: i18n.tr("Settings")
                            font.pixelSize: units.gu(1.35)
                            font.weight: Font.Bold
                            color: "#D6D5D2"
                        }

                        MouseArea {
                            id: settingsMouse
                            anchors.fill: parent
                            onClicked: root.settingsRequested()
                        }
                    }

                    // How to Play Button
                    Rectangle {
                        id: guideBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.2)
                        radius: units.gu(2.1)
                        color: guideMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.12)
                        scale: guideMouse.pressed ? 0.95 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Label {
                            anchors.centerIn: parent
                            text: i18n.tr("How to Play")
                            font.pixelSize: units.gu(1.35)
                            font.weight: Font.Bold
                            color: "#D6D5D2"
                        }

                        MouseArea {
                            id: guideMouse
                            anchors.fill: parent
                            onClicked: root.showingHowToPlay = true
                        }
                    }
                }

                // Quick Setup Row: Theme & Speed Toggles
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    // Quick Theme Switcher
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: themeMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.1)
                        scale: themeMouse.pressed ? 0.95 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.7)

                            Rectangle {
                                width: units.gu(0.85)
                                height: units.gu(0.85)
                                radius: width / 2
                                color: root.theme ? (root.theme.previewColor || root.theme.accent) : "#D99B26"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.themeName.length > 0 ? root.themeName : i18n.tr("Theme")
                                font.pixelSize: units.gu(1.05)
                                font.weight: Font.DemiBold
                                color: "#D6D5D2"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: themeMouse
                            anchors.fill: parent
                            onClicked: root.themeCycleRequested()
                        }
                    }

                    // Quick Speed Switcher
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: speedMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.1)
                        scale: speedMouse.pressed ? 0.95 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.6)

                            Label {
                                text: i18n.tr("Speed: %1").arg(root.speedMode === 0 ? i18n.tr("Slow") : (root.speedMode === 2 ? i18n.tr("Fast") : i18n.tr("Normal")))
                                font.pixelSize: units.gu(1.05)
                                font.weight: Font.DemiBold
                                color: "#D6D5D2"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: speedMouse
                            anchors.fill: parent
                            onClicked: root.speedCycleRequested()
                        }
                    }
                }

                // Player Records Bento Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Row {
                        anchors.fill: parent

                        // Best Score
                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("BEST SCORE")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#848890"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.bestScore.toString()
                                    font.pixelSize: units.gu(1.5)
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

                        // Total Rings Passed
                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("RINGS CRASHED")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#848890"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.totalRings.toString()
                                    font.pixelSize: units.gu(1.5)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.accent : "#D99B26"
                                }
                            }
                        }
                    }
                }
            }

            // How to Play View
            Column {
                id: howToPlayContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.2)
                visible: root.showingHowToPlay

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("FLIGHT MANUAL")
                    font.pixelSize: units.gu(2.0)
                    font.weight: Font.Black
                    color: root.theme ? root.theme.accent : "#D99B26"
                }

                // Instructions Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: instructionsCol.height + units.gu(2.4)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        id: instructionsCol
                        anchors.centerIn: parent
                        width: parent.width - units.gu(2.4)
                        spacing: units.gu(0.9)

                        Row {
                            spacing: units.gu(1.0)
                            width: parent.width

                            Rectangle {
                                width: units.gu(2.0)
                                height: units.gu(2.0)
                                radius: units.gu(1.0)
                                color: root.theme ? root.theme.accent : "#D99B26"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "1"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: root.theme ? root.theme.accentText : "#0B0C0D"
                                }
                            }

                            Label {
                                text: i18n.tr("Drag horizontally to rotate the helical tower.")
                                font.pixelSize: units.gu(1.2)
                                color: "#D6D5D2"
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(3.0)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: units.gu(1.0)
                            width: parent.width

                            Rectangle {
                                width: units.gu(2.0)
                                height: units.gu(2.0)
                                radius: units.gu(1.0)
                                color: root.theme ? root.theme.accent : "#D99B26"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "2"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: root.theme ? root.theme.accentText : "#0B0C0D"
                                }
                            }

                            Label {
                                text: i18n.tr("Drop through ring gaps to gain gravity momentum.")
                                font.pixelSize: units.gu(1.2)
                                color: "#D6D5D2"
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(3.0)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: units.gu(1.0)
                            width: parent.width

                            Rectangle {
                                width: units.gu(2.0)
                                height: units.gu(2.0)
                                radius: units.gu(1.0)
                                color: root.theme ? root.theme.topHazard : "#BA3C3C"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "!"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                }
                            }

                            Label {
                                text: i18n.tr("Avoid landing directly on hazard zones.")
                                font.pixelSize: units.gu(1.2)
                                color: root.theme ? root.theme.topHazard : "#BA3C3C"
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(3.0)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: units.gu(1.0)
                            width: parent.width

                            Rectangle {
                                width: units.gu(2.0)
                                height: units.gu(2.0)
                                radius: units.gu(1.0)
                                color: root.theme ? root.theme.ballMid : "#E6D7BA"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "3"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: "#0B0C0D"
                                }
                            }

                            Label {
                                text: i18n.tr("Drop past 3 continuous rings to smash platforms!")
                                font.pixelSize: units.gu(1.2)
                                color: root.theme ? root.theme.ballMid : "#E6D7BA"
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(3.0)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Back Button
                Rectangle {
                    id: backBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: backMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#BF8419")
                           : (root.theme ? root.theme.accent : "#D99B26")
                    scale: backMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Back to Main")
                        font.pixelSize: units.gu(1.5)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        onClicked: root.showingHowToPlay = false
                    }
                }
            }
        }
    }
}
