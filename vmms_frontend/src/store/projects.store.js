import { create } from 'zustand';
import { getProjectsByDepartment } from '../api/projects.api';

const useProjectsStore = create((set, get) => ({
  // State
  projectsByDept: {}, // { [departmentId]: [projects] }
  loading: false,

  // Fetch projects for a department (with caching)
  async fetchByDepartment(departmentId) {
    if (!departmentId) return [];

    const cache = get().projectsByDept;
    if (cache[departmentId]) {
      return cache[departmentId]; // return cached data
    }

    set({ loading: true });

    try {
      const res = await getProjectsByDepartment(departmentId);
      const data = res.data?.data || res.data || [];

      set((state) => ({
        projectsByDept: {
          ...state.projectsByDept,
          [departmentId]: data,
        },
        loading: false,
      }));

      return data;
    } catch (error) {
      console.error('Failed to fetch projects:', error);
      set({ loading: false });
      return [];
    }
  },

  // Helper to get projects instantly from cache
  getProjects(departmentId) {
    return get().projectsByDept[departmentId] || [];
  },

  // Clear cache if needed (e.g., admin updates)
  clearCache() {
    set({ projectsByDept: {} });
  },
}));

export default useProjectsStore;