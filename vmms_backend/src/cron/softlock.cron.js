import cron from "node-cron";
import { run as runSoftlock } from "../services/softlock.service.js";

let isRunning = false;

export default async function startSoftlockCron() {

const schedule = process.env.SOFTLOCK_CRON || "0 1 * * *";

console.log(`Softlock cron scheduled: ${schedule}`);

// Run once on startup
await executeSoftlock("startup");

// Schedule cron
cron.schedule(schedule, async () => {
await executeSoftlock("cron");
});
}

async function executeSoftlock(source) {

if (isRunning) {
console.log(`Softlock ${source} skipped (previous run still active)`);
return;
}

const startTime = Date.now();
isRunning = true;

console.log(`Softlock ${source} started`);

try {


const result = await runSoftlock();

const duration = ((Date.now() - startTime) / 1000).toFixed(2);

console.log(
  `Softlock ${source} completed in ${duration}s`,
  result ? `| affected: ${result.rowCount || "unknown"}` : ""
);


} catch (error) {


console.error(`Softlock ${source} error:`, error);


} finally {


isRunning = false;

}
}
