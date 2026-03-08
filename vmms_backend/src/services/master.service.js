import * as repo from '../repositories/master.repo.js';

export const fetchMasters = async () => {
  const [departments, projects, visitorTypes, hosts, gates] = await Promise.all([
    repo.getDepartments(),
    repo.getProjects(),
    repo.getVisitorTypes(),
    repo.getHosts(),
    repo.getGates(),
  ]);

  return { departments, projects, visitorTypes, hosts, gates };
};
