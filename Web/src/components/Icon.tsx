import React from 'react';
import styled from 'styled-components';
import { createFromIconfontCN } from '@ant-design/icons';

const MyIcon = createFromIconfontCN({
  scriptUrl: 'https://at.alicdn.com/t/font_2183559_fne9nxzeyb.js',
});

const Icon = styled(MyIcon)`
  width: ${(props) => props.width || '24'}px;
  height: ${(props) => props.height || '24'}px;
  color: ${(props) => props.color || 'inherit'};
  & > svg {
    width: ${(props) => props.width || '24'}px;
    height: ${(props) => props.height || '24'}px;
  }
`;

export default Icon;
