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


-- drop materialized view  dv_pipeline_description.dvpd_model_profile cascade;

Create  view dv_pipeline_description.dvpd_model_profile as 
	
SELECT
	meta_inserted_at,
	lower(model_profile_name) model_profile_name,
	lower(property_name) property_name,
	property_value
FROM
	dv_pipeline_description.dvpd_model_profile_raw;

comment on view dv_pipeline_description.dvpd_model_profile is
 'available model profiles';

-- select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;