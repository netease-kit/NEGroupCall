#include "NECameraDeviceListWidget.h"
#include "ui_NECameraDeviceListWidget.h"

NECameraDeviceListWidget::NECameraDeviceListWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NECameraDeviceListWidget)
{
    ui->setupUi(this);

    ui->widget->setDeviceTitleName("请选择摄像头");
    setAttribute(Qt::WA_TranslucentBackground, true);
    connect(ui->widget, &NEDeviceListWidget::sigDeviceChanged, this, &NECameraDeviceListWidget::sigCameraDeviceChanged);
}

NECameraDeviceListWidget::~NECameraDeviceListWidget()
{
    delete ui;
}

void NECameraDeviceListWidget::loadDeviceList(const QList<DeviceInfo> &deviceList)
{
    ui->widget->loadDeviceList(deviceList);
    this->resize(320, ui->widget->height());
    adjustSize();
}

void NECameraDeviceListWidget::setCurrentDevice(const QString &deviceID)
{
    ui->widget->setCurrentDevice(deviceID);
}
