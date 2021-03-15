QT       += core gui opengl network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

TEMPLATE = app
TARGET = multipersionCallDemo
DESTDIR = $$PWD/bin

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#DEFINES += USE_BEAUTY #是否开启美颜：如果需要开启美颜，取消此注释，获取相芯科技的美颜证书拷贝到/CNamaSDK/auth目录

win32 {

    RC_ICONS = "nim.ico"

    INCLUDEPATH += $$PWD/ \
                   $$PWD/nertc_sdk/api/

    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/nertc_sdk/lib/x86 -lnertc_sdk
    } else {
        LIBS += -L$$PWD/nertc_sdk/lib/x86 -lnertc_sdk
    }

    contains(DEFINES,USE_BEAUTY){
        INCLUDEPATH += $$PWD/ \
                       $$PWD/CNamaSDK/api/ \
                       $$PWD/CNamaSDK/auth/

        LIBS += -L$$PWD/CNamaSDK/lib/x86 -lCNamaSDK
    }

    LIBS+=-lopengl32 -lglu32

    QMAKE_CXXFLAGS += -wd4100 /utf-8
}

macx {
    INCLUDEPATH += $$PWD/ \
                   $$PWD/CNamaSDK/auth \
                   $$PWD/nertc_sdk/mac/NEFundation_Mac.framework/Headers \
                   $$PWD/nertc_sdk/mac/nertc_sdk_Mac.framework/Headers

    LIBS +=  -ObjC\
             -framework CoreVideo \
             -F$$PWD/nertc_sdk/mac -framework NEFundation_Mac -framework nertc_sdk_Mac \

    NEFUNDATION_FRAMEWORK.files = $$PWD/nertc_sdk/mac/NEFundation_Mac.framework
    NEFUNDATION_FRAMEWORK.path = /Contents/Frameworks

    NERTC_SDK_FRAMEWORK.files = $$PWD/nertc_sdk/mac/nertc_sdk_Mac.framework
    NERTC_SDK_FRAMEWORK.path = /Contents/Frameworks

    FUAI_DYLIB.files = $$PWD/CNamaSDK/mac/lib/libfuai.dylib
    FUAI_DYLIB.path = /Contents/Frameworks

    NAMA_DYLIB.files = $$PWD/CNamaSDK/mac/lib/libCNamaSDK.dylib
    NAMA_DYLIB.path = /Contents/Frameworks

    FU_BUNDLE.files = $$PWD/resource/assert/face_beautification_v2.bundle
    FU_BUNDLE.path = /Contents/MacOS/assert

    contains(DEFINES,USE_BEAUTY){
        INCLUDEPATH += $$PWD/ \
                       $$PWD/CNamaSDK/auth \
                       $$PWD/CNamaSDK/mac/include

        LIBS += -ObjC\
             $$PWD/CNamaSDK/mac/lib/libfuai.dylib \
             $$PWD/CNamaSDK/mac/lib/libCNamaSDK.dylib
    }

    QMAKE_BUNDLE_DATA += NEFUNDATION_FRAMEWORK \
                         NERTC_SDK_FRAMEWORK\
                         FUAI_DYLIB \
                         NAMA_DYLIB \
                         FU_BUNDLE
}

macx {
    ICON = nim.icns
    HEADERS += utils/macxhelper.h
    SOURCES += utils/macxhelper.mm
    DISTFILES += nim.icns
}

contains(DEFINES,USE_BEAUTY){

SOURCES += \
    rtc/NEBeautyManager.cpp

HEADERS += \
    rtc/NEBeautyManager.h
}


SOURCES += \
    http/NEHttpApi.cpp \
    http/NEHttpManager.cpp \
    http/NERequest.cpp \
    rtc/NEAudioMixer.cpp \
    rtc/NEDeviceManager.cpp \
    rtc/NEEventHandler.cpp \
    rtc/NERtcEngine.cpp \
    utils/NERoomLiveConfig.cpp \
    view/MClearLineEdit.cpp \
    view/MLineEdit.cpp \
    view/NEAudioDeviceListWidget.cpp \
    view/NECallWidget.cpp \
    view/NECameraDeviceListWidget.cpp \
    view/NEChatRoomBottomTool.cpp \
    view/NEDeviceItemWidget.cpp \
    view/NEDeviceListWidget.cpp \
    view/NEFeedbackButton.cpp \
    view/NEJoinWidget.cpp \
    main.cpp \
    view/NESuggestTipWidget.cpp \
    view/NEVideoWidget.cpp \
    view/Toast.cpp

HEADERS += \
    http/NEHttpApi.h \
    http/NEHttpManager.h \
    http/NERequest.h \
    rtc/NEAudioMixer.h \
    rtc/NEDeviceManager.h \
    rtc/NEEventHandler.h \
    rtc/NERtcEngine.h \
    utils/NERoomLiveConfig.h \
    view/MClearLineEdit.h \
    view/MLineEdit.h \
    view/NEAudioDeviceListWidget.h \
    view/NECallWidget.h \
    view/NECameraDeviceListWidget.h \
    view/NEChatRoomBottomTool.h \
    view/NEDeviceItemWidget.h \
    view/NEDeviceListWidget.h \
    view/NEFeedbackButton.h \
    view/NEJoinWidget.h \
    view/NESuggestTipWidget.h \
    view/NEVideoWidget.h \
    view/Toast.h

FORMS += \
    view/NEAudioDeviceListWidget.ui \
    view/NECallWidget.ui \
    view/NECameraDeviceListWidget.ui \
    view/NEChatRoomBottomTool.ui \
    view/NEDeviceItemWidget.ui \
    view/NEDeviceListWidget.ui \
    view/NEFeedbackButton.ui \
    view/NEJoinWidget.ui \
    view/NESuggestTipWidget.ui \
    view/NEVideoWidget.ui \
    view/Toast.ui

RESOURCES += \
    resource/image.qrc
