import logDebug from 'yunxin-log-debug';
import packageJson from '../../package.json';

const logger = logDebug({
  appName: 'groupCall',
  version: packageJson.version,
  level: 'trace',
  storeWindow: true,
});

export default logger;
