package com.netease.yunxin.nertc.demo.pager;

import android.util.SparseArray;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import com.netease.yunxin.nertc.demo.app.AppEntranceFragment;
import com.netease.yunxin.nertc.demo.user.UserCenterFragment;

public class MainPagerAdapter extends FragmentPagerAdapter {

  public MainPagerAdapter(@NonNull FragmentManager fm) {
    super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
  }

  @NonNull @Override public Fragment getItem(int position) {
    return getFragmentByPosition(position);
  }

  @Override public int getCount() {
    return 2;
  }

  /**
   * fragment 缓存
   */
  private final SparseArray<Fragment> fragmentCache = new SparseArray<>(2);

  /**
   * 获取对应位置 fragment
   *
   * @param position 位置
   * @return fragment
   */
  private Fragment getFragmentByPosition(int position) {
    Fragment fragment = fragmentCache.get(position);
    if (fragment != null) {
      return fragment;
    }
    if (position == 0) {
      fragment = new AppEntranceFragment();
    } else if (position == 1) {
      fragment = new UserCenterFragment();
    }
    fragmentCache.put(position, fragment);
    return fragment;
  }
}
