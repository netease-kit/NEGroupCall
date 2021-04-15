package com.netease.biz_live.yunxin.live.audience.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.netease.biz_live.R;

import java.util.List;

/**
 * Created by luc on 2020/11/11.
 * <p>
 * 聊天室信息列表 adapter，主要追加信息时 定位到最后一条数据
 */
public class ChatMsgListAdapter extends LiveBaseAdapter<CharSequence> {
    public ChatMsgListAdapter(Context context, List<CharSequence> dataSource) {
        super(context, dataSource);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.view_item_msg_content_layout;
    }

    @Override
    protected LiveViewHolder onCreateViewHolder(View itemView) {
        return new LiveViewHolder(itemView);
    }

    @Override
    protected void onBindViewHolder(LiveViewHolder holder, CharSequence itemData) {
        TextView tvContent = holder.getView(R.id.tv_msg_content);
        tvContent.setText(itemData);
    }

    public void appendItem(CharSequence sequence) {
        if (sequence == null) {
            return;
        }
        dataSource.add(sequence);
        notifyItemInserted(dataSource.size() - 1);
    }

    public void appendItems(List<CharSequence> sequenceList) {
        if (sequenceList == null || sequenceList.isEmpty()) {
            return;
        }

        int start = getItemCount();
        dataSource.addAll(sequenceList);
        notifyItemRangeInserted(start, sequenceList.size());
    }

    public void clearAll() {
        dataSource.clear();
        notifyDataSetChanged();
    }
}
