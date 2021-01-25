package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PointF;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.Group;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.ui.dialog.GiftDialog;
import com.netease.biz_live.yunxin.live.audience.utils.DialogHelperActivity;
import com.netease.biz_live.yunxin.live.audience.utils.InputUtils;
import com.netease.biz_live.yunxin.live.audience.utils.PlayerControl;
import com.netease.biz_live.yunxin.live.audience.utils.PlayerVideoSizeUtils;
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils;
import com.netease.biz_live.yunxin.live.audience.utils.TimeUtils;
import com.netease.biz_live.yunxin.live.chatroom.control.Audience;
import com.netease.biz_live.yunxin.live.chatroom.control.ChatRoomNotify;
import com.netease.biz_live.yunxin.live.chatroom.control.SkeletonChatRoomNotify;
import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RoomMsg;
import com.netease.biz_live.yunxin.live.constant.LiveParams;
import com.netease.biz_live.yunxin.live.constant.LiveStatus;
import com.netease.biz_live.yunxin.live.constant.LiveTimeDef;
import com.netease.biz_live.yunxin.live.constant.LiveType;
import com.netease.biz_live.yunxin.live.gift.GiftCache;
import com.netease.biz_live.yunxin.live.gift.GiftRender;
import com.netease.biz_live.yunxin.live.gift.ui.GifAnimationView;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorMemberInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.model.response.PkLiveContributeTotal;
import com.netease.biz_live.yunxin.live.model.response.PkRecord;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.network.LiveServerApi;
import com.netease.biz_live.yunxin.live.ui.widget.AudiencePortraitRecyclerView;
import com.netease.biz_live.yunxin.live.ui.widget.ChatRoomMsgRecyclerView;
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView;
import com.netease.yunxin.android.lib.historian.Historian;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.lib_utils.utils.ToastUtils;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.utils.SpUtils;
import com.netease.yunxin.nertc.demo.utils.ViewUtils;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import io.reactivex.Single;
import io.reactivex.observers.ResourceSingleObserver;

/**
 * Created by luc on 2020/11/19.
 * <p>
 * 观众端详细控制，继承自{@link FrameLayout} 添加了 {@link TextureView} 以及 {@link ExtraTransparentView} 作为页面主要元素
 * <p>
 * TextureView 用于页面视频播放；
 * <p>
 * ExtraTransparentView 用于页面信息展示，由于页面存在左右横滑状态所以自定义view 继承自 {@link RecyclerView} 用于页面左右横滑支持；
 * 实际页面布局见 {@link #infoContentView}.
 *
 * <p>
 * 此处 {@link #prepare(),#release()} 方法依赖于recyclerView 子 view 的 {@link androidx.recyclerview.widget.RecyclerView#onChildAttachedToWindow(View)},
 * {@link androidx.recyclerview.widget.RecyclerView#onChildDetachedFromWindow(View)} 方法，
 * 方法，{@link #renderData(LiveInfo)} 依赖于 {@link androidx.recyclerview.widget.RecyclerView.Adapter#onBindViewHolder(RecyclerView.ViewHolder, int)}
 * 此处使用 {@link androidx.recyclerview.widget.LinearLayoutManager} 从源码角度可以保障 renderData 调用时机早于 prepare 时机。
 */
@SuppressLint("ViewConstructor")
public class AudienceContentView extends FrameLayout {
    private static final String TAG = AudienceContentView.class.getSimpleName();
    /**
     * 用户服务
     */
    private final UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    /**
     * 页面 View 所在 activity
     */
    private final BaseActivity activity;
    /**
     * 观众端聊天室相关控制
     */
    private final Audience audienceControl = Audience.getInstance();

    /**
     * 礼物渲染控制，完成礼物动画的播放，停止，顺序播放等
     */
    private final GiftRender giftRender = new GiftRender();
    /**
     * 直播播放View
     */
    private TextureView videoView;

    /**
     * 信息浮层左右切换
     */
    private ExtraTransparentView horSwitchView;
    /**
     * 观众端信息浮层
     */
    private View infoContentView;

    /**
     * 直播间详细信息
     */
    private LiveInfo liveInfo;

