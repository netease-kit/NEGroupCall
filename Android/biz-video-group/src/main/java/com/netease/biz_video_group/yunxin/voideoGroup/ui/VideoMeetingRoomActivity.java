package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.content.Context;
import android.content.Intent;
import android.hardware.Camera;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.faceunity.FURenderer;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.network.GroupBizControl;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.user.UserModel;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.observers.ResourceSingleObserver;

public class VideoMeetingRoomActivity extends BaseActivity implements View.OnClickListener,
        FURenderer.OnFUDebugListener,
        FURenderer.OnTrackingStatusChangedListener {

    private static final String LOG_TAG = VideoMeetingRoomActivity.class.getSimpleName();

    public static final String TRANS_ROOM_INFO = "room_info";

    /**
     * 本房间的本人昵称
     */
    public static final String TRANS_ROOM_NICKNAME = "room_nickname";

    private int status;//通话状态
    private static final int STATUS_INIT = 0;//初始化
    private static final int STATUS_CALLING = 1;//通话中
    private static final int STATUS_CALL_END = 2;//通话结束
    private static final int STATUS_COMMENTING = 3;//正在评价
    private static final int STATUS_COMMENT_END = 4;//评价结束

    private RecyclerView mRcvVideoView;
    private ImageView ivMute;
    private ImageView ivCameraOpen;
    private ImageView ivCameraSwitch;
    private ImageView ivBeauty;
    private ImageView ivLeave;

    private VideoViewAdapter videoViewAdapter;
    private RoomInfo roomInfo;//房间信息
    private String appKey;

    private NERtcEx neRtcEx;

    private FURenderer mFuRender;//美颜效果

    private int cameraFacing = Camera.CameraInfo.CAMERA_FACING_FRONT;//摄像头FACE_BACK = 0, FACE_FRONT = 1

    private static final int REQUEST_CODE_PERMISSION = 10000;

    /**
     * G2的回调
     */
    private NERtcCallback neRtcCallback = new NERtcCallback() {
        @Override
        public void onJoinChannel(int i, long l, long l1) {
            status = STATUS_CALLING;

        }

        @Override
        public void onLeaveChannel(int i) {

        }

        @Override
        public void onUserJoined(long l) {
            if (videoViewAdapter != null) {
                videoViewAdapter.addUser(new UserStatusInfo("", l));
            }
            requestUserModelByUid(l);

        }

        @Override
        public void onUserLeave(long uid, int i) {
            if (videoViewAdapter != null) {
                videoViewAdapter.deleteUser(uid);
            }
        }

        @Override
        public void onUserAudioStart(long userId) {
            neRtcEx.subscribeRemoteAudioStream(userId, true);
            if (videoViewAdapter != null) {
                videoViewAdapter.enableMute(false, userId, false);
            }
        }

        @Override
        public void onUserAudioStop(long l) {
            if (videoViewAdapter != null) {
                videoViewAdapter.enableMute(true, l, false);
            }
        }

        @Override
        public void onUserVideoStart(long userId, int i) {
            neRtcEx.subscribeRemoteVideoStream(userId, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);
            if (videoViewAdapter != null) {
                videoViewAdapter.enableVideo(userId, false, true);
            }
        }

        @Override
        public void onUserVideoStop(long userId) {
            if (videoViewAdapter != null) {
                videoViewAdapter.enableVideo(userId, false, false);
            }
        }

        @Override
        public void onDisconnect(int i) {
            ToastUtils.showLong("本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人");
            showCommentDialog();
        }
    };

    public static void startActivity(Context context, RoomInfo roomInfo, String nickname) {
        Intent intent = new Intent(context, VideoMeetingRoomActivity.class);
        intent.putExtra(TRANS_ROOM_INFO, roomInfo);
        intent.putExtra(TRANS_ROOM_NICKNAME, nickname);
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
        ivMute = findViewById(R.id.iv_audio_control);
        ivCameraOpen = findViewById(R.id.iv_video_control);
        ivCameraSwitch = findViewById(R.id.iv_switch_camera);
        ivBeauty = findViewById(R.id.iv_beauty_control);
        ivLeave = findViewById(R.id.iv_leave);
        ivMute.setOnClickListener(this);
        ivCameraOpen.setOnClickListener(this);
        ivCameraSwitch.setOnClickListener(this);
        ivBeauty.setOnClickListener(this);
        ivLeave.setOnClickListener(this);
        mRcvVideoView = findViewById(R.id.rcv_video_view);

        String nickname = getIntent().getStringExtra(TRANS_ROOM_NICKNAME);
        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 2);
        mRcvVideoView.setLayoutManager(gridLayoutManager);
        videoViewAdapter = new VideoViewAdapter(4);
        mRcvVideoView.setAdapter(videoViewAdapter);
        videoViewAdapter.addUser(new UserStatusInfo(true, nickname));
        initData();
    }

    private void initData() {
        roomInfo = (RoomInfo) getIntent().getSerializableExtra(TRANS_ROOM_INFO);
        if (roomInfo != null) {
            appKey = roomInfo.nrtcAppKey;
            setupNERtc(roomInfo.nrtcAppKey);
            joinChannel(roomInfo.avRoomCheckSum, roomInfo.avRoomCName, roomInfo.avRoomUid);
        }
        mFuRender = new FURenderer
                .Builder(this)
                .maxFaces(1)
                .inputImageOrientation(getCameraOrientation(Camera.CameraInfo.CAMERA_FACING_FRONT))
                .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
                .setOnFUDebugListener(this)
                .setOnTrackingStatusChangedListener(this)
                .build();
        mFuRender.onSurfaceCreated();
        mFuRender.setBeautificationOn(true);

        neRtcEx.setVideoCallback(neRtcVideoFrame -> {
            if (ivBeauty.isSelected()) {
                //此处可自定义第三方的美颜实现
                neRtcVideoFrame.textureId = mFuRender.onDrawFrame(neRtcVideoFrame.data, neRtcVideoFrame.textureId,
                        neRtcVideoFrame.width, neRtcVideoFrame.height);
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
        try {
            neRtcEx.init(getApplicationContext(), appKey, neRtcCallback, null);
            neRtcEx.enableLocalAudio(true);
            neRtcEx.enableLocalVideo(true);
        } catch (Exception e) {
            Log.e(LOG_TAG, "rtc init failed", e);
            Toast.makeText(this, R.string.sdk_init_failed, Toast.LENGTH_LONG).show();
            finish();
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

    /**
     * 打开（关闭）摄像头
     *
     * @param enable
     * @return 返回0 代表成功
     */
    private int enableVideo(boolean enable) {
        int ret = neRtcEx.enableLocalVideo(enable);
        if (ret == 0 && videoViewAdapter != null) {
            videoViewAdapter.enableVideo(0, true, enable);
        }
        return ret;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_audio_control) {
            if (neRtcEx.enableLocalAudio(ivMute.isSelected()) == 0) {
                ivMute.setSelected(!ivMute.isSelected());
                if (videoViewAdapter != null) {
                    videoViewAdapter.enableMute(ivMute.isSelected(), 0, true);
                }
            }
        } else if (v.getId() == R.id.iv_video_control) {
            if (enableVideo(ivCameraOpen.isSelected()) == 0) {
                ivCameraOpen.setSelected(!ivCameraOpen.isSelected());
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

    /**
     * videoView adapter
     */
    static class VideoViewAdapter extends RecyclerView.Adapter<VideoViewAdapter.VH> {

        private int capacity;

        private List<UserStatusInfo> userStatusInfoList;

        public VideoViewAdapter(int capacity) {
            this.capacity = capacity;
        }

        //创建ViewHolder
        public class VH extends RecyclerView.ViewHolder {

            public NERtcVideoView videoView;

            public TextView tvNicknameCenter;

            public TextView tvNicknameBottom;

            public ImageView ivMute;

            public VH(View v) {
                super(v);
                videoView = v.findViewById(R.id.video_view);
                tvNicknameBottom = v.findViewById(R.id.nickname_bottom);
                tvNicknameCenter = v.findViewById(R.id.nickname_center);
                ivMute = v.findViewById(R.id.iv_mute);
            }
        }

        /**
         * 删除用户
         *
         * @param userId
         */
        public void deleteUser(long userId) {
            if (userStatusInfoList != null && userId != 0) {
                int total = userStatusInfoList.size();
                for (int i = 0; i < total; i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if (userId == userInfo.userId) {
                        userStatusInfoList.remove(userInfo);
                        for (int j = i; j < total; j++) {
                            notifyItemChanged(j);
                        }
                        return;
                    }
                }
            }
        }

        /**
         * 打开(关闭)摄像头
         *
         * @param uid
         * @param self
         * @param enable
         */
        public void enableVideo(long uid, boolean self, boolean enable) {
            if (userStatusInfoList != null && (self || uid != 0)) {
                for (int i = 0; i < userStatusInfoList.size(); i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                        userInfo.enableVideo = enable;
                        notifyItemChanged(i);
                        return;
                    }
                }
            }
        }

        public void enableMute(boolean mute, long uid, boolean self) {
            if (userStatusInfoList != null && (self || uid != 0)) {
                for (int i = 0; i < userStatusInfoList.size(); i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                        userStatusInfoList.get(i).isMute = mute;
                        notifyItemChanged(i, userInfo);
                        return;
                    }
                }
            }
        }

        /**
         * 添加用户
         *
         * @param userStatusInfo
         */
        public void addUser(UserStatusInfo userStatusInfo) {
            if (userStatusInfoList == null) {
                userStatusInfoList = new ArrayList<>();
            }
            userStatusInfoList.add(userStatusInfo);

            int position = userStatusInfoList.indexOf(userStatusInfo);

            notifyItemChanged(position);
        }

        public void updateNickName(long uid, String nickName) {
            if (userStatusInfoList != null && uid != 0) {
                for (int i = 0; i < userStatusInfoList.size(); i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if (uid == userInfo.userId) {
                        userStatusInfoList.get(i).nickname = nickName;
                        notifyItemChanged(i, userInfo);
                        return;
                    }
                }
            }
        }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.video_view_layout, parent, false);
            return new VH(v);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            if (userStatusInfoList != null && userStatusInfoList.size() > position) {
                holder.itemView.setVisibility(View.VISIBLE);
                UserStatusInfo userStatusInfo = userStatusInfoList.get(position);
                if (userStatusInfo.isSelf) {
                    setupLocalVideo(holder.videoView);
                } else {
                    setupRemoteVideo(holder.videoView, userStatusInfo.userId);
                }
                if (!userStatusInfo.enableVideo) {
                    holder.videoView.setVisibility(View.INVISIBLE);
                    holder.tvNicknameCenter.setVisibility(View.VISIBLE);
                    holder.tvNicknameBottom.setVisibility(View.GONE);
                } else {
                    holder.videoView.setVisibility(View.VISIBLE);
                    holder.tvNicknameCenter.setVisibility(View.GONE);
                    holder.tvNicknameBottom.setVisibility(View.VISIBLE);
                }

                if (userStatusInfo.isMute) {
                    holder.ivMute.setVisibility(View.VISIBLE);
                } else {
                    holder.ivMute.setVisibility(View.GONE);
                }
                holder.tvNicknameCenter.setText(userStatusInfo.nickname);
                holder.tvNicknameBottom.setText(userStatusInfo.nickname);

            } else {
                holder.itemView.setVisibility(View.GONE);
            }
        }


        @Override
        public int getItemCount() {
            return capacity;
        }

        /**
         * 设置本地视图
         *
         * @param videoView
         */
        protected void setupLocalVideo(NERtcVideoView videoView) {
            if (videoView == null) {
                return;
            }
            videoView.setZOrderMediaOverlay(true);
            videoView.setMirror(true);
            videoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
            NERtcEx.getInstance().setupLocalVideoCanvas(videoView);
            videoView.setVisibility(View.VISIBLE);
        }

        /**
         * 设置远端视图
         *
         * @param videoView
         * @param userId
         */
        protected void setupRemoteVideo(NERtcVideoView videoView, long userId) {
            videoView.setZOrderMediaOverlay(true);
            videoView.setMirror(true);
            videoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_FIT);
            NERtcEx.getInstance().setupRemoteVideoCanvas(videoView, userId);
            videoView.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void onDestroy() {
        if (neRtcEx != null) {
            //关掉美颜
            neRtcEx.setVideoCallback(null, false);
            neRtcEx.release();
        }
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
                if (videoViewAdapter != null) {
                    videoViewAdapter.updateNickName(uid, user.nickname);
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

}

