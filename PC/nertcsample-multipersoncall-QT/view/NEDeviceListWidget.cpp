#include <QListWidgetItem>
#include <QScrollBar>
#include <QDebug>

#include "NEDeviceListWidget.h"
#include "ui_NEDeviceListWidget.h"
#include "NEDeviceItemWidget.h"
#include "rtc/NEDeviceManager.h"

NEDeviceListWidget::NEDeviceListWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NEDeviceListWidget)
{
    ui->setupUi(this);
    ui->listWidget->setSpacing(0);
    ui->listWidget->verticalScrollBar()->setMaximumWidth(0);
    ui->listWidget->verticalScrollBar()->setVisible(false);

    connect(ui->listWidget, &QListWidget::itemClicked, this, &NEDeviceListWidget::onItemClicked);
}

NEDeviceListWidget::~NEDeviceListWidget()
{
    delete ui;
}

void NEDeviceListWidget::setDeviceTitleName(const QString &name)
{
    ui->label->setText(name);
}

void NEDeviceListWidget::loadDeviceList(const QList<DeviceInfo> &deviceList)
{
    ui->listWidget->clear();

    for(int i = 0; i < deviceList.count(); ++i){
        QListWidgetItem* item = new QListWidgetItem(ui->listWidget);
        NEDeviceItemWidget* itemWidget = new NEDeviceItemWidget(ui->listWidget);
        itemWidget->setDeviceName(deviceList[i].deviceName);
        itemWidget->setDeviceUid(deviceList[i].deviceGuid);
        ui->listWidget->addItem(item);
        ui->listWidget->setItemWidget(item, itemWidget);

        if(i == 0)
        {
            ui->listWidget->setCurrentRow(0);
            itemWidget->setCurrentItem(true);
        }
    }

    ui->listWidget->setFixedSize(320, ui->listWidget->count() * 32);
    this->adjustSize();
}

void NEDeviceListWidget::setCurrentDevice(const QString &curDevice)
{
    for(int i = 0; i < ui->listWidget->count(); i++){
        NEDeviceItemWidget* widget = qobject_cast<NEDeviceItemWidget*>(ui->listWidget->itemWidget(ui->listWidget->item(i)));
        if(widget->getDeviceUid() == curDevice){
            widget->setCurrentItem(true);
        }else{
            widget->setCurrentItem(false);
        }
    }
}

void NEDeviceListWidget::onItemClicked(QListWidgetItem *item)
{
   NEDeviceItemWidget* itemWidget =  qobject_cast<NEDeviceItemWidget*>(ui->listWidget->itemWidget(item));

   if(Q_NULLPTR == itemWidget){
       return;
   }

   QString curDeviceGuid = itemWidget->getDeviceUid();

   for(int i = 0; i < ui->listWidget->count(); i++){
       NEDeviceItemWidget* widget = qobject_cast<NEDeviceItemWidget*>(ui->listWidget->itemWidget(ui->listWidget->item(i)));
       widget->setCurrentItem(false);

   }

   itemWidget->setCurrentItem(true);

   qInfo() << "curDeviceGuid: " << curDeviceGuid;

   Q_EMIT sigDeviceChanged(curDeviceGuid);
}
