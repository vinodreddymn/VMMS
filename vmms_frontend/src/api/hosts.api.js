import axios from './axios';

export const getHostsByDepartment = (departmentId) =>
  axios.get(`/hosts?department_id=${departmentId}`);