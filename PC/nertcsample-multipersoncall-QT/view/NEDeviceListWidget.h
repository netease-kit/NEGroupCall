#ifndef NEDEVICELISTWIDGET_H
#define NEDEVICELISTWIDGET_H

#include <QWidget>

namespace Ui {
class NEDeviceListWidget;
}

class QListWidgetItem;
struct DeviceInfo;

class NEDeviceListWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NEDeviceListWidget(QWidget *parent = nullptr);
    ~NEDeviceListWidget();

    void setDeviceTitleName(const QString& name);

    void loadDeviceList(const QList<DeviceInfo> &deviceList);

    void setCurrentDevice(const QString& curDevice);

Q_SIGNALS:
    void sigDeviceChanged(const QString& curDevice);

private Q_SLOTS:
    void onItemClicked(QListWidgetItem *item);

private:
    Ui::NEDeviceListWidget *ui;
};

#endif // NEDEVICELISTWIDGET_H
