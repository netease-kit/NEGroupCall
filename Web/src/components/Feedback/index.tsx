import React, { useState, useEffect } from 'react';
import { Modal, Radio, Input, Button, Checkbox } from 'antd';
import Icon from '@/components/Icon';
import styled from 'styled-components';
import styles from './index.less';
import { FeedbackParams } from '@/utils/rtc/base';

interface IProps {
  onOk: (params: FeedbackParams) => void;
  onCancel: () => void;
  visible: boolean;
}

const MyModal = styled(Modal)`
  width: 400px;
`;

const MyRadioGroup = styled(Radio.Group)`
  display: flex;
`;

const MyRadio = styled(Radio.Button)`
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
  background-color: #f2f3f5;
  color: #ccc;
  border: none !important;
  border-radius: 4px !important;
  &::before {
    background-color: transparent !important;
  }
  &:first-child {
    margin-right: 10px;
    &:hover {
      color: #337eff;
      background-color: #e9f2ff;
    }
    &.ant-radio-button-wrapper-checked {
      color: #337eff;
      background-color: #e9f2ff;
    }
  }
  &:last-child {
    &:hover {
      color: #f24957;
      background-color: #ffecee;
    }
    &.ant-radio-button-wrapper-checked {
      color: #f24957;
      background-color: #ffecee;
    }
  }
`;

const MyCheckBoxGroup = styled(Checkbox.Group)`
  .ant-checkbox-group-item {
    font-size: 15px;
    color: #333;
    &:not(:last-child) {
      margin-bottom: 10px;
    }
  }
`;

const MyTextArea = styled(Input.TextArea)`
  border-color: #e1e3e6;
  border-radius: 4px;
  margin: 20px 0 24px;
`;

const MyButton = styled(Button)`
  padding: 8px 46px;
  border-radius: 18px;
  height: auto;
  line-height: normal;
`;

const contentTypes = [
  { label: '听不到声音', value: '101' },
  { label: '机械音、杂音', value: '102' },
  { label: '声音卡顿', value: '103' },
  { label: '看不到画面', value: '104' },
  { label: '画面卡顿', value: '105' },
  { label: '画面模糊', value: '106' },
  { label: '声音画面不同步', value: '107' },
  { label: '意外退出', value: '108' },
  { label: '其他', value: '99' },
];

const Feedback: React.FC<IProps> = ({ onOk, onCancel, visible }) => {
  const [feedbackType, setFeedbackType] = useState<number | null>(null);
  const [contentType, setContentType] = useState<number[]>([]);
  const [content, setContent] = useState('');

  useEffect(() => {
    if (feedbackType === 1) {
      setContentType([]);
      setContent('');
      handleOnOk();
    }
  }, [feedbackType]);

  const handleOnOk = () => {
    onOk({
      feedback_type: feedbackType as number,
      content_type: contentType,
      content,
    });
  };

  const renderContent = () => {
    if (feedbackType === 1) {
      return (
        <div className={styles.goodContent}>
          <Icon type="iconhappy1x" color="#f29900" />
          <span className={styles.googText}>感谢您的评价~</span>
        </div>
      );
    }
    if (feedbackType === 0) {
      return (
        <div className={styles.badContent}>
          <div className={styles.badTitle}>
            很抱歉给您带来不便~请问您遇到了什么问题？
          </div>
          <MyCheckBoxGroup
            className={styles.badContentType}
            value={contentType}
            options={contentTypes}
            onChange={(value) => {
              setContentType(value as number[]);
            }}
          />
          <MyTextArea
            maxLength={1000}
            placeholder="其他问题..."
            value={content}
            onChange={(e) => {
              setContent(e.target.value);
            }}
          />
          <div className={styles.badFooter}>
            <MyButton type="primary" onClick={handleOnOk}>
              提交
            </MyButton>
          </div>
        </div>
      );
    }
    return null;
  };

  return (
    <MyModal
      title="通话品质如何？"
      visible={visible}
      footer={null}
      onCancel={onCancel}
      maskClosable={false}
    >
      <MyRadioGroup
        value={feedbackType}
        onChange={(e) => {
          setFeedbackType(e.target.value);
        }}
      >
        <MyRadio value={1}>
          <Icon className={styles.icon} type="icondianzanx" />
          <span className={styles.feedbackType}>好</span>
        </MyRadio>
        <MyRadio value={0}>
          <Icon className={styles.icon} type="icondianchapingx" />
          <span className={styles.feedbackType}>差</span>
        </MyRadio>
      </MyRadioGroup>
      {renderContent()}
    </MyModal>
  );
};

export default Feedback;
