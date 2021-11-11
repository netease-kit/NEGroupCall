import React, { FC, useState } from 'react';
import { Modal, Select, Radio, Divider } from 'antd';
import { AudioQuality, VideoQuality, VideoFrame } from '@/utils/rtc/base';

import styles from './index.less';

export type AudioScene = 'music' | 'chat';

interface IProps {
  visible?: boolean;
  onOk?: (params: {
    resolution: number;
    frameRate: number;
    audioQuality: AudioQuality;
  }) => void;
  onCancel?: () => void;
}

const resolutionOptions = [
  {
    label: '320x180',
    value: VideoQuality.VIDEO_QUALITY_180p as number,
  },
  {
    label: '640x480',
    value: VideoQuality.VIDEO_QUALITY_480p as number,
  },
  {
    label: '1280x720',
    value: VideoQuality.VIDEO_QUALITY_720p as number,
  },
  {
    label: '1920x1080',
    value: VideoQuality.VIDEO_QUALITY_1080p as number,
  },
];

const frameRateOptions = [
  {
    label: '5',
    value: VideoFrame.CHAT_VIDEO_FRAME_RATE_5 as number,
  },
  {
    label: '10',
    value: VideoFrame.CHAT_VIDEO_FRAME_RATE_10 as number,
  },
  {
    label: '15',
    value: VideoFrame.CHAT_VIDEO_FRAME_RATE_15 as number,
  },
  {
    label: '20',
    value: VideoFrame.CHAT_VIDEO_FRAME_RATE_20 as number,
  },
  {
    label: '25',
    value: VideoFrame.CHAT_VIDEO_FRAME_RATE_25 as number,
  },
];

const audioSceneOptions = [
  {
    label: '音乐',
    value: 'music',
  },
  {
    label: '语音',
    value: 'chat',
  },
];

const chatQualityOptions = [
  {
    label: '一般',
    value: 'speech_low_quality',
  },
  {
    label: '清晰',
    value: 'speech_standard',
  },
];

const musicQualityOptions = [
  {
    label: '一般',
    value: 'music_standard',
  },
  {
    label: '清晰',
    value: 'standard_stereo',
  },
  {
    label: '高清',
    value: 'high_quality',
  },
  {
    label: '极致',
    value: 'high_quality_stereo',
  },
];

const RtcOptModal: FC<IProps> = ({ visible, onOk, onCancel }) => {
  const [resolution, setResolution] = useState<number>(
    VideoQuality.VIDEO_QUALITY_720p,
  );
  const [frameRate, setFrameRate] = useState<number>(
    VideoFrame.CHAT_VIDEO_FRAME_RATE_20,
  );
  const [audioScene, setAudioScene] = useState<AudioScene>('chat');
  const [audioQuality, setAudioQuality] = useState<AudioQuality>(
    'speech_standard',
  );

  const okHandler = () => {
    onOk?.({
      resolution,
      frameRate,
      audioQuality,
    });
  };

  const onChangeScene = (e: any) => {
    const value: AudioScene = e.target.value;
    setAudioScene(value);
    if (value === 'music') {
      setAudioQuality('high_quality_stereo');
    } else if (value === 'chat') {
      setAudioQuality('speech_standard');
    }
  };

  return (
    <Modal
      visible={visible}
      title="设置"
      onOk={okHandler}
      onCancel={onCancel}
      okText="确定"
      cancelText="取消"
      maskClosable={false}
    >
      <div className={styles.wrapper}>
        <div>
          <div className={[styles.title, styles.mb20].join(' ')}>视频设置</div>
          <div className={[styles.item, styles.mb20].join(' ')}>
            <span>分辨率</span>
            <Select
              className={styles.select}
              value={resolution}
              options={resolutionOptions}
              onChange={setResolution}
            />
          </div>
          <div className={[styles.item, styles.mb20].join(' ')}>
            <span>帧率</span>
            <Select
              className={styles.select}
              value={frameRate}
              options={frameRateOptions}
              onChange={setFrameRate}
            />
          </div>
        </div>
        <Divider type="vertical" className={styles.mb20} />
        <div>
          <div className={[styles.title, styles.mb20].join(' ')}>音频设置</div>
          <div className={[styles.item, styles.mb20].join(' ')}>
            <span>场景</span>
            <Radio.Group
              className={styles.select}
              value={audioScene}
              options={audioSceneOptions}
              onChange={onChangeScene}
            />
          </div>
          <div className={styles.item}>
            <span>音质</span>
            <Select
              className={styles.select}
              value={audioQuality}
              options={
                audioScene === 'music'
                  ? musicQualityOptions
                  : audioScene === 'chat'
                  ? chatQualityOptions
                  : []
              }
              onChange={setAudioQuality}
            />
          </div>
        </div>
      </div>
      <div></div>
    </Modal>
  );
};

export default RtcOptModal;
