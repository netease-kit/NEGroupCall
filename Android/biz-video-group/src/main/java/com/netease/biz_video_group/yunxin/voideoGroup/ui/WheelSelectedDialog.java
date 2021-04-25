package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bigkoo.pickerview.adapter.ArrayWheelAdapter;
import com.contrarywind.view.WheelView;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.base.VideoGroupBaseDialog;

import java.util.ArrayList;

/**
 * 滚轮选择弹窗
 */
public class WheelSelectedDialog extends VideoGroupBaseDialog {
    private ArrayList<String> list;
    private int currentIndex=0;
    public final static String DATA_KEY="data_key";
    public final static String CURRENT_INDEX_KEY="currentIndex_key";

    @Override
    public void onStart() {
        super.onStart();
        setCancelable(false);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        parseBundle();
        View rootView = inflater.inflate(R.layout.video_group_wheel_selected_layout, container, false);
        initView(rootView);
        initEvent(rootView);
        return rootView;
    }

    private void initEvent(View rootView) {
        rootView.findViewById(R.id.tv_cancle).setOnClickListener(v -> {
            dismiss();
        });

        rootView.findViewById(R.id.tv_sure).setOnClickListener(v -> {
            if (onItemSelectedCallback!=null){
                onItemSelectedCallback.onItemSelected(currentIndex);
            }
            dismiss();
        });
    }

    private void initView(View rootView) {
        WheelView wheelView = rootView.findViewById(R.id.wheelview);
        wheelView.setCurrentItem(currentIndex);
        wheelView.setCyclic(false);
        wheelView.setAdapter(new ArrayWheelAdapter(list));
        wheelView.setOnItemSelectedListener(index -> {
            currentIndex=index;
        });
    }

    private void parseBundle() {
        Bundle arguments = getArguments();
        list = arguments.getStringArrayList(DATA_KEY);
        currentIndex = arguments.getInt(CURRENT_INDEX_KEY,0);
    }

    public void setOnItemSelectedCallback(OnItemSelectedCallback onItemSelectedCallback) {
        this.onItemSelectedCallback = onItemSelectedCallback;
    }

    private OnItemSelectedCallback onItemSelectedCallback;
    public interface OnItemSelectedCallback{
        void onItemSelected(int index);
    }
}
