package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.network.GroupBizControl;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.network.BaseResponse;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import io.reactivex.observers.ResourceSingleObserver;

public class VideoRoomSetActivity extends BaseActivity {

    private static final String LOG_TAG = VideoRoomSetActivity.class.getSimpleName();

    private EditText mEdtRoomName;

    private EditText mEdtUserName;

    private Button mBtnEnterRoom;

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
    }

    private void hideSoftKeyboard() {
        if (getCurrentFocus() == null) return;
        InputMethodManager imm = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
        if (imm == null) return;
        imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
    }

    private void requestStartMeetingRoom(String roomId, String nickName) {
        GroupBizControl.joinRoom(roomId, NativeConfig.getAppKey(), nickName).subscribe(new ResourceSingleObserver<BaseResponse<RoomInfo>>() {
            @Override
            public void onSuccess(BaseResponse<RoomInfo> response) {
                if (response.code == 200) {
                    VideoMeetingRoomActivity.startActivity(VideoRoomSetActivity.this, response.data, nickName);
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
}
