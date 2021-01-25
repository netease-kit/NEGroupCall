package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.content.DialogInterface;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.network.GroupBizControl;
import com.netease.yunxin.lib_utils.utils.ToastUtils;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * 评价dialog
 */
public class CommentDialog extends DialogFragment {

    LinearLayout llyUp;
    LinearLayout llyDown;
    ImageView ivUp;
    ImageView ivDown;
    LinearLayout llyMoreMessage;
    EditText edtComment;
    RecyclerView rcvComments;
    Button btnSubmit;
    ImageView ivClose;
    TextView tvThx;

    private String appKey;
    private ArrayList<CommentType> commentList;//需要提交的comment 的position

    private static final ArrayList<String> COMMENTS = new ArrayList<>(Arrays.asList("听不到声音",
            "机械音、杂音",
            "声音卡顿",
            "看不到画面",
            "画面卡顿",
            "画面模糊",
            "声音画面不同步",
            "意外退出"));

    private DialogInterface.OnDismissListener mOnClickListener;

    public void setOnDismissListener(DialogInterface.OnDismissListener listener) {
        this.mOnClickListener = listener;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.comment_dialog_layout, container, false);
        initView(rootView);
        return rootView;
    }

    @Override
    public void onStart() {
        super.onStart();
        initParams();
        initData();
    }

    public void setInfo(String appkey) {
        this.appKey = appkey;
    }

    protected void initView(View rootView) {
        llyUp = rootView.findViewById(R.id.lly_good);
        llyDown = rootView.findViewById(R.id.lly_bad);
        ivUp = rootView.findViewById(R.id.iv_good);
        ivDown = rootView.findViewById(R.id.iv_bad);
        llyMoreMessage = rootView.findViewById(R.id.lly_more_msg);
        edtComment = rootView.findViewById(R.id.edt_comment);
        rcvComments = rootView.findViewById(R.id.rcv_comment);
        btnSubmit = rootView.findViewById(R.id.btn_submit);
        ivClose = rootView.findViewById(R.id.iv_close);
        tvThx = rootView.findViewById(R.id.tv_thx);
    }


    protected void initData() {
        commentList = new ArrayList<>();
        CommentAdapter commentAdapter = new CommentAdapter();
        commentAdapter.setItemCheckListener(new CommentAdapter.ItemCheckListener() {
            @Override
            public void onChecked(int position, boolean isChecked) {
                if (isChecked) {
                    commentList.add(new CommentType(position));
                } else {
                    commentList.remove(new CommentType(position));
                }
            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        rcvComments.setLayoutManager(layoutManager);
        rcvComments.setAdapter(commentAdapter);
        llyUp.setOnClickListener(view -> {
            llyUp.setSelected(true);
            ivUp.setSelected(true);
            llyDown.setSelected(false);
            ivDown.setSelected(false);
            llyMoreMessage.setVisibility(View.GONE);
            submitComment(true);
        });

        ivClose.setOnClickListener(v -> {
            dismiss();
        });

        llyDown.setOnClickListener(v -> {
            llyDown.setSelected(true);
            ivDown.setSelected(true);
            llyUp.setSelected(false);
            ivUp.setSelected(false);
            llyMoreMessage.setVisibility(View.VISIBLE);
        });

        btnSubmit.setOnClickListener(v -> {
            submitComment(false);
        });

    }

    private void submitComment(boolean is_satisfied) {
        String conetent_type = commentList.toString();
        int feedback_type = is_satisfied ? 1 : 0;
        String feedback_source = "多人视频通话Demo";
        String content = edtComment.getText().toString().trim();
        UserModel userModel = ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser();
        String tel = userModel.mobile;
        String uid = userModel.avRoomUid;
        String appkey = TextUtils.isEmpty(this.appKey) ? (NativeConfig.getAppKey()) : this.appKey;
        String appid = Objects.requireNonNull(getContext()).getApplicationInfo().processName;
        GroupBizControl.submitComment(feedback_type, tel, uid, content, appkey, appid, conetent_type, feedback_source).subscribe(new ResourceSingleObserver<Boolean>() {
            @Override
            public void onSuccess(Boolean isSuccess) {
                if (isSuccess) {
                    if (!is_satisfied) {
                        ToastUtils.showShort("提交成功，感谢您的反馈");
                        dismiss();
                    } else {
                        tvThx.setVisibility(View.VISIBLE);
                        tvThx.postDelayed(() -> {
                            dismiss();
                        }, 1000);
                    }
                }
            }

            @Override
            public void onError(Throwable e) {
                Log.e("CommentDialog", "submit failed", e);
            }
        });
    }


    private void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.white_bottom_dialog_bg);

            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            window.setAttributes(params);
        }
        setCancelable(false);//设置点击外部是否消失
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        if (mOnClickListener != null) {
            mOnClickListener.onDismiss(dialog);
        }
    }

    public static class CommentType {
        int type;

        public CommentType(int type) {
            this.type = type;
        }

        @Override
        public String toString() {
            return String.valueOf(type);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            CommentType that = (CommentType) o;
            return type == that.type;
        }

        @Override
        public int hashCode() {
            return type;
        }
    }

    static class CommentAdapter extends RecyclerView.Adapter<CommentAdapter.VH> {

        //创建ViewHolder
        public class VH extends RecyclerView.ViewHolder {

            public CheckBox checkBox;

            public VH(View v) {
                super(v);
                checkBox = v.findViewById(R.id.cb_issue);
            }
        }

        private ItemCheckListener itemCheckListener;

        public void setItemCheckListener(ItemCheckListener itemCheckListener) {
            this.itemCheckListener = itemCheckListener;
        }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.comment_item_layout, parent, false);
            return new VH(v);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            holder.checkBox.setText(COMMENTS.get(position));
            holder.checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (itemCheckListener != null) {
                        itemCheckListener.onChecked(position, isChecked);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return COMMENTS.size();
        }

        public interface ItemCheckListener {
            void onChecked(int position, boolean isChecked);
        }
    }
}
