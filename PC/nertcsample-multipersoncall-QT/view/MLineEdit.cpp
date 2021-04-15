#include <QPushButton>
#include <QHBoxLayout>
#include <QStyle>
#include <QApplication>

#include "MLineEdit.h"

MLineEdit::MLineEdit(QWidget *parent)
    : QLineEdit(parent)
{
    m_button = new QPushButton(this);
    m_button->setVisible(false);
    m_button->setIconSize(QSize(20, 20));

    connect(m_button, &QPushButton::clicked, this, &MLineEdit::sigButtonClicked);
    connect(this, &QLineEdit::textChanged, this, &MLineEdit::onTextChanged);
}

void MLineEdit::setButtonSize(int width, int buttonMargin)
{
    auto policy = m_button->sizePolicy();
    policy.setHorizontalPolicy(QSizePolicy::Fixed);
    m_button->setSizePolicy(policy);
    m_button->setFixedWidth(width + buttonMargin*2);
}

void MLineEdit::setButtonIcon(const QString &iconUrl)
{
    QIcon icon;
    QPixmap pix(iconUrl);
    pix = pix.scaled(20, 20, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
    icon.addPixmap(pix);
    m_button->setIcon(icon);
    setButtonSize(20, 0);
    m_button->setFlat(true);
    addButton();
}

void MLineEdit::enterEvent(QEvent *event)
{
    if(!this->text().isEmpty()){
        m_button->setVisible(true);
        m_button->setCursor(QCursor(Qt::PointingHandCursor));
    }

    return QLineEdit::enterEvent(event);
}

void MLineEdit::leaveEvent(QEvent *event)
{
    m_button->setVisible(false);
    return QLineEdit::leaveEvent(event);
}

void MLineEdit::focusOutEvent(QFocusEvent *event)
{
    m_button->setVisible(false);
    return QLineEdit::focusOutEvent(event);
}

void MLineEdit::addButton()
{
    m_button->setFocusPolicy(Qt::NoFocus);
    m_button->setCursor(Qt::ArrowCursor);
    auto btnLayout = new QHBoxLayout;
    btnLayout->addStretch();
    btnLayout->addWidget(m_button);
    btnLayout->setAlignment(Qt::AlignRight);
    btnLayout->setContentsMargins(0, 0, 0, 0);
    setLayout(btnLayout);
    setTextMargins(0, 0, 0, 0);
}

void MLineEdit::onTextChanged(const QString &text)
{
    if(!this->text().isEmpty()){
        m_button->setVisible(true);
    }
}
