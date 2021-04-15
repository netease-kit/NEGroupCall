package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;

import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 * @author sunkeding
 * 多人通话演讲者模式控件
 */
public class VideoGroupSpeakerView extends FrameLayout {
    private RecyclerView rv;
    private SpeakerAdapter speakerAdapter;
    private final static int DP10 = SizeUtils.dp2px(10);
    public VideoGroupSpeakerView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public VideoGroupSpeakerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public VideoGroupSpeakerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        inflate(context, R.layout.video_group_speaker_layout, this);
        rv = findViewById(R.id.rv);
        closeDefaultAnimator();
        rv.setLayoutManager(new LinearLayoutManager(context,RecyclerView.HORIZONTAL,false));
        speakerAdapter = new SpeakerAdapter(context);
        rv.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                int position=parent.getChildAdapterPosition(view);
                if (position==0){
                    outRect.left=0;
                }else {
                    outRect.left=DP10;
                }

            }
        });
        rv.setAdapter(speakerAdapter);
        speakerAdapter.setOnItemClickListener(userStatusInfo -> {
            if (onSpeakerItemClickListener !=null){
                TempLogUtil.log("点击了小窗口用户"+userStatusInfo.nickname);
                onSpeakerItemClickListener.onSpeakerItemClick(userStatusInfo);
            }
        });
    }

    public void addUser(UserStatusInfo userStatusInfo){
        speakerAdapter.addUser(userStatusInfo);
    }
    public void deleteUser(long userId){
        speakerAdapter.deleteUser(userId);
    }

    public void enableMicphone(boolean enableMicphone, long userId, boolean self) {
        speakerAdapter.enableMicphone(enableMicphone,userId,self);
    }

    public SpeakerAdapter getSpeakerAdapter() {
        return speakerAdapter;
    }

    public void enableVideo(long userId, boolean self, boolean enable) {
        speakerAdapter.enableVideo(userId,self,enable);
    }

    public void clear() {
        speakerAdapter.list.clear();
        speakerAdapter.notifyDataSetChanged();
    }
    /**
     * 关闭默认局部刷新动画
     */
    public void closeDefaultAnimator() {
        rv.getItemAnimator().setAddDuration(0);
        rv.getItemAnimator().setChangeDuration(0);
        rv.getItemAnimator().setMoveDuration(0);
        rv.getItemAnimator().setRemoveDuration(0);
        ((SimpleItemAnimator) rv.getItemAnimator()).setSupportsChangeAnimations(false);
    }

    public void updateNickName(long uid, String nickname) {
        speakerAdapter.updateNickName(uid, nickname);
    }

    public static class SpeakerAdapter extends RecyclerView.Adapter {
        public ArrayList<UserStatusInfo> list = new ArrayList<>();
        private Context context;

        public SpeakerAdapter(Context context) {
            this.context = context;
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SpeakerHolder(LayoutInflater.from(context).inflate(R.layout.video_group_listitem_speaker, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
            UserStatusInfo userStatusInfo = list.get(position);
            SpeakerHolder speakerHolder = (SpeakerHolder) holder;
            speakerHolder.squareVideoCallView.setData(userStatusInfo);
            speakerHolder.squareVideoCallView.setOnItemClickListener(userStatusInfo1 -> {
               if (onItemClickListener!=null){
                   onItemClickListener.onItemClick(userStatusInfo1);
               }
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        private void addUser(UserStatusInfo userStatusInfo) {
            list.add(userStatusInfo);
            //按照加入时间戳排序，越早进入的排在越前
            Collections.sort(list, (o1, o2) -> {
                if (o1.joinRoomTimeStamp>o2.joinRoomTimeStamp){
                    return 1;
                }else if (o1.joinRoomTimeStamp==o2.joinRoomTimeStamp){
                    return 0;
                }
                return -1;
            });
            UserStatusInfo self=null;
            ArrayList<UserStatusInfo> tempList=new ArrayList<>();
            int selfIndex=-1;
            for (int i = 0; i < list.size(); i++) {
                UserStatusInfo info = list.get(i);
                if (info.isSelf){
                    self=info;
                    selfIndex=i;
                }else {
                    tempList.add(info);
                }
            }
            if (selfIndex!=0){
                list.clear();
                list.addAll(tempList);
                if (self!=null){
                    //始终把自己排到首位
                    list.add(0,self);
                }
                notifyDataSetChanged();
            }else {
                notifyItemInserted(list.size()-1);
            }
        }

        private void deleteUser(long userId) {
            int deletePosition=-1;
            for (int i = 0; i < list.size(); i++) {
                if (list.get(i).userId==userId){
                    deletePosition=i;
                    break;
                }
            }
            if (deletePosition>=0){
                list.remove(deletePosition);
            }
            notifyDataSetChanged();
        }
        public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
            this.onItemClickListener = onItemClickListener;
        }

        public OnItemClickListener onItemClickListener;

        /**
         * 打开(关闭)摄像头
         *
         * @param uid
         * @param self
         * @param enable
         */
        public void enableVideo(long uid, boolean self, boolean enable) {
            if (list != null && (self || uid != 0)) {
                for (int i = 0; i < list.size(); i++) {
                    UserStatusInfo userInfo = list.get(i);
                    if (userInfo!=null){
                        if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                            userInfo.enableVideo = enable;
                            notifyItemChanged(i,userInfo);
                            return;
                        }
                    }
                }
            }
        }

        public void enableMicphone(boolean enableMicphone, long uid, boolean self) {
            if (list != null && (self || uid != 0)) {
                for (int i = 0; i < list.size(); i++) {
                    UserStatusInfo userInfo = list.get(i);
                    if (userInfo!=null){
                        if ((self && userInfo.isSelf) || (!self && uid == userInfo.userId)) {
                            list.get(i).enableMicphone = enableMicphone;
                            notifyItemChanged(i, userInfo);
                            return;
                        }
                    }
                }
            }
        }

        public void updateNickName(long uid, String nickName) {
            if (list != null && uid != 0) {
                for (int i = 0; i < list.size(); i++) {
                    UserStatusInfo userInfo = list.get(i);
                    if (userInfo!=null){
                        if (uid == userInfo.userId) {
                            list.get(i).nickname = nickName;
                            notifyItemChanged(i, userInfo);
                            return;
                        }
                    }
                }
            }
        }

        public interface OnItemClickListener{
            void onItemClick(UserStatusInfo userStatusInfo);
        }
    }

    static class SpeakerHolder extends RecyclerView.ViewHolder {
        public SquareVideoCallItemView squareVideoCallView;

        public SpeakerHolder(@NonNull View itemView) {
            super(itemView);
            squareVideoCallView = itemView.findViewById(R.id.square_video_call_view);
        }
    }

    public void setOnSpeakerItemClickListener(OnSpeakerItemClickListener onSpeakerItemClickListener) {
        this.onSpeakerItemClickListener = onSpeakerItemClickListener;
    }

    public OnSpeakerItemClickListener onSpeakerItemClickListener;
    public interface OnSpeakerItemClickListener {
        /**
         * @param userStatusInfo 演讲者模式控件被点击的用户信息
         */
        void onSpeakerItemClick(UserStatusInfo userStatusInfo);
    }
}
