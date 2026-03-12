import api from "./axios"

// Public/media list for playback
export const getMediaFiles = () => api.get("/media")

// Admin endpoints
export const uploadMediaFile = (formData) =>
  api.post("/admin/media", formData, {
    headers: { "Content-Type": "multipart/form-data" }
  })

export const deleteMediaFile = (id) => api.delete(`/admin/media/${id}`)

export const getAdminMediaFiles = () => api.get("/admin/media")

