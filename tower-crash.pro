TEMPLATE = aux

CONFIG += no_check_exist

QML_FILES += \
    qml/Main.qml

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
