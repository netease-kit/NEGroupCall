#include "NERoomDataWidget.h"
#include "ui_NERoomDataWidget.h"
#include "rtc/NERtcEngine.h"

NERoomDataWidget::NERoomDataWidget(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::NERoomDataWidget)
{
    ui->setupUi(this);
    Qt::WindowFlags flags = Qt::Dialog;
    flags |= Qt::WindowCloseButtonHint;
    this->setWindowFlags(flags);
    setWindowTitle("实时数据");
}

NERoomDataWidget::~NERoomDataWidget()
{
    delete ui;
}

void NERoomDataWidget::setRtcEngine(std::shared_ptr<NERtcEngine> engine)
{
    m_engine = engine;
    qRegisterMetaType<NERoomStats>("NERoomStats");

    connect(m_engine.get(), &NERtcEngine::sigRtcStats, this, [=] (NERoomStats stats){
        ui->lblDelay->setText(QString("网络延时： %1").arg(stats.down_rtt) + " ms");

        ui->lblVideoBitrate->setText(QString("视频发送/接收码率：%1/%2").arg(stats.tx_video_kbitrate).arg(stats.rx_video_kbitrate) + " kbps");

        ui->lblAudioBitrate->setText(QString("音频发送/接收码率：%1/%2").arg(stats.tx_audio_kbitrate).arg(stats.rx_audio_kbitrate) + " kbps");

        ui->lblVideoLossRate->setText(QString("本地上行/下行视频丢包率：%1/%2").arg(stats.tx_video_packet_loss_rate).arg(stats.rx_video_packet_loss_rate) + " %");

        ui->lblAudioLossRate->setText(QString("本地上行/下行音频丢包率：%1/%2").arg(stats.tx_audio_packet_loss_rate).arg(stats.rx_audio_packet_loss_rate) + " %");

        ui->lblCpu->setText(QString("Cpu占用率 总/App：%1/%2").arg(stats.cpu_total_usage).arg(stats.cpu_app_usage) + " %");
    });
}
