import ElectronRtcImpl from './electronRtc';
import WebRtcImpl from './webRtc';

const AdapterImpl =
  process.env.PLATFORM === 'electron' ? ElectronRtcImpl : WebRtcImpl;

export default AdapterImpl;
