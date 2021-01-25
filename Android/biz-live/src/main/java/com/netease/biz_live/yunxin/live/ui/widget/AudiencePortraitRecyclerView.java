package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.yunxin.android.lib.picture.ImageLoader;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by luc on 2020/11/23.
 */
public class AudiencePortraitRecyclerView extends RecyclerView {
    private static final int MAX_SHOWN_COUNT = 10;

    private LayoutManager layoutManager;
    private InnerAdapter adapter;

    public AudiencePortraitRecyclerView(@NonNull Context context) {
        super(context);
        init();
    }

    public AudiencePortraitRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AudiencePortraitRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }


    private void init() {
        adapter = new InnerAdapter(getContext());
        layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        setLayoutManager(layoutManager);
        setAdapter(adapter);
        setOverScrollMode(OVER_SCROLL_NEVER);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        setLayoutManager(null);
        setAdapter(null);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                getParent().requestDisallowInterceptTouchEvent(true);
                break;
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                getParent().requestDisallowInterceptTouchEvent(false);
                break;
        }
        return super.dispatchTouchEvent(ev);
    }

    public void addItem(AudienceInfo audience) {
        adapter.addItem(audience);
    }

    public void addItems(List<AudienceInfo> audienceList) {
        adapter.addItems(audienceList);
    }

    public void removeItem(AudienceInfo audience) {
        adapter.removeItem(audience);
    }

    public void updateAll(List<AudienceInfo> audienceList){
        adapter.clear();
        addItems(audienceList);
    }

    private static class InnerAdapter extends RecyclerView.Adapter<LiveBaseAdapter.LiveViewHolder> {
        private final List<AudienceInfo> dataSource = new ArrayList<>();
        private final Context context;

        public InnerAdapter(Context context) {
            this.context = context;
        }

        @NonNull
        @Override
        public LiveBaseAdapter.LiveViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new LiveBaseAdapter.LiveViewHolder(LayoutInflater.from(context)
                    .inflate(R.layout.view_item_audience_portrait_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull LiveBaseAdapter.LiveViewHolder holder, int position) {
            ImageView ivPortrait = holder.getView(R.id.iv_item_audience_portrait);
            AudienceInfo info = dataSource.get(position);
            ImageLoader.with(context).circleLoad(info.avatar, ivPortrait);
        }

        @Override
        public int getItemCount() {
            return Math.min(dataSource.size(), MAX_SHOWN_COUNT);
        }

        public void addItem(AudienceInfo audience) {
            dataSource.add(audience);
            notifyDataSetChanged();
        }

        public void addItems(List<AudienceInfo> audienceList) {
            if (audienceList == null) {
                return;
            }
            dataSource.addAll(audienceList);
            notifyDataSetChanged();
        }

        public void removeItem(AudienceInfo audience) {
            if (dataSource.remove(audience)) {
                notifyDataSetChanged();
            }
        }

        public void clear(){
            dataSource.clear();
        }

    }
}
