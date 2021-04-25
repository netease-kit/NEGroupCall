package com.netease.biz_video_group.yunxin.voideoGroup.adapter;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoCallBaseItemView;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoCallHalfStyleItemView;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoCallQuarterStyleItemView;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoCallThirdUserSpecialStyleItemView;

/**
 * @author sunkeding
 * 视频通话页面ViewHolder管理类
 */
public class VideoMeetRoomHolderManager {

    public static class FullScreenTypeHolder extends RecyclerView.ViewHolder {
        public VideoCallBaseItemView root;

        public FullScreenTypeHolder(@NonNull View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
        }

        public void bindData(UserStatusInfo userStatusInfo,int uiType) {
            root.setData(userStatusInfo);
            root.setUIType(uiType);
        }
    }

    public static class HalfTypeHolder extends RecyclerView.ViewHolder {
        public VideoCallHalfStyleItemView root;

        public HalfTypeHolder(@NonNull View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
        }

        public void bindData(UserStatusInfo userStatusInfo,int position) {
            root.setData(userStatusInfo);
        }
    }

    public static class ThirdSpecialTypeHolder extends RecyclerView.ViewHolder {
        public VideoCallThirdUserSpecialStyleItemView root;

        public ThirdSpecialTypeHolder(@NonNull View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
        }

        public void bindData(UserStatusInfo userStatusInfo) {
            root.setData(userStatusInfo);
        }
    }

    public static class QuarterTypeHolder extends RecyclerView.ViewHolder {
        public VideoCallQuarterStyleItemView root;

        public QuarterTypeHolder(@NonNull View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
        }

        public void bindData(UserStatusInfo userStatusInfo,int position) {
            root.setData(userStatusInfo);
        }
    }
}