    /**
     * 播放器控制，通过注册 TextureView 实现，控制播放器的
     */
    private PlayerControl playerControl;

    /**
     * 聊天室信息列表
     */
    private ChatRoomMsgRecyclerView roomMsgView;

    /**
     * 直播间顶部用户列表
     */
    private AudiencePortraitRecyclerView audiencePortraitView;

    /**
     * pk 状态整体控制
     */
    private PKControlView pkControlView;

    /**
     * 聊天输入框
     */
    private EditText etInputView;

    /**
     * 直播间总人数
     */
    private TextView tvAudienceCount;

    /**
     * 直播间主播云币数量
     */
    private TextView tvCoinCount;

    /**
     * 主播错误状态展示（包含结束直播）
     */
    private AudienceErrorStateView errorStateView;

    /**
     * 主播正常直播状态
     */
    private Group gpNormalState;

    /**
     * pk 阶段倒计时
     */
    private PKControlView.WrapperCountDownTimer countDownTimer;

    /**
     * 礼物弹窗
     */
    private GiftDialog giftDialog;

    /**
     * 依赖对象中回调，{@link #prepare()} 状态设置为 true；
     * {@link #release()} 状态设置为 false;
     */
    private boolean canRender;

    /**
     * 聊天室消息回调
     */
    private final ChatRoomNotify roomNotify = new SkeletonChatRoomNotify() {

        @Override
        public void onJoinRoom(boolean success, int code) {
            super.onJoinRoom(success, code);
            Historian.e("=====>", "onJoinRoom " + "success " + success + ", code " + code);
        }

        @Override
        public void onMsgArrived(RoomMsg msg) {
            roomMsgView.appendItem(msg.message);
        }

        @Override
        public void onGiftArrived(RewardGiftInfo giftInfo) {
            giftRender.addGift(GiftCache.getGift(giftInfo.giftId).dynamicIconResId);
        }

        @Override
        public void onUserCountChanged(int count) {
            super.onUserCountChanged(count);
            tvAudienceCount.setText(StringUtils.getAudienceCount(count));
        }

        @Override
        public void onRoomDestroyed(LiveChatRoomInfo roomInfo) {
            if (!canRender) {
                return;
            }
            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
        }

        @Override
        public void onAnchorLeave() {
            if (!canRender) {
                return;
            }
            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
        }

        @Override
        public void onKickedOut() {
            if (!canRender) {
                return;
            }
            if (activity != null) {
                activity.finish();
                getContext().startActivity(new Intent(getContext(), DialogHelperActivity.class));
            }
        }

        @Override
        public void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment) {
            super.onAnchorCoinChanged(attachment);
            tvCoinCount.setText(StringUtils.getCoinCount(attachment.totalCoinCount));
            if (pkControlView.getVisibility() == VISIBLE) {
                pkControlView.updateScore(attachment.PKCoinCount, attachment.otherPKCoinCount);
                pkControlView.updateRanking(attachment.rewardList, attachment.otherRewardList);
            }
        }

        @Override
        public void onPKStatusChanged(PKStatusAttachment pkStatus) {
            if (countDownTimer != null) {
                countDownTimer.stop();
            }
            if (pkStatus.isStartState()) {
                // pk 状态下view渲染
                pkControlView.setVisibility(VISIBLE);
                // 重置pk控制view
                pkControlView.reset();
                // 设置pk 主播昵称/头像
                pkControlView.updatePkAnchorInfo(pkStatus.otherAnchorNickname, pkStatus.otherAnchorAvatar);
                // 调整视频播放比例
                adjustVideoSizeForPk(true);
                // 定时器倒计时
                long leftTime = pkStatus.getLeftTime(LiveTimeDef.TOTAL_TIME_PK, 0);
                countDownTimer = pkControlView.createCountDownTimer(leftTime);
                countDownTimer.start();
            } else {
                pkControlView.handleResultFlag(true, pkStatus.anchorWin);
            }
        }

