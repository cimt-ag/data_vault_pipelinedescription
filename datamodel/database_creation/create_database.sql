/* 
 * must be executed as sysadmin (postgres) 
 * must be executed after establishing owner_dwh user
 */


CREATE DATABASE "dwh"
    WITH 
    OWNER = owner_dwh
    ENCODING = 'UTF8'
    LC_COLLATE = 'German_Germany.1252'
    LC_CTYPE = 'German_Germany.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;