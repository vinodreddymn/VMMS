const rbac = (allowedRoles = []) => {
  return (req, res, next) => {
    try {
      if (!req.user || !allowedRoles.includes(req.user.role)) {
        return res.status(403).json({ message: "Access Denied" });
      }

      next();
    } catch (error) {
      return res.status(500).json({ message: "RBAC Middleware Error" });
    }
  };
};

export default rbac;