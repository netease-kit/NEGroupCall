package com.netease.biz_live.yunxin.live.dialog;

import android.app.Activity;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter;
import com.netease.biz_live.yunxin.live.audience.ui.dialog.BottomBaseDialog;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

import java.util.Arrays;
import java.util.List;

/**
 * 主播端底部更多弹窗
 */
public class AnchorMoreDialog extends BottomBaseDialog {

    public static final int ITEM_CAMERA = 1;
    public static final int ITEM_MUTE = 2;
    public static final int ITEM_RETURN = 3;
    public static final int ITEM_CAMERA_SWITCH = 4;
    public static final int ITEM_SETTING = 5;
    public static final int ITEM_DATA = 6;
    public static final int ITEM_FINISH = 7;

    public static final List<MoreItem> itemList = Arrays.asList(
            new MoreItem(1, R.drawable.selector_more_camera_status, "摄像头"),
            new MoreItem(2, R.drawable.selector_more_voice_status, "麦克风"),
            new MoreItem(3, R.drawable.selector_more_ear_return_status, "耳返").setEnable(false),
            new MoreItem(4, R.drawable.icon_camera_flip, "反转"),
//            new MoreItem(5, R.drawable.icon_live_setting, "直播设置"),
//            new MoreItem(6, R.drawable.icon_real_time_data, "实时数据"),
            new MoreItem(7, R.drawable.icon_live_finish, "结束直播")
    );

    public static void clearItem() {
        for (MoreItem item : itemList) {
            if (item.id == ITEM_RETURN) {
                item.setEnable(false);
            } else {
                item.setEnable(true);
            }
        }
    }

    protected OnItemClickListener clickListener;

    public AnchorMoreDialog(@NonNull Activity activity) {
        super(activity);
    }

    public AnchorMoreDialog registerOnItemClickListener(OnItemClickListener listener) {
        this.clickListener = listener;
        return this;
    }

    public void updateData(MoreItem item) {
        if (itemList == null || itemList.isEmpty()) {
            return;
        }
        for (MoreItem itemStep : itemList) {
            if (itemStep.id == item.id) {
                itemStep.enable = item.enable;
            }
        }
    }

    public List<MoreItem> getData() {
        return itemList;
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("更多");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        RecyclerView rvList = new RecyclerView(getContext());
        rvList.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, SpUtils.dp2pix(getContext(), 222));
        parent.addView(rvList, layoutParams);

        rvList.setLayoutManager(new GridLayoutManager(getContext(), 4));
        rvList.setAdapter(new LiveBaseAdapter<MoreItem>(getContext(), itemList) {
            @Override
            protected int getLayoutId(int viewType) {
                return R.layout.view_item_dialog_bottom_more;
            }

            @Override
            protected LiveViewHolder onCreateViewHolder(View itemView) {
                return new LiveViewHolder(itemView);
            }

            @Override
            protected void onBindViewHolder(LiveViewHolder holder, MoreItem itemData) {
                ImageView ivIcon = holder.getView(R.id.iv_item_icon);
                ivIcon.setImageResource(itemData.iconResId);
                ivIcon.setEnabled(itemData.enable);

                TextView tvName = holder.getView(R.id.tv_item_name);
                tvName.setText(itemData.name);

                holder.itemView.setOnClickListener(v -> {

                    if (clickListener != null) {
                        if (clickListener.onItemClick(v, itemData)) {
                            itemData.enable = !ivIcon.isEnabled();
                            ivIcon.setEnabled(itemData.enable);
                            updateData(itemData);
                        }
                    }
                    dismiss();
                });
            }
        });
    }

    public static class MoreItem {
        public int id;
        public int iconResId;
        public String name;
        public boolean enable = true;

        public MoreItem(int id, int iconResId, String name) {
            this.id = id;
            this.iconResId = iconResId;
            this.name = name;
        }

        public MoreItem setEnable(boolean enable) {
            this.enable = enable;
            return this;
        }
    }

    public interface OnItemClickListener {
        boolean onItemClick(View itemView, MoreItem item);
    }
}
