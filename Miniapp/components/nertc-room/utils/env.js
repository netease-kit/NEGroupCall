import version from './version'
import { logger } from './logger'
const TAG_NAME = 'NERTC-ROOM'

const env = wx ? wx : qq
if (!env) {
  logger.error(TAG_NAME, '不支持当前小程序环境')
}
const systemInfo = env.getSystemInfoSync()
const safeArea = systemInfo.safeArea

export const IS_QQ = typeof qq !== 'undefined'
export const IS_WX = typeof wx !== 'undefined'
export const IS_IOS = /iOS/i.test(systemInfo.system)
export const IS_ANDROID = /Android/i.test(systemInfo.system)
export const IS_MAC = /mac/i.test(systemInfo.system)
export const APP_VERSION = systemInfo.version

let isFullscreenDevie = false
if (systemInfo.screenHeight > safeArea.bottom) {
// if (/iphone\s{0,}x/i.test(systemInfo.model)) {
  isFullscreenDevie = true
}

export const IS_FULLSCREEN_DEVICE = isFullscreenDevie
export const VERSION = version
