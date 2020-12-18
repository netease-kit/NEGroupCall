package com.netease.yunxin.nertc.demo.list;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.R;

import java.util.List;

public class FunctionAdapter extends CommonAdapter<FunctionItem> {
    public static final int TYPE_VIEW_TITLE = 0;
    public static final int TYPE_VIEW_CONTENT = 1;

    public FunctionAdapter(Context context, List<FunctionItem> dataSource) {
        super(context, dataSource);
    }

    @Override
    public int getItemViewType(int position) {
        return getItem(position).type;
    }

    @Override
    protected int getLayoutId(int viewType) {
        int layoutId;
        if (viewType == TYPE_VIEW_CONTENT) {
            layoutId = R.layout.view_item_function;
        } else {
            layoutId = R.layout.view_item_function_title;
        }
        return layoutId;
    }

    @Override
    protected ItemViewHolder onCreateViewHolder(View itemView, int viewType) {
        return new ItemViewHolder(itemView);
    }

    @Override
    protected void onBindViewHolder(ItemViewHolder holder, FunctionItem itemData) {
        if (itemData.type == TYPE_VIEW_TITLE) {
            ImageView ivIcon = holder.getView(R.id.iv_title_icon);
            ivIcon.setImageResource(itemData.iconResId);
            return;
        }
        ImageView ivIcon = holder.getView(R.id.iv_function_icon);
        ivIcon.setImageResource(itemData.iconResId);
        TextView tvName = holder.getView(R.id.tv_function_name);
        tvName.setText(itemData.nameStr);
        holder.itemView.setOnClickListener(v -> {
            if (itemData.action != null) {
                itemData.action.run();
            }
        });
    }
}
