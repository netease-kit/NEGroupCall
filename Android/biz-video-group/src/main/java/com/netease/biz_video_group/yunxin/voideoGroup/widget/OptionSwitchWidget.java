package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;

/**
 * @author sunkeding
 * 选项切换组件
 */
public class OptionSwitchWidget extends LinearLayout {
    private TextView leftTextView;
    private TextView rightTextView;
    private OptionSelectedListener optionSelectedListener;

    public OptionSwitchWidget(Context context) {
        super(context);
        init(context);
    }

    public OptionSwitchWidget(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public OptionSwitchWidget(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }


    private void init(Context context) {
        leftTextView = new TextView(context);
        rightTextView = new TextView(context);
        leftTextView.setText("视频");
        rightTextView.setText("音频");
        leftTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        rightTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        leftTextView.setLayoutParams(new LayoutParams(0, SizeUtils.dp2px(32), 1));
        rightTextView.setLayoutParams(new LayoutParams(0, SizeUtils.dp2px(32), 1));
        leftTextView.setGravity(Gravity.CENTER);
        rightTextView.setGravity(Gravity.CENTER);
        leftTextView.setBackgroundResource(R.drawable.video_group_left_selected_background);
        rightTextView.setBackgroundResource(R.drawable.video_group_right_selected_background);
        leftTextView.setSelected(true);
        setSelectTextColor(0);
        this.removeAllViews();
        this.addView(leftTextView);
        this.addView(rightTextView);
        this.invalidate();
        initEvent();
    }

    private void initEvent() {
        leftTextView.setOnClickListener(v -> {
            if (leftTextView.isSelected()) {
                return;
            }
            leftTextView.setSelected(true);
            rightTextView.setSelected(false);
            setSelectTextColor(0);
            if (optionSelectedListener != null) {
                optionSelectedListener.onOptionSelected(leftTextView, 0);
            }
        });

        rightTextView.setOnClickListener(v -> {
            if (rightTextView.isSelected()) {
                return;
            }
            rightTextView.setSelected(true);
            leftTextView.setSelected(false);
            setSelectTextColor(1);
            if (optionSelectedListener != null) {
                optionSelectedListener.onOptionSelected(rightTextView, 1);
            }
        });
    }

    public void setSelectTextColor(int position) {
        if (position == 0) {
            leftTextView.setSelected(true);
            rightTextView.setSelected(false);
            leftTextView.setTextColor(Color.WHITE);
            rightTextView.setTextColor(getResources().getColor(R.color.checked_color));
        } else if (position == 1) {
            leftTextView.setSelected(false);
            rightTextView.setSelected(true);
            leftTextView.setTextColor(getResources().getColor(R.color.checked_color));
            rightTextView.setTextColor(Color.WHITE);
        }
    }

    public interface OptionSelectedListener {
        void onOptionSelected(View view, int position);
    }

    public void setOnOptionSelectedListener(OptionSelectedListener optionSelectedListener) {
        this.optionSelectedListener = optionSelectedListener;
    }
}
