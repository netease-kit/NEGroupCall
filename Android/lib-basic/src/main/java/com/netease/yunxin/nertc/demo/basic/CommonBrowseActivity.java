package com.netease.yunxin.nertc.demo.basic;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class CommonBrowseActivity extends BaseActivity {
    private static final String PARAM_KEY_TITLE = "param_key_title";
    private static final String PARAM_KEY_URL = "param_key_url";
    private static final String SCHEME_HTTP = "http";
    private static final String SCHEME_HTTPS = "https";

    private String title;
    private String url;

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_common_browse);
        title = getIntent().getStringExtra(PARAM_KEY_TITLE);
        url = getIntent().getStringExtra(PARAM_KEY_URL);
        initViews();
        paddingStatusBarHeight(R.id.rl_root);
    }

    private void initViews() {
        View close = findViewById(R.id.iv_close);
        close.setOnClickListener(v -> finish());

        TextView tvTitle = findViewById(R.id.tv_title);
        tvTitle.setText(title);

        webView = initWebView();
        ViewGroup webViewGroup = findViewById(R.id.rl_root);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        layoutParams.addRule(RelativeLayout.BELOW, R.id.title_divide);
        webView.setLayoutParams(layoutParams);
        webViewGroup.addView(webView);
        webView.loadUrl(url);
    }

    private WebView initWebView() {
        WebView webView = new WebView(getApplicationContext());
        webView.setOnLongClickListener(v -> true);

        WebViewClient client = new WebViewClient() {

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Uri uri = Uri.parse(url);
                String scheme = uri.getScheme();
                boolean result = TextUtils.isEmpty(scheme) || (!scheme.equals(SCHEME_HTTP) && !scheme.equals(SCHEME_HTTPS));
                if (result) {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(uri);
                    intent.addCategory(Intent.CATEGORY_DEFAULT);
                    if (intent.resolveActivity(getPackageManager()) != null) {
                        startActivity(intent);
                    } else {
                        result = false;
                    }

                }
                return result;
            }
        };
        webView.setWebViewClient(client);
        webView.setWebChromeClient(new WebChromeClient());

        webView.getSettings().setUseWideViewPort(true);
        webView.getSettings().setLoadWithOverviewMode(true);

        webView.getSettings().setSupportZoom(true);
        webView.getSettings().setBuiltInZoomControls(true);
        webView.getSettings().setDisplayZoomControls(false);

        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setBlockNetworkImage(false);

        webView.getSettings().setJavaScriptEnabled(true);
        return webView;
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
            return;
        }
        super.onBackPressed();

    }

    @Override
    protected boolean ignoredLoginEvent() {
        return true;
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(true)
                .statusBarColor(R.color.color_ffffff)
                .build();
    }

    public static void launch(Context context, String title, String url) {
        Intent intent = new Intent(context, CommonBrowseActivity.class);
        if (!(context instanceof Activity)) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        intent.putExtra(PARAM_KEY_TITLE, title);
        intent.putExtra(PARAM_KEY_URL, url);

        context.startActivity(intent);
    }
}