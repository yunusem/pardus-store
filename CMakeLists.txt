cmake_minimum_required(VERSION 3.0)

project(pardus-store)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 5.6 COMPONENTS Qml Quick Widgets Svg Network REQUIRED)

add_executable(pardus-store
    src/main.cpp
    src/helper.cpp
    src/filehandler.cpp
    src/packagehandler.cpp
    src/applicationlistmodel.cpp
    src/networkhandler.cpp
    src/applicationdetail.cpp
    src/singleton.cpp
    src/dpkg-progress.cpp
    qml.qrc
    file.qrc
    images.qrc
    images.qrc
    translations.qrc
)

target_link_libraries(pardus-store
    Qt5::Qml
    Qt5::Quick
    Qt5::Widgets
    Qt5::Svg
    Qt5::Network
)

install(TARGETS pardus-store DESTINATION bin)
install(
    FILES
    ${PROJECT_SOURCE_DIR}/pardus-store.desktop
    DESTINATION
    share/applications
)
install(
    FILES
    ${PROJECT_SOURCE_DIR}/images/icon.svg
    DESTINATION
    share/pardus/pardus-store
)
install(
    FILES
    ${PROJECT_SOURCE_DIR}/tr.org.pardus.pkexec.pardus-store.policy
    DESTINATION
    share/polkit-1/actions
)
