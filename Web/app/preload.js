// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
const path = require('path');

window.NERtcSDK = require('nertc-electron-sdk').default;
window.pcUtil = require('pc-util');
window.electronLogPath = path.resolve(__dirname, './logs');

// window.addEventListener('load', () => {
// window.pcUtil.askForCameraAccess().then((status) => {
//   console.log('askForCameraAccess: ', status);
// });
// window.pcUtil.askForMicrophoneAccess().then((status) => {
//   console.log('askForMicrophoneAccess: ', status);
// });
// });
