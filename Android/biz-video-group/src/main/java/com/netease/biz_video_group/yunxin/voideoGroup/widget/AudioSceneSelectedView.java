package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.AudioConstant;

import java.util.ArrayList;

/**
 * @author sunkeding
 * 音频场景选择器
 */
public class AudioSceneSelectedView extends RecyclerView {
    private SceneAdapter sceneAdapter;
    private ArrayList<SceneBean> list = new ArrayList<>();
    private AudioSceneSelectedListener audioSceneSelectedListener;
    private final static int dp24 = SizeUtils.dp2px(24);

    public void setAudioSceneSelectedListener(AudioSceneSelectedListener audioSceneSelectedListener) {
        this.audioSceneSelectedListener = audioSceneSelectedListener;
    }

    public interface AudioSceneSelectedListener {
        void audioSceneSelected(String scene);
    }

    public AudioSceneSelectedView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public AudioSceneSelectedView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public AudioSceneSelectedView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        list.add(new SceneBean(AudioConstant.AudioScene.MUSIC));
        list.add(new SceneBean(AudioConstant.AudioScene.SPEECH));
        setLayoutManager(new LinearLayoutManager(context, HORIZONTAL, false));
        addItemDecoration(new ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull State state) {
                super.getItemOffsets(outRect, view, parent, state);
                int position = parent.getChildAdapterPosition(view);
                if (position == 1) {
                    outRect.left = dp24;
                }else {
                    outRect.left = 0;
                }
            }
        });
        sceneAdapter = new SceneAdapter(context, list);
        setAdapter(sceneAdapter);
        sceneAdapter.notifyDataSetChanged();
        sceneAdapter.setSceneSelectedListener(scene -> {
            if (audioSceneSelectedListener != null) {
                audioSceneSelectedListener.audioSceneSelected(scene);
            }
        });
    }

    static class SceneAdapter extends RecyclerView.Adapter<ViewHolder> {
        private Context context;
        private ArrayList<SceneBean> list;
        private int selectedPosition=0;
        public SceneAdapter(Context context, ArrayList<SceneBean> list) {
            this.context = context;
            this.list = list;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SceneHolder(LayoutInflater.from(context).inflate(R.layout.video_group_listitem_scene_selected, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            SceneHolder sceneHolder = (SceneHolder) holder;
            sceneHolder.tv.setText(list.get(position).title);
            if (selectedPosition==position) {
                sceneHolder.iv.setImageResource(R.drawable.video_group_icon_tick);
            } else {
                sceneHolder.iv.setImageResource(R.drawable.video_group_icon_circle);
            }
            sceneHolder.itemView.setOnClickListener(v -> {
                selectedPosition=position;
                if (sceneSelectedListener != null) {
                    sceneSelectedListener.sceneSelected(list.get(position).title);
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        public void setSceneSelectedListener(SceneSelectedListener sceneSelectedListener) {
            this.sceneSelectedListener = sceneSelectedListener;
        }

        private SceneSelectedListener sceneSelectedListener;

        public interface SceneSelectedListener {
            void sceneSelected(String scene);
        }
    }

    static class SceneHolder extends ViewHolder {
        ImageView iv;
        TextView tv;

        public SceneHolder(@NonNull View itemView) {
            super(itemView);
            iv = itemView.findViewById(R.id.iv);
            tv = itemView.findViewById(R.id.tv);
        }
    }

    static class SceneBean {
        public SceneBean(String title) {
            this.title = title;
        }

        public String title;
    }


}
