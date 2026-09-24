import QtQuick 2.9

Item {
    id: root
    anchors.fill: parent

    property var game: null
    property var gameCanvas: null
    property var stageClearTimer: null

    focus: true

    function isInputAllowed() {
        if (!game) return false;
        return !game.gameOver && !game.isPaused && !game.isSettingsOpen && !game.isWelcomeOpen && !game.isStageClearOpen && !game.isStageClearCelebrating;
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: root.isInputAllowed()

        onPressed: {
            if (!root.game) return;
            root.game.isDragging = true;
            root.game.angularVelocity = 0.0;
            root.game.lastDragX = mouse.x;
            root.game.lastDragTime = Date.now();
        }

        onPositionChanged: {
            if (pressed && root.isInputAllowed()) {
                var now = Date.now();
                var elapsed = Math.max(1, now - root.game.lastDragTime);
                var dx = mouse.x - root.game.lastDragX;

                var sens = root.game.touchSensitivityMultiplier;
                root.game.towerAngle -= dx * 0.014 * sens;
                var fling = -(dx / elapsed) * 0.12 * sens;
                root.game.angularVelocity = Math.max(-0.25, Math.min(0.25, fling));

                root.game.lastDragX = mouse.x;
                root.game.lastDragTime = now;
                if (root.gameCanvas) root.gameCanvas.requestPaint();
            }
        }

        onReleased: {
            if (root.game) root.game.isDragging = false;
        }
        onCanceled: {
            if (root.game) root.game.isDragging = false;
        }
    }

    Keys.onPressed: {
        if (!root.game) return;
        if (event.key === Qt.Key_A) {
            if (root.isInputAllowed()) {
                root.game.towerAngle += 0.12;
                if (root.gameCanvas) root.gameCanvas.requestPaint();
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_D) {
            if (root.isInputAllowed()) {
                root.game.towerAngle -= 0.12;
                if (root.gameCanvas) root.gameCanvas.requestPaint();
                event.accepted = true;
            }
        }
    }

    Keys.onLeftPressed: {
        if (root.isInputAllowed()) {
            root.game.towerAngle += 0.12;
            if (root.gameCanvas) root.gameCanvas.requestPaint();
        }
    }

    Keys.onRightPressed: {
        if (root.isInputAllowed()) {
            root.game.towerAngle -= 0.12;
            if (root.gameCanvas) root.gameCanvas.requestPaint();
        }
    }

    Keys.onSpacePressed: {
        if (!root.game) return;
        if (root.game.isWelcomeOpen) {
            root.game.startGame();
            return;
        }
        if (root.game.isSettingsOpen) {
            return;
        }
        if (root.game.isStageClearCelebrating) {
            if (root.stageClearTimer) root.stageClearTimer.stop();
            root.game.isStageClearCelebrating = false;
            root.game.ballY = root.game.milestoneRingY;
            root.game.ballVy = 0.0;
            root.game.cameraY = root.game.milestoneRingY;
            root.game.activePlatformY = root.game.milestoneRingY;
            root.game.isStageClearOpen = true;
            if (root.gameCanvas) root.gameCanvas.requestPaint();
            return;
        }
        if (root.game.isStageClearOpen) {
            if (root.game.stageClearIsGrand) {
                root.game.goToMainMenu();
            } else {
                root.game.continueDescent();
            }
            return;
        }
        if (root.game.gameOver) {
            root.game.startGame();
        } else {
            root.game.isPaused = !root.game.isPaused;
        }
    }

    Keys.onEscapePressed: {
        if (!root.game) return;
        if (root.game.isSettingsOpen) {
            root.game.isSettingsOpen = false;
            if (!root.game.wasPausedBeforeSettings && !root.game.gameOver && !root.game.isWelcomeOpen && !root.game.isStageClearOpen) {
                root.game.isPaused = false;
            }
        } else if (root.game.isStageClearOpen) {
            root.game.goToMainMenu();
        } else if (!root.game.isWelcomeOpen && root.game.isPaused) {
            root.game.isPaused = false;
        } else if (!root.game.isWelcomeOpen && !root.game.gameOver && !root.game.isStageClearCelebrating) {
            root.game.isPaused = true;
        }
    }
}
