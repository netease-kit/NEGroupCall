package com.netease.biz_live.yunxin.live.audience.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;

import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveAnchorListAdapter;
import com.netease.biz_live.yunxin.live.audience.ui.view.AudienceContentView;
import com.netease.biz_live.yunxin.live.audience.ui.view.ExtraTransparentView;
import com.netease.biz_live.yunxin.live.audience.ui.view.PagerVerticalLayoutManager;
import com.netease.biz_live.yunxin.live.chatroom.control.Audience;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.yunxin.android.lib.historian.Historian;
import com.netease.yunxin.lib_utils.utils.ToastUtils;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;

import java.util.ArrayList;
import java.util.List;

/**
 * 观众端页面 activity
 * <p>
 * 页面具体信息展示以及相关逻辑控制详细见 {@link AudienceContentView}
 */
public class LiveAudienceActivity extends BaseActivity {

    /**
     * 传递至观众端页面的主播信息列表
     */
    private static final String KEY_PARAM_LIVE_INFO_LIST = "live_info_list";
    /**
     * 传递当前选中主播在列表中的位置
     */
    private static final String KEY_PARAM_LIVE_INFO_POSITION = "live_info_position";

    /**
     * 当前视频流位置
     */
    private int currentPosition;

    /**
     * 观众端竖直翻页 LayoutManager
     */
    private PagerVerticalLayoutManager layoutManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 屏幕常亮
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        // 使用 TextureView 添加硬件加速设置
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED);
        setContentView(R.layout.activity_live_audience);
        @SuppressWarnings("unchecked")
        List<LiveInfo> infoList = (List<LiveInfo>) getIntent().getSerializableExtra(KEY_PARAM_LIVE_INFO_LIST);
        // 初始化内部 view 以及相关控制逻辑
        initViews(infoList);
    }

    private void initViews(List<LiveInfo> infoList) {
        RecyclerView rvAnchorList = findViewById(R.id.rv_anchor_list);
        layoutManager = new PagerVerticalLayoutManager(this);
        // 页面竖直滚动监听
        layoutManager.setOnPageChangedListener(new PagerVerticalLayoutManager.OnPageChangedListener() {
            @Override
            public void onPageInit(int position) {
                // 当页面处于部分可见时即会回调
                Historian.e("=====>", "init " + position);
                currentPosition = position;
                View itemView = layoutManager.findViewByPosition(position);
                if (itemView instanceof AudienceContentView) {
                    ((AudienceContentView) itemView).prepare();
                }
            }

            @Override
            public void onPageSelected(int position, boolean isLimit) {
                // 当页面完全可见时回调
                Historian.e("=====>", "selected " + position + ", isLimit " + isLimit);
                if (isLimit) {
                    ToastUtils.showShort("没有更多了");
                    return;
                }
                View itemView = layoutManager.findViewByPosition(position);
                if (itemView instanceof AudienceContentView) {
                    ((AudienceContentView) itemView).select();
                }
            }

            @Override
            public void onPageRelease(int position) {
                // 页面不可见时回调
                Historian.e("=====>", "release " + position);
                View itemView = layoutManager.findViewByPosition(position);
                if (itemView instanceof AudienceContentView) {
                    ((AudienceContentView) itemView).release();
                }
            }
        });
        rvAnchorList.setLayoutManager(layoutManager);
        LiveAnchorListAdapter adapter = new LiveAnchorListAdapter(this, infoList);
        rvAnchorList.setAdapter(adapter);
        // 定位到直播间指定列表
        int currentPosition = getIntent().getIntExtra(KEY_PARAM_LIVE_INFO_POSITION, -1);
        if (currentPosition >= 0 && currentPosition < infoList.size()) {
            layoutManager.scrollToPosition(currentPosition);
        }
        // 初始化直播间左右滑动页面位置
        ExtraTransparentView.initPosition();
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }

    @Override
    public void finish() {
        // 页面销毁时资源释放，由于页面直接销毁时不会回调最后一个页面的 onPageRelease 所以在此处进行最后资源的释放；
        if (currentPosition >= 0) {
            View itemView = layoutManager.findViewByPosition(currentPosition);
            if (itemView instanceof AudienceContentView) {
                ((AudienceContentView) itemView).release();
                Audience.getInstance().leaveRoom();
            }
        }
        super.finish();
    }

    /**
     * 启动观众页面
     *
     * @param context  上下文
     * @param infoList 主播列表信息
     * @return 是否成功启动
     */
    public static boolean launchAudiencePage(Context context, ArrayList<LiveInfo> infoList, int position) {
        if (infoList == null || infoList.isEmpty()) {
            return false;
        }
        Intent intent = new Intent(context, LiveAudienceActivity.class);
        intent.putExtra(KEY_PARAM_LIVE_INFO_LIST, infoList);
        intent.putExtra(KEY_PARAM_LIVE_INFO_POSITION, position);
        if (!(context instanceof Activity)) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        context.startActivity(intent);
        return true;
    }
}