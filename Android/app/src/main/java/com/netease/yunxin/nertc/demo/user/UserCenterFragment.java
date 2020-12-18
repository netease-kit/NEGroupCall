package com.netease.yunxin.nertc.demo.user;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseFragment;
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity;
import com.netease.yunxin.nertc.demo.basic.Constants;
import com.netease.yunxin.nertc.demo.feedback.FeedbackActivity;
import com.netease.yunxin.nertc.demo.picture.ImageLoader;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

public class UserCenterFragment extends BaseFragment {
    private final UserCenterService service = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    private final UserCenterServiceNotify notify = new CommonUserNotify() {
        @Override
        public void onUserInfoUpdate(UserModel model) {
            currentUser = model;
            initUser(rootView);
        }
    };
    private UserModel currentUser;
    private View rootView;

    public UserCenterFragment() {
        currentUser = service.getCurrentUser();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        service.registerLoginObserver(notify, true);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        service.registerLoginObserver(notify, false);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_user_center, container, false);
        initViews(rootView);
        paddingStatusBarHeight(rootView);
        return rootView;
    }

    private void initViews(View rootView) {
        initUser(rootView);

        View userInfoGroup = rootView.findViewById(R.id.rl_user_group);
        userInfoGroup.setOnClickListener(v -> startActivity(new Intent(getContext(), UserInfoActivity.class)));

        View feedback = rootView.findViewById(R.id.tv_feedback);
        feedback.setOnClickListener(v -> startActivity(new Intent(getContext(), FeedbackActivity.class)));


        View aboutApp = rootView.findViewById(R.id.tv_app_about);
        aboutApp.setOnClickListener(v -> startActivity(new Intent(getContext(), AppAboutActivity.class)));

        View freeTrail = rootView.findViewById(R.id.tv_free_trail);
        freeTrail.setOnClickListener(v -> CommonBrowseActivity.launch(getActivity(), "免费试用", Constants.URL_FREE_TRAIL));

    }

    private void initUser(View rootView) {
        if (currentUser == null) {
            if (getActivity() != null) {
                getActivity().finish();
            }
            return;
        }
        ImageView ivUserPortrait = rootView.findViewById(R.id.iv_user_portrait);
        ImageLoader.with(getContext()).circleLoad(currentUser.avatar, ivUserPortrait);

        TextView tvUserName = rootView.findViewById(R.id.tv_user_name);
        tvUserName.setText(currentUser.getNickname());
    }
}