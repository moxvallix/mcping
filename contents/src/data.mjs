import {runCommand} from "./helpers.mjs";
import ServerInfo from "./serverInfo.mjs";

const MCPING_PATH = Qt.resolvedUrl("../bin/mcping-rs").toString().replace("file://", "");
const SERVER_INFO_DATA = {};

let plasmoid;

function onLoad(plasmoidInstance) {
  plasmoid = plasmoidInstance;
  runCommand("date", (_1, _2, stdout, _3) => console.log(stdout));
}

function getServerName(entry) {
  const [name, _] = entry.split(":").map(decodeURIComponent);

  return name;
}

function getServerAddress(entry) {
  const [_, address] = entry.split(":").map(decodeURIComponent);

  return address;
}

function getAddressList() {
  return plasmoid.configuration.serverList.map(getServerAddress);
}

function updateServerInfo(name, address) {
  runCommand(`${MCPING_PATH} ${address}`, (_1, _2, stdout, _3) => {
    SERVER_INFO_DATA[address] = new ServerInfo(name, address, JSON.parse(stdout));
  });
}

export {onLoad};