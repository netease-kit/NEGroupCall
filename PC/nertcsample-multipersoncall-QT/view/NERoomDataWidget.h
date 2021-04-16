#ifndef NEROOMDATAWIDGET_H
#define NEROOMDATAWIDGET_H

#include <QDialog>

namespace Ui {
class NERoomDataWidget;
}

class NERtcEngine;

class NERoomDataWidget : public QDialog
{
    Q_OBJECT

public:
    explicit NERoomDataWidget(QWidget *parent = nullptr);
    ~NERoomDataWidget();

    void setRtcEngine(std::shared_ptr<NERtcEngine> engine);

private:
    Ui::NERoomDataWidget *ui;
    std::shared_ptr<NERtcEngine> m_engine;
};

#endif // NEROOMDATAWIDGET_H
