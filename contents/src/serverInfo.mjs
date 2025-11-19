import { safeDig } from "./helpers.mjs";
import { path } from "./data.mjs";

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
    return safeDig(this._data, "favicon") || `file://${path}assets/images/pack.png`;
  }

  summaryText() {
    let output = `<b>${this.name}:</b> `;

    if (this.getPlayerCount() < 1) {
      output += "Empty";
    } else {
      output += `${this.getPlayerCount()} online`;
    }

    return output;
  }

  playerInfo() {
    const players = this.getOnlinePlayers();
    const playerCount = this.getPlayerCount();

    if (playerCount < 1) return `No players are on ${this.name}.`;
    if (players.length < 1) return `${playerCount} players are on ${this.name}.`;

    let playerList = players.join("\n");

    if (players.length < playerCount) playerList += "\nand more..."

    return `Players on ${this.name}:\n${playerList}`;
  }

  serialize() {
    return {
      playerCount: this.getPlayerCount(),
      playerMax: this.getPlayerMax(),
      onlinePlayers: this.getOnlinePlayers(),
      icon: this.getIcon(),
    }
  }
}

export default ServerInfo;