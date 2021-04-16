import React, { useState, useMemo, useEffect } from 'react';
import { Input, Button, message, Checkbox } from 'antd';
import Icon from '@/components/Icon';
import { history } from 'umi';
import { checkBrowser } from '@/utils';
import RtcOptModal, { Quality } from '@/components/RtcOptModal';
import styled from 'styled-components';
import { sessionIns } from '@/utils/storage';
import logger from '@/utils/logger';

import styles from './index.less';

const JoinInput = styled(Input)`
  width: 320px;
  padding: 11px 0;
  margin-bottom: 20px;
  border-bottom: 1px solid #dcdfe5;
  &:hover,
  &:active,
  &:focus {
    border-bottom: 1px solid #dcdfe5;
  }
  .ant-input {
    font-size: 17px;
    color: #337eff;
  }
`;

const IButton = styled(Button)`
  width: 320px;
  margin-top: 42px;
  &.ant-btn-lg {
    font-size: 16px;
    height: 50px;
    font-weight: normal;
  }
`;

const platforms = [
  {
    icon: (
      <Icon
        type="iconmacOS"
        width="32"
        height="32"
        className={styles.macIcon}
      />
    ),
    desc: 'macOS',
    descHover: '点击下载',
    downloadLink:
      'https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/default/多人视频通话_b715cbb_v1.1.0.dmg',
  },
  {
    icon: (
      <Icon
        type="iconWindows"
        width="32"
        height="32"
        className={styles.winIcon}
      />
    ),
    desc: 'Windows',
    descHover: '点击下载',
    downloadLink:
      'https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/default/多人视频通话_b715cbb_v1.1.0.exe',
  },
  {
    icon: (
      <Icon type="iconiOS" width="32" height="32" className={styles.iosIcon} />
    ),
    desc: 'iOS',
    descHover: '扫码下载',
    qrCodeLink: require('@/assets/ios.png'),
    hasQrCode: true,
  },
  {
    icon: (
      <Icon
        type="iconAndroid"
        width="32"
        height="32"
        className={styles.aosIcon}
      />
    ),
    desc: 'Andriod',
    descHover: '扫码下载',
    qrCodeLink: require('@/assets/android.png'),
    hasQrCode: true,
  },
  {
    icon: (
      <Icon
        type="iconxiaochengxu"
        width="32"
        height="32"
        className={styles.miniIcon}
      />
    ),
    desc: '小程序',
    descHover: '扫码下载',
    qrCodeLink: require('@/assets/xiaocx.png'),
    hasQrCode: true,
  },
];

export default () => {
  const disabled = useMemo(
    () => !checkBrowser('chrome') && !checkBrowser('safari'),
    [],
  );

  const [channelName, setChannelName] = useState('');
  const [nickName, setNickName] = useState('');
  const [openCamera, setOpenCamera] = useState(true);
  const [openMic, setOpenMic] = useState(true);
  const [optModalVisible, setOptModalVisible] = useState(false);

  useEffect(() => {
    sessionIns.remove('globalState');
  }, []);

  const onSaveSetting = ({
    resolution,
    frameRate,
    audioQuality,
  }: {
    resolution: number;
    frameRate: number;
    audioQuality: Quality;
  }) => {
    sessionIns.set('globalState', {
      ...(sessionIns.get('globalState') || {}),
      resolution,
      frameRate,
      audioQuality,
    });
    logger.log('设置成功', {
      resolution,
      frameRate,
      audioQuality,
    });
    setOptModalVisible(false);
  };

  const joinHandler = () => {
    if (!channelName) {
      message.error('请输入房间号');
      return;
    }
    if (!/^\d{1,12}$/.test(channelName)) {
      message.error('仅支持12位及以下纯数字');
      return;
    }
    if (nickName && !/^[\u4e00-\u9fa5a-zA-Z0-9]{1,12}$/.test(nickName)) {
      message.error('仅支持12位及以下文本、字母及数字组合');
      return;
    }
    sessionIns.set('globalState', {
      ...(sessionIns.get('globalState') || {}),
      channelName,
      nickName: nickName || `用户${Math.ceil(Math.random() * 1000000)}`,
      openCamera,
      openMic,
    });
    history.push({
      pathname: '/call',
    });
  };

  return (
    <div className={styles.wrapper}>
      <div className={styles.joinWrapper}>
        <div className={styles.joinTextWrapper}>
          <div className={styles.joinTextHeader}>
            欢迎使用
            <br />
            新一代 网易云信RTC
          </div>
          <div className={styles.joinTextDesc}>
            新一代音视频通话支持双声道128Kbps码率立体声高清音质，支持1080P高清画质，3行代码接入。提供更高清，更易用的音视频服务
          </div>
          <div className={styles.downloadTitle}>客户端下载</div>
          <div className={styles.downloadContent}>
            {platforms.map((item) => (
              <a
                key={item.desc}
                href={item.downloadLink}
                className={styles.downloadItem}
              >
                <div className={styles.downloadItemIcon}>{item.icon}</div>
                <span className={styles.downloadItemDesc}>{item.desc}</span>
                <span className={styles.downloadItemDescTxt}>
                  {item.descHover}
                </span>
                {item.hasQrCode ? (
                  <div className={styles.qrCode}>
                    <img src={item.qrCodeLink} alt="" />
                  </div>
                ) : null}
              </a>
            ))}
          </div>
        </div>
        <div className={styles.joinFormWrapper}>
          <div className={styles.title}>加入频道</div>
          <JoinInput
            bordered={false}
            placeholder="输入相同房间号即可通话"
            allowClear={true}
            value={channelName}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
              setChannelName(e.target.value);
            }}
          />
          <JoinInput
            bordered={false}
            placeholder="请输入昵称"
            allowClear={true}
            value={nickName}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
              setNickName(e.target.value);
            }}
          />
          <label className={styles.optLabel}>
            <Checkbox
              checked={openCamera}
              onChange={(e) => {
                setOpenCamera(e.target.checked);
              }}
            />
            <span className={styles.optText}>入会时打开摄像头</span>
          </label>
          <label className={styles.optLabel}>
            <Checkbox
              checked={openMic}
              onChange={(e) => {
                setOpenMic(e.target.checked);
              }}
            />
            <span className={styles.optText}>入会时打开麦克风</span>
          </label>
          <div>
            <IButton
              disabled={disabled}
              type="primary"
              shape="round"
              size="large"
              onClick={joinHandler}
            >
              加入频道
            </IButton>
          </div>
          <div
            className={styles.option}
            onClick={() => {
              setOptModalVisible(true);
            }}
          >
            <Icon type="iconshezhi" width="20" height="20" color="#999" />
          </div>
          {disabled && (
            <div className={styles.errorMsg}>
              当前浏览器不支持体验，建议下载安装最新chrome浏览器
            </div>
          )}
        </div>
      </div>
      <RtcOptModal
        visible={optModalVisible}
        onOk={onSaveSetting}
        onCancel={() => {
          setOptModalVisible(false);
        }}
      />
    </div>
  );
};
