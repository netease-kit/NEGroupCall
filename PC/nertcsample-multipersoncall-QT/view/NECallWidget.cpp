#include <utils/log_instance.h>
#include <QDebug>
#include <QDesktopWidget>
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
#include "NERoomDataWidget.h"
#include "NESuggestTipWidget.h"
#include "Toast.h"
#include "http/NEHttpApi.h"
#include "rtc/NEDeviceManager.h"
#include "ui_NECallWidget.h"
#include "utils/NERoomLiveConfig.h"

NECallWidget::NECallWidget(QWidget* parent)
    : QOpenGLWidget(parent)
    , ui(new Ui::NECallWidget) {
    ui->setupUi(this);

    this->resize(1184, 666);
    ui->stackedWidget->setCurrentIndex(0);
    setVisible(false);
    initVideoLayout();

    m_engine = std::make_shared<NERtcEngine>(Q_NULLPTR);
    bottomTool = new NEChatRoomBottomTool(this);
    bottomTool->setVisible(false);
    bottomTool->setRtcEngine(m_engine);
    bottomTool->init();

    qRegisterMetaType<nertc::NERtcNetworkQualityType>("nertc::NERtcNetworkQualityType");

    connect(bottomTool, &NEChatRoomBottomTool::sigVoiceEnable, this, &NECallWidget::onVoiceEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigVideoEnable, this, &NECallWidget::onVideoEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigBeautyEnable, this, &NECallWidget::onBeautyEnable);
    connect(bottomTool, &NEChatRoomBottomTool::sigExitCall, this, &NECallWidget::onExitCall);
    connect(bottomTool, &NEChatRoomBottomTool::sigShowData, this, [=] {
        wdt = new NERoomDataWidget();
        wdt->setRtcEngine(m_engine);
        wdt->exec();
        wdt->deleteLater();
        wdt = Q_NULLPTR;
    });

    connect(m_engine.get(), &NERtcEngine::sigUserJoined, this, &NECallWidget::onUserJoin);
    connect(m_engine.get(), &NERtcEngine::sigUserLeft, this, &NECallWidget::onUserLeft);
    connect(m_engine.get(), &NERtcEngine::sigJoinChannelSuccess, this, &NECallWidget::onJoinChannelSuccess);
    connect(m_engine.get(), &NERtcEngine::sigJoinChannelFail, this, &NECallWidget::onJoinChannelFail);
    connect(m_engine.get(), &NERtcEngine::sigDisconnected, this, &NECallWidget::onDisconnected);
    connect(m_engine.get(), &NERtcEngine::sigUserVideoMute, this, &NECallWidget::onUserVideoMute);
    connect(m_engine.get(), &NERtcEngine::sigUserAudioMute, this, &NECallWidget::onUserAudioMute);
    connect(m_engine.get(), &NERtcEngine::sigLeavingChannel, this, &NECallWidget::onLeavingChannel);
    connect(m_engine.get(), &NERtcEngine::sigNetworkQuality, this, &NECallWidget::onNetworkQuality);
}

NECallWidget::~NECallWidget() {
    delete ui;
}

void NECallWidget::onJoinChannel() {
    NERoomInfo info = NERoomLiveConfig::instance().getRoomInfo();

    setWindowTitle("房间ID: " + info.mpRoomId);
    m_videoWidgetList[0]->setNickname(info.selfnickName);
    m_videoWidgetList[0]->setUserId(info.avRoomUid);

    LOG(INFO) << "info.avRoomUid: " << info.avRoomUid.toStdString();

    if (!m_engine->getIsInit()) {
        //设置日志路径
        auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        auto rtcLog = appDataDir + "/NeRTC";
        auto byteLogDir = rtcLog.toUtf8();

        //初始化
        if (!m_engine->init(APP_KEY, byteLogDir)) {
            qDebug("[ERROR] Failed to initialize NERtc engine! NERtc SDK can't work!");
            return;
        }
    }

    setWindowFlags(Qt::Window);
    this->showNormal();
    this->resize(1184, 666);
    // move((QApplication::desktop()->width() - this->width()) / 2, (QApplication::desktop()->height() - this->height()) / 2);
    m_userCount = 1;

    //设置自己的渲染窗口
    void* hwnd = (void*)m_videoWidgetList[0]->getVideoHwnd();
    m_engine->setupLocalVideo(hwnd);

    //加入频道前设置参数
    NERoomProfile profile = NERoomLiveConfig::instance().getRoomProfile();
    m_engine->setCurrentAudioProfile(profile.audioProfile, profile.audioSence);
    m_engine->setCustomVideoProfile(profile.videoProfile, profile.framerate);

    //加入频道
    m_engine->joinChannel(info.avRoomCheckSum, info.avRoomCName, info.avRoomUid);
}

