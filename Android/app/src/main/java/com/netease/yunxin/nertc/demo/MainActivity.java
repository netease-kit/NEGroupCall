package com.netease.yunxin.nertc.demo;

import android.os.Bundle;

import androidx.viewpager.widget.ViewPager;

import com.google.android.material.tabs.TabLayout;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.pager.MainPagerAdapter;

public class MainActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ViewPager mainPager = findViewById(R.id.vp_fragment);
        mainPager.setAdapter(new MainPagerAdapter(getSupportFragmentManager()));
        mainPager.setOffscreenPageLimit(2);

        TabLayout tabLayout = findViewById(R.id.tl_tab);
        tabLayout.setupWithViewPager(mainPager);
        tabLayout.removeAllTabs();
        tabLayout.setTabGravity(TabLayout.GRAVITY_CENTER);
        tabLayout.setSelectedTabIndicator(null);
        tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.view_item_home_tab_app), 0, true);
        tabLayout.addTab(tabLayout.newTab().setCustomView(R.layout.view_item_home_tab_user), 1, false);

        mainPager.addOnPageChangeListener(new TabLayout.TabLayoutOnPageChangeListener(tabLayout) {
            @Override
            public void onPageSelected(int position) {
                TabLayout.Tab item = tabLayout.getTabAt(position);
                if (item != null) {
                    item.select();
                }
                super.onPageSelected(position);
            }
        });

    }

    @Override
    protected void onResume() {
        super.onResume();
//        CallService.start(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
//        CallService.stop(this);
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }
}