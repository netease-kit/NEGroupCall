package com.netease.biz_live.yunxin.live.dialog;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.faceunity.FilterEnum;
import com.faceunity.OnFUControlListener;
import com.faceunity.entity.Filter;
import com.netease.biz_live.R;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.lib_utils.utils.ToastUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 滤镜控制dialog
 */
public class FilterDialog extends BaseBottomDialog {

    /**
     * 每个滤镜强度值。key: name, value: level
     */
    public static Map<String, Integer> sFilterLevel = new HashMap<>();

    /**
     * 滤镜默认强度 0.4
     */
    public static final int DEFAULT_FILTER_LEVEL = 40;

    /**
     * 默认滤镜 自然 2
     */
    public static Filter sFilter = FilterEnum.origin.create();

    private SeekBar seekBarSaturability;//饱和度的拖动条

    private RecyclerView rcvFilter;//滤镜

    private ImageView ivReset;//恢复

    //滤镜list
    private List<Filter> mFilters;

    // 默认选中第三个粉嫩
    private static int mFilterPositionSelect = 0;

    private OnFUControlListener mOnFUControlListener;

    private FilterRecyclerAdapter filterRecyclerAdapter;

    //恢复recyclerView 位置使用
    private static int lastOffset;
    private static int lastPosition;

    public void setOnFUControlListener(@NonNull OnFUControlListener onFUControlListener) {
        mOnFUControlListener = onFUControlListener;
        mOnFUControlListener.onFilterNameSelected(sFilter.getName());
        int level = getFilterLevel(sFilter.getName());
        setFilterLevel(sFilter.getName(), level);
    }

    @Override
    protected int getResourceLayout() {
        return R.layout.filter_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        super.initView(rootView);
        seekBarSaturability = rootView.findViewById(R.id.sb_saturability);
        rcvFilter = rootView.findViewById(R.id.rcv_filter);
        ivReset = rootView.findViewById(R.id.iv_reset);
    }

    @Override
    protected void initData() {
        super.initData();
        mFilters = FilterEnum.getFiltersByFilterType();
        filterRecyclerAdapter = new FilterRecyclerAdapter();
        rcvFilter.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rcvFilter.addItemDecoration(new DividerItemDecoration(getContext(), DividerItemDecoration.HORIZONTAL));
        rcvFilter.setAdapter(filterRecyclerAdapter);

        rcvFilter.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if(recyclerView.getLayoutManager() != null) {
                    getPositionAndOffset(recyclerView.getLayoutManager());
                }
            }
        });

        ivReset.setOnClickListener(v -> resetFilter());

        seekBarSaturability.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    setFilterLevel(sFilter.getName(), progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        seekToSeekBar(getFilterLevel(sFilter.getName()));
    }

    @Override
    public void onResume() {
        super.onResume();
        scrollToPosition();
    }

    /**
     * 记录RecyclerView当前位置
     */
    private void getPositionAndOffset(RecyclerView.LayoutManager layoutManager) {
        //获取可视的第一个view
        View leftView = layoutManager.getChildAt(0);
        if(leftView != null) {
            //获取与该view的顶部的偏移量
            lastOffset = leftView.getTop();
            //得到该View的数组位置
            lastPosition = layoutManager.getPosition(leftView);
        }
    }

    /**
     * 让RecyclerView滚动到指定位置
     */
    private void scrollToPosition() {
        if(rcvFilter.getLayoutManager() != null && lastPosition >= 0) {
            ((LinearLayoutManager) rcvFilter.getLayoutManager()).scrollToPositionWithOffset(lastPosition, lastOffset);
        }
    }

    /**
     * 设置滤镜leave 值
     *
     * @param filterName
     * @param faceBeautyFilterLevel
     */
    public void setFilterLevel(String filterName, int faceBeautyFilterLevel) {
        sFilterLevel.put(filterName, faceBeautyFilterLevel);
        if (mOnFUControlListener != null) {
            mOnFUControlListener.onFilterLevelSelected(faceBeautyFilterLevel / 100f);
        }
    }

    /**
     * 获取滤镜leave值
     *
     * @param filterName
     * @return
     */
    public int getFilterLevel(String filterName) {
        Integer level = sFilterLevel.get(filterName);
        if (level == null) {
            level = DEFAULT_FILTER_LEVEL;
            sFilterLevel.put(filterName, level);
        }
        return level;
    }

    private void resetFilter() {
        sFilter = FilterEnum.origin.create();
        mFilterPositionSelect = 0;
        if (filterRecyclerAdapter != null) {
            filterRecyclerAdapter.notifyDataSetChanged();
        }
        if (mOnFUControlListener != null) {
            mOnFUControlListener.onFilterNameSelected(sFilter.getName());
            setFilterLevel(sFilter.getName(), DEFAULT_FILTER_LEVEL);
            seekToSeekBar(DEFAULT_FILTER_LEVEL);
        }
        lastOffset = 0;
        lastPosition = 0;
        scrollToPosition();
    }

    /**
     * 设置seekBar值
     *
     * @param value
     */
    private void seekToSeekBar(int value) {
        seekBarSaturability.setVisibility(View.VISIBLE);
        seekBarSaturability.setProgress(value);
    }

    class FilterRecyclerAdapter extends RecyclerView.Adapter<FilterRecyclerAdapter.HomeRecyclerHolder> {

        @Override
        public FilterRecyclerAdapter.HomeRecyclerHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new FilterRecyclerAdapter.HomeRecyclerHolder(LayoutInflater.from(getContext()).inflate(R.layout.layout_beauty_control_recycler, parent, false));
        }

        @Override
        public void onBindViewHolder(FilterRecyclerAdapter.HomeRecyclerHolder holder, final int position) {
            final List<Filter> filters = mFilters;
            ImageLoader.with(getContext()).circleLoad(filters.get(position).getIconId(), holder.filterImg);
            holder.filterName.setText(filters.get(position).getNameId());
            if (mFilterPositionSelect == position) {
                holder.rlyCover.setVisibility(View.VISIBLE);
                holder.filterName.setTextColor(Color.parseColor("#337EFF"));
            } else {
                holder.rlyCover.setVisibility(View.GONE);
                holder.filterName.setTextColor(Color.parseColor("#222222"));
            }
            holder.itemView.setOnClickListener(v -> {
                mFilterPositionSelect = position;
                setFilterProgress();
                notifyDataSetChanged();
                if (mOnFUControlListener != null) {
                    sFilter = filters.get(mFilterPositionSelect);
                    mOnFUControlListener.onFilterNameSelected(sFilter.getName());
                    ToastUtils.showShort(sFilter.getNameId());
                }
            });
        }

        @Override
        public int getItemCount() {
            return mFilters.size();
        }

        void setFilterProgress() {
            if (mFilterPositionSelect > 0) {
                seekToSeekBar(getFilterLevel(mFilters.get(mFilterPositionSelect).getName()));
            }
        }

        class HomeRecyclerHolder extends RecyclerView.ViewHolder {

            ImageView filterImg;
            TextView filterName;
            RelativeLayout rlyCover;

            HomeRecyclerHolder(View itemView) {
                super(itemView);
                filterImg = itemView.findViewById(R.id.iv_icon);
                filterName = itemView.findViewById(R.id.tv_filter_name);
                rlyCover = itemView.findViewById(R.id.rly_cover);
            }
        }
    }
}
