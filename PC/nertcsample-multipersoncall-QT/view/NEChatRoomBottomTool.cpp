#include <QAction>
#include <QDateTime>
#include <QDebug>
#include <QMenu>
#include <QWidgetAction>

#include "NECameraDeviceListWidget.h"
#include "NEChatRoomBottomTool.h"
#include "rtc/NEDeviceManager.h"
#include "rtc/NERtcEngine.h"
#include "ui_NEChatRoomBottomTool.h"
#include "view/NEAudioDeviceListWidget.h"
#include "view/NECameraDeviceListWidget.h"

NEChatRoomBottomTool::NEChatRoomBottomTool(QWidget* parent) : QWidget(parent), ui(new Ui::NEChatRoomBottomTool) {
    ui->setupUi(this);

    this->setWindowFlags(Qt::FramelessWindowHint | Qt::Tool);
    this->setAttribute(Qt::WA_TranslucentBackground);

#ifdef USE_BEAUTY
    connect(ui->btnBeauty, &QPushButton::clicked, this, &NEChatRoomBottomTool::onBeautyClicked);
#else
    ui->btnBeauty->setVisible(false);
#endif

    connect(ui->btnVoice, &QPushButton::clicked, this, &NEChatRoomBottomTool::onVoiceClicked);
    connect(ui->btnVideo, &QPushButton::clicked, this, &NEChatRoomBottomTool::onVideoClicked, Qt::QueuedConnection);
    connect(ui->btnExitCall, &QPushButton::clicked, this, &NEChatRoomBottomTool::sigExitCall);

    QMenu* menu = new QMenu(this);
    QWidgetAction* action = new QWidgetAction(this);
    cameraWidget = new NECameraDeviceListWidget(this);
    action->setDefaultWidget(cameraWidget);
    menu->addAction(action);
    menu->setAttribute(Qt::WA_TranslucentBackground);
    menu->setWindowFlag(Qt::NoDropShadowWindowHint);
    menu->setStyleSheet("background-color: transparent;padding: 0px;");
    ui->btnVideoSetting->setMenu(menu);

    QMenu* menu2 = new QMenu(this);
    QWidgetAction* action2 = new QWidgetAction(this);
    audioWidget = new NEAudioDeviceListWidget(this);
    action2->setDefaultWidget(audioWidget);
    menu2->addAction(action2);
    menu2->setAttribute(Qt::WA_TranslucentBackground);
    menu2->setWindowFlag(Qt::NoDropShadowWindowHint);
    menu2->setStyleSheet("background-color: transparent;padding: 0px;");
    ui->btnVoiceSetting->setMenu(menu2);

    lastClickTime = QDateTime::currentMSecsSinceEpoch();

    menu->installEventFilter(this);
    menu2->installEventFilter(this);

    connect(cameraWidget, &NECameraDeviceListWidget::sigCameraDeviceChanged, this, &NEChatRoomBottomTool::onCameraDeviceChanged);
    connect(audioWidget, &NEAudioDeviceListWidget::sigSpeakerDeviceChanged, this, &NEChatRoomBottomTool::onSpeakerDeviceChanged);
    connect(audioWidget, &NEAudioDeviceListWidget::sigMicDeviceChanged, this, &NEChatRoomBottomTool::onMicDeviceChanged);
}

NEChatRoomBottomTool::~NEChatRoomBottomTool() {
    delete ui;
}

void NEChatRoomBottomTool::setRtcEngine(std::shared_ptr<NERtcEngine> engine) {
    m_engine = engine;
}

void NEChatRoomBottomTool::init() {
    ui->btnVoice->setChecked(false);
    ui->btnVideo->setChecked(false);
    ui->btnBeauty->setChecked(true);
}

void NEChatRoomBottomTool::setVideoCheck(bool check) {
    ui->btnVideo->setChecked(check);
}

bool NEChatRoomBottomTool::eventFilter(QObject* watched, QEvent* event) {
    if (event->type() == QEvent::Show && watched == ui->btnVideoSetting->menu()) {
        onVideoSettingClicked();
        QPoint p = ui->btnVideoSetting->mapToGlobal(QPoint(0, 0));
        ui->btnVideoSetting->menu()->move(p.x() - cameraWidget->width() / 2, p.y() - cameraWidget->height() - 25);

        return true;
    } else if (event->type() == QEvent::Show && watched == ui->btnVoiceSetting->menu()) {
        onAudioSettingClicked();
        QPoint p = ui->btnVoiceSetting->mapToGlobal(QPoint(0, 0));
        ui->btnVoiceSetting->menu()->move(p.x() - audioWidget->width() / 2, p.y() - audioWidget->height() - 25);

        return true;
    }

    return false;
}

