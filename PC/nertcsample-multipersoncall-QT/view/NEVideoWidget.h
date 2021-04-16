#ifndef NEVIDEOWIDGET_H
#define NEVIDEOWIDGET_H

#include <QWidget>
#include "include/base_type_defines.h"

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

    //设置视频窗口缩放按钮
    void showZoomButton(bool visible);

    //设置用户名
    void setNickname(const QString& strNickname);

    //设置uid
    void setUserId(const QString& uid);
    QString getUid() const;

    //窗口是否已有用户加入
    bool isJoin();
    //设置UI状态
    void setJoinStatus(bool join);

    //设置网络状态
    void setNetworkQuality(NetWorkQualityType type);
    //设置中心文本大小
    void setCenterNameSize(bool max);

    //重置
    void resetStatus();

Q_SIGNALS:
    void sigZoomIn(QString uid);
    void sigZoomOut();

protected:
    virtual void resizeEvent(QResizeEvent* event) override;

private:
    Ui::NEVideoWidget* ui;

    QWidget* videoRender;
    QLabel* label;
    QString m_uid;
    QString nickName;
    bool m_bJoin = false;
    bool m_bZoomIn = false;
};

#endif  // NEVIDEOWIDGET_H
