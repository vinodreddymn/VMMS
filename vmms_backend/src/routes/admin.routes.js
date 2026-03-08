import express from "express";
import * as controller from "../controllers/admin.controller.js";

const router = express.Router();

/* ================= USERS ================= */
router.post("/users", controller.createUser);
router.get("/users", controller.getUsers);
router.put("/users/:id", controller.updateUser);
router.delete("/users/:id", controller.deactivateUser);

/* ================= PROJECTS ================= */
router.post("/projects", controller.createProject);
router.get("/projects", controller.getProjects);
router.put("/projects/:id", controller.updateProject);
router.delete("/projects/:id", controller.deleteProject);

/* ================= DEPARTMENTS ================= */
router.post("/departments", controller.createDepartment);

/* ================= HOSTS ================= */
router.post("/hosts", controller.createHost);
router.get("/hosts", controller.getHosts);
router.put("/hosts/:id", controller.updateHost);

/* ================= GATES ================= */
router.post("/gates", controller.createGate);
router.get("/gates", controller.getGates);
router.put("/gates/:id", controller.updateGate);

/* ================= ROLES ================= */
router.get("/roles", controller.getRoles);
router.post("/roles", controller.createRole);
router.put("/roles/:id", controller.updateRole);

/* ================= DEPARTMENTS (FULL CRUD) ================= */
router.get("/departments", controller.getDepartments);
router.post("/departments", controller.createDepartment);
router.put("/departments/:id", controller.updateDepartment);
router.delete("/departments/:id", controller.deleteDepartment);

/* ================= ENTRANCES ================= */
router.get("/entrances", controller.getEntrances);
router.post("/entrances", controller.createEntrance);
router.put("/entrances/:id", controller.updateEntrance);
router.delete("/entrances/:id", controller.deleteEntrance);

/* ================= RFID STOCK (VISITORS) ================= */
router.get("/rfid-cards-stock", controller.getVisitorRFIDCardStock);
router.post("/rfid-cards-stock", controller.addVisitorRFIDCardStock);
router.delete("/rfid-cards-stock/:id", controller.markVisitorRFIDCardStockDamaged);

/* ================= RFID STOCK (LABOUR TOKENS) ================= */
router.get("/rfid-stock", controller.getLabourRFIDStock);
router.post("/rfid-stock", controller.addLabourRFIDStock);
router.delete("/rfid-stock/:id", controller.markLabourRFIDStockDamaged);

/* ================= HOST PROJECT ASSIGNMENT ================= */
router.get("/:id/projects", controller.getHostProjects);
router.post("/:id/projects", controller.assignProjectsToHost);
router.put("/:id/projects", controller.replaceHostProjects);
router.delete("/:id/projects/:projectId", controller.removeProjectFromHost);

export default router;
