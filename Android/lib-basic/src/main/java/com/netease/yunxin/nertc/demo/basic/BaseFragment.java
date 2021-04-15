package com.netease.yunxin.nertc.demo.basic;

import android.view.View;

import androidx.fragment.app.Fragment;

/**
 * Created by luc on 2020/11/13.
 */
public class BaseFragment extends Fragment {

    protected final void paddingStatusBarHeight(View view) {
        StatusBarConfig.paddingStatusBarHeight(getActivity(), view);
    }
}
