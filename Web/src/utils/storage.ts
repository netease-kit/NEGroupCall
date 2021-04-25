class Storage {
  private static instace: Storage;
  private store = new Map();
  private type: 'localStorage' | 'sessionStorage' | 'memory' = 'memory';
  private salt = 'yunxin_groupcall_';

  constructor(type?: 'localStorage' | 'sessionStorage' | 'memory') {
    if (type) {
      this.type = type;
    }
  }

  public get(key: string): any {
    let value;
    switch (this.type) {
      case 'memory':
        return this.store.get(key);
      case 'localStorage':
        value = localStorage.getItem(`${this.salt}${key}`);
        if (value) {
          return JSON.parse(value);
        }
        return value;
      case 'sessionStorage':
        value = sessionStorage.getItem(`${this.salt}${key}`);
        if (value) {
          return JSON.parse(value);
        }
        return value;
    }
  }

  public set(key: string, value: any) {
    switch (this.type) {
      case 'memory':
        this.store.set(key, value);
        break;
      case 'localStorage':
        localStorage.setItem(`${this.salt}${key}`, JSON.stringify(value));
        break;
      case 'sessionStorage':
        sessionStorage.setItem(`${this.salt}${key}`, JSON.stringify(value));
        break;
    }
  }

  public remove(key: string) {
    switch (this.type) {
      case 'memory':
        this.store.delete(key);
        break;
      case 'localStorage':
        localStorage.removeItem(`${this.salt}${key}`);
        break;
      case 'sessionStorage':
        sessionStorage.removeItem(`${this.salt}${key}`);
        break;
    }
  }

  static getInstance(type?: 'localStorage' | 'sessionStorage' | 'memory') {
    if (!this.instace) {
      this.instace = new Storage(type);
    }
    return this.instace;
  }
}

export default Storage;

export const sessionIns = Storage.getInstance('sessionStorage');
export const localIns = Storage.getInstance('localStorage');
export const memoryIns = Storage.getInstance('memory');
