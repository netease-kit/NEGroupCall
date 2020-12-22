#include <QJsonArray>
#include <QJsonDocument>

#include "NEFeedbackButton.h"
#include "NESuggestTipWidget.h"
#include "Toast.h"
#include "http/NEHttpApi.h"
#include "ui_NESuggestTipWidget.h"
#include "utils/NERoomLiveConfig.h"

NESuggestTipWidget::NESuggestTipWidget(QWidget* parent) : QDialog(parent), ui(new Ui::NESuggestTipWidget) {
    ui->setupUi(this);

    Qt::WindowFlags flags = Qt::Dialog;
    flags |= Qt::WindowCloseButtonHint;
    this->setWindowFlags(flags);
    this->setWindowTitle("问题反馈");
    ui->btnGood->setIsGoodFeedback(true);
    ui->btnPoor->setIsGoodFeedback(false);
    ui->stackedWidget->setVisible(false);
    ui->frame_3->setFixedWidth(370);
    ui->frame_3->setFixedHeight(1);
    ui->frame_3->setStyleSheet("background-color: #F2F3F5;margin-left: 20px;");
    adjustSize();

    this->move(parent->x() + parent->width() / 2 - this->width() / 2, parent->y() + 80);
    connect(ui->btnGood, &NEFeedbackButton::clicked, this, &NESuggestTipWidget::onBtnGoodClicked);
    connect(ui->btnPoor, &NEFeedbackButton::clicked, this, &NESuggestTipWidget::onBtnPoorClicked);
    connect(ui->btnSave, &QPushButton::clicked, this, &NESuggestTipWidget::onBtnSaveClicked);
}

NESuggestTipWidget::~NESuggestTipWidget() {
    delete ui;
}

void NESuggestTipWidget::onBtnGoodClicked() {
    ui->btnPoor->setIsCheck(false);
    ui->stackedWidget->setVisible(true);
    ui->stackedWidget->setCurrentIndex(0);
    resize(400, 247);
    repaint();

    Q_EMIT sigCallQuality(true);

    QTimer::singleShot(800, [this]() -> void { accept(); });
}

void NESuggestTipWidget::onBtnPoorClicked() {
    ui->btnGood->setIsCheck(false);
    ui->stackedWidget->setVisible(true);
    ui->stackedWidget->setCurrentIndex(1);
    resize(400, 540);
    repaint();

    Q_EMIT sigCallQuality(false);
}

void NESuggestTipWidget::onBtnSaveClicked() {
    NERoomInfo roomInfo = NERoomLiveConfig::instance().getRoomInfo();

    NERoomSuggestInfo info;

    info.cid = roomInfo.avRoomCid;
    info.uid = roomInfo.avRoomUid;
    info.content = ui->textEdit->toPlainText();
    info.appkey = roomInfo.nrtcAppKey;
    info.conetent_type = getCaseTypeJsonString();

    NEHttpApi::saveSuggest(info);

    Toast::showTip("提交成功，感谢您的反馈");

    ui->btnSave->setEnabled(false);

    QTimer::singleShot(1500, [this]() -> void { accept(); });
}

QString NESuggestTipWidget::getCaseTypeJsonString() {
    QJsonArray array;

    if (ui->cBNoAsyn->isChecked()) {
        array.push_back(QString::number(NO_SYNC));
    }

    if (ui->cBNoVideo->isChecked()) {
        array.push_back(QString::number(NO_VIDEO));
    }

    if (ui->cBNoVoice->isChecked()) {
        array.push_back(QString::number(NO_VOICE));
    }

    if (ui->cBMurVoice->isChecked()) {
        array.push_back(QString::number(MUR_VOICE));
    }

    if (ui->cBCrashExit->isChecked()) {
        array.push_back(QString::number(CRASH_EXIT));
    }

    if (ui->cBCatonVideo->isChecked()) {
        array.push_back(QString::number(CATON_VIDEO));
    }

    if (ui->cBCatonVoice->isChecked()) {
        array.push_back(QString::number(CATON_VOICE));
    }

    if (ui->cBBlurredVideo->isChecked()) {
        array.push_back(QString::number(BLURRED_VIDEO));
    }

    QString typeJson = QJsonDocument(array).toJson(QJsonDocument::Compact);
    return typeJson;
}
