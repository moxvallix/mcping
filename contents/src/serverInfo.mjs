import { safeDig } from "./helpers.mjs";

class ServerInfo {
  constructor(name, address, data) {
    this.name = name;
    this.address = address;
    this._data = data;
  }
  
  getPlayerCount() {
    return safeDig(this._data, "players", "online") || 0
  }

  getPlayerMax() {
    return safeDig(this._data, "players", "max") || 20
  }

  getOnlinePlayers() {
    return (safeDig(this._data, "players", "sample") || []).map(e => e.name);
  }

  getIcon() {
    return safeDig(this._data, "favicon") || Qt.resolvedUrl("../assets/images/pack.png");
  }
}

export default ServerInfo;