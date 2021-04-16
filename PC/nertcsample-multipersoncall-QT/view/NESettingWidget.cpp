#include "NESettingWidget.h"
#include "ui_NESettingWidget.h"
#include <QDebug>

NESettingWidget::NESettingWidget(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::NESettingWidget)
{
    ui->setupUi(this);

    initWidget();

    connect(ui->comboxProfile, &QComboBox::currentTextChanged, this, [=]{
        if(ui->comboxProfile->currentIndex() < 2){
            ui->comboxFramerate->setCurrentIndex(2);
        } else{
            ui->comboxFramerate->setCurrentIndex(4);
        }
    });

    connect(ui->rBMusic, &QRadioButton::clicked, this, [=]{
        m_voiceSenceQualityIndex = ui->comboxAudioQuality->currentIndex();
        initQualityComboBox(true);
        ui->comboxAudioQuality->setCurrentIndex(m_musicSenceQualityIndex);
    });

    connect(ui->rBVoice, &QRadioButton::clicked, this, [=]{
        m_musicSenceQualityIndex = ui->comboxAudioQuality->currentIndex();
        initQualityComboBox(false);
        ui->comboxAudioQuality->setCurrentIndex(m_voiceSenceQualityIndex);
    });

    connect(ui->btnCancel, &QPushButton::clicked, this, &QDialog::reject);

    connect(ui->btnConfirm, &QPushButton::clicked, this, [=]{

        NERoomProfile profile;
        profile.videoProfile = (NEVideoProfileType)ui->comboxProfile->currentIndex();
        profile.audioSence = (NEAudioScenarioType)(ui->rBMusic->isChecked() ? kNEAudioScenarioMusic : kNEAudioScenarioSpeech);
        profile.framerate = (NEVideoFramerateType)ui->comboxFramerate->currentText().toInt();
        if(profile.audioSence == kNEAudioScenarioMusic){
            profile.audioProfile = (NEAudioProfileType)(ui->comboxAudioQuality->currentIndex() + 3);
        }else{
            profile.audioProfile = (NEAudioProfileType)(ui->comboxAudioQuality->currentIndex() + 1);
        }
        NERoomLiveConfig::instance().setRoomProfile(profile);
        accept();
    });
}

NESettingWidget::~NESettingWidget()
{
    delete ui;
}

void NESettingWidget::initWidget()
{
    Qt::WindowFlags flags = Qt::Dialog;
    flags |= Qt::WindowCloseButtonHint;
    this->setWindowFlags(flags);
    this->setWindowTitle("设置");
    ui->line->setMaximumHeight(1);
    ui->line_2->setMaximumHeight(1);
    ui->line->setStyleSheet(QString("QFrame{border:1px solid #e6e7eb}"));
    ui->line_2->setStyleSheet(QString("QFrame{border:1px solid #e6e7eb}"));

    NERoomProfile profile = NERoomLiveConfig::instance().getRoomProfile();
    if(profile.audioSence == kNEAudioScenarioMusic){
        initQualityComboBox(true);
        m_musicSenceQualityIndex = (unsigned int)profile.audioProfile - 3;
        ui->comboxAudioQuality->setCurrentIndex(m_musicSenceQualityIndex);
        ui->rBMusic->setChecked(true);
    }else{
        initQualityComboBox(false);
        m_voiceSenceQualityIndex = (unsigned int)profile.audioProfile - 1;
        ui->comboxAudioQuality->setCurrentIndex(m_voiceSenceQualityIndex);
        ui->rBVoice->setChecked(true);
    }

    ui->comboxProfile->setCurrentIndex(profile.videoProfile);
    ui->comboxFramerate->setCurrentText(QString::number((int)profile.framerate));
}

void NESettingWidget::initQualityComboBox(bool bMusicSence)
{
    ui->comboxAudioQuality->clear();
    QStringList items;
    items << "一般" << "清晰";
    if(bMusicSence){
        items << "高清" << "极致";
    }
    ui->comboxAudioQuality->addItems(items);
}
