import { defineConfig } from 'umi';
import * as path from 'path';

export default defineConfig({
  title: '网易 | 多人通话',
  favicon: `${
    process.env.PLATFORM === 'electron'
      ? './'
      : process.env.NODE_ENV === 'production'
      ? '/webdemo/groupCall/'
      : '/'
  }favicon.ico`,
  publicPath:
    process.env.PLATFORM === 'electron'
      ? './'
      : process.env.NODE_ENV === 'production'
      ? '/webdemo/groupCall/'
      : '/',
  define: {
    'process.env.ENV': process.env.ENV,
    'process.env.PLATFORM': process.env.PLATFORM,
  },
  hash: true,
  history: {
    type: 'hash',
  },
  nodeModulesTransform: {
    type: 'none',
  },
  esbuild: {},
  routes: [
    { path: '/', component: '@/pages/join/index' },
    { path: '/call', component: '@/pages/call/index' },
  ],
  devServer: {
    https: {
      key: path.join(__dirname, './cert/key.pem'),
      cert: path.join(__dirname, './cert/cert.pem'),
    },
  },
});
