QT += qml quick widgets svg

CONFIG += c++11

SOURCES += src/main.cpp \
    src/helper.cpp \
    src/filehandler.cpp \
    src/packagehandler.cpp \
    src/applicationlistmodel.cpp \
    src/networkhandler.cpp \
    src/applicationdetail.cpp

HEADERS += \
    src/helper.h \
    src/filehandler.h \
    src/packagehandler.h \
    src/iconprovider.h \
    src/applicationlistmodel.h \
    src/networkhandler.h \
    src/applicationdetail.h

TARGET = pardus-store

RESOURCES += qml.qrc file.qrc \
    images.qrc \
    translations.qrc

DEFINES += QT_DEPRECATED_WARNINGS

#LIBS += -lapt-pkg

