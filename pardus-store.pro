QT += qml quick widgets

CONFIG += c++11

SOURCES += src/main.cpp \
    src/helper.cpp

HEADERS += \
    src/helper.h

TARGET = ps

RESOURCES += qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS

LIBS += -lapt-pkg

