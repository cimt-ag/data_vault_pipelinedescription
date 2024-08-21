/*
 * This script needs to be executed as sysadmin ("postgres")
 * Exectution has to be done statement by statement
 * The result of the generator script has to be executed also 
 */

CREATE USER owner_data_vault WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  CREATEDB
  NOCREATEROLE
  NOREPLICATION;
  
alter user owner_data_vault with password 'djPN44PPBc094eOi5DfY'; -- <==== changepasssword before execution but dont save to git
