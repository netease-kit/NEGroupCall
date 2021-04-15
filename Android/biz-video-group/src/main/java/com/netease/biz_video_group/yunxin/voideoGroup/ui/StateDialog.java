package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.content.DialogInterface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.NERtcStatsDelegateManager;
import com.netease.biz_video_group.yunxin.voideoGroup.model.NERtcStatsObserverTemp;
import com.netease.lava.nertc.sdk.stats.NERtcStats;

/**
 * 实时数据dialog
 */
public class StateDialog extends DialogFragment {

    TextView tvNetWork;

    TextView tvVideoBitrate;

    TextView tvAudioBitRate;

    TextView tvVideoLost;

    TextView tvAudioLost;

    NERtcStatsObserverTemp neRtcStatsObserver = null;

    StringBuilder stringBuilder=new StringBuilder();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.video_state_dialog_layout, container, false);
        initView(rootView);
        return rootView;
    }

    @Override
    public void onStart() {
        super.onStart();
        initParams();
        neRtcStatsObserver = new NERtcStatsObserverTemp(){
            @Override
            public void onRtcStats(NERtcStats neRtcStats) {
                stringBuilder.setLength(0);
                stringBuilder.append("网络延时: ")
                        .append(neRtcStats.upRtt)
                        .append("ms");
                tvNetWork.setText(stringBuilder.toString());
                stringBuilder.setLength(0);
                stringBuilder.append("视频发送/接收码率: ")
                        .append(neRtcStats.txAudioKBitRate)
                        .append("/")
                        .append(neRtcStats.rxVideoKBitRate)
                        .append("kbps");
                tvVideoBitrate.setText(stringBuilder.toString());
                stringBuilder.setLength(0);
                stringBuilder.append("音频发送/接收码率: ")
                        .append(neRtcStats.txAudioKBitRate)
                        .append("/")
                        .append(neRtcStats.rxAudioKBitRate)
                        .append("kbps");
                tvAudioBitRate.setText(stringBuilder.toString());
                stringBuilder.setLength(0);
                stringBuilder.append("本地上行/下行视频丢包率: ")
                        .append(neRtcStats.txVideoPacketLossRate)
                        .append("/")
                        .append(neRtcStats.rxVideoPacketLossRate)
                        .append("%");
                tvVideoLost.setText(stringBuilder.toString());
                stringBuilder.setLength(0);
                stringBuilder.append("本地上行/下行音频丢包率: ")
                        .append(neRtcStats.txAudioPacketLossRate)
                        .append("/")
                        .append(neRtcStats.rxAudioPacketLossRate)
                        .append("%");
                tvAudioLost.setText(stringBuilder.toString());
            }
        };
        NERtcStatsDelegateManager.getInstance().addObserver(neRtcStatsObserver);
    }


    protected void initView(View rootView) {
        tvNetWork = rootView.findViewById(R.id.tv_network);
        tvVideoBitrate = rootView.findViewById(R.id.tv_video_bitrate);
        tvAudioBitRate = rootView.findViewById(R.id.tv_audio_bitrate);
        tvVideoLost = rootView.findViewById(R.id.tv_video_lost);
        tvAudioLost = rootView.findViewById(R.id.tv_audio_lost);
    }



    private void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.white_bottom_dialog_bg);

            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            window.setAttributes(params);
        }
        setCancelable(true);//设置点击外部是否消失
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        if(neRtcStatsObserver != null) {
            NERtcStatsDelegateManager.getInstance().removeObserver(neRtcStatsObserver);
        }
    }

}
