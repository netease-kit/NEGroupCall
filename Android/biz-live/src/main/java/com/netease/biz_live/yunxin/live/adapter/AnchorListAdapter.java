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
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.android.lib.picture.ImageLoader;

import java.util.ArrayList;
import java.util.List;

/**
 * 主播选择PK列表
 */
public class AnchorListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private ArrayList<LiveInfo> liveInfos;

    private final Context context;

    private OnItemClickListener onItemClickListener;

    public static final int VIEW_TYPE_ITEM = 1;
    public static final int VIEW_TYPE_EMPTY = 0;

    public AnchorListAdapter(Context context) {
        this.context = context;
        liveInfos = new ArrayList<>();
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    // Live ViewHolder
    static class LiveItemHolder extends RecyclerView.ViewHolder {

        public ImageView ivAnchor;

        public TextView tvAnchorName;

        public TextView tvAudienceNum;

        public TextView tvStartPk;

        public LiveItemHolder(View itemView) {
            super(itemView);
            ivAnchor = itemView.findViewById(R.id.iv_anchor);
            tvStartPk = itemView.findViewById(R.id.tv_start_pk);
            tvAnchorName = itemView.findViewById(R.id.tv_anchor_name);
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
        rootView = LayoutInflater.from(parent.getContext()).inflate(R.layout.anchor_list_item_layout, parent, false);
        return new LiveItemHolder(rootView);

    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof LiveItemHolder) {
            LiveInfo liveInfo = liveInfos.get(position);
            LiveItemHolder liveItemHolder = (LiveItemHolder) holder;
            liveItemHolder.tvAnchorName.setText(liveInfo.nickname);
            liveItemHolder.tvAudienceNum.setText("观众数：" + StringUtils.getAudienceCount(liveInfo.audienceCount));
            ImageLoader.with(context.getApplicationContext())
                    .circleLoad(liveInfo.avatar, liveItemHolder.ivAnchor);
            liveItemHolder.tvStartPk.setOnClickListener(v -> {
                if (onItemClickListener != null) {
                    onItemClickListener.onItemClick(liveInfo);
                }
            });
        }
    }

    /**
     * 更新数据
     *
     * @param liveInfoList
     */
    public void setDataList(List<LiveInfo> liveInfoList) {
        if (liveInfos == null) {
            liveInfos = new ArrayList<>();
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
        void onItemClick(LiveInfo liveInfo);
    }
}
