import React, { useState, useMemo, useEffect } from 'react';
import { useLocation, history } from 'umi';
import RTC, { UserInfo, FeedbackParams } from '@/utils/rtc';
import { Button, message } from 'antd';
import Icon from '@/components/Icon';
import DeviceList, { IProps as DeviceListProps } from '@/components/DeviceList';
import Feedback from '@/components/Feedback';
import config from '@/config';
import logo from '@/assets/logo.png';
import styles from './index.less';

export default () => {
  const location = useLocation();
  const { channelName, nickName } = (location as any).query;

  const [localStream, setLocalStream] = useState<any>(null);
  const [remoteStreams, setRemoteStreams] = useState<any[]>([]);
  const [remoteUsers, setRemoteUsers] = useState<UserInfo[]>([]);
  const [mute, setMute] = useState(true);
  const [videoEnabled, setVideoEnabled] = useState(true);
  const [muteAudioIng, setMuteAudioIng] = useState(false);
  const [enableVideoIng, setEnableVideoIng] = useState(false);
  const [microphoneId, setMicrophoneId] = useState('');
  const [cameraId, setCameraId] = useState('');
  const [speakerId, setSpeakerId] = useState('');

  const [deviceList, setDeviceList] = useState<DeviceListProps['data']>([]);
  const [position, setPosition] = useState<DeviceListProps['postion']>({});
  const [listType, setListType] = useState<'audio' | 'video' | null>(null);
  const [feedbackVisible, setFeedbackVisible] = useState(false);

  const rtc = useMemo(
    () =>
      new RTC({
        appkey: config.appkey,
        // appSecret: config.appSecret,
        channelName,
        nickName,
        onLocalStreamUpdate: () => {
          setMicrophoneId(rtc.microphoneId);
          setCameraId(rtc.cameraId);
          setSpeakerId(rtc.speakerId);
          playLocalVideo();
        },
        onRemoteStreamUpdate: (userId: string) => {
          setRemoteUsers(rtc.remoteUsers);
          setRemoteStreams(rtc.remoteStreams);
        },
        onRemoteStreamSubscribed: (userId: string) => {
          const div = document.getElementById(`remote-container-${userId}`);
          div && rtc.setupRemoteView(userId, div);
        },
        onDisconnect: () => {
          setFeedbackVisible(true);
        }
      }),
    [],
  );

  const returnJoin = () => {
    rtc.leave().then(() => {
      console.log('离开成功');
    }).catch(err => {
      console.log('离开失败: ', err);
    });
    history.push('/');
  }

  useEffect(() => {
    if (!channelName || !nickName) {
      returnJoin();
      return;
    }
    rtc.join().then(() => {
      message.info('本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人');
    }).catch(err => {
      if (err.code && err.code === 2001) {
        message.error('本应用为测试产品，每个频道最多4人', 1, returnJoin)
      } else {
        message.error(err?.msg || '加入房间失败', 1, returnJoin);
      }
    });
  }, []);

  useEffect(() => {
    rtc.getDevices().then(({ audioIn, audioOut, video }) => {
      const data: DeviceListProps['data'] = [
        {
          title: '请选择扬声器',
          type: 'speaker',
          list: audioOut.map(item => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: speakerId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('speakerId', value)
              .then(() => {
                console.log('切换扬声器成功！');
              })
              .catch(err => {
                console.error('切换扬声器失败：', err);
              });
          },
        },
        {
          title: '请选择麦克风',
          type: 'microphone',
          list: audioIn.map(item => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: microphoneId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('microphoneId', value)
              .then(() => {
                setMute(true);
                console.log('切换麦克风成功！');
              })
              .catch(err => {
                console.error('切换麦克风失败：', err);
              });
          },
        },
        {
          title: '请选择摄像头',
          type: 'camera',
          list: video.map(item => ({
            label: item.label,
            value: item.deviceId,
          })),
          value: cameraId,
          onChange: ({ value }) => {
            rtc
              .changeDevice('cameraId', value)
              .then(() => {
                setVideoEnabled(true);
                console.log('切换摄像头成功！');
              })
              .catch(err => {
                console.error('切换摄像头失败：', err);
              });
          },
        },
      ];
      setDeviceList(data);
    });
  }, [speakerId, microphoneId, cameraId]);

  const finalDeviceList = useMemo(() => {
    if (!listType) {
      return deviceList;
    }
    if (listType === 'audio') {
      return deviceList.filter(item => item.type !== 'camera');
    }
    return deviceList.filter(item => item.type === 'camera');
  }, [deviceList, listType]);

  const playLocalVideo = () => {
    const div = document.getElementById('local-container');
    setLocalStream(rtc.localStream);
    rtc
      .setupLocalView(div as HTMLElement)
      .then(() => {
        console.log('播放成功');
      })
      .catch(err => {
        console.error('播放失败：', err);
      });
  };

  const handleMute = () => {
    setMuteAudioIng(true);
    rtc
      .muteLocalAudio(!mute)
      .then(() => {
        console.log(!mute ? '开启声音成功' : '静音成功');
        setMute(!mute);
      })
      .catch(err => {
        console.error(err);
      }).finally(() => {
        setMuteAudioIng(false);
      });
  };

  const handleVideoEnabled = () => {
    setEnableVideoIng(true);
    rtc
      .enableLocalVideo(!videoEnabled)
      .then(() => {
        console.log(!videoEnabled ? '开启画面成功' : '关闭画面成功');
        if (!videoEnabled) {
          playLocalVideo();
        } else {
          setLocalStream(null);
        }
        setVideoEnabled(!videoEnabled);
      })
      .catch(err => {
        console.error(err);
      }).finally(() => {
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

  const handleHangup = () => {
    setFeedbackVisible(true);
  };

  const exit = () => {
    setFeedbackVisible(false);
    returnJoin();
  }

  const handleFeedbackOk = (params: FeedbackParams) => {
    rtc
      .sendFeedbackRequest(params)
      .then(() => {
        message.success('反馈成功', 2, exit);
      })
      .catch(err => {
        console.error(`反馈失败：${err}`);
        exit();
      })
  };

  const localContainer = useMemo(() => {
    return (
      <div id="local-container" className={styles.userWrapper}>
        <div className={styles[localStream ? 'userNickSmall' : 'userNick']}>
          {!mute && (
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
      </div>
    );
  }, [localStream, nickName, mute]);

  const remoteContainers = useMemo(
    () =>
      remoteUsers.map(({ nickName, uid }) => (
        <div
          key={uid}
          id={`remote-container-${uid}`}
          className={styles.userWrapper}
        >
          <div
            className={
              styles[
                (remoteStreams.find(item => item.getId() === uid) || {}).video
                  ? 'userNickSmall'
                  : 'userNick'
              ]
            }
          >
            {!(remoteStreams.find(item => item.getId() === uid) || {}).audio && (
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
        </div>
      )),
    [remoteStreams, remoteUsers],
  );

  return (
    <div className={styles.wrapper} onClick={handleClickEmpty}>
      <div className={styles.header}>
        {/* <img className={styles.logo} src={logo} alt=""/> */}
        <span className={styles.channelName}>会议ID：{channelName}</span>
      </div>
      <div className={styles.content}>
        {localContainer}
        {remoteContainers}
      </div>
      <div className={styles.footer}>
        <div className={styles.buttonGroup}>
          <Button
            className={styles.buttonHover}
            onClick={handleMute}
            loading={muteAudioIng}
            type="text"
            icon={
              mute ? (
                <Icon type="iconyx-tv-voice-onx" color="#fff" />
              ) : (
                <Icon type="iconyx-tv-voice-offx" color="red" />
              )
            }
          ></Button>
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
          ></Button>
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
          ></Button>
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
          ></Button>
        </div>
        <Button
          className={styles.buttonHover}
          onClick={handleHangup}
          type="text"
          icon={<Icon type="iconhang-up-y1x" color="red" />}
        ></Button>
      </div>
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
