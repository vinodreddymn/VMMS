export const normalizeRole = (user) => {
  const role = user?.role || user?.role_name || "USER"
  return String(role).toUpperCase().trim()
}

export const canCreateVisitor = (role) => role === "ENROLLMENT_STAFF_VISITORS"

export const canEditVisitor = (role) =>
  ["ADMIN", "SUPER_ADMIN", "REGULATING_PETTY_OFFICER"].includes(role)
