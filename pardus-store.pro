QT += qml quick widgets svg

CONFIG += c++11

SOURCES += src/main.cpp \
    src/helper.cpp \
    src/filehandler.cpp \
    src/packagehandler.cpp \
    src/applicationlistmodel.cpp \
    src/artwork.cpp \
    src/screenshotinfo.cpp

HEADERS += \
    src/helper.h \
    src/filehandler.h \
    src/packagehandler.h \
    src/iconprovider.h \
    src/applicationlistmodel.h \
    src/artwork.h \
    src/screenshotinfo.h

TARGET = ps

RESOURCES += qml.qrc file.qrc \
    images.qrc

DEFINES += QT_DEPRECATED_WARNINGS

#LIBS += -lapt-pkg

