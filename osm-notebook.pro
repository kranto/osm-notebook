# Add more folders to ship with the application, here

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT+= declarative
symbian:TARGET.UID3 = 0xE66B1D7C

CONFIG += mobility
MOBILITY += location

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    locator.cpp


OTHER_FILES += \
    qml/MainPage.qml \
    qml/main.qml \
    osm-notebook.desktop \
    osm-notebook.svg \
    osm-notebook.png \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/storage.js \
    qml/MultiMap.qml \
    qtc_packaging/meego.spec \
    qml/TrackSelectionDialog.qml \
    qml/SettingsPage.qml \
    qml/Tracker.qml \
    qml/TextEntryDialog.qml \
    qml/Settings.qml

RESOURCES += \
    res.qrc

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

# enable booster
CONFIG += qdeclarative-boostable
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

HEADERS += \
    locator.h


contains(MEEGO_EDITION,harmattan) {
    icon.files = osm-notebook.png
    icon.path = /usr/share/icons/hicolor/80x80/apps
    INSTALLS += icon
}







