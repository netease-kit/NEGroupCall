package com.netease.yunxin.nertc.demo.feedback;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.list.CommonAdapter;

import java.util.List;

/**
 * Created by luc on 2020/11/19.
 */
class DemoNameAdapter extends CommonAdapter<String> {
    private String focusedItem;

    public DemoNameAdapter(Context context, String focusedItem, List<String> dataSource) {
        super(context, dataSource);
        this.focusedItem = focusedItem;
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.view_item_feedback_child;
    }

    @Override
    protected ItemViewHolder onCreateViewHolder(View itemView, int viewType) {
        return new ItemViewHolder(itemView);
    }

    @Override
    protected void onBindViewHolder(ItemViewHolder holder, String itemData) {
        TextView tvName = holder.getView(R.id.tv_item_name);
        tvName.setText(itemData);
        View ivChosen = holder.getView(R.id.iv_chosen_icon);
        ivChosen.setVisibility(focusedItem.equals(itemData) ? View.VISIBLE : View.GONE);
        holder.itemView.setOnClickListener(v -> {
            focusedItem = itemData;
            notifyDataSetChanged();
        });
    }

    public String getFocusedItem() {
        return focusedItem;
    }
}
