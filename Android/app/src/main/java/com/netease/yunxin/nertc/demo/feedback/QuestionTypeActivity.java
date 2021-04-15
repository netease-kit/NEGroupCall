package com.netease.yunxin.nertc.demo.feedback;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ExpandableListView;
import android.widget.ImageView;

import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionGroup;
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionItem;
import com.netease.yunxin.nertc.demo.feedback.expand.QuestionTypeAdapter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 问题类型选择页面
 */
public class QuestionTypeActivity extends BaseActivity {
    public static final String KEY_PARAM_QUESTION_TYPE_LIST = "key_param_question_type_list";
    private final ArrayList<QuestionItem> questionTypeList = new ArrayList<>();

    private final List<QuestionGroup> QUESTION_GROUPS = Arrays.asList(
            new QuestionGroup("音频问题", Arrays.asList(
                    new QuestionItem(102, "杂音、机械音"),
                    new QuestionItem(101, "声音有延迟"),
                    new QuestionItem(103, "声音断断续续")
            )),
            new QuestionGroup("视频问题", Arrays.asList(
                    new QuestionItem(106, "画面模糊"),
                    new QuestionItem(105, "画面卡顿"),
                    new QuestionItem(107, "音画不同步")
            ))
    );

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_question_type);
        paddingStatusBarHeight(findViewById(R.id.cl_root));

        @SuppressWarnings("unchecked") ArrayList<QuestionItem> initList = (ArrayList<QuestionItem>) getIntent().getSerializableExtra(KEY_PARAM_QUESTION_TYPE_LIST);
        if (initList != null) {
            questionTypeList.clear();
            questionTypeList.addAll(initList);
        }

        initViews(initList);
    }

    private void initViews(List<QuestionItem> initList) {
        ImageView ivClose = findViewById(R.id.iv_close);
        ivClose.setOnClickListener(v -> finish());

        ExpandableListView rvQuestionList = findViewById(R.id.rv_question_list);

        QuestionTypeAdapter adapter = new QuestionTypeAdapter(this, QUESTION_GROUPS, initList);
        rvQuestionList.setAdapter(adapter);
        rvQuestionList.setOnChildClickListener((parent, v, groupPosition, childPosition, id) -> {
            View itemView = v.findViewById(R.id.iv_chosen_icon);
            QuestionItem item = QUESTION_GROUPS.get(groupPosition).items.get(childPosition);
            if (questionTypeList.contains(item)) {
                questionTypeList.remove(item);
                itemView.setVisibility(View.GONE);
            } else {
                questionTypeList.add(item);
                itemView.setVisibility(View.VISIBLE);
            }
            adapter.updateSelectedItem(item);
            return true;
        });


        QuestionItem interactiveItem = new QuestionItem(109, "交互体验");
        View tvInteractive = findViewById(R.id.tv_interactive_question);
        View ivInteractive = findViewById(R.id.iv_interactive_question);
        if (questionTypeList.contains(interactiveItem)) {
            ivInteractive.setVisibility(View.VISIBLE);
        }
        tvInteractive.setOnClickListener(v -> {
            if (questionTypeList.contains(interactiveItem)) {
                questionTypeList.remove(interactiveItem);
                ivInteractive.setVisibility(View.GONE);
            } else {
                questionTypeList.add(interactiveItem);
                ivInteractive.setVisibility(View.VISIBLE);
            }
        });

        QuestionItem otherItem = new QuestionItem(99, "其他问题");
        View tvOther = findViewById(R.id.tv_other_question);
        View ivOther = findViewById(R.id.iv_other_question);
        if (questionTypeList.contains(otherItem)) {
            ivOther.setVisibility(View.VISIBLE);
        }
        tvOther.setOnClickListener(v -> {
            if (questionTypeList.contains(otherItem)) {
                questionTypeList.remove(otherItem);
                ivOther.setVisibility(View.GONE);
            } else {
                questionTypeList.add(otherItem);
                ivOther.setVisibility(View.VISIBLE);
            }
        });
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }

    public static void launchForResult(Activity activity, int requestCode, ArrayList<QuestionItem> questionList) {
        Intent intent = new Intent(activity, QuestionTypeActivity.class);
        intent.putExtra(KEY_PARAM_QUESTION_TYPE_LIST, questionList);
        activity.startActivityForResult(intent, requestCode);
    }

    @Override
    public void finish() {
        Intent intent = new Intent();
        intent.putExtra(KEY_PARAM_QUESTION_TYPE_LIST, questionTypeList);
        setResult(RESULT_OK, intent);
        super.finish();
    }
}