package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SnapHelper;

/**
 * Created by luc on 2020/11/19.
 * <p>
 * 自定义view 继承自 {@link RecyclerView} 且 child count 数目固定为 2；child 1 为空白页面；child 2 为信息展示页面
 */
@SuppressLint("ViewConstructor")
public class ExtraTransparentView extends RecyclerView {
    private static int DEFAULT_SELECT_POSITION = 1;

    private final SnapHelper snapHelper = new PagerSnapHelper();

    private final LinearLayoutManager layoutManager;
    private final InnerAdapter adapter;

    private Runnable selectedRunnable;

    private final OnChildAttachStateChangeListener onChildAttachStateChangeListener
            = new OnChildAttachStateChangeListener() {
        @Override
        public void onChildViewAttachedToWindow(@NonNull View view) {
            DEFAULT_SELECT_POSITION = layoutManager.getPosition(view);
            if (DEFAULT_SELECT_POSITION != 0) {
                selectedRunnable.run();
            }
        }

        @Override
        public void onChildViewDetachedFromWindow(@NonNull View view) {
        }
    };


    public ExtraTransparentView(@NonNull Context context, View contentView) {
        super(context);
        this.adapter = new InnerAdapter(context, contentView);
        layoutManager = new LinearLayoutManager(getContext(), HORIZONTAL, false) {
            @Override
            public boolean requestChildRectangleOnScreen(@NonNull RecyclerView parent, @NonNull View child, @NonNull Rect rect, boolean immediate, boolean focusedChildVisible) {
                return false;
            }
        };
        snapHelper.attachToRecyclerView(this);

        initViews();

    }

    private void initViews() {
        setLayoutManager(layoutManager);
        snapHelper.attachToRecyclerView(this);
        setAdapter(adapter);
        setOverScrollMode(OVER_SCROLL_NEVER);
    }

    public void registerSelectedRunnable(Runnable selectedRunnable) {
        this.selectedRunnable = selectedRunnable;
    }

    public static void initPosition() {
        DEFAULT_SELECT_POSITION = 1;
    }

    public void toSelectedPosition() {
        layoutManager.scrollToPosition(DEFAULT_SELECT_POSITION);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        addOnChildAttachStateChangeListener(onChildAttachStateChangeListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeOnChildAttachStateChangeListener(onChildAttachStateChangeListener);
    }

    private static class InnerAdapter extends RecyclerView.Adapter<InnerViewHolder> {
        private static final int TYPE_TRANSPARENT = 0;
        private static final int TYPE_CONTENT = 1;

        private static final int COUNT_TOTAL = 2;

        private final Context context;

        private final View contentView;

        private InnerAdapter(Context context, View contentView) {
            this.context = context;
            this.contentView = contentView;
        }

        @Override
        public int getItemViewType(int position) {
            return position == 0 ? TYPE_TRANSPARENT : TYPE_CONTENT;
        }

        @NonNull
        @Override
        public InnerViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            InnerViewHolder holder;
            View itemView;
            if (viewType == TYPE_CONTENT) {
                itemView = contentView;
            } else {
                itemView = new View(context);
            }
            itemView.setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            holder = new InnerViewHolder(itemView);
            return holder;
        }

        @Override
        public void onBindViewHolder(@NonNull InnerViewHolder holder, int position) {
        }

        @Override
        public int getItemCount() {
            return COUNT_TOTAL;
        }
    }

    public static class InnerViewHolder extends RecyclerView.ViewHolder {
        public InnerViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }

}
