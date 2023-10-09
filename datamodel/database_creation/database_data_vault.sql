-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================

/*
 * must be executed as sysadmin (postgres) 
 * must be executed after establishing owner_dwh user
 */


CREATE DATABASE "data_vault"
    WITH 
    OWNER = owner_data_vault
    ENCODING = 'UTF8'
    LC_COLLATE = 'de_DE.utf8'
    LC_CTYPE = 'de_DE.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
   template template0;
    
