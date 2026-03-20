const { exec } = require("child_process");
const os = require("os");
require("dotenv").config();

class GammuService {
  constructor() {
    this.config = this.getConfigPath();
  }

  getConfigPath() {
    const platform = os.platform();

    if (platform === "win32") {
      return process.env.GAMMU_CONFIG_WINDOWS;
    } else {
      return process.env.GAMMU_CONFIG_LINUX;
    }
  }

  executeCommand(command) {
    return new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
        if (error) {
          return reject({
            success: false,
            error: error.message,
            stderr,
          });
        }

        resolve({
          success: true,
          data: stdout,
        });
      });
    });
  }

  async sendSMS(number, message) {
    try {
      const cmd = `gammu -c ${this.config} sendsms TEXT ${number} -text "${message}"`;
      return await this.executeCommand(cmd);
    } catch (err) {
      return err;
    }
  }

  async getAllSMS() {
    try {
      const cmd = `gammu -c ${this.config} getallsms`;
      return await this.executeCommand(cmd);
    } catch (err) {
      return err;
    }
  }

  async identify() {
    try {
      const cmd = `gammu -c ${this.config} identify`;
      return await this.executeCommand(cmd);
    } catch (err) {
      return err;
    }
  }
}

module.exports = new GammuService();