void NECallWidget::onVoiceEnable(bool bEnable) {
    m_engine->enableAudio(bEnable);
    m_videoWidgetList[0]->showMuteMic(!bEnable);
}

void NECallWidget::onVideoEnable(bool bEnable) {
    m_videoWidgetList[0]->showMuteCamera(!bEnable);

    if (bottomTool->getIsBeutyOpen()) {
        m_engine->enableBeauty(bEnable);
        //延迟操作摄像头，先让美颜数据走完
        QTimer::singleShot(100, [this, bEnable]() -> void {
            m_engine->enableVideo(bEnable);
        });
    } else {
        m_engine->enableVideo(bEnable);
    }
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

    for (int i = 0; i < 4; i++) {
        m_videoWidgetList[i]->resetStatus();
    }

    NESuggestTipWidget dlg(this);
    dlg.exec();

    adjustVideoLayout(ONE_PERSON_MODE);
    ui->stackedWidget->setCurrentIndex(0);
    this->setWindowFlags(Qt::SubWindow);
    this->showNormal();

    this->hide();
    bottomTool->setVisible(false);

    if (wdt != Q_NULLPTR) {
        wdt->accept();
        wdt->deleteLater();
        wdt = Q_NULLPTR;
    }

    Q_EMIT sigCloseWindow();
}

void NECallWidget::onUserJoin(quint64 uid, const QString& name) {
    LOG(INFO) << "onUserJoin: " << uid << "name：" << name.toStdString();

    m_userCount++;
    void* hwnd = Q_NULLPTR;
    QString strUid = QString::number(uid);

    for (int i = 1; i < 4; i++) {
        if (!m_videoWidgetList[i]->isJoin()) {
            m_videoWidgetList[i]->setUserId(strUid);
            m_videoWidgetList[i]->setJoinStatus(true);
            m_videoWidgetList[i]->showMuteMic(true);
            if (zoomInUserId.isEmpty()) {
                m_videoWidgetList[i]->showZoomButton(true);
            }
            hwnd = m_videoWidgetList[i]->getVideoHwnd();
            break;
        }
    }

    m_engine->setupRemoteVideo(uid, hwnd);

    if (m_userCount > 2 && !zoomInUserId.isEmpty()) {
        adjustVideoLayout(MUL_SPEAKER_MODE, zoomInUserId);
    } else {
        adjustVideoLayout(MUL_GALLERY_MODE);
    }

    NERoomInfo info = NERoomLiveConfig::instance().getRoomInfo();
    NERequest* request = NEHttpApi::getUserInfo(info.mpRoomId, QString::number(uid));
    connect(request, &NERequest::onSuccess, this, &NECallWidget::onGetUserInfoSuccess);
}

void NECallWidget::onUserLeft(quint64 uid) {
    LOG(INFO) << "onUserLeft: " << uid;
    m_userCount--;
    QString strUid = QString::number(uid);

    NEVideoWidget* temp = Q_NULLPTR;
    for (int i = 1; i < 4; i++) {
        if (m_videoWidgetList[i]->getUid() == strUid) {
            m_videoWidgetList[i]->setJoinStatus(false);
            temp = m_videoWidgetList[i];
            m_videoWidgetList.removeAt(i);
            break;
        }
    }

    if (temp != Q_NULLPTR) {
        m_videoWidgetList.push_back(temp);
    }

    if (m_userCount == 1) {
        adjustVideoLayout(ONE_PERSON_MODE);
        m_engine->setupRemoteVideo(uid, Q_NULLPTR);
        return;
    }

    if (m_userCount < 2) {
        adjustVideoLayout(ONE_PERSON_MODE);
    } else {
        if (m_viewMode == MUL_GALLERY_MODE || strUid == zoomInUserId) {
            adjustVideoLayout(MUL_GALLERY_MODE);
        } else {
            adjustVideoLayout(MUL_SPEAKER_MODE, zoomInUserId);
        }
    }

    m_engine->setupRemoteVideo(uid, Q_NULLPTR);
}

