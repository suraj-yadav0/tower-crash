import QtQuick 2.9
import QtMultimedia 5.0

Item {
    id: backend

    property bool soundEnabled: true
    property real masterVolume: 0.85
    property int bounceVoiceIndex: 0

    Audio {
        id: bounceVoice1
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
    }

    Audio {
        id: bounceVoice2
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
    }

    Audio {
        id: roundClearedVoice
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
        if (!soundEnabled || backend.masterVolume <= 0.001) return;
        try {
            var v = (velocityNorm !== undefined && velocityNorm !== null) ? Number(velocityNorm) : 0.6;
            if (isNaN(v)) v = 0.6;
            var vol = Math.max(0.2, Math.min(1.0, 0.35 + 0.65 * v)) * backend.masterVolume;
            var voice = (bounceVoiceIndex === 0) ? bounceVoice1 : bounceVoice2;
            bounceVoiceIndex = (bounceVoiceIndex + 1) % 2;
            voice.volume = Math.max(0.0, Math.min(1.0, vol));
            voice.stop();
            voice.play();
        } catch (e) {}
    }

    function playRoundCleared() {
        if (!soundEnabled || backend.masterVolume <= 0.001) return;
        try {
            roundClearedVoice.volume = Math.max(0.0, Math.min(1.0, backend.masterVolume * 0.95));
            roundClearedVoice.stop();
            roundClearedVoice.play();
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
            bounceVoice1.stop();
            bounceVoice2.stop();
            roundClearedVoice.stop();
        } catch (e) {}
    }
}
