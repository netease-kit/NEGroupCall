#ifndef NEDEVICEITEMWIDGET_H
#define NEDEVICEITEMWIDGET_H

#include <QWidget>

namespace Ui {
class NEDeviceItemWidget;
}

class NEDeviceItemWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NEDeviceItemWidget(QWidget *parent = nullptr);
    ~NEDeviceItemWidget();

    void setDeviceName(const QString& deviceName);

    void setCurrentItem(bool isCurrent);

    void setDeviceUid(const QString& uid);
    QString getDeviceUid() const;

private:
    Ui::NEDeviceItemWidget *ui;

    QString m_deviceName;
    QString m_deviceUid;
};

#endif // NEDEVICEITEMWIDGET_H
