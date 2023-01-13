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

--drop functiondv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(varchar);
create or replace function dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(
   profile_to_load varchar
)
returns boolean
language plpgsql    
as 
$$
begin
	
	/* Load json scripts into relational raw model */
truncate table dv_pipeline_description.dvpd_model_profile_raw;
INSERT INTO dv_pipeline_description.dvpd_model_profile_raw
(model_profile_name,
property_name,
property_value)
SELECT
	model_profile_name,
property_name,
property_value
FROM
	dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE;


REFRESH MATERIALIZED VIEW dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;

return true;

end;
$$;
