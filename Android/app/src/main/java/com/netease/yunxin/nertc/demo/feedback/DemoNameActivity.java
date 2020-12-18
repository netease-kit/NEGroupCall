package com.netease.yunxin.nertc.demo.feedback;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;

import java.util.Arrays;

/**
 * demo 名称选择 页面
 */
public class DemoNameActivity extends BaseActivity {
    public static final String KEY_PARAM_DEMO_NAME = "key_param_demo_name";
    private DemoNameAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_demo_name);
        paddingStatusBarHeight(findViewById(R.id.cl_root));

        initViews();
    }

    private void initViews() {
        View close = findViewById(R.id.iv_close);
        close.setOnClickListener(v -> finish());

        RecyclerView demoNameList = findViewById(R.id.rv_demo_name_list);
        demoNameList.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        String demoName = getIntent().getStringExtra(KEY_PARAM_DEMO_NAME);
        adapter = new DemoNameAdapter(this, demoName, Arrays.asList(
                "一对一音视频通话",
                "多人视频通话"
        ));
        demoNameList.setAdapter(adapter);
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }

    public static void launchForResult(Activity activity, int requestCode, String demoName) {
        Intent intent = new Intent(activity, DemoNameActivity.class);
        intent.putExtra(KEY_PARAM_DEMO_NAME, demoName);
        activity.startActivityForResult(intent, requestCode);
    }

    @Override
    public void finish() {
        Intent intent = new Intent();
        intent.putExtra(KEY_PARAM_DEMO_NAME, adapter.getFocusedItem());
        setResult(RESULT_OK, intent);
        super.finish();
    }
}