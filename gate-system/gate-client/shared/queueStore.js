import { promises as fs } from "fs";
import path from "path";

const ensureFile = async (filePath) => {
  try {
    await fs.access(filePath);
  } catch {
    await fs.mkdir(path.dirname(filePath), { recursive: true });
    await fs.writeFile(filePath, JSON.stringify({ items: [] }, null, 2));
  }
};

export const createQueueStore = (baseDir, filename = "queue.json") => {
  const filePath = path.join(baseDir, filename);

  const read = async () => {
    await ensureFile(filePath);
    return JSON.parse(await fs.readFile(filePath));
  };

  const write = async (items) => {
    await fs.writeFile(filePath, JSON.stringify({ items }, null, 2));
  };

  const pushMany = async (newItems) => {
    const { items } = await read();
    const next = items.concat(newItems);
    await write(next);
    return next.length;
  };

  const shiftBatch = async (limit = 50) => {
    const { items } = await read();
    const batch = items.slice(0, limit);
    const remaining = items.slice(batch.length);
    if (batch.length) await write(remaining);
    return batch;
  };

  const size = async () => {
    const { items } = await read();
    return items.length;
  };

  return { filePath, read, write, pushMany, shiftBatch, size };
};
