package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.NERtcStatsDelegateManager;
import com.netease.biz_video_group.yunxin.voideoGroup.model.NERtcStatsObserverTemp;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.util.VideoViewUtil;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.stats.NERtcAudioRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcAudioSendStats;
import com.netease.lava.nertc.sdk.stats.NERtcNetworkQualityInfo;
import com.netease.lava.nertc.sdk.stats.NERtcStats;
import com.netease.lava.nertc.sdk.stats.NERtcStatsObserver;
import com.netease.lava.nertc.sdk.stats.NERtcVideoRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcVideoSendStats;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;

/**
 * @author sunkeding
 * 视频通话控件样式封装,就是一张卡片样式，方便外部控制大小，默认宽高满屏
 */
public class VideoCallBaseItemView extends ConstraintLayout{
    private NERtcVideoView videoView;
    private TextView tvNicknameCenter;

    private TextView tvNicknameBottom;

    private ImageView ivMute;
    private ImageView ivToFullScreen;
    private ImageView ivSignal;
    private View llNicknameBottom;
    private UserStatusInfo userStatusInfo;

    public VideoCallBaseItemView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public VideoCallBaseItemView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public VideoCallBaseItemView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        inflate(context, R.layout.video_group_video_call_view_base_layout, this);
        videoView = findViewById(R.id.video_view);
        llNicknameBottom = findViewById(R.id.ll_nickname_bottom);
        tvNicknameBottom = findViewById(R.id.nickname_bottom);
        tvNicknameCenter = findViewById(R.id.nickname_center);
        ivMute = findViewById(R.id.iv_mute);
        ivToFullScreen = findViewById(R.id.iv_to_full_screen);
        ivToFullScreen.setVisibility(VISIBLE);
        ivToFullScreen.setImageResource(R.drawable.video_group_icon_full_screen);
        ivSignal = findViewById(R.id.iv_signal);
        ivSignal.setImageResource(R.drawable.video_group_signal_green);
        ivToFullScreen.setOnClickListener(v -> {
            if (fullScreenButtonClickListener != null) {
                fullScreenButtonClickListener.fullScreenButtonClick(userStatusInfo);
            }
        });
        NERtcStatsDelegateManager.getInstance().addObserver(new NERtcStatsObserverTemp(){
            @Override
            public void onNetworkQuality(NERtcNetworkQualityInfo[] neRtcNetworkQualityInfos) {
                if (userStatusInfo==null){
                    return;
                }
                if (neRtcNetworkQualityInfos != null && neRtcNetworkQualityInfos.length > 0) {
                    for (NERtcNetworkQualityInfo info : neRtcNetworkQualityInfos) {
//                        0：网络状态未知
//                        1：网络状态极好
//                        2：用户主观感受和excellent差不多，但码率可能低于excellent
//                        3：用户主观感受有瑕疵但不影响沟通
//                        4：勉强能沟通但不顺畅
//                        5：网络质量非常差，基本不能沟通
//                        6：完全无法沟通
                        if (userStatusInfo.isSelf&&userStatusInfo.userId == info.userId) {
                            // 自己的话是上行，其他用户是下行
                            switch (info.upStatus) {
                                case NERtcConstants.NetworkStatus.UNKNOWN:
                                case NERtcConstants.NetworkStatus.DOWN:
                                    ivSignal.setImageResource(R.drawable.video_group_signal_gray);
                                    break;

                                case NERtcConstants.NetworkStatus.EXCELLENT:
                                case NERtcConstants.NetworkStatus.GOOD:
                                    ivSignal.setImageResource(R.drawable.video_group_signal_green);
                                    break;

                                case NERtcConstants.NetworkStatus.POOR:
                                    ivSignal.setImageResource(R.drawable.video_group_signal_yellow);
                                    break;
                                case NERtcConstants.NetworkStatus.BAD:
                                case NERtcConstants.NetworkStatus.VERYBAD:
                                    ivSignal.setImageResource(R.drawable.video_group_signal_red);
                                    break;
                                default:
                                    ivSignal.setImageResource(R.drawable.video_group_signal_green);
                                    break;
                            }

                            break;
                        }else {
                            if (userStatusInfo.userId== info.userId){
                                switch (info.downStatus) {
                                    case NERtcConstants.NetworkStatus.UNKNOWN:
                                    case NERtcConstants.NetworkStatus.DOWN:
                                        ivSignal.setImageResource(R.drawable.video_group_signal_gray);
                                        break;

                                    case NERtcConstants.NetworkStatus.EXCELLENT:
                                    case NERtcConstants.NetworkStatus.GOOD:
                                        ivSignal.setImageResource(R.drawable.video_group_signal_green);
                                        break;

                                    case NERtcConstants.NetworkStatus.POOR:
                                        ivSignal.setImageResource(R.drawable.video_group_signal_yellow);
                                        break;
                                    case NERtcConstants.NetworkStatus.BAD:
                                    case NERtcConstants.NetworkStatus.VERYBAD:
                                        ivSignal.setImageResource(R.drawable.video_group_signal_red);
                                        break;
                                    default:
                                        ivSignal.setImageResource(R.drawable.video_group_signal_green);
                                        break;
                                }
                            }
                        }
                    }
                }
            }
        });

