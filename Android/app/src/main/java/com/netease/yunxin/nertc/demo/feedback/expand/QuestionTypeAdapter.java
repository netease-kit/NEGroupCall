package com.netease.yunxin.nertc.demo.feedback.expand;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by luc on 2020/11/17.
 */
public class QuestionTypeAdapter extends BaseExpandableListAdapter {
    private final Context context;
    private final List<QuestionGroup> groups;
    private final List<QuestionItem> selectedList;

    public QuestionTypeAdapter(Context context, List<QuestionGroup> groups, List<QuestionItem> selectedList) {
        this.context = context;
        this.groups = new ArrayList<>(groups);
        this.selectedList = new ArrayList<>(selectedList);
    }

    @Override
    public int getGroupCount() {
        return groups.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return groups.get(groupPosition).items.size();
    }

    @Override
    public Object getGroup(int groupPosition) {
        return groups.get(groupPosition);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return groups.get(groupPosition).items.get(childPosition);
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return groups.get(groupPosition).items.get(childPosition).id;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
        View rootView = LayoutInflater.from(context).inflate(R.layout.view_item_feedback_group, parent, false);
        TextView tvName = rootView.findViewById(R.id.tv_group_name);
        tvName.setText(groups.get(groupPosition).title);
        ImageView ivArrow = rootView.findViewById(R.id.iv_arrow);
        ivArrow.setImageResource(isExpanded ? R.drawable.icon_up_arrow : R.drawable.icon_down_arrow);
        return rootView;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        View rootView = LayoutInflater.from(context).inflate(R.layout.view_item_feedback_child, parent, false);
        QuestionItem item = groups.get(groupPosition).items.get(childPosition);
        TextView tvName = rootView.findViewById(R.id.tv_item_name);
        tvName.setText(item.name);

        View chosenView = rootView.findViewById(R.id.iv_chosen_icon);
        chosenView.setVisibility(isSelected(item) ? View.VISIBLE : View.GONE);
        return rootView;
    }

    private boolean isSelected(QuestionItem item) {
        if (selectedList.isEmpty()) {
            return false;
        }
        return selectedList.contains(item);
    }

    public void updateSelectedItem(QuestionItem item) {
        if (selectedList.contains(item)) {
            selectedList.remove(item);
        } else {
            selectedList.add(item);
        }
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }
}
