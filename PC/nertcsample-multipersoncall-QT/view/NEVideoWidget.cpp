#include "NEVideoWidget.h"
#include "ui_NEVideoWidget.h"

NEVideoWidget::NEVideoWidget(QWidget* parent) : QWidget(parent), ui(new Ui::NEVideoWidget), m_bJoin(false) {
    ui->setupUi(this);

    videoRender = new QWidget(ui->videoContentView);
    videoRender->setStyleSheet("QWidget{background-color: #292933;}");
    videoRender->resize(this->size());
    videoRender->stackUnder(ui->frame);
    videoRender->setVisible(false);
    ui->lblMuteIcon->setVisible(false);
}

NEVideoWidget::~NEVideoWidget() {
    delete ui;
}

void NEVideoWidget::resizeEvent(QResizeEvent* event) {
    videoRender->resize(this->size());

    return QWidget::resizeEvent(event);
}

void* NEVideoWidget::getVideoHwnd() {
    return (void*)videoRender->winId();
}

void NEVideoWidget::showMuteCamera(bool mute) {
    videoRender->setVisible(!mute);
    update();
}

void NEVideoWidget::showMuteMic(bool mute) {
    ui->lblMuteIcon->setVisible(mute);
}

void NEVideoWidget::setNickname(const QString& strNickname) {
    nickName = strNickname;

    ui->lblCenterName->setText(strNickname);
    ui->lblCenterName->adjustSize();
    ui->lblName->setText(strNickname);
    ui->lblName->adjustSize();
    ui->lblName->setFixedHeight(20);
    repaint();
}

void NEVideoWidget::setUserId(const QString& uid) {
    m_uid = uid;
}

QString NEVideoWidget::getUid() const {
    return m_uid;
}

bool NEVideoWidget::isJoin() {
    return m_bJoin;
}

void NEVideoWidget::setJoinStatus(bool join) {
    m_bJoin = join;

    if (m_bJoin) {
        videoRender->setVisible(true);
    } else {
        repaint();
        videoRender->setVisible(false);
        ui->lblMuteIcon->setVisible(false);
        setNickname("");
    }
}
