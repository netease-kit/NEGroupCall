import React from 'react';
import Icon from '@/components/Icon';
import styles from './index.less';

export type DeviceType = 'speaker' | 'camera' | 'microphone';

export interface ItemList {
  label: string;
  value: string;
}

export interface DeviceListData {
  title: string;
  type: DeviceType;
  list: ItemList[];
  value?: string;
  onChange: (v: ItemList) => void | Promise<void>;
}

export interface IProps {
  data: DeviceListData[];
  postion: {
    left?: number | string;
    right?: number | string;
    top?: number | string;
    bottom?: number | string;
  };
  visible?: boolean;
}

const DeviceList: React.FC<IProps> = ({ data, postion, visible = true }) => {
  const handleClickEmpty = (e: React.MouseEvent<HTMLElement, MouseEvent>) => {
    e.stopPropagation();
  };

  return visible ? (
    <div
      onClick={handleClickEmpty}
      style={{ ...postion }}
      className={styles.devieListWrapper}
    >
      {data.map((item) => (
        <div key={item.title + item.type} className={styles.dataItem}>
          <div className={styles.title}>{item.title}</div>
          <div>
            {item.list.map((l) => (
              <div
                onClick={() => {
                  item.onChange({ ...l });
                }}
                key={l.value}
                className={styles.listItem}
              >
                <span className={styles.itemText}>{l.label}</span>
                {l.value === item.value && (
                  <Icon
                    type="iconcheck-line-regular1x"
                    width="12"
                    height="12"
                    color="#fff"
                  />
                )}
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  ) : null;
};

export default DeviceList;
