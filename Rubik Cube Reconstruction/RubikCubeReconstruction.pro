#-------------------------------------------------
#
# Project created by QtCreator 2012-12-13T00:37:51
#
#-------------------------------------------------

QT       -= gui core

TARGET = RubikCubeReconstruction
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    "Rubik Cube Reconstruction/vertexBufferObject.cpp" \
    "Rubik Cube Reconstruction/texture.cpp" \
    "Rubik Cube Reconstruction/static_geometry.cpp" \
    "Rubik Cube Reconstruction/skybox.cpp" \
    "Rubik Cube Reconstruction/shaders.cpp" \
    "Rubik Cube Reconstruction/renderScene.cpp" \
    "Rubik Cube Reconstruction/flyingCamera.cpp"

HEADERS += \
    "Rubik Cube Reconstruction/vertexBufferObject.h" \
    "Rubik Cube Reconstruction/texture.h" \
    "Rubik Cube Reconstruction/static_geometry.h" \
    "Rubik Cube Reconstruction/skybox.h" \
    "Rubik Cube Reconstruction/shaders.h" \
    "Rubik Cube Reconstruction/geometry.h" \
    "Rubik Cube Reconstruction/flyingCamera.h"

INCLUDEPATH += /usr/include/nvidia-current


