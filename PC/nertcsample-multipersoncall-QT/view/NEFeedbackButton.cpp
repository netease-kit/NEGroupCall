#include "NEFeedbackButton.h"
#include "ui_NEFeedbackButton.h"

NEFeedbackButton::NEFeedbackButton(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::NEFeedbackButton)
    , m_bCheck(false)
    , m_bGoodFeedback(false)
{
    ui->setupUi(this);
}

NEFeedbackButton::~NEFeedbackButton()
{
    delete ui;
}

void NEFeedbackButton::mousePressEvent(QMouseEvent *event)
{
    m_bCheck = !m_bCheck;
    updateButtonStyle();

    Q_EMIT clicked();
}

void NEFeedbackButton::setIsGoodFeedback(bool isGood)
{
    m_bGoodFeedback = isGood;
    updateButtonStyle();
}

void NEFeedbackButton::setIsCheck(bool isCheck)
{
    m_bCheck = isCheck;
    updateButtonStyle();
}

void NEFeedbackButton::updateButtonStyle()
{
    if(!m_bCheck){

        this->setStyleSheet("QFrame#frame{border-radius: 4px;background-color: #F2F3F5;}");

        if(m_bGoodFeedback){

            ui->lblThumbIcon->setStyleSheet("QLabel#lblThumbIcon{background-image: url(:/image/thumb-up.svg);background-color: transparent;}");
            ui->lblFeedback->setText("好");

        }else{
            ui->lblThumbIcon->setStyleSheet("background-image: url(:/image/thumbs-down.svg);background-color: transparent;");
            ui->lblFeedback->setText("坏");
        }
    }else{
        if(m_bGoodFeedback){

            this->setStyleSheet("QFrame#frame{border-radius: 4px;background-color: #eaf2ff;}");
            ui->lblThumbIcon->setStyleSheet("background-image: url(:/image/thumb-up-active.svg);background-color: transparent;");
            ui->lblFeedback->setText("好");
        }else{
            this->setStyleSheet("QFrame#frame{border-radius: 4px;background-color: #fdecee;}");
            ui->lblThumbIcon->setStyleSheet("background-image: url(:/image/thumbs-down-active.svg);background-color: transparent;");
            ui->lblFeedback->setText("坏");
        }
    }
}
