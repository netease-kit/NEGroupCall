import version from './version'

const LevelMap = {
  log: 0,
  trace: 1,
  debug: 2,
  info: 3,
  warn: 4,
  error: 5,
}

class LogDebug {
  constructor({
    level = 'log',
    appName = '',
    version = '',
    debug = false,
  } = {}) {
    this.level = LevelMap[level]
    this.appName = appName
    this.version = version
    this.enable = debug
  }
  log(...msgs) {
    this._print('log', ...msgs);
  }
  trace(...msgs) {
    this._print('trace', ...msgs);
  }
  debug(...msgs) {
    this._print('debug', ...msgs);
  }
  info(...msgs) {
    this._print('info', ...msgs);
  }
  warn(...msgs) {
    this._print('warn', ...msgs);
  }
  error(...msgs) {
    this._print('error', ...msgs);
  }
  _print(funcName, ...msgs) {
    if (LevelMap[funcName] >= this.level && console[funcName] && this.enable) {
      console[funcName](`[ ${this.appName} ${this.version} ${this._genTime()} ]`, ...msgs)
    }
  }
  _genTime() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const hour = now.getHours() < 10 ? `0${now.getHours()}` : now.getHours();
    const min = now.getMinutes() < 10 ? `0${now.getMinutes()}`: now.getMinutes();
    const s = now.getSeconds() < 10 ? `0${now.getSeconds()}` : now.getSeconds();
    const nowString = `${year}-${month}-${day} ${hour}:${min}:${s}`;
    return nowString;
  }
}

export const logger = new LogDebug({
  appName: 'GroupCall-Miniapp',
  version,
  debug: true,
})

export default LogDebug
