import { createClient } from "redis";
import env from "./env.js";
const client = createClient({
  socket: {
    host: env.redis.host,
    port: env.redis.port,
  },
});

client.connect().then(() => {
  console.log("Redis Connected");
});

export default client;