#ifndef NEJOINWIDGET_H
#define NEJOINWIDGET_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class NEJoinWidget; }
QT_END_NAMESPACE

class NECallWidget;

class NEJoinWidget : public QMainWindow
{
    Q_OBJECT

public:
    NEJoinWidget(QWidget *parent = nullptr);
    ~NEJoinWidget();

Q_SIGNALS:
    void sigJoinChannel();

private Q_SLOTS:
    void onBtnJoinChannelClicked();
    void onCloseWindow();
    void onJoinHttpRequestSuccess(const QString &response);
    void onJoinHttpRequestFailed(int errType,int errCode,const QString &err);

private:
    Ui::NEJoinWidget *ui;

    std::shared_ptr<NECallWidget> videowindowPtr;
};
#endif // NEJOINWIDGET_H
