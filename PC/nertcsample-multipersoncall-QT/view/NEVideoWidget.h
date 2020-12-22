#ifndef NEVIDEOWIDGET_H
#define NEVIDEOWIDGET_H

#include <QWidget>

namespace Ui {
class NEVideoWidget;
}

class VideoWidget;
class QLabel;

class NEVideoWidget : public QWidget {
    Q_OBJECT

public:
    explicit NEVideoWidget(QWidget* parent = nullptr);
    ~NEVideoWidget();

    //获取窗口句柄
    void* getVideoHwnd();

    //设置禁用摄像头时的显示
    void showMuteCamera(bool mute);

    //设置禁用麦克风时的显示
    void showMuteMic(bool mute);

    //设置用户名
    void setNickname(const QString& strNickname);

    //设置uid
    void setUserId(const QString& uid);

    QString getUid() const;

    //窗口是否已有用户加入
    bool isJoin();

    void setJoinStatus(bool join);

protected:
    virtual void resizeEvent(QResizeEvent* event) override;

private:
    Ui::NEVideoWidget* ui;

    QWidget* videoRender;
    QLabel* label;
    bool m_bJoin;
    QString m_uid;
    QString nickName;
};

#endif  // NEVIDEOWIDGET_H
