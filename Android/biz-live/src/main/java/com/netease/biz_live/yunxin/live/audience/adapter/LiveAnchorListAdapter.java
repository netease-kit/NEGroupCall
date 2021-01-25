package com.netease.biz_live.yunxin.live.audience.adapter;

import android.view.ViewGroup;

import com.netease.biz_live.yunxin.live.audience.ui.view.AudienceContentView;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by luc on 2020/11/9.
 * <p>
 * 观众页面展示主播信息的 adapter
 */
public class LiveAnchorListAdapter extends RecyclerView.Adapter<LiveAnchorListAdapter.ListViewHolder> {
    private final BaseActivity activity;
    private final List<LiveInfo> liveInfoList;

    public LiveAnchorListAdapter(BaseActivity activity, List<LiveInfo> dataSource) {
        this.activity = activity;
        liveInfoList = new ArrayList<>(dataSource);
    }

    @NonNull
    @Override
    public ListViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        AudienceContentView itemView = new AudienceContentView(activity);
        RecyclerView.LayoutParams layoutParams = new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        itemView.setLayoutParams(layoutParams);
        return new ListViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull ListViewHolder holder, int position) {
        holder.contentView.renderData(getItem(position));
    }

    @Override
    public int getItemCount() {
        return liveInfoList.size();
    }

    public LiveInfo getItem(int position) {
        return liveInfoList.get(position);
    }

    public static class ListViewHolder extends RecyclerView.ViewHolder {
        final AudienceContentView contentView;

        public ListViewHolder(@NonNull AudienceContentView itemView) {
            super(itemView);
            this.contentView = itemView;
        }
    }
}
