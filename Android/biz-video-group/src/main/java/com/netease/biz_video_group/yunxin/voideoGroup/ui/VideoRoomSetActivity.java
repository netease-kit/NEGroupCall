package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.app.Activity;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ActivityUtils;
import com.blankj.utilcode.util.LogUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RtcSetting;
import com.netease.biz_video_group.yunxin.voideoGroup.network.GroupBizControl;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.ParameterSettingView;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import io.reactivex.observers.ResourceSingleObserver;

public class VideoRoomSetActivity extends BaseActivity {

    private static final String LOG_TAG = VideoRoomSetActivity.class.getSimpleName();

    private EditText mEdtRoomName;

    private EditText mEdtUserName;

    private Button mBtnEnterRoom;
    private ImageView mIvSetting;

    private ParameterSettingView mCameraSetting;
    private ParameterSettingView mMicphoneSetting;
    private RtcSetting rtcSetting=new RtcSetting();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.room_set_layout);
        initView();
    }

    private void initView() {
        mEdtRoomName = findViewById(R.id.et_room_name);
        mEdtUserName = findViewById(R.id.et_user_name);
        mBtnEnterRoom = findViewById(R.id.btn_enter);
        mIvSetting= findViewById(R.id.iv_setting);
        mCameraSetting= findViewById(R.id.camera_setting);
        mMicphoneSetting= findViewById(R.id.micphone_setting);
        mCameraSetting.setTitle("入会时打开摄像头");
        mMicphoneSetting.setTitle("入会时打开麦克风");

        mBtnEnterRoom.setOnClickListener(v -> {
            mBtnEnterRoom.setEnabled(false);
            UserModel userModel = ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser();
            String nickname = !TextUtils.isEmpty(mEdtUserName.getText()) ? mEdtUserName.getText().toString() : getRandomNickname();

            String roomId = mEdtRoomName.getText() != null ? mEdtRoomName.getText().toString() : "";
            if (TextUtils.isEmpty(roomId)) {
                Toast.makeText(this, R.string.room_name_can_not_null, Toast.LENGTH_SHORT).show();
                mBtnEnterRoom.setEnabled(true);
                return;
            }
            requestStartMeetingRoom(roomId, nickname);
            hideSoftKeyboard();
        });

        findViewById(R.id.iv_back).setOnClickListener(v -> onBackPressed());

        mIvSetting.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showSettingDialog();
            }
        });

        mCameraSetting.setCheckedChangeListener(new ParameterSettingView.CheckedChangeListener() {
            @Override
            public void onCheckedChanged(boolean isChecked) {
                rtcSetting.enableCamera=isChecked;
            }
        });
        mMicphoneSetting.setCheckedChangeListener(new ParameterSettingView.CheckedChangeListener() {
            @Override
            public void onCheckedChanged(boolean isChecked) {
                rtcSetting.enableMicphone=isChecked;
            }
        });
    }

    private void showSettingDialog() {
        SettingDialog settingDialog=new SettingDialog();
        settingDialog.show(getSupportFragmentManager(),getClass().getSimpleName());
        settingDialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                rtcSetting = settingDialog.getRtcSetting();
            }
        });
    }

    private void hideSoftKeyboard() {
        if (getCurrentFocus() == null) return;
        InputMethodManager imm = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
        if (imm == null) return;
        imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
    }

    private void requestStartMeetingRoom(String roomId, String nickName) {
        GroupBizControl.joinRoom(roomId, BuildConfig.APP_KEY, nickName).subscribe(new ResourceSingleObserver<BaseResponse<RoomInfo>>() {
            @Override
            public void onSuccess(BaseResponse<RoomInfo> response) {
                if (ActivityUtils.isActivityExistsInStack(VideoMeetingRoomActivity.class)){
                    return;
                }
                if (response.code == 200) {
                    Bundle bundle=new Bundle();
                    bundle.putSerializable(VideoMeetingRoomActivity.TRANS_ROOM_INFO,response.data);
                    bundle.putString(VideoMeetingRoomActivity.TRANS_ROOM_NICKNAME,nickName);
                    bundle.putSerializable(VideoMeetingRoomActivity.TRANS_RTC_PARAMS,rtcSetting);
                    VideoMeetingRoomActivity.startActivity(VideoRoomSetActivity.this, bundle);
                    ToastUtils.showShort("本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人");
                } else if (!TextUtils.isEmpty(response.msg)) {
                    ToastUtils.showShort(response.msg);
                }
                mBtnEnterRoom.setEnabled(true);
            }

            @Override
            public void onError(Throwable e) {
                Log.e(LOG_TAG, "request room info failed", e);
                mBtnEnterRoom.setEnabled(true);
            }
        });
    }

    private String getRandomNickname() {
        return "用户" + (int) ((Math.random() * 9 + 1) * 100000);
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        mBtnEnterRoom.setEnabled(true);
    }
}
