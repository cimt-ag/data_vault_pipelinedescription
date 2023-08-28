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




-- DROP SCHEMA RVLT_TEST_KK;

CREATE schema if not EXISTS RVLT_TEST_KK WITH MANAGED ACCESS;

COMMENT ON SCHEMA RVLT_TEST_KK
  IS 'Input data for tests';
  
grant usage on schema RVLT_TEST_KK to role dvf_z_process;
grant select, insert, update, delete on future tables in schema RVLT_TEST_KK to role dvf_z_process;
grant select                         on future views in schema RVLT_TEST_KK to role dvf_z_process;
grant usage on future procedures in schema RVLT_TEST_KK to role dvf_z_process;
