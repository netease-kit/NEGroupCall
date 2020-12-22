#ifndef NENAMEWIDGET_H
#define NENAMEWIDGET_H

#include <QWidget>

namespace Ui {
class NENameWidget;
}

class NENameWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NENameWidget(QWidget *parent = nullptr);
    ~NENameWidget();

    void setName(const QString& name);

private:
    Ui::NENameWidget *ui;
};

#endif // NENAMEWIDGET_H
