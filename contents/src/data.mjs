import {Option, runCommand} from "./helpers.mjs";
import ServerInfo from "./serverInfo.mjs";

const SERVER_INFO_DATA = {};
const BRIDGE = Qt.createQmlObject(
  'import QtQuick 2.0; QtObject { signal serverListUpdate(var value) }',
  Qt.application,
  'QmlDataBridge'
);

let plasmoid;
let plasmoidRoot;
let path;

function onLoad(plasmoidInstance, root, basePath) {
  plasmoid = plasmoidInstance;
  plasmoidRoot = root;
  path = basePath;
  
  updateServerInfoList();
}

function onRefresh() {
  updateServerInfoList();
}

function getServerInfo(entry) {
  return entry.split(":").map(decodeURIComponent);
}

function getServerInfoList() {
  return plasmoid.configuration.serverList.map(getServerInfo);
}

function getMCPingPath() {
  return `${path}/bin/mcping-rs`;
}

function cleanupServerInfoData() {
  const addresses = getServerInfoList().map(e => e[1]);
  Object.keys(SERVER_INFO_DATA).forEach(key => {
    if (!addresses.includes(key)) {
      delete SERVER_INFO_DATA[key];
    }
  })
}

function updateServerInfo(name, address) {
  runCommand(`${getMCPingPath()} ${address}`, (_1, _2, stdout, _3) => {
    // console.log(stdout, _3);

    let serverInfo;

    try {
      const data = JSON.parse(stdout);

      serverInfo = Option.of(new ServerInfo(name, address, data)); 
    } catch (error) {
      serverInfo = Option.none();
    }

    SERVER_INFO_DATA[address] = serverInfo;
    cleanupServerInfoData();

    BRIDGE.serverListUpdate(SERVER_INFO_DATA);
  });
}

function getServerInfoData() {
  return SERVER_INFO_DATA;
}

function updateServerInfoList() {
  getServerInfoList().forEach(element => {
    updateServerInfo(...element);
  });
}

export {BRIDGE, SERVER_INFO_DATA, getServerInfoData, onLoad, onRefresh, path};