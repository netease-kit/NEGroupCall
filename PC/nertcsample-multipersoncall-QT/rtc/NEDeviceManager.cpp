#include <QDebug>
#include <QTimer>

#include "NEDeviceManager.h"
#include "NERtcEngine.h"

NEDeviceManager::NEDeviceManager(NERtcEngine* engine)
{
    engine->GetRtcEngine()->queryInterface(nertc::kNERtcIIDAudioDeviceManager, (void**)&audio_device_manager);
    engine->GetRtcEngine()->queryInterface(nertc::kNERtcIIDVideoDeviceManager, (void**)&video_device_manager);

    qDebug() << "NEDeviceManager";
}

NEDeviceManager::~NEDeviceManager()
{
    qDebug() << "~NEDeviceManager";
}

void NEDeviceManager::startDeviceTest()
{

}

void NEDeviceManager::stopDeviceTest()
{

}

void NEDeviceManager::queryDevices()
{
    devices[DEVICE_MICROPHONE] = enumMicphoneDevices();
    devices[DEVICE_AUDIO] = enumAudioDevices();
    devices[DEVICE_CAMERA] = enumCameraDevices();
}

QMap<DeviceType, QList<DeviceInfo> > &NEDeviceManager::getDevices()
{
    return devices;
}

void NEDeviceManager::setCurAudioDevice(const QString &deviceGuid)
{
    if(curAudioDeviceId == deviceGuid){
        return;
    }

    curAudioDeviceId = deviceGuid;

    audio_device_manager->setPlayoutDevice(deviceGuid.toUtf8().data());
}

const QString &NEDeviceManager::getCurAudioDevice()
{
    return curAudioDeviceId;
}

void NEDeviceManager::setCurMicphone(const QString &deviceGuid)
{
    if(curMicphoneId == deviceGuid){
        return;
    }

    curMicphoneId = deviceGuid;

    qInfo() << "setCurMicphone: " <<  audio_device_manager->setRecordDevice(deviceGuid.toUtf8().data());
}

const QString &NEDeviceManager::getCurMicphone()
{
    return curMicphoneId;
}

void NEDeviceManager::setCurCameraDevice(const QString &deviceGuid)
{
    if(curCameraDeviceId == deviceGuid){
        return;
    }

    curCameraDeviceId = deviceGuid;

    qInfo() << "deviceGuid: " << deviceGuid;
    qInfo() << "setCurCameraDevice: " <<  video_device_manager->setDevice(deviceGuid.toUtf8().data());
}

const QString &NEDeviceManager::getCurCameraDevice()
{
    return curCameraDeviceId;
}

void NEDeviceManager::testCamera(bool isTest)
{
    //todo
    if(isTest){

    }else{

    }
}

void NEDeviceManager::testMicphone(bool isTest)
{
    if(isTest){
        audio_device_manager->startRecordDeviceTest(200);
    }else{
        audio_device_manager->stopPlayoutDeviceTest();
    }
}

void NEDeviceManager::testAudioDevice(const QString& audioFile, bool isTest)
{
    if(isTest){
        audio_device_manager->startPlayoutDeviceTest(audioFile.toUtf8().data());
    }else{
        audio_device_manager->stopPlayoutDeviceTest();
    }
}

QList<DeviceInfo> NEDeviceManager::enumAudioDevices()
{
    QList<DeviceInfo> playoutDevices;

    nertc::IDeviceCollection * playoutDeviceList = audio_device_manager->enumeratePlayoutDevices();
    int count = playoutDeviceList->getCount();

    for(int i = 0; i < count; ++i){
        char ID[kNERtcMaxDeviceIDLength];
        char name[kNERtcMaxDeviceNameLength];
        memset(ID, 0, sizeof(ID));
        memset(name, 0, sizeof(name));
        playoutDeviceList->getDevice(i, name, ID);

        DeviceInfo device;
        device.deviceGuid = ID;
        device.deviceName = name;

        playoutDevices << device;
    }

    playoutDeviceList->destroy();

    return playoutDevices;
}

QList<DeviceInfo> NEDeviceManager::enumMicphoneDevices()
{
    QList<DeviceInfo> audioDevices;

    nertc::IDeviceCollection * recordingDeviceList = audio_device_manager->enumerateRecordDevices();
    int count = recordingDeviceList->getCount();

    for(int i = 0; i < count; ++i){
        char ID[kNERtcMaxDeviceIDLength];
        char name[kNERtcMaxDeviceNameLength];
        memset(ID, 0, sizeof(ID));
        memset(name, 0, sizeof(name));
        recordingDeviceList->getDevice(i, name, ID);

        DeviceInfo device;
        device.deviceGuid = ID;
        device.deviceName = name;

        audioDevices << device;
    }

    recordingDeviceList->destroy();

    return audioDevices;
}

QList<DeviceInfo> NEDeviceManager::enumCameraDevices()
{
    QList<DeviceInfo> cameraDevices;

    nertc::IDeviceCollection * cameraDeviceList = video_device_manager->enumerateCaptureDevices();
    int count = cameraDeviceList->getCount();

    for(int i = 0; i < count; ++i){
        char ID[kNERtcMaxDeviceIDLength];
        char name[kNERtcMaxDeviceNameLength];
        memset(ID, 0, sizeof(ID));
        memset(name, 0, sizeof(name));
        cameraDeviceList->getDevice(i, name, ID);

        DeviceInfo device;
        device.deviceGuid = ID;
        device.deviceName = name;

        cameraDevices << device;
    }

    cameraDeviceList->destroy();

    return cameraDevices;
}
