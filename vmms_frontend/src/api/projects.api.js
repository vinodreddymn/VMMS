import axios from './axios';

export const getProjectsByDepartment = (departmentId) =>
  axios.get(`/projects?department_id=${departmentId}`);