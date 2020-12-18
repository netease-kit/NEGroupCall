package com.netease.yunxin.nertc.demo.app;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.lib_video_group.yunxin.video_group.VideoGroupService;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseFragment;
import com.netease.yunxin.nertc.demo.list.FunctionAdapter;
import com.netease.yunxin.nertc.demo.list.FunctionItem;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.Arrays;

public class AppEntranceFragment extends BaseFragment {
    public AppEntranceFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private void initView(View rootView) {
        // 功能列表初始化
        RecyclerView rvFunctionList = rootView.findViewById(R.id.rv_function_list);
        rvFunctionList.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        rvFunctionList.setAdapter(new FunctionAdapter(getContext(), Arrays.asList(
                new FunctionItem(FunctionAdapter.TYPE_VIEW_TITLE, "通话", R.drawable.icon_title_basic),
                // 每个业务功能入口均在此处生成 item
//                new FunctionItem(R.drawable.video_call_icon, getString(R.string.video_call),
//                        () -> {
//                            UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(
//                                    UserCenterService.class);
//                            if (userCenterService.isLogin()) {
//                                NERTCSelectCallUserActivity.startSelectUser(getContext());
//                            } else {
//                                userCenterService.launchLogin(getContext());
//                            }
//                        })
                new FunctionItem(R.drawable.icon_group_call, "多人视频通话",
                        () -> {
                            VideoGroupService videoGroupService = ModuleServiceMgr.getInstance().getService(VideoGroupService.class);
                            videoGroupService.startVideoGroup(getContext());
                        })
//                new FunctionItem(FunctionAdapter.TYPE_VIEW_TITLE, "Live", R.drawable.icon_title_live),
//                new FunctionItem(R.drawable.icon_pk_live, "PK 直播",
//                        () -> {
//                            LiveService liveService = ModuleServiceMgr.getInstance().getService(LiveService.class);
//                            liveService.launchPkLive(getContext());
//                        })
        )));
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_app_entrance, container, false);
        initView(rootView);
        paddingStatusBarHeight(rootView);
        return rootView;
    }
}