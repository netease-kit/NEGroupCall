package com.netease.biz_live.yunxin.live.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils;
import com.netease.biz_live.yunxin.live.constant.LiveStatus;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 直播主界面直播列表adapter
 */
public class LiveListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private ArrayList<LiveInfo> liveInfos;

    private final Context context;

    private OnItemClickListener onItemClickListener;

    public static final int VIEW_TYPE_ITEM = 1;
    public static final int VIEW_TYPE_EMPTY = 0;


    public LiveListAdapter(Context context) {
        this.context = context;
        liveInfos = new ArrayList<>();
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    // Live ViewHolder
    static class LiveItemHolder extends RecyclerView.ViewHolder {

        public ImageView ivRoomPic;

        public ImageView ivPkTag;

        public TextView tvAnchorName;

        public TextView tvRoomName;

        public TextView tvAudienceNum;

        public LiveItemHolder(View itemView) {
            super(itemView);
            ivRoomPic = itemView.findViewById(R.id.iv_room_pic);
            ivPkTag = itemView.findViewById(R.id.iv_pk_tag);
            tvAnchorName = itemView.findViewById(R.id.tv_anchor_name);
            tvRoomName = itemView.findViewById(R.id.tv_room_name);
            tvAudienceNum = itemView.findViewById(R.id.tv_audience_num);
        }
    }


    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == VIEW_TYPE_EMPTY) {
            View emptyView = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_empty_layout, parent, false);

            return new RecyclerView.ViewHolder(emptyView) {

            };

        }
        View rootView;
        rootView = LayoutInflater.from(parent.getContext()).inflate(R.layout.live_item_layout, parent, false);
        return new LiveItemHolder(rootView);

    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof LiveItemHolder) {
            LiveInfo liveInfo = liveInfos.get(position);
            ((LiveItemHolder) holder).tvRoomName.setText(liveInfo.roomTopic);
            ((LiveItemHolder) holder).tvAnchorName.setText(liveInfo.nickname);
            ((LiveItemHolder) holder).tvAudienceNum.setText(StringUtils.getAudienceCount(liveInfo.audienceCount));
            ImageLoader.with(context.getApplicationContext())
                    .roundedCorner(liveInfo.liveCoverPic, SpUtils.dp2pix(context, 4), ((LiveItemHolder) holder).ivRoomPic);
            if (liveInfo.live == LiveStatus.PK_LIVING || liveInfo.live == LiveStatus.PK_PUNISHMENT) {
                ((LiveItemHolder) holder).ivPkTag.setVisibility(View.VISIBLE);
            } else {
                ((LiveItemHolder) holder).ivPkTag.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(v -> {
                if (onItemClickListener != null) {
                    onItemClickListener.onItemClick(liveInfos, position);
                }
            });
        }
    }

    /**
     * 判断是否是空布局
     */
    public boolean isEmptyPosition(int position) {
        return position == 0 && liveInfos.isEmpty();
    }

    /**
     * 更新数据
     *
     * @param liveInfoList
     * @param isRefresh
     */
    public void setDataList(List<LiveInfo> liveInfoList, boolean isRefresh) {
        if (liveInfos == null) {
            liveInfos = new ArrayList<>();
        }
        if (isRefresh) {
            liveInfos.clear();
        }
        if (liveInfoList != null && liveInfoList.size() != 0) {
            liveInfos.addAll(liveInfoList);
        }
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        if (liveInfos != null && liveInfos.size() > 0) {
            return liveInfos.size();
        }
        return 1;
    }

    @Override
    public int getItemViewType(int position) {
        //在这里进行判断，如果我们的集合的长度为0时，我们就使用emptyView的布局
        if (liveInfos.size() == 0) {
            return VIEW_TYPE_EMPTY;
        }
        //如果有数据，则使用ITEM的布局
        return VIEW_TYPE_ITEM;
    }

    public interface OnItemClickListener {
        void onItemClick(ArrayList<LiveInfo> liveList, int position);
    }
}
