import React, { FC, useState } from 'react';
import { Modal, message } from 'antd';
import { DataInfo } from '@/utils/rtc';
import useInterval from '@/hooks/useInterval';

import styles from './index.less';

interface IProps {
  getInfo: () => Promise<DataInfo>;
  onCancel: () => void;
  visible?: boolean;
}

const RtcDataModal: FC<IProps> = ({ getInfo, visible = false, onCancel }) => {
  const [data, setData] = useState<DataInfo>({
    rtt: '-',
    audioSendBitrate: 0,
    videoSendBitrate: 0,
    audioRecvBitrate: 0,
    videoRecvBitrate: 0,
  });

  useInterval(
    async () => {
      try {
        const res = await getInfo();
        setData(res);
      } catch (error) {
        message.error('获取实时数据失败');
      }
    },
    visible ? 2000 : null,
  );

  return (
    <Modal
      footer={null}
      maskClosable={true}
      title="实时数据"
      visible={visible}
      onCancel={onCancel}
    >
      <div className={styles.item}>
        <span className={styles.label}>网络延迟：</span>
        <span>{data.rtt}ms</span>
      </div>
      <div className={styles.item}>
        <span className={styles.label}>视频发送/接收码率：</span>
        <span>
          {data.videoSendBitrate}/{data.videoRecvBitrate} kbps
        </span>
      </div>
      <div className={styles.item}>
        <span className={styles.label}>音频发送/接收码率：</span>
        <span>
          {data.audioSendBitrate}/{data.audioRecvBitrate} kbps
        </span>
      </div>
    </Modal>
  );
};

export default RtcDataModal;