void NECallWidget::onJoinChannelSuccess() {
    LOG(INFO) << "onJoinChannelSuccess";

    m_videoWidgetList[0]->setJoinStatus(true);

    if (!NERoomLiveConfig::instance().getRoomInfo().isOpenMic) {
        bottomTool->setAudioCheck(true);
        m_videoWidgetList[0]->showMuteMic(true);
    } else {
        m_engine->enableAudio(true);
        bottomTool->setAudioCheck(false);
        m_videoWidgetList[0]->showMuteMic(false);
    }

    if (!NERoomLiveConfig::instance().getRoomInfo().isOpenCamera) {
        bottomTool->setVideoCheck(true);
        m_videoWidgetList[0]->showMuteCamera(true);
    } else {
        m_engine->enableVideo(true);
        bottomTool->setVideoCheck(false);
        m_videoWidgetList[0]->showMuteCamera(false);
    }

    //从收到进房成功回调到视频渲染会有个延迟
    QTimer::singleShot(1500, [this]() -> void {
        if (!this->isHidden()) {
            ui->stackedWidget->setCurrentIndex(1);

            if (this->windowState() != Qt::WindowMinimized && this->windowState() != 3) {
                bottomTool->setVisible(true);
                bottomTool->init();
            }

            Toast::showTip("本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人", this);
        }
    });
}

void NECallWidget::onJoinChannelFail(const QString& reson) {
    LOG(INFO) << "onJoinChannelFail: " << reson.toStdString();

    this->hide();
    Q_EMIT sigCloseWindow();
}

void NECallWidget::onDisconnected(int code) {
    for (int i = 0; i < 4; i++) {
        m_videoWidgetList[i]->setJoinStatus(false);
    }

    //房间事件 > 10分钟被踢出房间
    if (code == 30207) {
        QMessageBox::warning(this, "警告", "本应用为测试产品，单次通话最长10分钟，点击确定退出", "确定");
    }

    LOG(INFO) << "onDisconnected" << code;

    onExitCall();
}

void NECallWidget::onGetUserInfoSuccess(const QString& response) {
    LOG(INFO) << "onGetUserInfoSuccess: " << response.toStdString();

    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
    QJsonObject data = doc.object()["data"].toObject();
    QString strUid = data["avRoomUid"].toVariant().toString();
    QString nickName = data["nickname"].toString();

    if (nickName.isEmpty()) {
        return;
    }

    for (int i = 1; i < 4; i++) {
        if (m_videoWidgetList[i]->getUid() == strUid) {
            m_videoWidgetList[i]->setNickname(nickName);
        }
    }
}

void NECallWidget::onUserVideoMute(quint64 uid, bool mute) {
    LOG(INFO) << "onUserVideoMute: " << uid;

    if (!mute) {
        m_engine->startRemoteVideo(uid);
    }

    QString strUid = QString::number(uid);
    for (int i = 1; i < 4; i++) {
        if (m_videoWidgetList[i]->getUid() == strUid) {
            m_videoWidgetList[i]->showMuteCamera(mute);
        }
    }
}

void NECallWidget::onUserAudioMute(quint64 uid, bool mute) {
    LOG(INFO) << "onUserAudioMute"
              << "uid: " << uid << "mute" << mute;

    QString strUid = QString::number(uid);
    for (int i = 1; i < 4; i++) {
        if (m_videoWidgetList[i]->getUid() == strUid) {
            m_videoWidgetList[i]->showMuteMic(mute);
        }
    }
}

void NECallWidget::onLeavingChannel() {
    m_engine->setupLocalVideo(Q_NULLPTR);
}

void NECallWidget::onNetworkQuality(quint64 uid, nertc::NERtcNetworkQualityType up, nertc::NERtcNetworkQualityType down) {
    // LOG(INFO) << "NetworkQuality " << " uid " << uid << " up " << up << " down " << down;

    QString strUid = QString::number(uid);
    NetWorkQualityType type = netWorkQualityType(up, down, strUid == m_videoWidgetList[0]->getUid());

    for (int i = 0; i < 4; i++) {
        if (m_videoWidgetList[i]->getUid() == strUid) {
            m_videoWidgetList[i]->setNetworkQuality(type);
            return;
        }
    }
}

void NECallWidget::onZoomIn(QString uid) {
    NEVideoWidget* wdt = qobject_cast<NEVideoWidget*>(QObject::sender());
    adjustVideoLayout(MUL_SPEAKER_MODE, wdt->getUid());
}

