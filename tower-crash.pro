TEMPLATE = aux

CONFIG += no_check_exist

QML_FILES += \
    qml/Main.qml \
    qml/components/GameBackground.qml \
    qml/components/GameCanvas.qml \
    qml/components/GameHud.qml \
    qml/components/MilestoneBanner.qml \
    qml/components/ModalLayer.qml \
    qml/components/PauseModal.qml \
    qml/components/SettingsModal.qml \
    qml/components/ThemePickerView.qml \
    qml/components/WelcomeScreen.qml \
    qml/components/HowToPlayView.qml \
    qml/components/AboutView.qml \
    qml/components/GameOverModal.qml \
    qml/components/StageClearModal.qml \
    qml/components/SoundManager.qml \
    qml/components/SoundBackendMultimedia.qml \
    qml/js/Themes.js \
    qml/js/Storage.js \
    qml/js/RingGenerator.js \
    qml/js/ParticleSystem.js \
    qml/js/Progression.js \
    qml/js/GamePhysics.js

INSTALLS += qml desktop apparmor manifest assets license

qml.files = qml
qml.path = /

desktop.files = tower-crash.desktop
desktop.path = /

apparmor.files = apparmor.json
apparmor.path = /

manifest.files = manifest.json
manifest.path = /

assets.files = assets
assets.path = /

license.files = LICENSE
license.path = /
