#ifndef NESUGGESTTIPWIDGET_H
#define NESUGGESTTIPWIDGET_H

#include <QDialog>

namespace Ui {
class NESuggestTipWidget;
}

class NESuggestTipWidget : public QDialog
{
    Q_OBJECT

public:
    explicit NESuggestTipWidget(QWidget *parent = nullptr);
    ~NESuggestTipWidget();


Q_SIGNALS:
    void sigCallQuality(bool good);

private:
    void onBtnGoodClicked();
    void onBtnPoorClicked();
    void onBtnSaveClicked();

private:
    QString getCaseTypeJsonString();

private:
    Ui::NESuggestTipWidget *ui;
};

#endif // NESUGGESTTIPWIDGET_H
