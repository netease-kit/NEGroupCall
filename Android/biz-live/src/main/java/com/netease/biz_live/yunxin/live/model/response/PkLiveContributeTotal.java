package com.netease.biz_live.yunxin.live.model.response;

import com.google.gson.annotations.SerializedName;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by luc on 2020/11/26.
 */
public class PkLiveContributeTotal {
    /**
     * 主播账号id
     */
    public String accountId;
    /**
     * 打赏总金额
     */
    @SerializedName("rewardCoinTotal")
    public long rewardCoinTotal;

    /**
     * 打赏用户列表
     */
    @SerializedName("rewardRankVOList")
    public List<PkLiveContributor> contributors;

    /**
     * 从打赏列表模型转换至 观众列表信息
     */
    public List<AudienceInfo> getAudienceInfoList() {
        if (contributors == null || contributors.isEmpty()) {
            return Collections.emptyList();
        }
        List<AudienceInfo> audienceList = new ArrayList<>(contributors.size());

        for (PkLiveContributor contributor : contributors) {
            AudienceInfo info = new AudienceInfo(contributor.accountId, Long.parseLong(contributor.imAccid),
                    contributor.nickname, contributor.avatar);
            audienceList.add(info);
        }
        return audienceList;
    }
}
