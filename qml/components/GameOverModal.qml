import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int score: 0
    property int bestScore: 0
    property int levelReached: 1

    signal restartRequested()

    anchors.fill: parent
    color: "#E6080C10"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4), units.gu(34))
        height: cardColumn.height + units.gu(4.2)
        radius: units.gu(2.0)
        color: "#141A22"
        border.color: "#253344"
        border.width: units.gu(0.15)

        Column {
            id: cardColumn
            anchors.centerIn: parent
            width: parent.width - units.gu(4.0)
            spacing: units.gu(1.4)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("GAME OVER")
                font.pixelSize: units.gu(3.0)
                font.weight: Font.Bold
                color: "#FF4757"
            }

            // Score readout box
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: units.gu(7.2)
                radius: units.gu(1.2)
                color: "#0B1015"
                border.color: "#1C2633"
                border.width: units.gu(0.1)

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(0.2)

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("FINAL SCORE")
                        font.pixelSize: units.gu(1.2)
                        font.weight: Font.DemiBold
                        color: "#7E90A3"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.score.toString()
                        font.pixelSize: units.gu(3.8)
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }
            }

            // Stats row (Best Score & Level Reached)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: (parent.width - units.gu(1.0)) / 2.0
                    height: units.gu(4.2)
                    radius: units.gu(1.0)
                    color: "#0B1015"
                    border.color: "#1C2633"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.1)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("BEST")
                            font.pixelSize: units.gu(1.1)
                            color: "#7E90A3"
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.bestScore.toString()
                            font.pixelSize: units.gu(1.6)
                            font.weight: Font.Bold
                            color: "#FBBF24"
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - units.gu(1.0)) / 2.0
                    height: units.gu(4.2)
                    radius: units.gu(1.0)
                    color: "#0B1015"
                    border.color: "#1C2633"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.1)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("STAGE")
                            font.pixelSize: units.gu(1.1)
                            color: "#7E90A3"
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Level %1").arg(root.levelReached)
                            font.pixelSize: units.gu(1.6)
                            font.weight: Font.Bold
                            color: "#00D2D3"
                        }
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Play Again")
                color: "#10B981"
                width: parent.width
                height: units.gu(4.8)
                onClicked: root.restartRequested()
            }
        }
    }
}
