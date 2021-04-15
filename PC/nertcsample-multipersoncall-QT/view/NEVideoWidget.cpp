#include <QStyle>

#include "NEVideoWidget.h"
#include "ui_NEVideoWidget.h"

NEVideoWidget::NEVideoWidget(QWidget* parent) : QWidget(parent), ui(new Ui::NEVideoWidget) {
    ui->setupUi(this);

    videoRender = new QWidget(ui->videoContentView);
    videoRender->setStyleSheet("QWidget{background-color: #292933;}");
    videoRender->stackUnder(ui->frame);
    videoRender->stackUnder(ui->btnZoom);
    videoRender->setVisible(false);
    ui->lblMuteIcon->setVisible(false);
    ui->lblCenterName->setVisible(true);
    ui->btnZoom->setVisible(false);
    ui->lblSignal->setVisible(false);

    ui->btnZoom->setProperty("zoomMode", "zoomIn");

    connect(ui->btnZoom, &QPushButton::clicked, this, [=]{
        m_bZoomIn = !m_bZoomIn;
        if(m_bZoomIn){
            ui->btnZoom->setProperty("zoomMode", "zoomOut");
            Q_EMIT sigZoomIn(m_uid);
        }else{
            ui->btnZoom->setProperty("zoomMode", "zoomIn");
            Q_EMIT sigZoomOut();
        }

        ui->btnZoom->style()->unpolish(ui->btnZoom);
        ui->btnZoom->style()->polish(ui->btnZoom);
        ui->btnZoom->update();
    });
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

    ui->lblCenterName->setVisible(mute);
    update();
}

void NEVideoWidget::showMuteMic(bool mute) {
    ui->lblMuteIcon->setVisible(mute);
}

void NEVideoWidget::showZoomButton(bool visible)
{
    ui->btnZoom->setVisible(visible);
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
        ui->lblSignal->setVisible(true);
    } else {
        repaint();
        videoRender->setVisible(false);
        ui->lblMuteIcon->setVisible(false);
        ui->lblSignal->setVisible(false);
        ui->btnZoom->setVisible(false);
        ui->btnZoom->setProperty("zoomMode", "zoomIn");
        ui->btnZoom->style()->unpolish(ui->btnZoom);
        ui->btnZoom->style()->polish(ui->btnZoom);
        ui->btnZoom->update();
        setNickname("");
        m_uid.clear();
    }
}

void NEVideoWidget::setNetworkQuality(NetWorkQualityType type)
{
    if(type == NETWORKQUALITY_GOOD) {
        ui->lblSignal->setStyleSheet("border-image: url(:/image/networkquality_good.svg);");
    } else if (type ==NETWORKQUALITY_GENERAL){
        ui->lblSignal->setStyleSheet("border-image: url(:/image/networkquality_general.svg);");
    } else if(type == NETWORKQUALITY_POOR) {
        ui->lblSignal->setStyleSheet("border-image: url(:/image/networkquality_bad.svg);");
    } else if(type == NETWORKQUALITY_BAD){
        ui->lblSignal->setStyleSheet("border-image: url(:/image/networkquality_unknown.svg);");
    }
}

void NEVideoWidget::setCenterNameSize(bool max)
{
    int px = max ? 36 : 12;
    ui->lblCenterName->setStyleSheet(QString("color: rgb(255, 255, 255);font-size: %1px;background-color: transparent;").arg(px));
}

void NEVideoWidget::resetStatus()
{
    ui->lblMuteIcon->setVisible(false);
    ui->lblCenterName->setVisible(true);
    ui->btnZoom->setVisible(false);
    ui->lblSignal->setVisible(false);
    videoRender->setVisible(false);
    videoRender->setStyleSheet("QWidget{background-color: #292933;}");
    videoRender->update();
    ui->btnZoom->setProperty("zoomMode", "zoomIn");
    ui->btnZoom->style()->unpolish(ui->btnZoom);
    ui->btnZoom->style()->polish(ui->btnZoom);
    ui->btnZoom->update();
    ui->lblSignal->setStyleSheet("border-image: url(:/image/networkquality_unknown.svg);");
    setCenterNameSize(true);
    setNickname("");
    m_bJoin = false;
    m_uid.clear();
}
