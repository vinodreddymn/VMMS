import initSocket, {
  emitEvent,
  updateStats,
  emitAccessEvent,
} from "./sockets/realtime.socket.js";

export default initSocket;
export { emitEvent, updateStats, emitAccessEvent };