void NECallWidget::onZoomOut() {
    NEVideoWidget* wdt = qobject_cast<NEVideoWidget*>(QObject::sender());
    adjustVideoLayout(MUL_GALLERY_MODE, wdt->getUid());
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

void NECallWidget::changeEvent(QEvent* event) {
    if (event->type() != QEvent::WindowStateChange)
        return;

    if (ui->stackedWidget->currentIndex() != 0) {
        if (this->windowState() == Qt::WindowMinimized || this->windowState() == 3) {
            bottomTool->setVisible(false);
        } else if (this->windowState() == Qt::WindowNoState) {
            bottomTool->setVisible(true);
        }
    }

    return QWidget::changeEvent(event);
}

NetWorkQualityType NECallWidget::netWorkQualityType(nertc::NERtcNetworkQualityType upNetWorkQuality,
                                                    nertc::NERtcNetworkQualityType downNetWorkQuality,
                                                    bool bSelf) {
    if (bSelf) {
        if ((nertc::kNERtcNetworkQualityExcellent == upNetWorkQuality || nertc::kNERtcNetworkQualityGood == upNetWorkQuality)) {
            return NETWORKQUALITY_GOOD;
        } else if (nertc::kNERtcNetworkQualityPoor == upNetWorkQuality) {
            return NETWORKQUALITY_GENERAL;
        } else if (nertc::kNERtcNetworkQualityBad == upNetWorkQuality || nertc::kNERtcNetworkQualityVeryBad == upNetWorkQuality) {
            return NETWORKQUALITY_POOR;
        } else if (nertc::kNERtcNetworkQualityUnknown == upNetWorkQuality || nertc::kNERtcNetworkQualityDown == upNetWorkQuality) {
            return NETWORKQUALITY_BAD;
        } else {
            return NETWORKQUALITY_GENERAL;
        }
    } else {
        if ((nertc::kNERtcNetworkQualityExcellent == downNetWorkQuality || nertc::kNERtcNetworkQualityGood == downNetWorkQuality)) {
            return NETWORKQUALITY_GOOD;
        } else if (nertc::kNERtcNetworkQualityPoor == downNetWorkQuality) {
            return NETWORKQUALITY_GENERAL;
        } else if (nertc::kNERtcNetworkQualityBad == downNetWorkQuality || nertc::kNERtcNetworkQualityVeryBad == downNetWorkQuality) {
            return NETWORKQUALITY_POOR;
        } else if (nertc::kNERtcNetworkQualityUnknown == downNetWorkQuality || nertc::kNERtcNetworkQualityDown == downNetWorkQuality) {
            return NETWORKQUALITY_BAD;
        } else {
            return NETWORKQUALITY_GENERAL;
        }
    }
}

void NECallWidget::initVideoLayout() {
    NEVideoWidget* videoWidget_1 = new NEVideoWidget(this);
    videoWidget_1->setMinimumSize(160, 90);
    videoWidget_1->setObjectName(QString::fromUtf8("videoWidget_1"));
    m_videoWidgetList.push_back(videoWidget_1);
    connect(videoWidget_1, &NEVideoWidget::sigZoomIn, this, &NECallWidget::onZoomIn);
    connect(videoWidget_1, &NEVideoWidget::sigZoomOut, this, &NECallWidget::onZoomOut);

    NEVideoWidget* videoWidget_2 = new NEVideoWidget(this);
    videoWidget_2->setMinimumSize(160, 90);
    videoWidget_2->setObjectName(QString::fromUtf8("videoWidget_2"));
    videoWidget_2->setVisible(false);
    m_videoWidgetList.push_back(videoWidget_2);
    connect(videoWidget_2, &NEVideoWidget::sigZoomIn, this, &NECallWidget::onZoomIn);
    connect(videoWidget_2, &NEVideoWidget::sigZoomOut, this, &NECallWidget::onZoomOut);

    NEVideoWidget* videoWidget_3 = new NEVideoWidget(this);
    videoWidget_3->setMinimumSize(160, 90);
    videoWidget_3->setObjectName(QString::fromUtf8("videoWidget_3"));
    videoWidget_3->setVisible(false);
    m_videoWidgetList.push_back(videoWidget_3);
    connect(videoWidget_3, &NEVideoWidget::sigZoomIn, this, &NECallWidget::onZoomIn);
    connect(videoWidget_3, &NEVideoWidget::sigZoomOut, this, &NECallWidget::onZoomOut);

    NEVideoWidget* videoWidget_4 = new NEVideoWidget(this);
    videoWidget_4->setMinimumSize(160, 90);
    videoWidget_4->setObjectName(QString::fromUtf8("videoWidget_4"));
    videoWidget_4->setVisible(false);
    m_videoWidgetList.push_back(videoWidget_4);
    connect(videoWidget_4, &NEVideoWidget::sigZoomIn, this, &NECallWidget::onZoomIn);
    connect(videoWidget_4, &NEVideoWidget::sigZoomOut, this, &NECallWidget::onZoomOut);

    ui->layout_top->addWidget(videoWidget_1);
}

void NECallWidget::clearLayout() {
    if (Q_NULLPTR != ui->speakerLayout->itemAt(0)) {
        ui->speakerLayout->removeItem(ui->speakerLayout->itemAt(0));
    }

    int secondaryMemberCount = ui->secondaryMembersLayout->count();
    for (int i = 0; i < secondaryMemberCount; i++) {
        ui->secondaryMembersLayout->removeItem(ui->secondaryMembersLayout->itemAt(0));
    }

    int layout_top_count = ui->layout_top->count();
    for (int i = 0; i < layout_top_count; i++) {
        ui->layout_top->removeItem(ui->layout_top->itemAt(0));
    }

    int layout_bottom_count = ui->layout_bottom->count();
    for (int i = 0; i < layout_bottom_count; i++) {
        ui->layout_bottom->removeItem(ui->layout_bottom->itemAt(0));
    }

    int count = ui->verticalLayout_7->count();
    for (int i = 0; i < count; i++) {
        QLayoutItem* layoutItem = ui->verticalLayout_7->itemAt(0);
        ui->verticalLayout_7->removeItem(layoutItem);
    }

    for (int i = 0; i < 4; i++) {
        m_videoWidgetList[i]->setVisible(false);
        m_videoWidgetList[i]->showZoomButton(true);
        m_videoWidgetList[i]->setMaximumSize(16777215, 16777215);
    }
}

void NECallWidget::adjustVideoLayout(NEViewMode viewMode, QString speakerUid) {
    clearLayout();
    m_viewMode = viewMode;

    if (viewMode == ONE_PERSON_MODE) {
        zoomInUserId.clear();

        ui->layout_top->addWidget(m_videoWidgetList[0]);
        ui->verticalLayout_7->addLayout(ui->layout_top);

        m_videoWidgetList[0]->showZoomButton(false);
        m_videoWidgetList[0]->setVisible(true);

        ui->stackedWidget->setCurrentIndex(1);
    } else if (viewMode == MUL_GALLERY_MODE) {
        zoomInUserId.clear();

        if (m_userCount == 2) {
            ui->layout_top->addWidget(m_videoWidgetList[0]);
            ui->layout_top->addWidget(m_videoWidgetList[1]);

            ui->verticalLayout_7->addStretch(1);
            ui->verticalLayout_7->addLayout(ui->layout_top, 2);
            ui->verticalLayout_7->addStretch(1);
        } else if (m_userCount == 3) {
            ui->layout_top->addWidget(m_videoWidgetList[0], 1);
            ui->layout_top->addWidget(m_videoWidgetList[1], 1);
            ui->layout_bottom->addStretch(1);
            ui->layout_bottom->addWidget(m_videoWidgetList[2], 2);
            ui->layout_bottom->addStretch(1);

            ui->verticalLayout_7->addLayout(ui->layout_top);
            ui->verticalLayout_7->addLayout(ui->layout_bottom);
        } else if (m_userCount == 4) {
            ui->layout_top->addWidget(m_videoWidgetList[0]);
            ui->layout_top->addWidget(m_videoWidgetList[1]);
            ui->layout_bottom->addWidget(m_videoWidgetList[2]);
            ui->layout_bottom->addWidget(m_videoWidgetList[3]);

            ui->verticalLayout_7->addLayout(ui->layout_top);
            ui->verticalLayout_7->addLayout(ui->layout_bottom);
        }

        for (int i = 0; i < m_userCount; i++) {
            m_videoWidgetList[i]->setVisible(true);
        }

        ui->stackedWidget->setCurrentIndex(1);
    } else if (viewMode == MUL_SPEAKER_MODE) {
        zoomInUserId = speakerUid;

        for (int i = 0; i < 4; i++) {
            if (!m_videoWidgetList[i]->isJoin()) {
                continue;
            }

            m_videoWidgetList[i]->setVisible(true);

            if (!zoomInUserId.isEmpty() && (zoomInUserId == m_videoWidgetList[i]->getUid())) {
                ui->speakerLayout->addWidget(m_videoWidgetList[i]);
            } else {
                m_videoWidgetList[i]->showZoomButton(false);
                m_videoWidgetList[i]->setCenterNameSize(false);
                m_videoWidgetList[i]->setMaximumSize(160, 90);
                ui->secondaryMembersLayout->addWidget(m_videoWidgetList[i]);
            }
        }

        ui->stackedWidget->setCurrentIndex(2);
    }
}
