import QtQuick 2.9
import QtMultimedia 5.0

Item {
    id: backend

    property bool soundEnabled: true

    SoundEffect {
        id: sfxBounce
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
        volume: 0.85
    }

    SoundEffect {
        id: sfxPass
        source: Qt.resolvedUrl("../../assets/sounds/pass.wav")
        muted: !backend.soundEnabled
        volume: 0.85
    }

    SoundEffect {
        id: sfxSmash
        source: Qt.resolvedUrl("../../assets/sounds/smash.wav")
        muted: !backend.soundEnabled
        volume: 0.9
    }

    SoundEffect {
        id: sfxGameOver
        source: Qt.resolvedUrl("../../assets/sounds/gameover.wav")
        muted: !backend.soundEnabled
        volume: 0.95
    }

    SoundEffect {
        id: sfxFanfare
        source: Qt.resolvedUrl("../../assets/sounds/fanfare.wav")
        muted: !backend.soundEnabled
        volume: 0.95
    }

    SoundEffect {
        id: sfxClick
        source: Qt.resolvedUrl("../../assets/sounds/click.wav")
        muted: !backend.soundEnabled
        volume: 0.65
    }

    SoundEffect {
        id: sfxWhoosh
        source: Qt.resolvedUrl("../../assets/sounds/whoosh.wav")
        muted: !backend.soundEnabled
        volume: 0.75
        loops: SoundEffect.Infinite
    }

    Audio {
        id: audioPass
        source: Qt.resolvedUrl("../../assets/sounds/pass.wav")
        muted: !backend.soundEnabled
        volume: 0.85
    }

    Audio {
        id: audioSmash
        source: Qt.resolvedUrl("../../assets/sounds/smash.wav")
        muted: !backend.soundEnabled
        volume: 0.9
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
            var vol = Math.max(0.35, Math.min(1.0, 0.35 + 0.65 * v));
            sfxBounce.volume = vol;
            sfxBounce.play();
        } catch (e) {
            try { sfxBounce.play(); } catch (e2) {}
        }
    }

    function playPass(streak) {
        if (!soundEnabled) return;
        var s = (streak !== undefined && streak !== null) ? Number(streak) : 0;
        if (isNaN(s)) s = 0;
        var pitch = Math.min(1.85, Math.pow(1.059463, Math.min(12, s)));

        try {
            audioPass.playbackRate = pitch;
            audioPass.seek(0);
            audioPass.play();
        } catch (e) {
            try { sfxPass.play(); } catch (e2) {}
        }
    }

    function playSmash(streak) {
        if (!soundEnabled) return;
        var s = (streak !== undefined && streak !== null) ? Number(streak) : 0;
        if (isNaN(s)) s = 0;
        var pitch = Math.min(1.5, Math.pow(1.04, Math.min(10, s)));

        try {
            audioSmash.playbackRate = pitch;
            audioSmash.seek(0);
            audioSmash.play();
        } catch (e) {
            try { sfxSmash.play(); } catch (e2) {}
        }
    }

    function playGameOver() {
        if (!soundEnabled) return;
        stopWhoosh();
        try {
            sfxGameOver.play();
        } catch (e) {}
    }

    function playFanfare() {
        if (!soundEnabled) return;
        try {
            sfxFanfare.play();
        } catch (e) {}
    }

    function playWhoosh() {
        if (!soundEnabled) return;
        try {
            if (!sfxWhoosh.playing) {
                sfxWhoosh.play();
            }
        } catch (e) {}
    }

    function stopWhoosh() {
        try {
            sfxWhoosh.stop();
        } catch (e) {}
    }

    function playClick() {
        if (!soundEnabled) return;
        try {
            sfxClick.play();
        } catch (e) {}
    }

    function stopAll() {
        try {
            sfxBounce.stop();
            sfxPass.stop();
            sfxSmash.stop();
            sfxGameOver.stop();
            sfxFanfare.stop();
            sfxWhoosh.stop();
            sfxClick.stop();
            audioPass.stop();
            audioSmash.stop();
        } catch (e) {}
    }
}
