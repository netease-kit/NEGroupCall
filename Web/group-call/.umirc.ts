import { defineConfig } from 'umi';
import * as path from 'path';

export default defineConfig({
  publicPath: process.env.NODE_ENV === 'production' ? '/webdemo/groupCall/' : '/',
  history: {
    type: 'hash'
  },
  nodeModulesTransform: {
    type: 'none',
  },
  routes: [
    { path: '/', component: '@/pages/join/index' },
    { path: '/call', component: '@/pages/call/index' },
  ],
  devServer: {
    https: {
      key: path.join(__dirname, './src/cert/key.pem'),
      cert: path.join(__dirname, './src/cert/cert.pem'),
    }
  }
});
