#ifndef NECAMERADEVICELISTWIDGET_H
#define NECAMERADEVICELISTWIDGET_H

#include <QWidget>

namespace Ui {
class NECameraDeviceListWidget;
}

struct DeviceInfo;

class NECameraDeviceListWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NECameraDeviceListWidget(QWidget *parent = nullptr);
    ~NECameraDeviceListWidget();

     void loadDeviceList(const QList<DeviceInfo>& deviceList);

     void setCurrentDevice(const QString& deviceID);

Q_SIGNALS:
     void sigCameraDeviceChanged(const QString& deviceID);

private:
    Ui::NECameraDeviceListWidget *ui;
};

#endif // NECAMERADEVICELISTWIDGET_H
