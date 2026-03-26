import * as repo from '../repositories/master.repo.js';

export const fetchMasters = async () => {
  const [departments, projects, visitorTypes, hosts, gates, entrances] = await Promise.all([
    repo.getDepartments(),
    repo.getProjects(),
    repo.getVisitorTypes(),
    repo.getHosts(),
    repo.getGates(),
    repo.getEntrances(),
  ]);

  return { departments, projects, visitorTypes, hosts, gates, entrances };
};
