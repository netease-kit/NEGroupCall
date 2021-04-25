package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.adapter.VideoMeetRoomHolderManager;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.ui.VideoMeetingRoomActivity;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * @author sunkeding
 * 多人通话主视图UI
 */
public class VideoGroupMainView extends RecyclerView {

    public VideoViewAdapter videoViewAdapter;

    public VideoGroupMainView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public VideoGroupMainView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public VideoGroupMainView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    public VideoViewAdapter getVideoViewAdapter() {
        return videoViewAdapter;
    }

    private void init(Context context) {
        GridLayoutManager gridLayoutManager = new GridLayoutManager(context, 2);
        gridLayoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                if (videoViewAdapter.userStatusInfoList == null) {
                    return 1;
                }
                if (videoViewAdapter.userStatusInfoList.size() == 1) {
                    return 2;
                } else if (videoViewAdapter.userStatusInfoList.size() == 2 || videoViewAdapter.userStatusInfoList.size() == 4) {
                    return 1;
                } else if (videoViewAdapter.userStatusInfoList.size() == 3) {
                    if (position < 2) {
                        return 1;
                    } else {
                        return 2;
                    }
                }
                return 1;
            }
        });
        setLayoutManager(gridLayoutManager);
        addItemDecoration(new GridSpacingItemDecoration(2, SizeUtils.dp2px(2), false, 0));
        videoViewAdapter = new VideoViewAdapter(context);
        setAdapter(videoViewAdapter);
    }

    public void addUser(UserStatusInfo userStatusInfo){
        videoViewAdapter.addUser(userStatusInfo);
    }

    public void deleteUser(long uid) {
        videoViewAdapter.deleteUser(uid);
    }

    public void enableMicphone(boolean enableMicphone, long userId, boolean self) {
        videoViewAdapter.enableMicphone(enableMicphone,userId,self);
    }

    public void enableVideo(long userId, boolean self, boolean enable) {
        videoViewAdapter.enableVideo(userId,self,enable);
    }

    public void updateNickName(long uid, String nickname) {
        videoViewAdapter.updateNickName(uid, nickname);
    }

    public static class VideoViewAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
        public List<UserStatusInfo> userStatusInfoList=new ArrayList<>();
        private Context context;

        public VideoViewAdapter(Context context) {
            this.context = context;
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
                    if (userInfo!=null){
                        if (userId == userInfo.userId) {
                            userStatusInfoList.remove(userInfo);
                            resetUserOrderAndUIPropertyByUserCount(userStatusInfoList);
                            notifyDataSetChanged();
                            return;
                        }
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
                    if (userInfo!=null){
                        if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                            userInfo.enableVideo = enable;
                            notifyItemChanged(i,userInfo);
                            return;
                        }
                    }
                }
            }
        }

        public void enableMicphone(boolean enableMicphone, long uid, boolean self) {
            if (userStatusInfoList != null && (self || uid != 0)) {
                for (int i = 0; i < userStatusInfoList.size(); i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if (userInfo!=null){
                        if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                            userStatusInfoList.get(i).enableMicphone = enableMicphone;
                            notifyItemChanged(i, userInfo);
                            return;
                        }
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
            userStatusInfoList.add(userStatusInfo);
            //按照加入时间戳排序，越早进入的排在越前
            Collections.sort(userStatusInfoList, (o1, o2) -> {
                if (o1.joinRoomTimeStamp>o2.joinRoomTimeStamp){
                    return 1;
                }else if (o1.joinRoomTimeStamp==o2.joinRoomTimeStamp){
                    return 0;
                }
                return -1;
            });
            UserStatusInfo self=null;
            ArrayList<UserStatusInfo> tempList=new ArrayList<>();
            for (int i = 0; i < userStatusInfoList.size(); i++) {
                UserStatusInfo info = userStatusInfoList.get(i);
                if (info.isSelf){
                    self=info;
                }else {
                    tempList.add(info);
                }
            }
            userStatusInfoList.clear();
            userStatusInfoList.addAll(tempList);
            if (self!=null){
                //始终把自己排到首位
                userStatusInfoList.add(0,self);
            }
            resetUserOrderAndUIPropertyByUserCount(userStatusInfoList);
            notifyDataSetChanged();
        }


        /**
         * 根据用户数重新设置用户的顺序以及UI样式属性
         *
         * @param userStatusInfoList
         */
        public void resetUserOrderAndUIPropertyByUserCount(List<UserStatusInfo> userStatusInfoList) {
            if (userStatusInfoList != null && !userStatusInfoList.isEmpty()) {
                if (userStatusInfoList.size() == 1) {
                    userStatusInfoList.get(0).uiType = UserStatusInfo.UIType.FULL_SCREEN_TYPE;
                } else if (userStatusInfoList.size() == 2) {
                    for (UserStatusInfo userStatusInfo : userStatusInfoList) {
                        userStatusInfo.uiType = UserStatusInfo.UIType.HALF_TYPE;
                    }
                } else if (userStatusInfoList.size() == 3) {
                    userStatusInfoList.get(0).uiType = UserStatusInfo.UIType.QUARTER_TYPE;
                    userStatusInfoList.get(1).uiType = UserStatusInfo.UIType.QUARTER_TYPE;
                    userStatusInfoList.get(2).uiType = UserStatusInfo.UIType.THIRD_SPECIAL_TYPE;
                } else if (userStatusInfoList.size() == 4) {
                    for (UserStatusInfo userStatusInfo : userStatusInfoList) {
                        userStatusInfo.uiType = UserStatusInfo.UIType.QUARTER_TYPE;
                    }
                }
            }
        }


        public void updateNickName(long uid, String nickName) {
            if (userStatusInfoList != null && uid != 0) {
                for (int i = 0; i < userStatusInfoList.size(); i++) {
                    UserStatusInfo userInfo = userStatusInfoList.get(i);
                    if (userInfo!=null){
                        if (uid == userInfo.userId) {
                            userStatusInfoList.get(i).nickname = nickName;
                            notifyItemChanged(i, userInfo);
                            return;
                        }
                    }
                }
            }
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            switch (viewType) {
                case UserStatusInfo.UIType.FULL_SCREEN_TYPE:
                    return new VideoMeetRoomHolderManager.FullScreenTypeHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.video_group_listitem_single_user_style_layout, parent, false));
                case UserStatusInfo.UIType.HALF_TYPE:
                    return new VideoMeetRoomHolderManager.HalfTypeHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.video_group_listitem_two_user_style_layout, parent, false));
                case UserStatusInfo.UIType.THIRD_SPECIAL_TYPE:
                    return new VideoMeetRoomHolderManager.ThirdSpecialTypeHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.video_group_listitem_third_user_style_layout, parent, false));
                case UserStatusInfo.UIType.QUARTER_TYPE:
                    return new VideoMeetRoomHolderManager.QuarterTypeHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.video_group_listitem_four_user_style_layout, parent, false));
                default:
                    return new VideoMeetRoomHolderManager.FullScreenTypeHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.video_group_listitem_single_user_style_layout, parent, false));
            }
        }

        @Override
        public int getItemViewType(int position) {
            if (userStatusInfoList!=null&&position<userStatusInfoList.size()&&position>=0&&userStatusInfoList.get(position)!=null){
                return userStatusInfoList.get(position).uiType;
            }
            return UserStatusInfo.UIType.FULL_SCREEN_TYPE;
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
            if (userStatusInfoList != null && userStatusInfoList.size() > position) {
                holder.itemView.setVisibility(View.VISIBLE);
                UserStatusInfo userStatusInfo = userStatusInfoList.get(position);
                int itemViewType = getItemViewType(position);
                switch (itemViewType) {
                    case UserStatusInfo.UIType.FULL_SCREEN_TYPE:
                        VideoMeetRoomHolderManager.FullScreenTypeHolder fullScreenTypeHolder = (VideoMeetRoomHolderManager.FullScreenTypeHolder) holder;
                        VideoMeetingRoomActivity videoMeetingRoomActivity= (VideoMeetingRoomActivity) context;
                        int type=VideoCallBaseItemView.UIType.SHOW_FULL_SCREEN_BUTTON_TYPE;
                        if (userStatusInfoList.size()==1){
                            if (!videoMeetingRoomActivity.videoGroupSpeakerView.getSpeakerAdapter().list.isEmpty()){
                                //演讲者模式
                                type=VideoCallBaseItemView.UIType.SHOW_TO_SMALL_BUTTON_TYPE;
                            }else {
                                //房间只有一人
                                type=VideoCallBaseItemView.UIType.DONT_SHOW_FULL_SCREEN_BUTTON_TYPE;
                            }
                        }
                        fullScreenTypeHolder.bindData(userStatusInfo,type);
                        fullScreenTypeHolder.root.setFullScreenButtonClickListener(new VideoCallBaseItemView.FullScreenButtonClickListener() {
                            @Override
                            public void fullScreenButtonClick(UserStatusInfo userStatusInfo) {
                                TempLogUtil.log("主页面只有一个用户，点击了"+userStatusInfo.nickname+"的放大按钮");
                                resetTwoRecycleViewData(context, userStatusInfo, userStatusInfoList);
                            }
                        });
                        break;
                    case UserStatusInfo.UIType.HALF_TYPE:
                        VideoMeetRoomHolderManager.HalfTypeHolder halfTypeHolder = (VideoMeetRoomHolderManager.HalfTypeHolder) holder;
                        halfTypeHolder.bindData(userStatusInfo, position);
                        halfTypeHolder.root.setFullScreenButtonClickListener(new VideoCallHalfStyleItemView.FullScreenButtonClickListener() {
                            @Override
                            public void fullScreenButtonClick(UserStatusInfo userStatusInfo) {
                                TempLogUtil.log("主页面有2个用户，点击了"+userStatusInfo.nickname+"的放大按钮");
                                resetTwoRecycleViewData(context, userStatusInfo, userStatusInfoList);
                            }
                        });
                        break;
                    case UserStatusInfo.UIType.THIRD_SPECIAL_TYPE:
                        VideoMeetRoomHolderManager.ThirdSpecialTypeHolder thirdSpecialTypeHolder = (VideoMeetRoomHolderManager.ThirdSpecialTypeHolder) holder;
                        thirdSpecialTypeHolder.bindData(userStatusInfo);
                        thirdSpecialTypeHolder.root.setFullScreenButtonClickListener(new VideoCallThirdUserSpecialStyleItemView.FullScreenButtonClickListener() {
                            @Override
                            public void fullScreenButtonClick(UserStatusInfo userStatusInfo) {
                                TempLogUtil.log("主页面有3个用户，点击了第三个用户"+userStatusInfo.nickname+"的放大按钮");
                                resetTwoRecycleViewData(context, userStatusInfo, userStatusInfoList);
                            }
                        });
                        break;
                    case UserStatusInfo.UIType.QUARTER_TYPE:
                        VideoMeetRoomHolderManager.QuarterTypeHolder quarterTypeHolder = (VideoMeetRoomHolderManager.QuarterTypeHolder) holder;
                        quarterTypeHolder.bindData(userStatusInfo, position);
                        quarterTypeHolder.root.setFullScreenButtonClickListener(new VideoCallQuarterStyleItemView.FullScreenButtonClickListener() {
                            @Override
                            public void fullScreenButtonClick(UserStatusInfo userStatusInfo) {
                                TempLogUtil.log("主页面有4个用户，点击了用户"+userStatusInfo.nickname+"的放大按钮");
                                resetTwoRecycleViewData(context, userStatusInfo, userStatusInfoList);
                            }
                        });
                        break;
                    default:
                        break;
                }

            } else {
                holder.itemView.setVisibility(View.GONE);
            }
        }

        /**
         * 普通模式下点击视图的全屏按钮触发，重新设置普通模式的数据集合与演讲者模式的数据集合
         *
         * @param userStatusInfo     普通模式下，点击全屏按钮的那个用户
         * @param userStatusInfoList 普通模式下的用户集合
         */
        private void resetTwoRecycleViewData(Context context, UserStatusInfo userStatusInfo, List<UserStatusInfo> userStatusInfoList) {
            if (userStatusInfo==null){
                return;
            }
            //如果是演讲者模式下，点击缩小按钮重新变回普通模式
            VideoMeetingRoomActivity videoMeetingRoomActivity= (VideoMeetingRoomActivity) context;
            if (userStatusInfoList.size()==1&&!videoMeetingRoomActivity.videoGroupSpeakerView.getSpeakerAdapter().list.isEmpty()){
                for (UserStatusInfo info : videoMeetingRoomActivity.videoGroupSpeakerView.getSpeakerAdapter().list) {
                     addUser(info);
                }
                videoMeetingRoomActivity.videoGroupSpeakerView.clear();
                return;
            }

            // 如果是普通模式下，点击放大按钮变成演讲者模式
            for (UserStatusInfo info : userStatusInfoList) {
                if (info!=null&&userStatusInfo.userId != info.userId) {
                    videoMeetingRoomActivity.videoGroupSpeakerView.addUser(info);
                }
            }
            userStatusInfoList.clear();
            userStatusInfoList.add(userStatusInfo);
            resetUserOrderAndUIPropertyByUserCount(userStatusInfoList);
            notifyDataSetChanged();
        }


        @Override
        public int getItemCount() {
            if(userStatusInfoList == null){
                return 0;
            }
            return userStatusInfoList.size();
        }

    }
}
