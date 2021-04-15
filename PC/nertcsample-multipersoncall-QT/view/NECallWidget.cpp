#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMessageBox>
#include <QMoveEvent>
#include <QStandardPaths>
#include <QTimer>

#include "NEAudioDeviceListWidget.h"
#include "NECallWidget.h"
#include "NECameraDeviceListWidget.h"
#include "NEChatRoomBottomTool.h"
#include "NESuggestTipWidget.h"
#include "Toast.h"
#include "http/NEHttpApi.h"
#include "rtc/NEDeviceManager.h"
#include "rtc/NERtcEngine.h"
#include "ui_NECallWidget.h"
#include "utils/NERoomLiveConfig.h"

NECallWidget::NECallWidget(QWidget* parent) : QOpenGLWidget(parent), ui(new Ui::NECallWidget) {
    ui->setupUi(this);

    this->resize(1184, 666);
    ui->stackedWidget->setCurrentIndex(0);
    setVisible(false);

    m_engine = std::make_shared<NERtcEngine>(Q_NULLPTR);
    bottomTool = new NEChatRoomBottomTool(this);
    bottomTool->setVisible(false);
    bottomTool->setRtcEngine(m_engine);

    connect(bottomTool, &NEChatRoomBottomTool::sigVoiceEnable, this, &NECallWidget::onVoiceEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigVideoEnable, this, &NECallWidget::onVideoEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigBeautyEnable, this, &NECallWidget::onBeautyEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigExitCall, this, &NECallWidget::onExitCall);

    connect(m_engine.get(), &NERtcEngine::sigUserJoined, this, &NECallWidget::onUserJoin);
    connect(m_engine.get(), &NERtcEngine::sigUserLeft, this, &NECallWidget::onUserLeft);
    connect(m_engine.get(), &NERtcEngine::sigJoinChannelSuccess, this, &NECallWidget::onJoinChannelSuccess);
    connect(m_engine.get(), &NERtcEngine::sigJoinChannelFail, this, &NECallWidget::onJoinChannelFail);
    connect(m_engine.get(), &NERtcEngine::sigDisconnected, this, &NECallWidget::onDisconnected);
    connect(m_engine.get(), &NERtcEngine::sigUserVideoMute, this, &NECallWidget::onUserVideoMute);
    connect(m_engine.get(), &NERtcEngine::sigUserAudioMute, this, &NECallWidget::onUserAudioMute);
    connect(m_engine.get(), &NERtcEngine::sigLeavingChannel, this, &NECallWidget::onLeavingChannel);
}

NECallWidget::~NECallWidget() {
    delete ui;
}

void NECallWidget::onJoinChannel() {
    NERoomInfo info = NERoomLiveConfig::instance().getRoomInfo();

    setWindowTitle("房间ID: " + info.mpRoomId);
    ui->videoWidget_1->setNickname(info.selfnickName);

    if (!m_engine->getIsInit()) {
        //设置日志路径
        auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        auto rtcLog = appDataDir + "/NeRTC";
        auto byteLogDir = rtcLog.toUtf8();

        //初始化
        if (!m_engine->init(info.nrtcAppKey.toUtf8().data(), byteLogDir)) {
            qDebug("[ERROR] Failed to initialize NERtc engine! NERtc SDK can't work!");
            return;
        }
    }

    this->show();

    //设置自己的渲染窗口
    void* hwnd = (void*)ui->videoWidget_1->getVideoHwnd();
    m_engine->setupLocalVideo(hwnd);

    //加入频道
    m_engine->joinChannel(info.avRoomCheckSum, info.avRoomCName, info.avRoomUid);
    //默认启用音视频
    m_engine->enableVideo(true);
    m_engine->enableAudio(true);
}

void NECallWidget::onVoiceEnable(bool bEnable) {
    m_engine->enableAudio(bEnable);
    ui->videoWidget_1->showMuteMic(!bEnable);
}

void NECallWidget::onVideoEnable(bool bEnable) {
    m_engine->enableVideo(bEnable);
    ui->videoWidget_1->showMuteCamera(!bEnable);
    bottomTool->setVideoCheck(!bEnable);
}

void NECallWidget::onBeautyEnable(bool bEnable) {
    m_engine->enableBeauty(bEnable);
}

void NECallWidget::onExitCall() {
    if (m_engine->getBeautyEnable()) {
        m_engine->enableBeauty(false);
    }

    bottomTool->setVisible(false);
    m_engine->leaveChannel();
    ui->videoWidget_2->setJoinStatus(false);
    ui->videoWidget_3->setJoinStatus(false);
    ui->videoWidget_4->setJoinStatus(false);

    NESuggestTipWidget dlg(this);
    dlg.exec();

    this->hide();
    Q_EMIT sigCloseWindow();
}

