package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewConfiguration;

import com.netease.biz_live.yunxin.live.audience.adapter.ChatMsgListAdapter;

import java.util.Collections;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by luc on 2020/11/11.
 */
public class ChatRoomMsgRecyclerView extends RecyclerView {
    private ChatMsgListAdapter chatMsgListAdapter;
    private LayoutManager layoutManager;
    private boolean isTouching = false;
    private float lastX;
    private float lastY;
    private int touchSlop;

    public ChatRoomMsgRecyclerView(@NonNull Context context) {
        super(context);
        init();
    }

    public ChatRoomMsgRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ChatRoomMsgRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        chatMsgListAdapter = new ChatMsgListAdapter(getContext(), Collections.emptyList());
        touchSlop = ViewConfiguration.get(getContext()).getScaledTouchSlop();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        setLayoutManager(layoutManager);
        setAdapter(chatMsgListAdapter);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        setLayoutManager(null);
        setAdapter(null);
    }

    public void appendItem(CharSequence sequence) {
        chatMsgListAdapter.appendItem(sequence);
        toLatestMsg();
    }

    public void appendItems(List<CharSequence> sequenceList) {
        chatMsgListAdapter.appendItems(sequenceList);
        toLatestMsg();
    }

    public void toLatestMsg() {
        if (!isTouching) {
            layoutManager.scrollToPosition(chatMsgListAdapter.getItemCount() - 1);
        }
    }

    public void clearAllInfo() {
        if (chatMsgListAdapter != null) {
            chatMsgListAdapter.clearAll();
        }
    }

    /**
     * 滑动冲突处理，目前并不完善，横向滑动出现丢失，落点坐标未更新
     */
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                lastX = ev.getX();
                lastY = ev.getY();
                isTouching = true;
                getParent().requestDisallowInterceptTouchEvent(true);
                break;
            case MotionEvent.ACTION_MOVE:
                float currentX = ev.getX();
                float currentY = ev.getY();
                float resultX = currentX - lastX;
                float resultY = currentY - lastY;
                getParent().requestDisallowInterceptTouchEvent(
                        !(Math.abs(resultX) > touchSlop) || !(Math.abs(resultY) < touchSlop));
                break;
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                isTouching = false;
                getParent().requestDisallowInterceptTouchEvent(false);
                break;
        }
        return super.dispatchTouchEvent(ev);
    }
}
