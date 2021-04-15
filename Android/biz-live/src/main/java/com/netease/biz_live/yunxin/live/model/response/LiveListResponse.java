package com.netease.biz_live.yunxin.live.model.response;

import com.netease.biz_live.yunxin.live.model.LiveInfo;

import java.util.List;

/**
 * 直播主页面列表返回值
 */
public class LiveListResponse {
    public int endRow;//int	每页大小
    public boolean hasNextPage;//boolean	是否有下一页
    public boolean hasPreviousPage;//boolean	是否上一页
    public boolean isLastPage;//boolean	最后一页
    public boolean isFirstPage;//boolean	第一页
    public List<LiveInfo> list;//直播房间列表
}