void NECallWidget::onUserJoin(quint64 uid, const QString& name) {
    qInfo() << "onUserJoin: " << uid << "name：" << name;

    void* hwnd = Q_NULLPTR;

    if (!ui->videoWidget_2->isJoin()) {
        hwnd = (void*)ui->videoWidget_2->getVideoHwnd();
        ui->videoWidget_2->setUserId(QString::number(uid));
        ui->videoWidget_2->setJoinStatus(true);
    } else if (!ui->videoWidget_3->isJoin()) {
        hwnd = (void*)ui->videoWidget_3->getVideoHwnd();
        ui->videoWidget_3->setUserId(QString::number(uid));
        ui->videoWidget_3->setJoinStatus(true);
    } else if (!ui->videoWidget_4->isJoin()) {
        hwnd = (void*)ui->videoWidget_4->getVideoHwnd();
        ui->videoWidget_4->setUserId(QString::number(uid));
        ui->videoWidget_4->setJoinStatus(true);
    } else {
        return;
    }

    m_engine->setupRemoteVideo(uid, hwnd);

    NERoomInfo info = NERoomLiveConfig::instance().getRoomInfo();
    NERequest* request = NEHttpApi::getUserInfo(info.mpRoomId, QString::number(uid));
    connect(request, &NERequest::onSuccess, this, &NECallWidget::onGetUserInfoSuccess);
}

void NECallWidget::onUserLeft(quint64 uid) {
    qInfo() << "onUserLeft: " << uid;

    QString strUid = QString::number(uid);

    if (ui->videoWidget_2->getUid() == strUid) {
        ui->videoWidget_2->setJoinStatus(false);
    } else if (ui->videoWidget_3->getUid() == strUid) {
        ui->videoWidget_3->setJoinStatus(false);
    } else if (ui->videoWidget_4->getUid() == strUid) {
        ui->videoWidget_4->setJoinStatus(false);
    }

    m_engine->setupRemoteVideo(uid, Q_NULLPTR);
}

void NECallWidget::onJoinChannelSuccess() {
    qInfo() << "onJoinChannelSuccess";

    ui->videoWidget_1->setJoinStatus(true);
    //从收到进房成功回调到视频渲染会有个延迟
    QTimer::singleShot(1500, [this]() -> void {
        ui->stackedWidget->setCurrentIndex(1);
        bottomTool->setVisible(true);
        Toast::showTip("本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人", this);
    });
}

void NECallWidget::onJoinChannelFail(const QString& reson) {
    qInfo() << "onJoinChannelFail: " << reson;

    this->hide();
    Q_EMIT sigCloseWindow();
}

void NECallWidget::onDisconnected(int code) {
    //房间事件 > 10分钟被踢出房间
    if (code == 30207) {
        ui->videoWidget_1->setJoinStatus(false);
        ui->videoWidget_2->setJoinStatus(false);
        ui->videoWidget_3->setJoinStatus(false);
        ui->videoWidget_4->setJoinStatus(false);

        QMessageBox::warning(this, "警告", "本应用为测试产品，单次通话最长10分钟，点击确定退出", "确定");

        onExitCall();
    }
}

void NECallWidget::onGetUserInfoSuccess(const QString& response) {
    qInfo() << "onGetUserInfoSuccess: " << response;

    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
    QJsonObject data = doc.object()["data"].toObject();
    QString strUid = data["avRoomUid"].toVariant().toString();
    QString nickName = data["nickname"].toString();

    if (nickName.isEmpty()) {
        return;
    }

    if (ui->videoWidget_2->getUid() == strUid) {
        ui->videoWidget_2->setNickname(nickName);
    } else if (ui->videoWidget_3->getUid() == strUid) {
        ui->videoWidget_3->setNickname(nickName);
    } else if (ui->videoWidget_4->getUid() == strUid) {
        ui->videoWidget_4->setNickname(nickName);
    }
}

void NECallWidget::onUserVideoMute(quint64 uid, bool mute) {
    qInfo() << "onUserVideoMute: " << uid;

    if (!mute) {
        m_engine->startRemoteVideo(uid);
    }

    if (ui->videoWidget_2->getUid() == QString::number(uid)) {
        ui->videoWidget_2->showMuteCamera(mute);
    } else if (ui->videoWidget_3->getUid() == QString::number(uid)) {
        ui->videoWidget_3->showMuteCamera(mute);
    } else if (ui->videoWidget_4->getUid() == QString::number(uid)) {
        ui->videoWidget_4->showMuteCamera(mute);
    }
}

void NECallWidget::onUserAudioMute(quint64 uid, bool mute) {
    if (ui->videoWidget_2->getUid() == QString::number(uid)) {
        ui->videoWidget_2->showMuteMic(mute);
    } else if (ui->videoWidget_3->getUid() == QString::number(uid)) {
        ui->videoWidget_3->showMuteMic(mute);
    } else if (ui->videoWidget_4->getUid() == QString::number(uid)) {
        ui->videoWidget_4->showMuteMic(mute);
    }
}

void NECallWidget::onLeavingChannel() {
    m_engine->setupLocalVideo(Q_NULLPTR);
}

void NECallWidget::closeEvent(QCloseEvent* event) {
    onExitCall();

    return QWidget::closeEvent(event);
}

void NECallWidget::resizeEvent(QResizeEvent* event) {
    QPoint p(this->rect().left(), this->rect().bottom());
    p = mapToGlobal(p);

    bottomTool->move(p.x() + this->width() / 2 - bottomTool->width() / 2, p.y() - 92);

    return QWidget::resizeEvent(event);
}

void NECallWidget::moveEvent(QMoveEvent* event) {
    bottomTool->move(event->pos().x() + this->width() / 2 - bottomTool->width() / 2, event->pos().y() + this->rect().bottom() - 92);

    return QWidget::moveEvent(event);
}
