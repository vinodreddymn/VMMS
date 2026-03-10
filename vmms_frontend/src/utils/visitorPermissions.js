export const normalizeRole = (user) => {
  const role = user?.role || user?.role_name || "USER"
  return String(role).toUpperCase().trim()
}

export const canCreateVisitor = (role) => ["ADMIN", "SUPER_ADMIN", "REGULATING_PETTY_OFFICER", "ENROLLMENT_STAFF_VISITORS"].includes(role)

export const canEditVisitor = (role) =>
  ["ADMIN", "SUPER_ADMIN", "REGULATING_PETTY_OFFICER", "ENROLLMENT_STAFF_VISITORS"].includes(role)
