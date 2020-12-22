#include "NEAudioDeviceListWidget.h"
#include "ui_NEAudioDeviceListWidget.h"

NEAudioDeviceListWidget::NEAudioDeviceListWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NEAudioDeviceListWidget)
{
    ui->setupUi(this);

    ui->speakerWidget->setDeviceTitleName("请选择扬声器");
    ui->micphoneWidget->setDeviceTitleName("请选择麦克风");
    ui->line->setFixedHeight(1);
    ui->line->setStyleSheet(QString("QFrame{background-color: #FFFFFF;}"));
    setAttribute(Qt::WA_TranslucentBackground, true);

    this->resize(320, 300);

    connect(ui->speakerWidget, &NEDeviceListWidget::sigDeviceChanged, this, &NEAudioDeviceListWidget::sigSpeakerDeviceChanged);
    connect(ui->micphoneWidget, &NEDeviceListWidget::sigDeviceChanged, this, &NEAudioDeviceListWidget::sigMicDeviceChanged);
}

NEAudioDeviceListWidget::~NEAudioDeviceListWidget()
{
    delete ui;
}

void NEAudioDeviceListWidget::loadDevice(const QList<DeviceInfo> &speakerDevice, const QList<DeviceInfo> &micphoneDevice)
{
    ui->speakerWidget->loadDeviceList(speakerDevice);
    ui->micphoneWidget->loadDeviceList(micphoneDevice);
    this->resize(320, ui->speakerWidget->height() + ui->micphoneWidget->height() + 10);
    adjustSize();
}

void NEAudioDeviceListWidget::setCurrentSpeakerDevice(const QString &deviceID)
{
    ui->speakerWidget->setCurrentDevice(deviceID);
}

void NEAudioDeviceListWidget::setCurrentMicDevice(const QString &deviceID)
{
    ui->micphoneWidget->setCurrentDevice(deviceID);
}
