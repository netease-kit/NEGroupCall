import React, { useState, useMemo } from 'react';
import { Input, Button, message } from 'antd';
import { history } from 'umi';
import { checkBrowser } from '@/utils';
import styled from 'styled-components';
import styles from './index.less';

const JoinInput = styled(Input)`
  width: 320px;
  padding: 11px 0;
  margin-bottom: 20px;
  border-bottom: 1px solid #dcdfe5;
  &:hover, &:active, &:focus {
    border-bottom: 1px solid #dcdfe5;
  }
  .ant-input {
    font-size: 17px;
    color: #337eff;
  }
`

const IButton = styled(Button)`
  width: 320px;
  margin-top: 95px;
  &.ant-btn-lg {
    font-size: 16px;
    height: 50px;
    font-weight: normal;
  }
`

export default () => {
  const disabled = useMemo(() => !checkBrowser('chrome') && !checkBrowser('safari'), [])

  const [channelName, setChannelName] = useState('');
  const [nickName, setNickName] = useState('');

  const joinHandler = () => {
    if (!channelName) {
      message.error('请输入房间号')
      return
    }
    if (!/^\d{1,12}$/.test(channelName)) {
      message.error('仅支持12位及以下纯数字')
      return
    }
    if(nickName && !/^[\u4e00-\u9fa5a-zA-Z0-9]{1,12}$/.test(nickName)) {
      message.error('仅支持12位及以下文本、字母及数字组合')
      return
    }
    history.push({
      pathname: '/call',
      query: {
        channelName,
        nickName: nickName || `用户${Math.ceil(Math.random() * 1000000)}`
      }
    });
  }

  return (
    <div className={styles.wrapper}>
      <div className={styles.joinWrapper}>
        <div className={styles.title}>加入频道</div>
        <JoinInput bordered={false} placeholder="输入相同房间号即可通话" allowClear={true} value={channelName} onChange={(e: React.ChangeEvent<HTMLInputElement>) => { setChannelName(e.target.value) }} />
        <JoinInput bordered={false} placeholder="请输入昵称" allowClear={true} value={nickName} onChange={(e: React.ChangeEvent<HTMLInputElement>) => { setNickName(e.target.value) }} />
        <div>
          <IButton disabled={disabled} type="primary" shape="round" size="large" onClick={joinHandler}>加入频道</IButton>
        </div>
        {disabled && <div className={styles.errorMsg}>当前浏览器不支持体验，建议下载安装最新chrome浏览器</div>}
      </div>
    </div>
  );
}
