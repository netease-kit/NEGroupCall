package com.netease.biz_live.yunxin.live.audience.ui.dialog;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter;
import com.netease.biz_live.yunxin.live.gift.GiftCache;
import com.netease.biz_live.yunxin.live.gift.GiftInfo;
import com.netease.yunxin.nertc.demo.utils.SpUtils;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class GiftDialog extends BottomBaseDialog {
    private GiftSendListener sendListener;
    private final RecyclerView.ItemDecoration itemDecoration = new RecyclerView.ItemDecoration() {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            if (parent.getChildAdapterPosition(view) == 0) {
                outRect.set(SpUtils.dp2pix(getContext(), 16), 0, 0, 0);
            } else {
                super.getItemOffsets(outRect, view, parent, state);
            }
        }
    };

    public GiftDialog(@NonNull Activity activity) {
        super(activity);
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("送礼物");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        View bottomView = LayoutInflater.from(getContext()).inflate(R.layout.view_dialog_bottom_gift, parent);
        // 礼物列表初始化
        RecyclerView rvGiftList = bottomView.findViewById(R.id.rv_dialog_gift_list);
        rvGiftList.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvGiftList.removeItemDecoration(itemDecoration);
        rvGiftList.addItemDecoration(itemDecoration);
        InnerAdapter adapter = new InnerAdapter(getContext(), GiftCache.getGiftList());
        rvGiftList.setAdapter(adapter);

        // 发送礼物
        View sendGift = bottomView.findViewById(R.id.tv_dialog_send_gift);
        sendGift.setOnClickListener(v -> {
            if (sendListener != null) {
                dismiss();
                sendListener.onSendGift(adapter.getFocusedInfo());
            }
        });
    }

    /**
     * 弹窗展示
     *
     * @param listener 礼物发送回调
     */
    public void show(GiftSendListener listener) {
        this.sendListener = listener;
        show();
    }

    /**
     * 礼物发送回调
     */
    public interface GiftSendListener {
        void onSendGift(GiftInfo giftInfo);
    }

    /**
     * 内部礼物列表 adapter
     */
    private static class InnerAdapter extends LiveBaseAdapter<GiftInfo> {
        private GiftInfo focusedInfo;

        public InnerAdapter(Context context, List<GiftInfo> dataSource) {
            super(context, dataSource);
            if (!dataSource.isEmpty()) {
                focusedInfo = dataSource.get(0);
            }
        }

        @Override
        protected int getLayoutId(int viewType) {
            return R.layout.view_item_dialog_gift;
        }

        @Override
        protected LiveViewHolder onCreateViewHolder(View itemView) {
            return new LiveViewHolder(itemView);
        }

        @Override
        protected void onBindViewHolder(LiveViewHolder holder, GiftInfo itemData) {
            ImageView ivGift = holder.getView(R.id.iv_item_gift_icon);
            ivGift.setImageResource(itemData.staticIconResId);

            TextView tvName = holder.getView(R.id.tv_item_gift_name);
            tvName.setText(itemData.name);

            TextView tvValue = holder.getView(R.id.tv_item_gift_value);
            tvValue.setText(formatValue(itemData.coinCount));

            View border = holder.getView(R.id.rl_item_border);
            if (itemData.equals(focusedInfo)) {
                border.setBackgroundResource(R.drawable.layer_dialog_gift_chosen_bg);
            } else {
                border.setBackgroundColor(Color.TRANSPARENT);
            }

            holder.itemView.setOnClickListener(v -> {
                focusedInfo = itemData;
                notifyDataSetChanged();
            });
        }

        private GiftInfo getFocusedInfo() {
            return focusedInfo;
        }

        private String formatValue(long value) {
            return "(" + value + "云币)";
        }
    }
}