void NEChatRoomBottomTool::showEvent(QShowEvent* event) {
    init();
}

void NEChatRoomBottomTool::onVoiceClicked() {
    bool bCheck = !ui->btnVoice->isChecked();
    Q_EMIT sigVoiceEnable(bCheck);
}

void NEChatRoomBottomTool::onVideoClicked() {
    qint64 curTime = QDateTime::currentMSecsSinceEpoch();

    //防止操作过快导致卡死
    if (qAbs(lastClickTime - curTime) < 500) {
        qInfo() << "opt fast";
        return;
    }

    lastClickTime = curTime;

    m_bCheck = !m_bCheck;

    if (m_bCheck) {
        ui->btnVideo->setStyleSheet(
            "QPushButton{border-image: url(:/image/video-off.png);"
            "background-color: transparent;}");
    } else {
        ui->btnVideo->setStyleSheet(
            "QPushButton{border-image: url(:/image/video-on.png);"
            "background-color: transparent;}");
    }

    bool enable = !m_bCheck;
    Q_EMIT sigVideoEnable(enable);
}

void NEChatRoomBottomTool::onBeautyClicked() {
    bool bCheck = !ui->btnBeauty->isChecked();
    Q_EMIT sigBeautyEnable(bCheck);
}

void NEChatRoomBottomTool::onVideoSettingClicked() {
    QStringList list;
    m_engine->getDeviceManager()->queryDevices();
    QMap<DeviceType, QList<DeviceInfo>> device = m_engine->getDeviceManager()->getDevices();
    QList<DeviceInfo> videoList = device[DEVICE_CAMERA];
    cameraWidget->loadDeviceList(videoList);
    ui->btnVideoSetting->menu()->setFixedSize(cameraWidget->size());

    if (!videoList.isEmpty()) {
        QString curCameraDeviceId = m_engine->getDeviceManager()->getCurCameraDevice();

        if (curCameraDeviceId.isEmpty()) {
            curCameraDeviceId = videoList[0].deviceGuid;
        }

        cameraWidget->setCurrentDevice(curCameraDeviceId);
    }
}

void NEChatRoomBottomTool::onAudioSettingClicked() {
    QStringList speakerlist;
    m_engine->getDeviceManager()->queryDevices();
    QMap<DeviceType, QList<DeviceInfo>> device = m_engine->getDeviceManager()->getDevices();
    QList<DeviceInfo> speakerDevice = device[DEVICE_AUDIO];
    QList<DeviceInfo> minphoneDevice = device[DEVICE_MICROPHONE];
    audioWidget->loadDevice(speakerDevice, minphoneDevice);
    ui->btnVoiceSetting->menu()->setFixedSize(audioWidget->size());

    QString curSpeakerDevice = m_engine->getDeviceManager()->getCurAudioDevice();

    if (!curSpeakerDevice.isEmpty()) {
        if (speakerDevice.isEmpty()) {
            curSpeakerDevice = speakerDevice[0].deviceGuid;
        }

        audioWidget->setCurrentSpeakerDevice(curSpeakerDevice);
    }

    QString micDevice = m_engine->getDeviceManager()->getCurMicphone();

    if (!micDevice.isEmpty()) {
        if (minphoneDevice.isEmpty()) {
            micDevice = minphoneDevice[0].deviceGuid;
        }

        audioWidget->setCurrentMicDevice(micDevice);
    }
}

void NEChatRoomBottomTool::onCameraDeviceChanged(const QString& deviceID) {
    m_engine->getDeviceManager()->setCurCameraDevice(deviceID);
    if (!ui->btnVideo->isChecked()) {
        m_engine->enableVideo(true);
    }
}

void NEChatRoomBottomTool::onSpeakerDeviceChanged(const QString& deviceID) {
    m_engine->getDeviceManager()->setCurAudioDevice(deviceID);
}

void NEChatRoomBottomTool::onMicDeviceChanged(const QString& deviceID) {
    qInfo() << "onMicDeviceChanged: " << deviceID;
    m_engine->getDeviceManager()->setCurMicphone(deviceID);
}
