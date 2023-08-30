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




-- DROP SCHEMA DV_PIPELINE_DESCRIPTION;

CREATE schema if not EXISTS DV_PIPELINE_DESCRIPTION WITH MANAGED ACCESS;

COMMENT ON SCHEMA DV_PIPELINE_DESCRIPTION
  IS 'Storage and  projections of the dvdp for running the data vault pipelines';
  
grant usage on schema DV_PIPELINE_DESCRIPTION to role dvf_z_process;
grant select, insert, update, delete on future tables in schema DV_PIPELINE_DESCRIPTION to role dvf_z_process;
grant select                         on future views in schema DV_PIPELINE_DESCRIPTION to role dvf_z_process;
grant usage on future procedures in schema DV_PIPELINE_DESCRIPTION to role dvf_z_process;
