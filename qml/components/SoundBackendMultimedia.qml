import QtQuick 2.9
import QtMultimedia 5.0

Item {
    id: backend

    property bool soundEnabled: true
    property real masterVolume: 0.85

    SoundEffect {
        id: sfxBounce
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
        volume: backend.masterVolume
    }

    SoundEffect {
        id: sfxRoundCleared
        source: Qt.resolvedUrl("../../assets/sounds/fanfare.wav")
        muted: !backend.soundEnabled
        volume: backend.masterVolume * 0.95
    }

    onSoundEnabledChanged: {
        if (!soundEnabled) {
            stopAll();
        }
    }

    function playBounce(velocityNorm) {
        if (!soundEnabled) return;
        try {
            var v = (velocityNorm !== undefined && velocityNorm !== null) ? Number(velocityNorm) : 0.6;
            if (isNaN(v)) v = 0.6;
            var vol = Math.max(0.2, Math.min(1.0, 0.35 + 0.65 * v)) * backend.masterVolume;
            sfxBounce.volume = Math.max(0.0, Math.min(1.0, vol));
            sfxBounce.play();
        } catch (e) {
            try { sfxBounce.play(); } catch (e2) {}
        }
    }

    function playRoundCleared() {
        if (!soundEnabled) return;
        try {
            sfxRoundCleared.volume = Math.max(0.0, Math.min(1.0, backend.masterVolume * 0.95));
            sfxRoundCleared.play();
        } catch (e) {}
    }

    function playFanfare() {
        playRoundCleared();
    }

    // Unused sound methods kept as clean no-ops for compatibility
    function playPass(streak) {}
    function playSmash(streak) {}
    function playGameOver() {}
    function playWhoosh() {}
    function stopWhoosh() {}
    function playClick() {}

    function stopAll() {
        try {
            sfxBounce.stop();
            sfxRoundCleared.stop();
        } catch (e) {}
    }
}