        setDefaultStatus();
    }

    private void setDefaultStatus() {
        videoView.setVisibility(View.INVISIBLE);
        tvNicknameCenter.setVisibility(View.VISIBLE);
        ivMute.setVisibility(VISIBLE);
        ivMute.setImageResource(R.drawable.voice_off);
    }

    public void setData(UserStatusInfo userStatusInfo) {
        if (userStatusInfo==null){
            return;
        }
        this.userStatusInfo = userStatusInfo;
        if (userStatusInfo.isSelf) {
            VideoViewUtil.setupLocalVideo(videoView, false);
        } else {
            VideoViewUtil.setupRemoteVideo(videoView, userStatusInfo.userId, false);
        }
        if (!userStatusInfo.enableVideo) {
            videoView.setVisibility(View.INVISIBLE);
            tvNicknameCenter.setVisibility(View.VISIBLE);
        } else {
            videoView.setVisibility(View.VISIBLE);
            tvNicknameCenter.setVisibility(View.GONE);
        }

        if (userStatusInfo.enableMicphone) {
            ivMute.setVisibility(GONE);
        } else {
            ivMute.setVisibility(VISIBLE);
            ivMute.setImageResource(R.drawable.voice_off);
        }
        tvNicknameCenter.setText(userStatusInfo.nickname);
        tvNicknameBottom.setText(userStatusInfo.nickname);


    }

    public void setFullScreenButtonClickListener(FullScreenButtonClickListener fullScreenButtonClickListener) {
        this.fullScreenButtonClickListener = fullScreenButtonClickListener;
    }

    private FullScreenButtonClickListener fullScreenButtonClickListener;

    public void setUIType(int uiType) {
        if (uiType == UIType.SHOW_FULL_SCREEN_BUTTON_TYPE) {
            ivToFullScreen.setVisibility(VISIBLE);
            ivToFullScreen.setImageResource(R.drawable.video_group_icon_full_screen);
        } else if (uiType == UIType.DONT_SHOW_FULL_SCREEN_BUTTON_TYPE) {
            ivToFullScreen.setVisibility(INVISIBLE);
        }else if (uiType==UIType.SHOW_TO_SMALL_BUTTON_TYPE){
            ivToFullScreen.setVisibility(VISIBLE);
            ivToFullScreen.setImageResource(R.drawable.video_group_icon_fullscreen_to_small);
        }else {
            ivToFullScreen.setVisibility(VISIBLE);
            ivToFullScreen.setImageResource(R.drawable.video_group_icon_full_screen);
        }
    }

    public interface FullScreenButtonClickListener {
        void fullScreenButtonClick(UserStatusInfo userStatusInfo);
    }

    public static class UIType {
        /**
         * 展示全屏放大的按钮，场景是正常模式下房间人数大于1人
         */
        public static final int SHOW_FULL_SCREEN_BUTTON_TYPE = 0;
        /**
         * 不展示按钮，场景是：房间只有一人的时候
         */
        public static final int DONT_SHOW_FULL_SCREEN_BUTTON_TYPE = 1;
        /**
         * 展示全屏缩小的按钮，场景是：演讲者模式下，主页面RecycleView的item需要展示缩小按钮
         */
        public static final int SHOW_TO_SMALL_BUTTON_TYPE = 2;
    }

}
