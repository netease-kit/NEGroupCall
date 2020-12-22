#include "NENameWidget.h"
#include "ui_NENameWidget.h"

#include <QFontMetrics>

NENameWidget::NENameWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NENameWidget)
{
    ui->setupUi(this);
    setAttribute(Qt::WA_TranslucentBackground, true);
}

NENameWidget::~NENameWidget()
{
    delete ui;
}

void NENameWidget::setName(const QString &name)
{
    ui->lblName->setText(name);
    adjustSize();
}
