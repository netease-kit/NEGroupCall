package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.content.Context;
import android.content.Intent;
import android.hardware.Camera;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.faceunity.FURenderer;
import com.netease.biz_video_group.BuildConfig;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.NERtcStatsDelegateManager;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.AudioConstant;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.VideoConstant;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RtcSetting;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.network.GroupBizControl;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoGroupMainView;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoGroupSpeakerView;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.lava.nertc.sdk.video.NERtcVideoFrame;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;

import java.util.List;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * 说明：该页面分为两个视图，分别为主视图VideoGroupMainView和演讲者视图VideoGroupSpeakerView
 * VideoGroupMainView 主视图模式最多有4人，1-4人分别对应4种不同样式UI
 * VideoGroupSpeakerView 演讲者模式的View最多有3人
 */
public class VideoMeetingRoomActivity extends BaseActivity implements View.OnClickListener,
        FURenderer.OnFUDebugListener,
        FURenderer.OnTrackingStatusChangedListener, VideoGroupSpeakerView.OnSpeakerItemClickListener {

    private static final String LOG_TAG = VideoMeetingRoomActivity.class.getSimpleName();

    public static final String TRANS_ROOM_INFO = "room_info";

    /**
     * 本房间的本人昵称
     */
    public static final String TRANS_ROOM_NICKNAME = "room_nickname";

    /**
     * 入会时RTC相关参数
     */
    public static final String TRANS_RTC_PARAMS = "rtc_params";

    private RtcSetting rtcSetting;

    private int status;//通话状态
    private static final int STATUS_INIT = 0;//初始化
    private static final int STATUS_CALLING = 1;//通话中
    private static final int STATUS_CALL_END = 2;//通话结束
    private static final int STATUS_COMMENTING = 3;//正在评价
    private static final int STATUS_COMMENT_END = 4;//评价结束

    private VideoGroupMainView videoGroupMainView;
    public VideoGroupSpeakerView videoGroupSpeakerView;
    private ImageView ivMicphone;
    private ImageView ivCameraOpen;
    private ImageView ivCameraSwitch;
    private ImageView ivBeauty;
    private ImageView ivLeave;
    private ImageView ivRealTimeData;
    private ImageView ivSetting;
    private LinearLayout llExtraSetting;
    private LinearLayout llOperation;

    private RoomInfo roomInfo;//房间信息
    private String appKey;

    private NERtcEx neRtcEx;

    private FURenderer mFuRender;//美颜效果

    private int cameraFacing = Camera.CameraInfo.CAMERA_FACING_FRONT;//摄像头FACE_BACK = 0, FACE_FRONT = 1

    private static final int REQUEST_CODE_PERMISSION = 10000;
    private boolean isFirstInit = true;
    private Handler rtcHandler = null;
    /**
     * G2的回调
     */
    private NERtcCallback neRtcCallback = new NERtcCallback() {
        @Override
        public void onJoinChannel(int result, long channelId, long elapsed) {
            if (result!=0){
                //https://dev.yunxin.163.com/docs/interface/%E9%9F%B3%E8%A7%86%E9%A2%912.0Android%E7%AB%AF/com/netease/lava/nertc/sdk/NERtcCallback.html#onJoinChannel-int-long-long-
                // 走到这里的表现是黑屏，需要让用户退出房间重进下
                ToastUtils.showShort("加入房间发生异常，页面将关闭，请重试！");
                StringBuilder stringBuilder=new StringBuilder();
                stringBuilder.append("onJoinChannel failed,")
                        .append("result:")
                        .append(result)
                        .append(",")
                        .append("channelId:")
                        .append(channelId)
                        .append(",")
                        .append("elapsed:")
                        .append(elapsed);
                TempLogUtil.log(stringBuilder.toString());
                finish();
                return;
            }
            status = STATUS_CALLING;

        }

        @Override
        public void onLeaveChannel(int i) {

        }

        @Override
        public void onUserJoined(long l) {
            TempLogUtil.log("uid为"+l+"的用户加入房间");
            UserStatusInfo info = new UserStatusInfo("", l);
            info.joinRoomTimeStamp=System.currentTimeMillis();
            if (isSpeakerMode()) {
                videoGroupSpeakerView.addUser(info);
            } else {
                videoGroupMainView.addUser(info);
            }
            requestUserModelByUid(l);

        }

        @Override
        public void onUserLeave(long uid, int i) {
            TempLogUtil.log("uid为"+uid+"的用户离开房间");
            videoGroupSpeakerView.deleteUser(uid);
            videoGroupMainView.deleteUser(uid);
            // 如果演讲者离开了，需要特殊处理下逻辑,把演讲者的人重新添加到主视图
            if (videoGroupMainView.getVideoViewAdapter().userStatusInfoList.isEmpty() && !videoGroupSpeakerView.getSpeakerAdapter().list.isEmpty()) {
                for (UserStatusInfo info : videoGroupSpeakerView.getSpeakerAdapter().list) {
                    videoGroupMainView.addUser(info);
                }
                videoGroupSpeakerView.clear();
            }
            // 如果房间只剩一个人了,去掉全屏按钮
            if (videoGroupMainView.getVideoViewAdapter().userStatusInfoList.size() == 1) {
                videoGroupMainView.getVideoViewAdapter().notifyItemChanged(0);
            }
        }

        @Override
        public void onUserAudioStart(long userId) {
            neRtcEx.subscribeRemoteAudioStream(userId, true);
            videoGroupSpeakerView.enableMicphone(true, userId, false);
            videoGroupMainView.enableMicphone(true, userId, false);
        }

        @Override
        public void onUserAudioStop(long l) {
            videoGroupSpeakerView.enableMicphone(false, l, false);
            videoGroupMainView.enableMicphone(false, l, false);
        }

        @Override
        public void onUserVideoStart(long userId, int i) {
            neRtcEx.subscribeRemoteVideoStream(userId, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);
            videoGroupSpeakerView.enableVideo(userId, false, true);
            videoGroupMainView.enableVideo(userId, false, true);
        }

        @Override
        public void onUserVideoStop(long userId) {
            videoGroupSpeakerView.enableVideo(userId, false, false);
            videoGroupMainView.enableVideo(userId, false, false);
        }

        @Override
        public void onDisconnect(int i) {
            ToastUtils.showLong("本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人");
            showCommentDialog();
        }

        @Override
        public void onClientRoleChange(int i, int i1) {

        }
    };

    public static void startActivity(Context context, Bundle bundle) {
        Intent intent = new Intent(context, VideoMeetingRoomActivity.class);
        intent.putExtras(bundle);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.meeting_room_layout);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestPermissionsIfNeeded();
    }

    private void requestPermissionsIfNeeded() {
        final List<String> missedPermissions = NERtc.checkPermission(this);
        if (missedPermissions.size() > 0) {
            PermissionUtils.permission(missedPermissions.toArray(new String[0])).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(@NonNull List<String> granted) {
                    initView();
                }

                @Override
                public void onDenied(@NonNull List<String> deniedForever, @NonNull List<String> denied) {
                    ToastUtils.showShort("授权失败");
                    finish();
                }
            }).request();
        } else {
            initView();
        }
    }

    private void initView() {
        parseBundle();
        ivMicphone = findViewById(R.id.iv_audio_control);
        ivCameraOpen = findViewById(R.id.iv_video_control);
        ivCameraSwitch = findViewById(R.id.iv_switch_camera);
        ivBeauty = findViewById(R.id.iv_beauty_control);
        ivLeave = findViewById(R.id.iv_leave);
        ivSetting = findViewById(R.id.iv_setting);
        ivRealTimeData = findViewById(R.id.iv_real_time_data);
        llExtraSetting = findViewById(R.id.ll_extra_setting);
        llOperation = findViewById(R.id.lly_dialog_operation);
        ivMicphone.setOnClickListener(this);
        ivCameraOpen.setOnClickListener(this);
        ivCameraSwitch.setOnClickListener(this);
        ivBeauty.setOnClickListener(this);
        ivLeave.setOnClickListener(this);
        ivRealTimeData.setOnClickListener(this);
        ivSetting.setOnClickListener(this);
        videoGroupMainView = findViewById(R.id.rcv_video_view);
        videoGroupMainView.setOnTouchListener((v, event) -> {
            TempLogUtil.log("setOnTouchListener->event.getAction()："+event.getAction());
            if (event.getAction()==MotionEvent.ACTION_UP){
                if (llOperation.getVisibility() == View.VISIBLE) {
                    llOperation.setVisibility(View.GONE);
                    llExtraSetting.setVisibility(View.GONE);
                } else {
                    llOperation.setVisibility(View.VISIBLE);
                }
            }
            return true;
        });
        videoGroupSpeakerView = findViewById(R.id.speaker_view);
        videoGroupSpeakerView.setOnSpeakerItemClickListener(this);
        addSelf();
        initData();
    }

    private void addSelf() {
        String nickname = getIntent().getStringExtra(TRANS_ROOM_NICKNAME);
        UserStatusInfo info = new UserStatusInfo(true, nickname);
        info.joinRoomTimeStamp=System.currentTimeMillis();
        if (roomInfo!=null){
            info.userId=roomInfo.avRoomUid;
        }
        if (rtcSetting != null) {
            info.enableVideo = rtcSetting.enableCamera;
            info.enableMicphone = rtcSetting.enableMicphone;
        }
        videoGroupMainView.addUser(info);
    }

    private void parseBundle() {
        roomInfo = (RoomInfo) getIntent().getSerializableExtra(TRANS_ROOM_INFO);
        rtcSetting = (RtcSetting) getIntent().getSerializableExtra(TRANS_RTC_PARAMS);
        TempLogUtil.log(roomInfo.toString());
        TempLogUtil.log(rtcSetting.toString());
    }

    private void initData() {

        if (roomInfo != null) {
            appKey = roomInfo.nrtcAppKey;
            long begin = System.currentTimeMillis();
            setupNERtc(roomInfo.nrtcAppKey);
            long end = System.currentTimeMillis();
            long setupNeRtccost = end - begin;
            TempLogUtil.log("setupNeRtc Cost:"+setupNeRtccost);
            joinChannel(roomInfo.avRoomCheckSum, roomInfo.avRoomCName, roomInfo.avRoomUid);
            long joinChannelCost = System.currentTimeMillis() - end;
            TempLogUtil.log("joinChannel Cost:"+joinChannelCost);
            neRtcEx.setStatsObserver(NERtcStatsDelegateManager.getInstance());
        }
        long beautyBegin = System.currentTimeMillis();
        mFuRender = new FURenderer
                .Builder(this)
                .maxFaces(1)
                .inputImageOrientation(getCameraOrientation(Camera.CameraInfo.CAMERA_FACING_FRONT))
                .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
                .setOnFUDebugListener(this)
                .setOnTrackingStatusChangedListener(this)
                .build();

        mFuRender.setBeautificationOn(true);
        long beautyInitCost = System.currentTimeMillis() - beautyBegin;
        TempLogUtil.log("mFuRender Init Cost:"+beautyInitCost);

        neRtcEx.setVideoCallback(neRtcVideoFrame -> {
            if (ivBeauty.isSelected()) {
                if (isFirstInit){
                    if (rtcHandler==null){
                        rtcHandler=new Handler(Looper.myLooper());
                    }
                    mFuRender.onSurfaceCreated();
                    isFirstInit=false;
                    return false;
                }
                //此处可自定义第三方的美颜实现
                neRtcVideoFrame.textureId = mFuRender.onDrawFrame(neRtcVideoFrame.data, neRtcVideoFrame.textureId,
                        neRtcVideoFrame.width, neRtcVideoFrame.height);

                neRtcVideoFrame.format = NERtcVideoFrame.Format.TEXTURE_RGB;
            }
            return ivBeauty.isSelected();
        }, true);
    }

    /**
     * 初始化rtc
     *
     * @param appKey
     */
    private void setupNERtc(String appKey) {
        if (neRtcEx != null) {
            neRtcEx.release();
        } else {
            neRtcEx = NERtcEx.getInstance();
        }
        NERtcParameters parameters = new NERtcParameters();
        neRtcEx.setParameters(parameters); //先设置参数，后初始化
        NERtcOption option = new NERtcOption();
        if(BuildConfig.DEBUG){
            option.logLevel = NERtcConstants.LogLevel.INFO;
        }else {
            option.logLevel = NERtcConstants.LogLevel.WARNING;
        }
        try {
            long begin = System.currentTimeMillis();
            neRtcEx.init(getApplicationContext(), appKey, neRtcCallback, option);
            long cost = System.currentTimeMillis() - begin;
            TempLogUtil.log("neRtcEx init method first Cost:"+cost);
            initRtcParams();
        } catch (Exception e) {
            // 可能由于没有release导致初始化失败，release后再试一次
            TempLogUtil.log("SDK初始化失败第一次："+e.toString());
            long begin = System.currentTimeMillis();
            NERtcEx.getInstance().release();
            long end=System.currentTimeMillis();
            long cost = end - begin;
            TempLogUtil.log("release Cost:"+cost);
            try {
                neRtcEx.init(getApplicationContext(), appKey, neRtcCallback, option);
                long cost2 = System.currentTimeMillis() - end;
                TempLogUtil.log("neRtcEx init method second Cost:"+cost2);
                initRtcParams();
            } catch (Exception exception) {
                ALog.e(LOG_TAG, "rtc init failed", e);
                exception.printStackTrace();
                Toast.makeText(this, R.string.sdk_init_failed, Toast.LENGTH_LONG).show();
                TempLogUtil.log("SDK初始化失败第二次："+e.toString());
                finish();
            }


        }
    }

    private void initRtcParams() {
        if (rtcSetting != null) {
            long begin = System.currentTimeMillis();
            //摄像头和麦克风
            neRtcEx.enableLocalAudio(rtcSetting.enableMicphone);
            neRtcEx.enableLocalVideo(rtcSetting.enableCamera);
            ivMicphone.setSelected(rtcSetting.enableMicphone);
            ivCameraOpen.setSelected(rtcSetting.enableCamera);
            //视频参数
            NERtcVideoConfig neRtcVideoConfig = new NERtcVideoConfig();
            // 分辨率,字符串格式为：160*90、320*180
            if (!TextUtils.isEmpty(rtcSetting.resolution)) {
                String[] split = rtcSetting.resolution.split("\\*");
                if (split.length == 2) {
                    try {
                        neRtcVideoConfig.width = Integer.parseInt(split[0]);
                        neRtcVideoConfig.height = Integer.parseInt(split[1]);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
            //帧率
            if (VideoConstant.FPS.FPS_7.equals(rtcSetting.fps)) {
                neRtcVideoConfig.frameRate = NERtcEncodeConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_7;
            } else if (VideoConstant.FPS.FPS_10.equals(rtcSetting.fps)){
                neRtcVideoConfig.frameRate = NERtcEncodeConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_10;
            } else if (VideoConstant.FPS.FPS_15.equals(rtcSetting.fps)){
                neRtcVideoConfig.frameRate = NERtcEncodeConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_15;
            } else if (VideoConstant.FPS.FPS_24.equals(rtcSetting.fps)){
                neRtcVideoConfig.frameRate = NERtcEncodeConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_24;
            } else if (VideoConstant.FPS.FPS_30.equals(rtcSetting.fps)){
                neRtcVideoConfig.frameRate = NERtcEncodeConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_30;
            }
            neRtcEx.setLocalVideoConfig(neRtcVideoConfig);
            int profile = NERtcConstants.AudioProfile.DEFAULT;
            int scenario = NERtcConstants.AudioScenario.MUSIC;
            //音频场景，语音场景. AudioProfile 推荐使用 MIDDLE_QUALITY 及以下，音乐场景。AudioProfile 推荐使用 MIDDLE_QUALITY_STEREO 及以上
            //语音场景
//            int DEFAULT = 0;
//            int STANDARD = 1;  // 一般
//            int STANDARD_EXTEND = 2;// 清晰（默认）
//            int MIDDLE_QUALITY = 3;// 高清
            //音乐场景
//            int MIDDLE_QUALITY_STEREO = 4;// 清晰
//            int HIGH_QUALITY = 5;// 高清（默认）
//            int HIGH_QUALITY_STEREO = 6;// 极致
            if (AudioConstant.AudioScene.MUSIC.equals(rtcSetting.audioScene)) {
                scenario = NERtcConstants.AudioScenario.MUSIC;
            } else if (AudioConstant.AudioScene.SPEECH.equals(rtcSetting.audioScene)) {
                scenario = NERtcConstants.AudioScenario.SPEECH;
            }
            //音频质量
            switch (rtcSetting.audioQuality) {
                case AudioConstant.AudioQuality.ACME:
                    profile = NERtcConstants.AudioProfile.HIGH_QUALITY_STEREO;
                    break;
                case AudioConstant.AudioQuality.HD:
                    if (scenario == NERtcConstants.AudioScenario.MUSIC){
                        profile = NERtcConstants.AudioProfile.HIGH_QUALITY;
                    }else {
                        profile = NERtcConstants.AudioProfile.MIDDLE_QUALITY;
                    }
                    break;
                case AudioConstant.AudioQuality.SD:
                    if (scenario == NERtcConstants.AudioScenario.MUSIC) {
                        profile = NERtcConstants.AudioProfile.MIDDLE_QUALITY_STEREO;
                    } else {
                        profile = NERtcConstants.AudioProfile.STANDARD_EXTEND;
                    }
                    break;
                case AudioConstant.AudioQuality.GENERAL:
                    profile = NERtcConstants.AudioProfile.STANDARD;
                    break;
                default:
                    break;
            }
            //设置音频参数
            neRtcEx.setAudioProfile(profile, scenario);
            long cost = System.currentTimeMillis() - begin;
            TempLogUtil.log("initRtcParams Cost:"+cost);
        }
    }


    /**
     * 获取相机方向
     *
     * @param cameraFacing
     * @return
     */
    private int getCameraOrientation(int cameraFacing) {
        Camera.CameraInfo info = new Camera.CameraInfo();
        int cameraId = -1;
        int numCameras = Camera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
            Camera.getCameraInfo(i, info);
            if (info.facing == cameraFacing) {
                cameraId = i;
                break;
            }
        }
        if (cameraId < 0) {
            // no front camera, regard it as back camera
            return 90;
        } else {
            return info.orientation;
        }
    }

    /**
     * 加入rtc 房间
     *
     * @param token
     * @param channelName
     * @param uid
     */
    private void joinChannel(String token, String channelName, long uid) {
        NERtcEx.getInstance().joinChannel(token, channelName, uid);
    }


    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_setting) {
            if (llExtraSetting.getVisibility() == View.VISIBLE) {
                llExtraSetting.setVisibility(View.GONE);
            } else {
                llExtraSetting.setVisibility(View.VISIBLE);
            }
        } else if (v.getId() == R.id.iv_real_time_data) {
            showStateDialog();
        } else if (v.getId() == R.id.iv_audio_control) {
            ivMicphone.setSelected(!ivMicphone.isSelected());
            if (neRtcEx.enableLocalAudio(ivMicphone.isSelected()) == 0) {
                videoGroupSpeakerView.enableMicphone(ivMicphone.isSelected(), 0, true);
                videoGroupMainView.enableMicphone(ivMicphone.isSelected(), 0, true);
            }

        } else if (v.getId() == R.id.iv_video_control) {
            ivCameraOpen.setSelected(!ivCameraOpen.isSelected());
            if (neRtcEx.enableLocalVideo(ivCameraOpen.isSelected()) == 0) {
                videoGroupSpeakerView.enableVideo(0, true, ivCameraOpen.isSelected());
                videoGroupMainView.enableVideo(0, true, ivCameraOpen.isSelected());
            }

        } else if (v.getId() == R.id.iv_switch_camera) {
            neRtcEx.switchCamera();
            if (cameraFacing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                cameraFacing = Camera.CameraInfo.CAMERA_FACING_BACK;
            } else {
                cameraFacing = Camera.CameraInfo.CAMERA_FACING_FRONT;
            }
            mFuRender.onCameraChange(cameraFacing, getCameraOrientation(cameraFacing));
        } else if (v.getId() == R.id.iv_beauty_control) {
            ivBeauty.setSelected(!ivBeauty.isSelected());
        } else if (v.getId() == R.id.iv_leave) {
            leave();
            showCommentDialog();
        }
    }

    /**
     * 离开房间
     */
    private void leave() {
        neRtcEx.leaveChannel();
        status = STATUS_CALL_END;
    }

    @Override
    public void onBackPressed() {
        if (status == STATUS_CALLING) {
            leave();
            showCommentDialog();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public void onTrackStatusChanged(int type, int status) {
    }

    @Override
    public void onFpsChange(double fps, double renderTime) {
    }

    @Override
    public void onSpeakerItemClick(UserStatusInfo userStatusInfo) {
        if (videoGroupMainView.getVideoViewAdapter().userStatusInfoList == null) {
            return;
        }
        videoGroupSpeakerView.deleteUser(userStatusInfo.userId);
        for (UserStatusInfo info : videoGroupMainView.getVideoViewAdapter().userStatusInfoList) {
            if (info!=null&&userStatusInfo.userId != info.userId) {
                videoGroupSpeakerView.addUser(info);
            }
        }
        videoGroupMainView.getVideoViewAdapter().userStatusInfoList.clear();
        videoGroupMainView.getVideoViewAdapter().addUser(userStatusInfo);
        videoGroupMainView.getVideoViewAdapter().resetUserOrderAndUIPropertyByUserCount(videoGroupMainView.getVideoViewAdapter().userStatusInfoList);
        videoGroupMainView.getVideoViewAdapter().notifyItemChanged(0);
    }

    /**
     * videoView adapter
     */


    @Override
    protected void onDestroy() {
        if (neRtcEx != null) {
            //关掉美颜
            neRtcEx.setVideoCallback(null, false);
            neRtcEx.release();
        }
        if (rtcHandler!=null&&mFuRender!=null){
            rtcHandler.post(() -> mFuRender.onSurfaceDestroyed());
        }

        NERtcStatsDelegateManager.getInstance().clearAll();
        super.onDestroy();
    }

    /**
     * 获取用户信息
     *
     * @param uid
     */
    private void requestUserModelByUid(long uid) {
        GroupBizControl.getUserInfoByUid(String.valueOf(uid), roomInfo.mpRoomId).subscribe(new ResourceSingleObserver<UserModel>() {
            @Override
            public void onSuccess(UserModel user) {
                if (isSpeakerMode()){
                    videoGroupSpeakerView.updateNickName(uid, user.nickname);
                }else {
                    videoGroupMainView.updateNickName(uid, user.nickname);
                }
            }

            @Override
            public void onError(Throwable e) {

            }
        });
    }

    /**
     * 显示评价弹框
     */
    private void showCommentDialog() {
        CommentDialog commentDialog = new CommentDialog();
        commentDialog.setInfo(appKey);
        commentDialog.setOnDismissListener(dialog -> {
            status = STATUS_COMMENT_END;
            finish();
        });
        commentDialog.show(getSupportFragmentManager(), "commentDialog");
        status = STATUS_COMMENTING;
    }

    /**
     * 显示实时数据
     */
    private void showStateDialog() {
        StateDialog stateDialog = new StateDialog();
        stateDialog.show(getSupportFragmentManager(), "StateDialog");
    }

    public boolean isSpeakerMode() {
        return videoGroupMainView.getVideoViewAdapter().userStatusInfoList != null
                && !videoGroupMainView.getVideoViewAdapter().userStatusInfoList.isEmpty()
                && !videoGroupSpeakerView.getSpeakerAdapter().list.isEmpty();
    }

}

