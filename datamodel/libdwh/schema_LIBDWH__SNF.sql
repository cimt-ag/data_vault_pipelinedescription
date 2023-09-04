

-- DROP SCHEMA "LIBDWH";

CREATE schema if not EXISTS "LIBDWH" WITH MANAGED ACCESS;

COMMENT ON SCHEMA "LIBDWH"
  IS 'Schema containg functions and procedures for data warehouse processing and querying';


grant usage on schema LIBDWH to role dvf_z_process;
grant select, insert, update, delete on future tables in schema LIBDWH to role dvf_z_process;
grant select                         on future views in schema LIBDWH to role dvf_z_process;
grant usage on future procedures in schema LIBDWH to role dvf_z_process;
grant usage on future functions in schema LIBDWH to role dvf_z_process;
