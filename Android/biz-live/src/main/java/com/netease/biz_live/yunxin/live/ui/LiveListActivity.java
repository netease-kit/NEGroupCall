package com.netease.biz_live.yunxin.live.ui;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.adapter.LiveListAdapter;
import com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity;
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.ui.widget.FooterView;
import com.netease.biz_live.yunxin.live.ui.widget.HeaderView;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.utils.SpUtils;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;
import com.scwang.smart.refresh.layout.api.RefreshLayout;
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener;
import com.scwang.smart.refresh.layout.listener.OnRefreshListener;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * 直播列表页面
 */
public class LiveListActivity extends BaseActivity implements OnRefreshListener, OnLoadMoreListener {

    private RecyclerView recyclerView;

    private ImageView ivCreateLive;

    private SmartRefreshLayout refreshLayout;

    private RelativeLayout rlyEmpty;

    private LiveListAdapter liveListAdapter;

    private ImageView ivClose;

    //页码
    private boolean haveMore = false;

    //每页大小
    private static final int PAGE_SIZE = 20;

    // 下一页请求页码
    private int nextPageNum = 1;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.live_list_activity_layout);
        paddingStatusBarHeight(R.id.rl_root);
        initView();
    }

    private void initView() {
        recyclerView = findViewById(R.id.rcv_live);
        ivCreateLive = findViewById(R.id.iv_new_live);
        refreshLayout = findViewById(R.id.refreshLayout);
        ivClose = findViewById(R.id.iv_back);
        refreshLayout.setRefreshHeader(new HeaderView(this));
        refreshLayout.setRefreshFooter(new FooterView(this));
        refreshLayout.setOnRefreshListener(this);
        refreshLayout.setOnLoadMoreListener(this);
        ivCreateLive.setOnClickListener(v -> {
            LiveAnchorActivity.startAnchorActivity(LiveListActivity.this);
        });
        ivClose.setOnClickListener(v -> onBackPressed());


        liveListAdapter = new LiveListAdapter(this);
        liveListAdapter.setOnItemClickListener((liveList, position) -> {
            //goto audience page
            LiveAudienceActivity.launchAudiencePage(this, liveList, position);
        });
        final GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 2);
        int pixel8 = SpUtils.dp2pix(getApplicationContext(), 8);
        int pixel4 = SpUtils.dp2pix(getApplicationContext(), 4);
        recyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int position = parent.getChildAdapterPosition(view);

                int left;
                int right;
                if (position % 2 == 0) {
                    left = pixel8;
                    right = pixel4;
                } else {
                    left = pixel4;
                    right = pixel8;
                }
                outRect.set(left, pixel4, right, pixel4);
            }
        });
        gridLayoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                // 如果是空布局，让它占满一行
                if (liveListAdapter.isEmptyPosition(position)) {
                    return gridLayoutManager.getSpanCount();
                }
                return 1;
            }
        });

        recyclerView.setLayoutManager(gridLayoutManager);
        recyclerView.setAdapter(liveListAdapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
        initData();
    }

    private void initData() {
        getLiveLists(true);
    }

    private void getLiveLists(boolean isRefresh) {
        LiveInteraction.getLiveList(-1, nextPageNum, PAGE_SIZE).subscribe(new ResourceSingleObserver<BaseResponse<LiveListResponse>>() {
            @Override
            public void onSuccess(BaseResponse<LiveListResponse> liveListResponseBaseResponse) {
                if (liveListResponseBaseResponse.code == 200) {
                    nextPageNum++;
                    if (liveListAdapter != null) {
                        liveListAdapter.setDataList(liveListResponseBaseResponse.data.list, isRefresh);
                    }
                    haveMore = liveListResponseBaseResponse.data.hasNextPage;
                    if (isRefresh) {
                        refreshLayout.finishRefresh(true);
                    } else {
                        if (liveListResponseBaseResponse.data.list == null || liveListResponseBaseResponse.data.list.size() == 0) {
                            refreshLayout.finishLoadMoreWithNoMoreData();
                        } else {
                            refreshLayout.finishLoadMore(true);
                        }
                    }
                }
            }

            @Override
            public void onError(Throwable e) {
                if (isRefresh) {
                    refreshLayout.finishRefresh(false);
                } else {
                    refreshLayout.finishLoadMore(false);
                }
            }
        });
    }


    @Override
    public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
        if (!haveMore) {
            refreshLayout.finishLoadMoreWithNoMoreData();
        } else {
            getLiveLists(false);
        }
    }

    @Override
    public void onRefresh(@NonNull RefreshLayout refreshLayout) {
        nextPageNum = 1;
        getLiveLists(true);
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .statusBarColor(R.color.color_1a1a24)
                .build();
    }
}
