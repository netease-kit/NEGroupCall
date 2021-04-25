#include <QAction>
#include <QApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRandomGenerator>
#include <QRegExpValidator>
#include <QStyle>

#include "NECallWidget.h"
#include "NEChatRoomBottomTool.h"
#include "NEJoinWidget.h"
#include "Toast.h"
#include "http/NEHttpApi.h"
#include "http/NERequest.h"
#include "ui_NEJoinWidget.h"
#include "utils/NERoomLiveConfig.h"
#include "utils/log_instance.h"
#include "view/NESettingWidget.h"

NEJoinWidget::NEJoinWidget(QWidget* parent)
    : QMainWindow(parent)
    , ui(new Ui::NEJoinWidget) {
    ui->setupUi(this);
    setWindowTitle("多人通话");
    setFixedSize(460, 470);

    videowindowPtr = std::make_shared<NECallWidget>();
    connect(this, &NEJoinWidget::sigJoinChannel, videowindowPtr.get(), &NECallWidget::onJoinChannel);
    connect(ui->joinChannel, &QPushButton::clicked, this, &NEJoinWidget::onBtnJoinChannelClicked);
    connect(ui->leRoomID, &QLineEdit::returnPressed, this, &NEJoinWidget::onBtnJoinChannelClicked);
    connect(ui->leNickname, &QLineEdit::returnPressed, this, &NEJoinWidget::onBtnJoinChannelClicked);
    connect(videowindowPtr.get(), &NECallWidget::sigCloseWindow, this, &NEJoinWidget::onCloseWindow);
    connect(ui->btnSetting, &QPushButton::clicked, this, [=] {
        NESettingWidget widget;
        widget.exec();
    });
}

NEJoinWidget::~NEJoinWidget() {
    delete ui;
}

void NEJoinWidget::onBtnJoinChannelClicked() {
    ui->joinChannel->setEnabled(false);
    QString roomid = ui->leRoomID->text();
    QString nickname = ui->leNickname->text();
    int pos = 0;

    LOG(INFO) << "nickname: " << nickname.toStdString();

    if (roomid.isEmpty()) {
        Toast::showTip("请填写房间号", this);
        return;
    }

    QRegExp rx("^[0-9]{12}$");
    QRegExpValidator* validator = new QRegExpValidator(rx, this);
    if (QRegExpValidator::Invalid == validator->validate(roomid, pos)) {
        Toast::showTip("房间号错误，仅支持12位及以下纯数字", this);
        return;
    }

    if (nickname.isEmpty()) {
        auto randomNumber = QRandomGenerator::global()->bounded(100000, 999999);
        nickname = "用户" + QString::number(randomNumber);
        ui->leNickname->setText(nickname);
        ui->leNickname->setFocus();
    } else {
        QRegExp rx2("[a-zA-Z0-9\u4e00-\u9fa5]{12}");
        QRegExpValidator* validator2 = new QRegExpValidator(rx2, this);
        if (QRegExpValidator::Invalid == validator2->validate(nickname, pos)) {
            Toast::showTip("昵称错误，仅支持12位及以下文本、字母及数字组合", this);
            return;
        }
    }

    NERequest* request = NEHttpApi::join(roomid, nickname);
    connect(request, &NERequest::onSuccess, this, &NEJoinWidget::onJoinHttpRequestSuccess);
    connect(request, &NERequest::onFail, this, &NEJoinWidget::onJoinHttpRequestFailed);
}

void NEJoinWidget::onCloseWindow() {
    this->show();
}

void NEJoinWidget::onJoinHttpRequestSuccess(const QString& response) {
    LOG(INFO) << "onJoinHttpRequestSuccess: " << response.toStdString();

    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
    QJsonObject data = doc.object()["data"].toObject();
    NERoomInfo info;

    info.roomKey = data["roomKey"].toString();
    info.costTime = data["costTime"].toString();
    info.duration = data["duration"].toInt();
    info.mpRoomId = data["mpRoomId"].toString();
    info.avRoomCid = data["avRoomCid"].toString();
    info.avRoomUid = data["avRoomUid"].toVariant().toString();
    info.requestId = data["requestId"].toString();
    info.createTime = data["createTime"].toInt();
    info.avRoomCName = data["avRoomCName"].toString();
    info.avRoomCheckSum = data["avRoomCheckSum"].toString();
    info.meetingUniqueId = data["meetingUniqueId"].toString();
    info.selfnickName = ui->leNickname->text();
    info.isOpenMic = ui->cbOpenMic->isChecked();
    info.isOpenCamera = ui->cbOpenCamera->isChecked();

    //如果是非安全模式，则token为空
#ifdef UNSAFE_APPKEY
    info.avRoomCheckSum = "";
#endif

    NERoomLiveConfig::instance().setRoomInfo(info);
    Q_EMIT sigJoinChannel();
    this->hide();
    ui->joinChannel->setEnabled(true);
}

void NEJoinWidget::onJoinHttpRequestFailed(int errType, int errCode, const QString& err) {
    LOG(INFO) << "onJoinHttpRequestFailed err: " << err.toStdString();

    if (errCode == 2001) {
        Toast::showTip("本应用为测试产品，每个频道最多4人，已达人数上限", this);
    } else {
        Toast::showTip("加入房间失败", this);
    }

    ui->joinChannel->setEnabled(true);
}

void NEJoinWidget::closeEvent(QCloseEvent* event) {
    QApplication::quit();
}
