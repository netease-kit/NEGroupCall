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

protected:
    virtual void closeEvent(QCloseEvent *event) override;

private:
    void onBtnGoodClicked();
    void onBtnPoorClicked();
    void onBtnSaveClicked();

private:
    QString getCaseTypeJsonString();

private:
    Ui::NESuggestTipWidget *ui;
    bool m_bClose = false;;
};

#endif // NESUGGESTTIPWIDGET_H
