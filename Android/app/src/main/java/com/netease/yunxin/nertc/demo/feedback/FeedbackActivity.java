package com.netease.yunxin.nertc.demo.feedback;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.netease.yunxin.lib_utils.utils.ToastUtils;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionItem;
import com.netease.yunxin.nertc.demo.feedback.network.FeedbackServiceImpl;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

public class FeedbackActivity extends BaseActivity {
    private static final int CODE_REQUEST_FOR_QUESTION = 1000;
    private static final int CODE_REQUEST_FOR_NAME = 1001;
    private final UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    private final UserModel userModel = userCenterService.getCurrentUser();
    private final ArrayList<QuestionItem> questionTypeList = new ArrayList<>();

    private TextView tvDemoName;
    private TextView tvQuestionType;
    private EditText etQuestionDesc;
    private View btnCommit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_feed_back);
        paddingStatusBarHeight(findViewById(R.id.cl_root));
        initViews();
    }

    private void initViews() {
        View close = findViewById(R.id.iv_close);
        close.setOnClickListener(v -> finish());

        tvQuestionType = findViewById(R.id.tv_question_type);
        tvQuestionType.setOnClickListener(v ->
                QuestionTypeActivity.launchForResult(FeedbackActivity.this, CODE_REQUEST_FOR_QUESTION, questionTypeList));
        tvDemoName = findViewById(R.id.tv_demo_name);
        tvDemoName.setOnClickListener(v -> DemoNameActivity.launchForResult(FeedbackActivity.this, CODE_REQUEST_FOR_NAME, tvDemoName.getText().toString()));

        etQuestionDesc = findViewById(R.id.et_question_desc);
        etQuestionDesc.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                checkAndUpdateCommitBtn();
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        btnCommit = findViewById(R.id.tv_commit);
        btnCommit.setOnClickListener(v ->
                FeedbackServiceImpl.demoSuggest(userModel, tvDemoName.getText().toString(),
                        etQuestionDesc.getText().toString(),
                        formatItemsForIntArray(questionTypeList))
                        .subscribe(new ResourceSingleObserver<Boolean>() {
                            @Override
                            public void onSuccess(@NonNull Boolean aBoolean) {
                                if (aBoolean) {
                                    ToastUtils.showShort("反馈成功");
                                    finish();
                                } else {
                                    ToastUtils.showShort("反馈失败");
                                }
                            }

                            @Override
                            public void onError(@NonNull Throwable e) {
                                ToastUtils.showShort("反馈失败");
                            }
                        }));
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        if (requestCode == CODE_REQUEST_FOR_QUESTION && !onQuestionType(resultCode, data)) {
            return;
        }

        if (requestCode == CODE_REQUEST_FOR_NAME && !onDemoName(resultCode, data)) {
            return;
        }

        checkAndUpdateCommitBtn();
    }

    /**
     * 接收问题类型
     *
     * @return true 成功处理，false 处理失败
     */
    private boolean onQuestionType(int resultCode, Intent data) {
        if (resultCode != RESULT_OK || data == null) {
            return false;
        }
        questionTypeList.clear();
        @SuppressWarnings("unchecked")
        ArrayList<QuestionItem> result =
                (ArrayList<QuestionItem>) data.getSerializableExtra(QuestionTypeActivity.KEY_PARAM_QUESTION_TYPE_LIST);
        if (result == null || result.isEmpty()) {
            tvQuestionType.setText("");
            checkAndUpdateCommitBtn();
            return false;
        }
        questionTypeList.addAll(result);
        tvQuestionType.setText(formatItemsForString(questionTypeList));
        return true;
    }

    /**
     * 接收demo 名称
     *
     * @return true 成功处理，false 处理失败
     */
    private boolean onDemoName(int resultCode, Intent data) {
        if (resultCode != RESULT_OK || data == null) {
            return false;
        }

        String demoName = data.getStringExtra(DemoNameActivity.KEY_PARAM_DEMO_NAME);

        if (TextUtils.isEmpty(demoName)) {
            tvDemoName.setText("");
            checkAndUpdateCommitBtn();
            return false;
        }
        tvDemoName.setText(demoName);
        return true;
    }

    private void checkAndUpdateCommitBtn() {
        boolean disable = TextUtils.isEmpty(tvQuestionType.getText())
                || TextUtils.isEmpty(etQuestionDesc.getText().toString())
                || TextUtils.isEmpty(tvDemoName.getText().toString());
        btnCommit.setEnabled(!disable);
    }

    private String formatItemsForString(List<QuestionItem> items) {
        StringBuilder builder = new StringBuilder();
        for (QuestionItem item : items) {
            builder.append(item.name);
            builder.append("，");
        }
        String questionType = builder.toString();
        return questionType.substring(0, questionType.length() - 1);
    }

    private int[] formatItemsForIntArray(List<QuestionItem> items) {
        int[] typeArray = new int[items.size()];
        int i = 0;
        for (QuestionItem item : items) {
            typeArray[i++] = item.id;
        }
        return typeArray;
    }
}