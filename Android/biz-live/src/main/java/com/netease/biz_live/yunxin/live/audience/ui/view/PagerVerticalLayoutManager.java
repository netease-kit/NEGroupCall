package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SnapHelper;

/**
 * Created by luc on 2020/11/19.
 */
public class PagerVerticalLayoutManager extends LinearLayoutManager {
    /**
     * 是否为recyclerview 首次加载数据
     */
    private boolean isFirstLoad = true;

    /**
     * 子view attach window 状态变化
     */
    private final RecyclerView.OnChildAttachStateChangeListener onChildAttachStateChangeListener = new RecyclerView.OnChildAttachStateChangeListener() {
        @Override
        public void onChildViewAttachedToWindow(@NonNull View view) {
            if (pageChangedListener != null) {
                pageChangedListener.onPageInit(getPosition(view));
            }
            if (isFirstLoad) {
                isFirstLoad = false;
                int position = getPosition(view);
                lastPosition = position;

                if (pageChangedListener != null) {
                    pageChangedListener.onPageSelected(position, false);
                    isLimit = true;// 初始化位置认为此次滑动在端点
                }
            }
        }

        @Override
        public void onChildViewDetachedFromWindow(@NonNull View view) {
            if (pageChangedListener != null) {
                pageChangedListener.onPageRelease(getPosition(view));
            }
        }
    };
    private final SnapHelper snapHelper;
    /**
     * 页面滚动回调
     */
    private OnPageChangedListener pageChangedListener;
    /**
     * 上一次selected 记录位置
     */
    private int lastPosition = -1;

    /**
     * 标记是否为页面最前/最后的数据
     */
    private boolean isLimit = false;

    public PagerVerticalLayoutManager(Context context) {
        super(context, LinearLayoutManager.VERTICAL, false);
        this.snapHelper = new PagerSnapHelper();
    }

    // 避免请求焦点出现滚动；
    @Override
    public boolean requestChildRectangleOnScreen(@NonNull RecyclerView parent, @NonNull View child, @NonNull Rect rect, boolean immediate, boolean focusedChildVisible) {
        return false;
    }

    // 避免焦点请求失败导致页面重新填充，出现下一个view进行attach window 操作；
    @Override
    public View onFocusSearchFailed(View focused, int focusDirection, RecyclerView.Recycler recycler, RecyclerView.State state) {
        return null;
    }

    @Override
    public void onScrollStateChanged(int state) {
        if (state != RecyclerView.SCROLL_STATE_IDLE) {
            return;
        }
        View currentView = snapHelper.findSnapView(this);
        if (currentView == null) {
            return;
        }

        int position = getPosition(currentView);

        // 位置相同且判断不为首部/尾部数据滑动不进行回调
        if (position == lastPosition && !isLimit) {
            isLimit = true;// 位置相同 则可能是首部/尾部数据
            return;
        }

        if (pageChangedListener != null && getChildCount() == 1) {
            pageChangedListener.onPageSelected(position, isLimit);
        }
        lastPosition = position;
        isLimit = true; // 滑动时认为每个点都可能时端点数据

    }

    public void setOnPageChangedListener(OnPageChangedListener pageChangedListener) {
        this.pageChangedListener = pageChangedListener;
    }

    @Override
    public void onAttachedToWindow(RecyclerView view) {
        super.onAttachedToWindow(view);
        snapHelper.attachToRecyclerView(view);
        view.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                isLimit = dy == 0;// 如果存在纵向滑动变化则说明不在端点
            }

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
            }
        });
        view.addOnChildAttachStateChangeListener(onChildAttachStateChangeListener);
    }

    /**
     * 页面滑动监听
     */
    public interface OnPageChangedListener {
        /**
         * 页面初始化完成
         *
         * @param position 页面position
         */
        void onPageInit(int position);

        /**
         * 页面滑动时调用
         *
         * @param position 当前页面位置
         * @param isLimit  是否为滑动方向的最后一条，端点判断逻辑，认为每次滑动后都到达了端点，但是通过 dy 修正是否真正到达端点；
         */
        void onPageSelected(int position, boolean isLimit);

        /**
         * 页面销毁时调用
         *
         * @param position 页面position
         */
        void onPageRelease(int position);
    }
}
