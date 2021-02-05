package com.netease.biz_live.yunxin.live.dialog;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.adapter.AnchorListAdapter;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.ui.widget.FooterView;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.blankj.utilcode.util.ScreenUtils;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;
import com.scwang.smart.refresh.layout.api.RefreshLayout;
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * 主播列表，供PK选择
 */
public class AnchorListDialog extends BaseBottomDialog implements OnLoadMoreListener {

    private RecyclerView rcyAnchor;

    private SmartRefreshLayout refreshLayout;

    private AnchorListAdapter anchorListAdapter;

    //每页大小
    private static final int PAGE_SIZE = 20;

    // 下一页请求页码
    private int nextPageNum = 1;

    //页码
    private boolean haveMore = false;

    SelectAnchorListener selectAnchorListener;

    @Override
    protected int getResourceLayout() {
        return R.layout.anchor_list_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        rcyAnchor = rootView.findViewById(R.id.rcv_anchor);
        refreshLayout = rootView.findViewById(R.id.refreshLayout);
        super.initView(rootView);
    }

    @Override
    protected void initData() {
        refreshLayout.setEnableRefresh(false);
        refreshLayout.setRefreshFooter(new FooterView(getContext()));
        refreshLayout.setOnLoadMoreListener(this);

        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getContext());
        rcyAnchor.setLayoutManager(linearLayoutManager);
        anchorListAdapter = new AnchorListAdapter(getContext());
        anchorListAdapter.setOnItemClickListener(liveInfo -> {
            dismiss();
            if (selectAnchorListener != null) {
                selectAnchorListener.onAnchorSelect(liveInfo);
            }
        });
        rcyAnchor.setAdapter(anchorListAdapter);
        getAnchor();
        super.initData();
    }

    public void setSelectAnchorListener(SelectAnchorListener selectAnchorListener) {
        this.selectAnchorListener = selectAnchorListener;
    }

    /**
     * 获取主播
     */
    private void getAnchor() {
        LiveInteraction.getLiveList(1, nextPageNum, PAGE_SIZE).subscribe(new ResourceSingleObserver<BaseResponse<LiveListResponse>>() {
            @Override
            public void onSuccess(BaseResponse<LiveListResponse> liveListResponseBaseResponse) {
                if (liveListResponseBaseResponse.code == 200) {
                    nextPageNum++;
                    if (anchorListAdapter != null) {
                        anchorListAdapter.setDataList(liveListResponseBaseResponse.data.list);
                    }
                    haveMore = liveListResponseBaseResponse.data.hasNextPage;

                    if (liveListResponseBaseResponse.data.list == null || liveListResponseBaseResponse.data.list.size() == 0) {
                        refreshLayout.finishLoadMoreWithNoMoreData();
                    } else {
                        refreshLayout.finishLoadMore(true);
                    }

                }
            }

            @Override
            public void onError(Throwable e) {
                refreshLayout.finishLoadMore(false);
            }
        });
    }

    @Override
    protected void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.white_bottom_dialog_bg);

            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ScreenUtils.getScreenHeight() / 2;
            window.setAttributes(params);

        }
        setCancelable(true);//设置点击外部是否消失
    }

    @Override
    public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
        if (!haveMore) {
            refreshLayout.finishLoadMoreWithNoMoreData();
        } else {
            getAnchor();
        }
    }

    public interface SelectAnchorListener {
        void onAnchorSelect(LiveInfo liveInfo);
    }
}
