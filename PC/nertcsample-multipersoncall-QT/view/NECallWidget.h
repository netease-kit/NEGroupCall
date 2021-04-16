#ifndef NECALLWIDGET_H
#define NECALLWIDGET_H

#include <QOpenGLWidget>
#include <QWidget>
#include <QMap>

#include "rtc/NERtcEngine.h"
#include "include/base_type_defines.h"
#include "NEVideoWidget.h"

namespace Ui {
class NECallWidget;
}

class QSpacerItem;
class NEChatRoomBottomTool;
class NERoomDataWidget;

class NECallWidget : public QOpenGLWidget {
    Q_OBJECT

public:
    explicit NECallWidget(QWidget* parent = nullptr);
    ~NECallWidget();

    enum NEViewMode {
        ONE_PERSON_MODE,
        MUL_SPEAKER_MODE,
        MUL_GALLERY_MODE
    };

Q_SIGNALS:
    void sigCloseWindow();
    void sigNetWorkQualityChanged(quint64 uid, NetWorkQualityType type);

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
    void onNetworkQuality(quint64 uid, nertc::NERtcNetworkQualityType up, nertc::NERtcNetworkQualityType down);
    void onZoomIn(QString uid);
    void onZoomOut();

protected:
    virtual void closeEvent(QCloseEvent* event) override;
    virtual void resizeEvent(QResizeEvent* event) override;
    virtual void moveEvent(QMoveEvent* event) override;
    virtual void changeEvent(QEvent* event) override;

private:
    NetWorkQualityType netWorkQualityType(nertc::NERtcNetworkQualityType upNetWorkQuality, nertc::NERtcNetworkQualityType downNetWorkQuality, bool bSelf = false);
    void initVideoLayout();
    void clearLayout();
    void adjustVideoLayout(NEViewMode viewMode, QString speakerUid = "");

private:
    Ui::NECallWidget* ui;
    std::shared_ptr<NERtcEngine> m_engine;
    NEChatRoomBottomTool* bottomTool;
    int m_userCount = 1;
    QString zoomInUserId;
    QList<NEVideoWidget*> m_videoWidgetList;
    NERoomDataWidget *wdt = Q_NULLPTR;
    NEViewMode m_viewMode = ONE_PERSON_MODE;
    QSpacerItem *spacerItem;
    QSpacerItem *spacerItem2;
};

#endif  // NECALLWIDGET_H