        @Override
        public void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus) {
            if (countDownTimer != null) {
                countDownTimer.stop();
            }
            if (punishmentStatus.isStartState()) {
                // 定时器倒计时
                long leftTime = punishmentStatus.getLeftTime(LiveTimeDef.TOTAL_TIME_PUNISHMENT, 0);
                countDownTimer = pkControlView.createCountDownTimer(leftTime);
                countDownTimer.start();
            } else {
                pkControlView.setVisibility(INVISIBLE);
            }
        }

        @Override
        public void onAudienceChanged(List<AudienceInfo> infoList) {
            audiencePortraitView.updateAll(infoList);
        }
    };

    /**
     * 错误页面按钮点击响应
     */
    private final AudienceErrorStateView.ClickButtonListener clickButtonListener = new AudienceErrorStateView.ClickButtonListener() {
        @Override
        public void onBackClick(View view) {
            if (activity != null && !activity.isFinishing()) {
                activity.finish();
            }
        }

        @Override
        public void onRetryClick(View view) {
            if (canRender && liveInfo != null && videoView != null) {
                getPlayerControl().prepareToPlay(liveInfo.liveConfig.rtmpPullUrl, videoView);
                initForLiveType();
            }
        }
    };

    /**
     * 播放器控制回调
     */
    private final PlayerControl.PlayerNotify playerNotify = new PlayerControl.PlayerNotify() {
        @Override
        public void onPreparing() {
            Historian.e(TAG, "player, preparing");

        }

        @Override
        public void onPlaying() {
            changeErrorState(false, AudienceErrorStateView.TYPE_ERROR);
            Historian.e(TAG, "player, playing");
        }

        @Override
        public void onError() {
            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
            Historian.e(TAG, "player, error");
        }

        @Override
        public void onVideoSizeChanged(int width, int height) {
            if (height == LiveParams.PK_LIVE_HEIGHT) {
                adjustVideoSizeForPk(false);
            } else {
                adjustVideoSizeForNormal();
            }
            horSwitchView.post(() -> horSwitchView.setBackgroundColor(Color.parseColor("#00000000")));
            Historian.e(TAG, "video size changed, width is " + width + ", height is " + height);
        }
    };

    public AudienceContentView(@NonNull BaseActivity activity) {
        super(activity);
        this.activity = activity;
        initViews();
    }

    /**
     * 添加并初始化内部子 view
     */
    private void initViews() {
        // 设置 view 背景颜色
        setBackgroundColor(Color.parseColor("#ff201C23"));

        // 添加视频播放 TextureView
        videoView = new TextureView(getContext());
        addView(videoView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        // 添加顶部浮层页
        infoContentView = LayoutInflater.from(getContext()).inflate(R.layout.view_item_audience_live_room_info, null);
        horSwitchView = new ExtraTransparentView(getContext(), infoContentView);
        horSwitchView.setBackgroundColor(Color.parseColor("#ff201C23"));
        // 页面左右切换时滑动到最新的消息内容
        horSwitchView.registerSelectedRunnable(() -> {
            if (roomMsgView != null) {
                roomMsgView.toLatestMsg();
            }
        });
        addView(horSwitchView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        // 浮层信息向下便宜 status bar 高度，避免重叠
        StatusBarConfig.paddingStatusBarHeight(activity, horSwitchView);

        // 添加错误状态浮层
        errorStateView = new AudienceErrorStateView(getContext());
        addView(errorStateView);
        errorStateView.setVisibility(GONE);

        // 添加礼物展示浮层
        // 礼物动画渲染 view
        GifAnimationView gifAnimationView = new GifAnimationView(getContext());
        int size = SpUtils.getScreenWidth(getContext());
        FrameLayout.LayoutParams layoutParams = generateDefaultLayoutParams();
        layoutParams.width = size;
        layoutParams.height = size;
        layoutParams.gravity = Gravity.BOTTOM;
        layoutParams.bottomMargin = SpUtils.dp2pix(getContext(), 166);
        addView(gifAnimationView, layoutParams);
        gifAnimationView.bringToFront();
        // 绑定礼物渲染 view
        giftRender.init(gifAnimationView);

        // 监听软件盘弹起
        InputUtils.registerSoftInputListener(activity, new InputUtils.InputParamHelper() {
            @Override
            public int getHeight() {
                return AudienceContentView.this.getHeight();
            }

            @Override
            public EditText getInputView() {
                return etInputView;
            }
        });
    }

    /**
     * 页面信息，拉流，直播间信息展示等
     *
     * @param info 直播间信息
     */
    public void renderData(LiveInfo info) {
        this.liveInfo = info;
        // 整体页面控件定位并渲染基础信息

        errorStateView.renderInfo(info.avatar, info.nickname);

        // 主播正常之宝状态
        gpNormalState = infoContentView.findViewById(R.id.group_normal);
        gpNormalState.setVisibility(VISIBLE);
        // 直播间顶部列表
        audiencePortraitView = infoContentView.findViewById(R.id.rv_anchor_portrait_list);
        // 直播状态控制view
        pkControlView = infoContentView.findViewById(R.id.pkv_control);
        // 聊天室信息列表
        roomMsgView = infoContentView.findViewById(R.id.crv_msg_list);
        // 输入聊天框
        etInputView = infoContentView.findViewById(R.id.et_room_msg_input);
        etInputView.setOnEditorActionListener((v, actionId, event) -> {
            String input = etInputView.getText().toString();
            InputUtils.hideSoftInput(etInputView);
            audienceControl.sendTextMsg(input);
            return true;
        });
        etInputView.setVisibility(GONE);
        // 直播间总人数
        tvAudienceCount = infoContentView.findViewById(R.id.tv_audience_count);
        tvAudienceCount.setText(StringUtils.getAudienceCount(liveInfo.audienceCount));
        // 主播总云币
        tvCoinCount = infoContentView.findViewById(R.id.tv_anchor_coin_count);
        tvCoinCount.setText("");

        // 主播头像
        ImageView ivPortrait = infoContentView.findViewById(R.id.iv_anchor_portrait);
        ImageLoader.with(getContext().getApplicationContext()).circleLoad(info.avatar, ivPortrait);

        // 主播昵称
        TextView tvNickname = infoContentView.findViewById(R.id.tv_anchor_nickname);
        tvNickname.setText(info.nickname);

        // 关闭按钮
        View close = infoContentView.findViewById(R.id.iv_room_close);
        close.setOnClickListener(v -> {
            // 资源释放，页面退出
            activity.finish();
        });

        // 礼物发送
        View gift = infoContentView.findViewById(R.id.iv_room_gift);
        gift.setOnClickListener(v -> {
            if (giftDialog == null) {
                giftDialog = new GiftDialog(activity);
            }

            giftDialog.show(giftInfo -> {
                UserModel currentUser = getCurrentUser();
                RewardGiftInfo rewardGiftInfo = new RewardGiftInfo(liveInfo.liveCid, currentUser.accountId, currentUser.nickname, liveInfo.accountId, giftInfo.giftId);
                boolean isPk = pkControlView.getVisibility() == VISIBLE;
                LiveInteraction.rewardAnchor(isPk, rewardGiftInfo).subscribe(new ResourceSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(@NonNull Boolean aBoolean) {
                        if (!aBoolean) {
                            ToastUtils.showShort("打赏礼物失败");
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        ToastUtils.showShort("打赏礼物失败");
                    }
                });
            });
        });

        // 显示地步输入栏
        View input = infoContentView.findViewById(R.id.tv_room_msg_input);
        input.setOnClickListener(v -> InputUtils.showSoftInput(etInputView));
    }

    /**
     * 页面绑定准备
     */
    public void prepare() {
        changeErrorState(false, -1);
        if (horSwitchView != null) {
            horSwitchView.setBackgroundColor(Color.parseColor("#ff201C23"));
        }
        canRender = true;
        // 初始化信息页面位置
        horSwitchView.toSelectedPosition();
        // 播放器控制加载信息
        playerControl = getPlayerControl();
        playerControl.prepareToPlay(liveInfo.liveConfig.rtmpPullUrl, videoView);

        // 聊天室信息更新到最新到最新一条
        if (roomMsgView != null) {
            roomMsgView.toLatestMsg();
        }
    }

    /**
     * 页面展示
     */
    public void select() {
        // 加入聊天室
        try {
            audienceControl.joinRoom(new LiveChatRoomInfo(liveInfo.chatRoomId, liveInfo.accountId,
                    String.valueOf(liveInfo.roomUid), liveInfo.audienceCount));
        } catch (Exception e) {
            // 加入聊天室出现异常直接退出当前页面
            if (activity != null) {
                activity.finish();
            }
        }
        audienceControl.registerNotify(roomNotify, true);
        // 根据房间当前状态初始化房间信息
        initForLiveType();
    }

    /**
     * 页面资源释放
     */
    public void release() {
        if (!canRender) {
            return;
        }
        canRender = false;
        // 播放器资源释放
        if (playerControl != null) {
            playerControl.release();
            playerControl = null;
        }
        // 礼物渲染释放
        giftRender.release();
        // 消息列表清空
        roomMsgView.clearAllInfo();
        // pk 状态隐藏
        pkControlView.setVisibility(INVISIBLE);
    }


    private void changeErrorState(boolean error, int type) {
        if (!canRender) {
            return;
        }
        if (error) {
            getPlayerControl().reset();
            if (type == AudienceErrorStateView.TYPE_FINISHED) {
                release();
            } else {
                getPlayerControl().release();
            }
        }

        if (gpNormalState != null) {
            gpNormalState.setVisibility(error ? GONE : VISIBLE);
        }
        if (errorStateView != null) {
            errorStateView.setVisibility(error ? VISIBLE : GONE);
        }
        if (error && errorStateView != null) {
            errorStateView.updateType(type, clickButtonListener);
        }
    }

    private void initForLiveType() {
        LiveInteraction.queryAnchorRoomInfo(liveInfo.accountId, liveInfo.liveCid)
                .subscribe(new ResourceSingleObserver<BaseResponse<AnchorQueryInfo>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<AnchorQueryInfo> response) {
                        if (!canRender) {
                            return;
                        }
                        if (response.isSuccessful()) {
                            AnchorQueryInfo anchorQueryInfo = response.data;
                            tvCoinCount.setText(StringUtils.getCoinCount(anchorQueryInfo.coinTotal));

                            PkRecord record = anchorQueryInfo.pkRecord;
                            if (record != null && (record.status == LiveStatus.PK_LIVING || record.status == LiveStatus.PK_PUNISHMENT)) {
                                initForPk(anchorQueryInfo);
                            } else {
                                initForNormal();
                            }
                        } else if (response.code == LiveServerApi.ERROR_CODE_ROOM_NOT_EXIST || response.code == LiveServerApi.ERROR_CODE_USER_NOT_IN_ROOM) {
                            changeErrorState(true, AudienceErrorStateView.TYPE_FINISHED);
                        } else {
                            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
                            Historian.e(TAG, "获取房间信息失败，返回消息为 " + response);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        Historian.e(TAG, "获取房间信息失败");
                        changeErrorState(true, AudienceErrorStateView.TYPE_ERROR);
                    }
                });
    }

    private void initForPk(AnchorQueryInfo anchorQueryInfo) {
        // 停止倒计时
        if (countDownTimer != null) {
            countDownTimer.stop();
        }

        PkRecord record = anchorQueryInfo.pkRecord;
        pkControlView.setVisibility(VISIBLE);
        // 更新比分
        if (record.inviter.equals(liveInfo.accountId)) {
            pkControlView.updateScore(record.inviterRewards, record.inviteeRewards);
        } else {
            pkControlView.updateScore(record.inviteeRewards, record.inviterRewards);
        }

        // pk 场景下主播成员列表数为2，分别为当前主播以及pk方主播，从列表中取出pk 主播数据
        AnchorMemberInfo temp = anchorQueryInfo.members.get(0);
        AnchorMemberInfo temp1 = anchorQueryInfo.members.get(1);
        AnchorMemberInfo pkMemberInfo = liveInfo.accountId.equals(temp.accountId) ? temp1 : temp;
        // 更新pk 主播头像和昵称
        pkControlView.updatePkAnchorInfo(pkMemberInfo.nickname, pkMemberInfo.avatar);
        // 两次网络请求对应主播的贡献排行
        Single<PkLiveContributeTotal> anchorSource =
                LiveInteraction.queryPkLiveContributeTotal(liveInfo.accountId, liveInfo.liveCid, LiveType.PK_LIVING);
        Single<PkLiveContributeTotal> otherAnchorSource =
                LiveInteraction.queryPkLiveContributeTotal(pkMemberInfo.accountId, pkMemberInfo.liveCid, LiveType.PK_LIVING);
        // 合并网络请求
        Single.zip(anchorSource, otherAnchorSource,
                (pkLiveContributeTotal, pkLiveContributeTotal2) -> Arrays.asList(pkLiveContributeTotal, pkLiveContributeTotal2))
                .subscribe(new ResourceSingleObserver<List<PkLiveContributeTotal>>() {
                    @Override
                    public void onSuccess(@NonNull List<PkLiveContributeTotal> pkLiveContributeTotals) {
                        if (!canRender) {
                            return;
                        }
                        // 更新排行榜数据
                        PkLiveContributeTotal contributeTotal = pkLiveContributeTotals.get(0);
                        PkLiveContributeTotal contributeTotal1 = pkLiveContributeTotals.get(1);
                        if (liveInfo.accountId.equals(contributeTotal.accountId)) {
                            pkControlView.updateRanking(contributeTotal.getAudienceInfoList(), contributeTotal1.getAudienceInfoList());
                        } else {
                            pkControlView.updateRanking(contributeTotal1.getAudienceInfoList(), contributeTotal.getAudienceInfoList());
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        Historian.e(TAG, "获取贡献榜信息失败");
                    }
                });

        // 惩罚阶段 展示 pk 结果，并开始惩罚倒计时
        if (record.status == LiveStatus.PK_PUNISHMENT) {
            pkControlView.handleResultFlag(true, record.inviterRewards >= record.inviteeRewards);
            long leftTime = TimeUtils.getLeftTime(LiveTimeDef.TOTAL_TIME_PUNISHMENT, record.currentTime, record.punishmentStartTime, 0);
            countDownTimer = pkControlView.createCountDownTimer(leftTime);
        } else { // pk 进行中开始pk 倒计时
            pkControlView.handleResultFlag(false, false);
            long leftTime = TimeUtils.getLeftTime(LiveTimeDef.TOTAL_TIME_PK, record.currentTime, record.pkStartTime, 0);
            countDownTimer = pkControlView.createCountDownTimer(leftTime);
        }
        countDownTimer.start();
    }

    public void adjustVideoSizeForPk(boolean isPrepared) {
        int width = getWidth();
        int height = (int) (width / LiveParams.WH_RATIO_PK);

        float x = width / 2f;
        float y = StatusBarConfig.getStatusBarHeight(activity) + SpUtils.dp2pix(getContext(), 64) + height / 2f;

        PointF pivot = new PointF(x, y);
        Historian.e("=====>", "pk video view center point is " + pivot);
        if (isPrepared) {
            PlayerVideoSizeUtils.adjustForPreparePk(videoView, pivot);
        } else {
            PlayerVideoSizeUtils.adjustViewSizePosition(videoView, true, pivot);
        }
    }

    private void adjustVideoSizeForNormal() {
        PlayerVideoSizeUtils.adjustViewSizePosition(videoView);
    }

    private void initForNormal() {
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        pkControlView.setVisibility(INVISIBLE);
        pkControlView.updateRanking(Collections.emptyList(), Collections.emptyList());
        pkControlView.updateScore(0, 0);
    }

    /**
     * 获取播放器播放控制
     */
    private PlayerControl getPlayerControl() {
        if (playerControl == null || playerControl.isReleased()) {
            playerControl = new PlayerControl(activity, playerNotify);
            return playerControl;
        }
        return playerControl;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        int x = (int) ev.getRawX();
        int y = (int) ev.getRawY();
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(etInputView, x, y)) {
            InputUtils.hideSoftInput(etInputView);
        }
        return super.dispatchTouchEvent(ev);
    }


    /**
     * 获取当前登录用户信息
     */
    private UserModel getCurrentUser() {
        return userCenterService.getCurrentUser();
    }
}
