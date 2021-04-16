#include <QVBoxLayout>

#include "MClearLineEdit.h"

MClearLineEdit::MClearLineEdit(QWidget *parent)
    : MLineEdit(parent)
    , holderTextColor("#B0B6BE")
    , inputColor("#337EFF")
    , textColor("#333333")
{
    setContextMenuPolicy(Qt::NoContextMenu);

    initBottomLine();

    setButtonIcon(":/image/clear.png");

    connect(this, &QLineEdit::textChanged, this, &MClearLineEdit::onTextChanged);
    connect(this, &MLineEdit::sigButtonClicked, this, &MClearLineEdit::onClearText);
}

void MClearLineEdit::setNormalTextColor(const QString &color)
{
    textColor = color;
}

void MClearLineEdit::setInputTextColor(const QString &color)
{
    inputColor = color;
}

void MClearLineEdit::setHolderTextColor(const QString &color)
{
    holderTextColor = color;
}

void MClearLineEdit::focusInEvent(QFocusEvent *event)
{
    QString color = text().isEmpty() ? holderTextColor : inputColor;
    setTextStyle(color);

    line->setStyleSheet(QString("QFrame{border:1px solid %1}").arg(inputColor));

    return QLineEdit::focusInEvent(event);
}

void MClearLineEdit::focusOutEvent(QFocusEvent *event)
{
    QString color = text().isEmpty() ? holderTextColor : textColor;
    setTextStyle(color);

    line->setStyleSheet(QString("QFrame{border:1px solid #DCDFE5}"));

    return QLineEdit::focusOutEvent(event);
}

void MClearLineEdit::onTextChanged(const QString &text)
{
    QString color = text.isEmpty() ? holderTextColor : inputColor;
    setTextStyle(color);
}

void MClearLineEdit::onClearText()
{
    setText("");
}

void MClearLineEdit::setTextStyle(const QString &color)
{
    this->setStyleSheet(QString("font-size: 17px;"
                        "color: %1;"
                                "border: 0px;").arg(color));
}

void MClearLineEdit::initBottomLine()
{
    line = new QFrame(this);
    line->setFrameShape(QFrame::HLine);
    line->setFrameShadow(QFrame::Sunken);
    line->setLineWidth(1);
    line->setStyleSheet("QFrame{border:1px solid #DCDFE5}");
    line->setMinimumSize(QSize(320, 1));
    line->setMaximumSize(QSize(320, 1));
    line->move(line->x(), line->y() + this->height() + 12);
}
