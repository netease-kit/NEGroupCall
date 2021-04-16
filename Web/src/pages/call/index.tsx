import React, { useState, useMemo, useEffect } from 'react';
import { history } from 'umi';
import RTC, { UserInfo, FeedbackParams, Stat, Evts } from '@/utils/rtc';
import { Button, message } from 'antd';
import Icon from '@/components/Icon';
import DeviceList, { IProps as DeviceListProps } from '@/components/DeviceList';
import Feedback from '@/components/Feedback';
import RtcDataModal from '@/components/RtcDataModal';
import config from '@/config';
// import logo from '@/assets/logo.png';
import logger from '@/utils/logger';
import { sessionIns } from '@/utils/storage';

import styles from './index.less';
import { checkBrowser } from '@/utils';

const networkColorMap = {
  0: '#e6e6e6',
  1: '#1afa29',
  2: '#1afa29',
  3: '#f4ea2a',
  4: '#d81e06',
  5: '#d81e06',
  6: '#e6e6e6',
};
let clickFlag = false;

export default () => {
  const {
    channelName,
    nickName,
    resolution,
    frameRate,
    audioQuality,
    openCamera,
    openMic,
  } = sessionIns.get('globalState') || {};

  const [localStream, setLocalStream] = useState<any>(null);
  const [remoteStreams, setRemoteStreams] = useState<any[]>([]);
  const [remoteUsers, setRemoteUsers] = useState<UserInfo[]>([]);
  const [audioEnabled, setAudioEnabled] = useState(true);
  const [videoEnabled, setVideoEnabled] = useState(true);
  const [enableAudioIng, setEnableAudioIng] = useState(false);
  const [enableVideoIng, setEnableVideoIng] = useState(false);
  const [microphoneId, setMicrophoneId] = useState('');
  const [cameraId, setCameraId] = useState('');
  const [speakerId, setSpeakerId] = useState('');
  const [stats, setStats] = useState<Stat[]>([]);

  const [deviceList, setDeviceList] = useState<DeviceListProps['data']>([]);
  const [position, setPosition] = useState<DeviceListProps['postion']>({});
  const [listType, setListType] = useState<'audio' | 'video' | null>(null);
  const [feedbackVisible, setFeedbackVisible] = useState(false);
  const [dataVisible, setDataVisible] = useState(false);

  const [largeOne, setLargeOne] = useState<string | number>('');

  const rtc = useMemo(() => {
    logger.log('SDKVersion：', '4.1.0');
    clickFlag = false;
    return new RTC({
      appkey: config.appKey,
      // appSecret: config.appSecret,
      channelName,
      nickName,
      options: {
        resolution,
        frameRate,
        audioQuality,
        openCamera,
        openMic,
      },
      onLocalStreamUpdate: () => {
        setMicrophoneId(rtc.microphoneId);
        setCameraId(rtc.cameraId);
        setSpeakerId(rtc.speakerId);
        playLocalVideo();
      },
      onRemoteStreamUpdate: () => {
        setRemoteUsers(rtc.remoteUsers);
        setRemoteStreams(rtc.remoteStreams);
      },
      onRemoteStreamSubscribed: (userId: number) => {
        const div = document.getElementById(`remote-container-${userId}`);
        div && rtc.setupRemoteView(userId, div as HTMLElement);
      },
      onNetworkQuality: (stats) => {
        logger.log('网络质量: ', stats);
        setStats(stats);
      },
      onDisconnect: () => {
        setFeedbackVisible(true);
      },
      onConnectionState: (evt: Evts) => {
        logger.log('网络连接状态: ', evt);
        if (
          evt.prevState === 'DISCONNECTING' &&
          evt.curState === 'DISCONNECTED'
        ) {
          if (!clickFlag) {
            message.error('网络连接断开', 1, returnJoin.bind(null, false));
          } else {
            returnJoin(false);
          }
        }
      },
    });
  }, []);
  // 便于调试
  // @ts-ignore
  window.rtc = rtc;

  const returnJoin = (rtcLeave: boolean) => {
    if (rtcLeave) {
      rtc
        .leave()
        .then(() => {
          logger.log('离开成功');
        })
        .catch((err) => {
          logger.log('离开失败: ', err);
        })
        .finally(() => {
          history.push('/');
        });
    } else {
      history.push('/');
    }
  };

  useEffect(() => {
    if (!channelName || !nickName) {
      returnJoin(false);
      return;
    }
    rtc
      .join()
      .then(() => {
        if (!openMic) {
          setAudioEnabled(false);
        }
        if (!openCamera) {
          setVideoEnabled(!videoEnabled);
          setLocalStream(null);
        }
        message.info(
          '本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人',
        );
      })
      .catch((err) => {
        logger.error('rtc join', err);
        if (err.code && err.code === 2001) {
          message.error(
            '本应用为测试产品，每个频道最多4人',
            1,
            returnJoin.bind(null, false),
          );
        } else {
          message.error(
            err?.msg || '加入房间失败',
            1,
            returnJoin.bind(null, false),
          );
        }
      });
  }, []);

  useEffect(() => {
    if (remoteUsers.length === 0) {
      setLargeOne('');
    }
    if (localStream) {
      const localDiv = document.getElementById('local-container');
      rtc.setLocalVideoSize(localDiv as HTMLElement);
    }
    if (remoteStreams.length) {
      remoteStreams.forEach((item) => {
        const uid = item.getId();
        const view = document.getElementById(`remote-container-${uid}`);
        if (view) {
          rtc.setRemoteVideoSize(uid, view);
        }
      });
    }
  }, [remoteUsers, largeOne, localStream, remoteStreams]);

  useEffect(() => {
    rtc.getDevices().then(({ audioIn = [], audioOut = [], video = [] }) => {
      const data: DeviceListProps['data'] = [
        {
          title: '请选择麦克风',
          type: 'microphone',
          list: audioIn.map((item) => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: microphoneId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('microphoneId', value)
              .then(() => {
                setAudioEnabled(true);
                logger.log('切换麦克风成功！');
              })
              .catch((err) => {
                logger.error('切换麦克风失败：', err);
              });
          },
        },
        {
          title: '请选择摄像头',
          type: 'camera',
          list: video.map((item) => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: cameraId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('cameraId', value)
              .then(() => {
                setVideoEnabled(true);
                logger.log('切换摄像头成功！');
              })
              .catch((err) => {
                logger.error('切换摄像头失败：', err);
              });
          },
        },
      ];
      if (!checkBrowser('safari')) {
        data.unshift({
          title: '请选择扬声器',
          type: 'speaker',
          list: audioOut.map((item) => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: speakerId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('speakerId', value)
              .then(() => {
                logger.log('切换扬声器成功！');
              })
              .catch((err) => {
                logger.error('切换扬声器失败：', err);
              });
          },
        });
      }
      setDeviceList(data);
    });
  }, [speakerId, microphoneId, cameraId]);

  const finalDeviceList = useMemo(() => {
    if (!listType) {
      return deviceList;
    }
    if (listType === 'audio') {
      return deviceList.filter((item) => item.type !== 'camera');
    }
    return deviceList.filter((item) => item.type === 'camera');
  }, [deviceList, listType]);

  const playLocalVideo = () => {
    const div = document.getElementById('local-container');
    setLocalStream(rtc.localStream);
    rtc
      .setupLocalView(div as HTMLElement)
      .then(() => {
        logger.log('播放成功');
      })
      .catch((err) => {
        logger.error('播放失败：', err);
      });
  };

  useEffect(() => {
    if (localStream || remoteStreams.length) {
      setLargeOne('');
    }
  }, [localStream, remoteStreams.length]);

  const handleAudioEnabled = () => {
    setEnableAudioIng(true);
    rtc
      .enableLocalAudio(!audioEnabled)
      .then(() => {
        logger.log(!audioEnabled ? '开启声音成功' : '静音成功');
        setAudioEnabled(!audioEnabled);
      })
      .catch((err) => {
        logger.error(err);
      })
      .finally(() => {
        setEnableAudioIng(false);
      });
  };

  const handleVideoEnabled = () => {
    setEnableVideoIng(true);
    rtc
      .enableLocalVideo(!videoEnabled)
      .then(() => {
        logger.log(!videoEnabled ? '开启画面成功' : '关闭画面成功');
        if (!videoEnabled) {
          playLocalVideo();
        } else {
          setLocalStream(null);
        }
        setVideoEnabled(!videoEnabled);
      })
      .catch((err) => {
        logger.error(err);
      })
      .finally(() => {
        setEnableVideoIng(false);
      });
  };

  const handleClickAudio = (e: React.MouseEvent<HTMLElement, MouseEvent>) => {
    e.stopPropagation();
    setPosition({
      left: '35%',
      bottom: 105,
    });
    setListType('audio');
  };

  const handleClickVideo = (e: React.MouseEvent<HTMLElement, MouseEvent>) => {
    e.stopPropagation();
    setPosition({
      left: '45%',
      bottom: 105,
    });
    setListType('video');
  };

  const handleClickEmpty = () => {
    setListType(null);
  };

  const handleShowData = () => {
    setDataVisible(!dataVisible);
  };

  const handleHangup = () => {
    setFeedbackVisible(true);
    clickFlag = true;
  };

  const exit = () => {
    setFeedbackVisible(false);
    returnJoin(true);
  };

  const handleFeedbackOk = (params: FeedbackParams) => {
    rtc
      .sendFeedbackRequest(params)
      .then(() => {
        message.success('反馈成功', 2, exit);
      })
      .catch((err) => {
        logger.error(`反馈失败：${err}`);
        exit();
      });
  };

  const handleClickZoom = (
    userId: number | string,
    value,
    type: string | undefined,
  ) => {
    if (type) {
      setLargeOne(!largeOne ? value : '');
    }
  };

  const localContainer = useMemo(() => {
    let wrapperClass = '';
    switch (remoteUsers.length) {
      case 0:
        wrapperClass = 'noneClass';
        break;
      case 1:
        wrapperClass = 'oneClass';
        break;
      default:
        wrapperClass = 'threeClass';
    }
    return (
      <div
        id="local-container"
        className={
          largeOne
            ? largeOne === 'me'
              ? styles['largenClass']
              : styles[`lessenClass${remoteUsers.length}`]
            : styles[wrapperClass]
        }
      >
        <div className={styles['userNickSmall']}>
          {!audioEnabled && (
            <Icon
              type="iconyx-tv-voice-offx"
              width="14"
              height="14"
              style={{ marginRight: '4px' }}
              color="red"
            />
          )}
          {nickName}
        </div>
        {localStream ? (
          ''
        ) : (
          <div className={styles['userNick']}>{nickName}</div>
        )}
        {localStream && stats.some((item) => item.uid === localStream.getId()) && (
          <div className={styles.networkInfo}>
            <Icon
              type="iconxinhao"
              width="12"
              height="12"
              color={
                networkColorMap[
                  (stats.find(
                    (item) => item.uid === localStream.getId(),
                  ) as Stat).uplinkNetworkQuality
                ]
              }
            />
          </div>
        )}
        {remoteUsers.length === 0 || (largeOne && largeOne !== 'me') ? null : (
          <div
            className={styles.screenZoom}
            onClick={() => handleClickZoom('', 'me', 'click')}
          >
            <Icon
              type={!largeOne ? 'iconfangda' : 'iconsuoxiao'}
              width="20"
              height="20"
            />
          </div>
        )}
      </div>
    );
  }, [localStream, remoteUsers, nickName, audioEnabled, stats, largeOne]);

  const remoteContainers = useMemo(() => {
    let wrapperClass = '';
    if (remoteUsers.length === 1) {
      wrapperClass = 'oneClass';
    }
    if (remoteUsers.length === 3) {
      wrapperClass = 'threeClass';
    }
    const remoteUserArr = remoteUsers.map(({ nickName, uid }, index) => (
      <div
        key={uid}
        id={`remote-container-${uid}`}
        className={
          largeOne
            ? index.toString() === largeOne
              ? styles['largenClass']
              : styles[`lessenClass${largeOne}${remoteUsers.length}${index}`]
            : remoteUsers.length === 2
            ? styles[`threeClass${index}`]
            : styles[wrapperClass]
        }
      >
        <div className={styles['userNickSmall']}>
          {!(remoteStreams.find((item) => item.getId() === uid) || {})
            .audio && (
            <Icon
              type="iconyx-tv-voice-offx"
              width="14"
              height="14"
              style={{ marginRight: '4px' }}
              color="red"
            />
          )}
          {nickName}
        </div>
        {(remoteStreams.find((item) => item.getId() === uid) || {}).video ? (
          ''
        ) : (
          <div className={styles['userNick']}>{nickName}</div>
        )}
        {stats.some((item) => item.uid === uid) && (
          <div className={styles.networkInfo}>
            <Icon
              type="iconxinhao"
              width="12"
              height="12"
              color={
                networkColorMap[
                  (stats.find((item) => item.uid === uid) as Stat)
                    .downlinkNetworkQuality
                ]
              }
            />
          </div>
        )}
        {largeOne && largeOne !== index.toString() ? null : (
          <div
            className={styles.screenZoom}
            onClick={() => handleClickZoom(uid, index.toString(), 'click')}
          >
            <Icon
              type={!largeOne ? 'iconfangda' : 'iconsuoxiao'}
              width="20"
              height="20"
            />
          </div>
        )}
      </div>
    ));
    return remoteUserArr;
  }, [remoteStreams, remoteUsers, stats, largeOne]);

  return (
    <div className={styles.wrapper} onClick={handleClickEmpty}>
      <div className={styles.header}>
        {/* <img className={styles.logo} src={logo} alt=""/> */}
        <span className={styles.channelName}>房间ID：{channelName}</span>
      </div>
      <div className={styles.content}>
        {localContainer}
        {remoteContainers}
      </div>
      <div className={styles.footer}>
        <div className={styles.buttonGroup}>
          <Button
            className={styles.buttonHover}
            onClick={handleAudioEnabled}
            loading={enableAudioIng}
            type="text"
            icon={
              audioEnabled ? (
                <Icon type="iconyx-tv-voice-onx" color="#fff" />
              ) : (
                <Icon type="iconyx-tv-voice-offx" color="red" />
              )
            }
          />
          <Button
            onClick={handleClickAudio}
            className={styles.buttonHover}
            type="text"
            icon={
              <Icon
                className={styles.updown}
                type="icontriangle-up1x"
                color="#fff"
                width="8"
                height="8"
              />
            }
          />
        </div>
        <div className={styles.buttonGroup}>
          <Button
            className={styles.buttonHover}
            onClick={handleVideoEnabled}
            loading={enableVideoIng}
            type="text"
            icon={
              videoEnabled ? (
                <Icon type="iconyx-tv-video-onx" color="#fff" />
              ) : (
                <Icon type="iconyx-tv-video-offx" color="red" />
              )
            }
          />
          <Button
            onClick={handleClickVideo}
            className={styles.buttonHover}
            type="text"
            icon={
              <Icon
                className={styles.updown}
                type="icontriangle-up1x"
                color="#fff"
                width="8"
                height="8"
              />
            }
          />
        </div>
        <Button
          className={styles.buttonHover}
          onClick={handleShowData}
          type="text"
          icon={<Icon type="iconshuju" width="24" height="24" color="#fff" />}
        />
        <Button
          className={styles.buttonHover}
          onClick={handleHangup}
          type="text"
          icon={<Icon type="iconhang-up-y1x" color="red" />}
        />
      </div>
      <RtcDataModal
        visible={dataVisible}
        getInfo={rtc.getInfo.bind(rtc)}
        onCancel={() => {
          setDataVisible(false);
        }}
      />
      <DeviceList
        data={finalDeviceList}
        visible={!!listType}
        postion={position}
      />
      <Feedback
        visible={feedbackVisible}
        onOk={handleFeedbackOk}
        onCancel={exit}
      />
    </div>
  );
};
