QT += qml quick widgets svg network

CONFIG += c++11

SOURCES += src/main.cpp \
    src/helper.cpp \
    src/filehandler.cpp \
    src/packagehandler.cpp \
    src/applicationlistmodel.cpp \
    src/networkhandler.cpp \
    src/applicationdetail.cpp \
    src/singleton.cpp \
    src/dpkg-progress.cpp \
    src/application.cpp

HEADERS += \
    src/helper.h \
    src/filehandler.h \
    src/packagehandler.h \
    src/iconprovider.h \
    src/applicationlistmodel.h \
    src/networkhandler.h \
    src/applicationdetail.h \
    src/singleton.h \
    src/dpkg-progress.h \
    src/application.h \
    src/namfactory.h

TARGET = pardus-store

RESOURCES += qml.qrc file.qrc \
    images.qrc \
    translations.qrc

DEFINES += QT_DEPRECATED_WARNINGS

target.path = /usr/bin

desktop_file.files = pardus-store.desktop
desktop_file.path = /usr/share/applications/

icon.files = images/icon.svg
icon.commands = mkdir -p /usr/share/pardus/pardus-store
icon.path = /usr/share/pardus/pardus-store

policy.files = tr.org.pardus.pkexec.pardus-store.policy
policy.commands = mkdir -p /usr/share/polkit-1/actions
policy.path = /usr/share/polkit-1/actions

INSTALLS += target desktop_file icon policy

#LIBS += -lapt-pkg

