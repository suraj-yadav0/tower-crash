import QtQuick 2.9
import QtFeedback 5.0

Item {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true

    Loader {
        id: multimediaLoader
        asynchronous: false
        source: "SoundBackendMultimedia.qml"
        onLoaded: {
            if (item) {
                item.soundEnabled = Qt.binding(function() { return root.soundEnabled; });
            }
        }
    }

    HapticsEffect {
        id: hapticLight
        duration: 25
        intensity: 0.6
    }

    HapticsEffect {
        id: hapticHeavy
        duration: 70
        intensity: 1.0
    }

    ThemeEffect {
        id: themeHaptic
        effect: ThemeEffect.Press
    }

    Timer {
        id: dualHapticTimer
        interval: 120
        repeat: false
        onTriggered: {
            try { hapticHeavy.start(); } catch (e) {}
        }
    }

    onSoundEnabledChanged: {
        if (!soundEnabled && multimediaLoader.item) {
            try { multimediaLoader.item.stopAll(); } catch (e) {}
        }
    }

    function playBounce(velocityNorm) {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playBounce(velocityNorm);
        } catch (e) {}
    }

    function playPass(streak) {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playPass(streak);
        } catch (e) {}
    }

    function playSmash(streak) {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playSmash(streak);
        } catch (e) {}
    }

    function playGameOver() {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playGameOver();
        } catch (e) {}
    }

    function playFanfare() {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playFanfare();
        } catch (e) {}
    }

    function playWhoosh() {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playWhoosh();
        } catch (e) {}
    }

    function stopWhoosh() {
        if (!multimediaLoader.item) return;
        try {
            multimediaLoader.item.stopWhoosh();
        } catch (e) {}
    }

    function playClick() {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playClick();
        } catch (e) {}
    }

    function stopAll() {
        if (!multimediaLoader.item) return;
        try {
            multimediaLoader.item.stopAll();
        } catch (e) {}
    }

    function play(type) {
        if (!soundEnabled) return;
        if (type === "bounce") playBounce(0.6);
        else if (type === "pass") playPass(0);
        else if (type === "smash") playSmash(0);
        else if (type === "gameover") playGameOver();
        else if (type === "fanfare") playFanfare();
        else if (type === "whoosh") playWhoosh();
        else if (type === "click") playClick();
    }

    function haptic(heavy) {
        if (!hapticsEnabled) return;
        try {
            if (heavy) hapticHeavy.start();
            else hapticLight.start();
        } catch (e) {}
    }

    function buttonHaptic() {
        playClick();
        if (!hapticsEnabled) return;
        try {
            themeHaptic.start();
        } catch (e) {}
    }

    function milestoneHaptic() {
        if (!hapticsEnabled) return;
        try {
            hapticHeavy.start();
            dualHapticTimer.start();
        } catch (e) {}
    }
}
