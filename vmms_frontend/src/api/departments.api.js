import axios from './axios';

export const getDepartments = () => axios.get('/departments');