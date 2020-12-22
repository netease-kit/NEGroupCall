#include "NEDeviceItemWidget.h"
#include "ui_NEDeviceItemWidget.h"

NEDeviceItemWidget::NEDeviceItemWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NEDeviceItemWidget)
{
    ui->setupUi(this);
    ui->lblCheckIcon->setVisible(false);
}

NEDeviceItemWidget::~NEDeviceItemWidget()
{
    delete ui;
}

void NEDeviceItemWidget::setDeviceName(const QString &deviceName)
{
    ui->lblDeviceName->setText(deviceName);

    m_deviceName = deviceName;
}

void NEDeviceItemWidget::setCurrentItem(bool isCurrent)
{
    ui->lblCheckIcon->setVisible(isCurrent);
}

void NEDeviceItemWidget::setDeviceUid(const QString &uid)
{
    m_deviceUid = uid;
}

QString NEDeviceItemWidget::getDeviceUid() const
{
    return m_deviceUid;
}
