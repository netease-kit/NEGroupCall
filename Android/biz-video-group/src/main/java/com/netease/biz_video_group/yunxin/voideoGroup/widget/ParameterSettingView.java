package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.Switch;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.netease.biz_video_group.R;

/**
 * @author sunkeding
 * 带开关的View，用来设置一些参数
 */
public class ParameterSettingView extends ConstraintLayout {
    private TextView tvTitle;
    private Switch switchButton;
    public ParameterSettingView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public ParameterSettingView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ParameterSettingView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        inflate(context, R.layout.video_group_parameters_setting_layout,this);
        tvTitle=findViewById(R.id.tv_title);
        switchButton=findViewById(R.id.switch_button);
        switchButton.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (checkedChangeListener!=null){
                checkedChangeListener.onCheckedChanged(isChecked);
            }
        });
    }

    public void setTitle(String title){
        tvTitle.setText(title);
    }

    public void setCheckedChangeListener(CheckedChangeListener checkedChangeListener) {
        this.checkedChangeListener = checkedChangeListener;
    }

    private CheckedChangeListener checkedChangeListener;

    public interface CheckedChangeListener{
        void onCheckedChanged(boolean isChecked);
    }
}
