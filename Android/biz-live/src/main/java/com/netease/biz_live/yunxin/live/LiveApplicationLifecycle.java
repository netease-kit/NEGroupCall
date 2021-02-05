package com.netease.biz_live.yunxin.live;

import android.app.Application;

import com.netease.neliveplayer.sdk.NELivePlayer;
import com.netease.neliveplayer.sdk.model.NESDKConfig;
import com.netease.yunxin.android.lib.historian.Historian;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.android.lib.network.common.NetworkConstant;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.nertc.demo.user.CommonUserNotify;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.AbsApplicationLifecycle;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.Map;

/**
 * Created by luc on 2020/11/12.
 */
public class LiveApplicationLifecycle extends AbsApplicationLifecycle {
    private static final String TAG = LiveApplicationLifecycle.class.getSimpleName();
    /**
     * 用户拉流数据采集
     */
    private final NELivePlayer.OnDataUploadListener dataUploadListener = new NELivePlayer.OnDataUploadListener() {
        @Override
        public boolean onDataUpload(String s, String s1) {
            Historian.e("Player===>", "stream url is " + s + ", detail data is " + s1);
            return true;
        }

        @Override
        public boolean onDocumentUpload(String s, Map<String, String> map, Map<String, String> map1) {
            return true;
        }
    };

    public LiveApplicationLifecycle() {
        super(LiveApplicationLifecycle.class.getCanonicalName());
    }

    @Override
    protected void onModuleCreate(Application application) {
        NESDKConfig config = new NESDKConfig();
        config.dataUploadListener = dataUploadListener;
        NELivePlayer.init(application.getApplicationContext(), config);

        // 统一处理 网络请求 token 失效的情况，登出并退至登录页面
        NetworkClient.getInstance().registerHandler(NetworkConstant.ERROR_RESPONSE_CODE_TOKEN_FAIL,
                (errorCode, msg, data) -> {
                    ToastUtils.showLong("登录已过期，请重新登录");
                    UserCenterService service = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
                    if (service.isLogin()) {
                        service.logout(new CommonUserNotify() {
                            @Override
                            public void onUserLogout(boolean success, int code) {
                                if (success) {
                                    service.launchLogin(application.getApplicationContext());
                                } else {
                                    Historian.e(TAG, "logout fail code is " + code);
                                }
                            }

                            @Override
                            public void onError(Throwable exception) {
                                super.onError(exception);
                                Historian.e(TAG, "logout error", exception);
                            }
                        });
                    } else {
                        service.tryLogin(new CommonUserNotify() {
                            @Override
                            public void onUserLogin(boolean success, int code) {
                                ToastUtils.showLong("请刷新");
                            }

                            @Override
                            public void onError(Throwable exception) {
                                service.launchLogin(application.getApplicationContext());
                            }
                        });
                    }

                });
    }
}

