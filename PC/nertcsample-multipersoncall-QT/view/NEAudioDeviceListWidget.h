#ifndef NEAUDIODEVICELISTWIDGET_H
#define NEAUDIODEVICELISTWIDGET_H

#include <QWidget>


namespace Ui {
class NEAudioDeviceListWidget;
}

struct DeviceInfo;

class NEAudioDeviceListWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NEAudioDeviceListWidget(QWidget *parent = nullptr);
    ~NEAudioDeviceListWidget();

    void loadDevice(const QList<DeviceInfo> &speakerDevice, const QList<DeviceInfo> &micphoneDevice);

    void setCurrentSpeakerDevice(const QString& deviceID);

    void setCurrentMicDevice(const QString& deviceID);

Q_SIGNALS:
    void sigSpeakerDeviceChanged(const QString& deviceID);
    void sigMicDeviceChanged(const QString& deviceID);

private:
    Ui::NEAudioDeviceListWidget *ui;
};

#endif // NEAUDIODEVICELISTWIDGET_H
