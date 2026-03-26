import db from '../config/db.js';

export const getDepartments = async () => {
  const { rows } = await db.query(
    `SELECT id, department_name 
     FROM departments 
     WHERE is_active = true 
     ORDER BY department_name`
  );
  return rows;
};

export const getProjects = async () => {
  const { rows } = await db.query(
    `SELECT 
        id, 
        project_name, 
        department_id
     FROM projects 
     WHERE is_active = true 
     ORDER BY project_name`
  );
  return rows;
};

export const getVisitorTypes = async () => {
  const { rows } = await db.query(
    `SELECT id, type_name 
     FROM visitor_types 
     ORDER BY type_name`
  );
  return rows;
};


export const getHosts = async () => {

  const { rows } = await db.query(`
    SELECT 
      h.id,
      h.host_name,
      h.department_id,
      COALESCE(
        json_agg(
          json_build_object(
            'project_id', p.id,
            'project_name', p.project_name
          )
        ) FILTER (WHERE p.id IS NOT NULL),
        '[]'
      ) AS projects
    FROM hosts h
    LEFT JOIN host_projects hp ON hp.host_id = h.id
    LEFT JOIN projects p ON p.id = hp.project_id
    WHERE h.is_active = TRUE
    GROUP BY h.id
    ORDER BY h.host_name
  `)

  return rows
}

export const getGates = async () => {
  const { rows } = await db.query(
    `SELECT id, gate_name, entrance_id 
     FROM gates 
     WHERE is_active = true 
     ORDER BY gate_name`
  );
  return rows;
};

export const getEntrances = async () => {
  const { rows } = await db.query(
    `SELECT id, entrance_name 
     FROM entrances 
     ORDER BY entrance_name`
  );
  return rows;
};
