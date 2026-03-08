import api from "./axios";

/* ================= USERS ================= */
export const getUsers = (params = {}) =>
  api.get("/admin/users", { params });

export const addUser = (data) =>
  api.post("/admin/users", data);

export const updateUser = (id, data) =>
  api.put(`/admin/users/${id}`, data);

export const deactivateUser = (id) =>
  api.delete(`/admin/users/${id}`);


/* ================= PROJECTS ================= */
export const getProjects = () =>
  api.get("/admin/projects");

export const addProject = (data) =>
  api.post("/admin/projects", data);

export const updateProject = (id, data) =>
  api.put(`/admin/projects/${id}`, data);

export const deleteProject = (id) =>
  api.delete(`/admin/projects/${id}`);


/* ================= HOSTS ================= */
export const getHosts = () =>
  api.get("/admin/hosts");

export const addHost = (data) =>
  api.post("/admin/hosts", data);

export const updateHost = (id, data) =>
  api.put(`/admin/hosts/${id}`, data);

// Optional (if backend later adds delete support)
export const deleteHost = (id) =>
  api.delete(`/admin/hosts/${id}`);


/* ================= GATES ================= */
export const getGates = () =>
  api.get("/admin/gates");

export const addGate = (data) =>
  api.post("/admin/gates", data);

export const updateGate = (id, data) =>
  api.put(`/admin/gates/${id}`, data);

// Optional delete (if backend supports later)
export const deleteGate = (id) =>
  api.delete(`/admin/gates/${id}`);


/* ================= ROLES ================= */
export const getRoles = () =>
  api.get("/admin/roles");

export const createRole = (data) =>
  api.post("/admin/roles", data);

export const updateRole = (id, data) =>
  api.put(`/admin/roles/${id}`, data);

// Optional delete (future support)
export const deleteRole = (id) =>
  api.delete(`/admin/roles/${id}`);

/* ================= ENTRANCES ================= */
export const getEntrances = () => api.get("/admin/entrances");
export const addEntrance = (data) => api.post("/admin/entrances", data);
export const updateEntrance = (id, data) => api.put(`/admin/entrances/${id}`, data);
export const deleteEntrance = (id) => api.delete(`/admin/entrances/${id}`);

/* ================= DEPARTMENTS ================= */
export const getDepartments = () => api.get("/admin/departments");
export const addDepartment = (data) => api.post("/admin/departments", data);
export const updateDepartment = (id, data) => api.put(`/admin/departments/${id}`, data);
export const deleteDepartment = (id) => api.delete(`/admin/departments/${id}`);

/* ================= VISITOR RFID STOCK ================= */
export const getVisitorRFIDCardStock = (params = {}) =>
  api.get("/admin/rfid-cards-stock", { params });

export const addVisitorRFIDCardStock = (data) =>
  api.post("/admin/rfid-cards-stock", data);

export const markVisitorRFIDCardStockDamaged = (id, data) =>
  api.delete(`/admin/rfid-cards-stock/${id}`, { data });

/* ================= LABOUR RFID STOCK ================= */
export const getLabourRFIDStock = (params = {}) =>
  api.get("/admin/rfid-stock", { params });

export const addLabourRFIDStock = (data) =>
  api.post("/admin/rfid-stock", data);

export const markLabourRFIDStockDamaged = (id, data) =>
  api.delete(`/admin/rfid-stock/${id}`, { data });
