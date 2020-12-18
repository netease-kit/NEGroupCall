package com.netease.yunxin.nertc.demo.feedback.expand;

import java.io.Serializable;

/**
 * Created by luc on 2020/11/17.
 */
public class QuestionItem implements Serializable {
    public final int id;
    public final String name;

    public QuestionItem(int id, String name) {
        this.name = name;
        this.id = id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        QuestionItem that = (QuestionItem) o;

        if (id != that.id) return false;
        return name.equals(that.name);
    }

    @Override
    public int hashCode() {
        int result = id;
        result = 31 * result + name.hashCode();
        return result;
    }
}
