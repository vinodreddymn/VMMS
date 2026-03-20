export const log = (...args) => {
  console.log('[LOG]', new Date().toISOString(), ...args);
};

export const error = (...args) => {
  console.error('[ERR]', new Date().toISOString(), ...args);
};
