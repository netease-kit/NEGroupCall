#ifndef NECALLWIDGET_H
#define NECALLWIDGET_H

#include <QOpenGLWidget>
#include <QWidget>

namespace Ui {
class NECallWidget;
}

class NERtcEngine;
class NEChatRoomBottomTool;

class NECallWidget : public QOpenGLWidget {
    Q_OBJECT

public:
    explicit NECallWidget(QWidget* parent = nullptr);
    ~NECallWidget();

Q_SIGNALS:
    void sigCloseWindow();

public Q_SLOTS:
    void onJoinChannel();
    void onVoiceEnable(bool bEnable);
    void onVideoEnable(bool bEnable);
    void onBeautyEnable(bool bEnable);
    void onExitCall();
    void onUserJoin(quint64 uid, const QString& name);
    void onUserLeft(quint64 uid);
    void onJoinChannelSuccess();
    void onJoinChannelFail(const QString& reson);
    void onDisconnected(int code);
    void onGetUserInfoSuccess(const QString& response);
    void onUserVideoMute(quint64 uid, bool mute);
    void onUserAudioMute(quint64 uid, bool mute);
    void onLeavingChannel();

protected:
    virtual void closeEvent(QCloseEvent* event) override;
    void resizeEvent(QResizeEvent* event) override;
    virtual void moveEvent(QMoveEvent* event) override;

private:
    Ui::NECallWidget* ui;

    std::shared_ptr<NERtcEngine> m_engine;

    NEChatRoomBottomTool* bottomTool;
};

#endif  // NECALLWIDGET_H
