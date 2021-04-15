#ifndef UPQCLOUDDEVICEMANAGER_H
#define UPQCLOUDDEVICEMANAGER_H

#include <QObject>
#include <QMap>

#include "nertc_sdk/api/nertc_audio_device_manager.h"
#include "nertc_sdk/api/nertc_video_device_manager.h"

class NERtcEngine;

enum DeviceType
{
    DEVICE_NODEVICE = 0,
    DEVICE_MICROPHONE = 1,
    DEVICE_AUDIO = 2,
    DEVICE_CAMERA = 3
};

struct DeviceInfo
{
    QString     deviceName;

    QString     deviceGuid;
};

class NEDeviceManager
{
public:
    NEDeviceManager(NERtcEngine* engine);

    ~NEDeviceManager();

    void startDeviceTest() ;
    void stopDeviceTest() ;

    void queryDevices() ;
    QMap<DeviceType, QList<DeviceInfo>> &getDevices() ;

    void setCurAudioDevice(const QString &deviceGuid) ;
    const QString &getCurAudioDevice() ;

    void setCurMicphone(const QString &deviceGuid) ;
    const QString &getCurMicphone() ;

    void setCurCameraDevice(const QString &deviceGuid) ;
    const QString &getCurCameraDevice() ;

    void testCamera(bool isTest) ;
    void testMicphone(bool isTest) ;
    void testAudioDevice(const QString& audioFile, bool isTest) ;

protected:
     QList<DeviceInfo> enumAudioDevices();
     QList<DeviceInfo> enumMicphoneDevices();
     QList<DeviceInfo> enumCameraDevices();

private:
    QMap<DeviceType, QList<DeviceInfo>>  devices;

    QString         curAudioDeviceId = "";
    QString         curMicphoneId = "";
    QString         curCameraDeviceId = "";

    nertc::IAudioDeviceManager *audio_device_manager;
    nertc::IVideoDeviceManager *video_device_manager;
};

#endif // UPQCLOUDDEVICEMANAGER_H
