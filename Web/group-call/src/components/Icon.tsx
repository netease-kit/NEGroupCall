import React from 'react'
import styled from 'styled-components'
import { createFromIconfontCN } from '@ant-design/icons'

const MyIcon = createFromIconfontCN({
  scriptUrl: '//at.alicdn.com/t/font_2183559_hk3vfz419i9.js',
})

const Icon = styled(MyIcon)`
  width: ${(props) => props.width || '24'}px;
  height: ${(props) => props.height || '24'}px;
  color: ${(props) => props.color || 'inherit'};
  &>svg {
    width: ${(props) => props.width || '24'}px;
    height: ${(props) => props.height || '24'}px;
  }
`

export default Icon;
