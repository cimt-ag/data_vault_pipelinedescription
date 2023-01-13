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


-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_DRIVING_KEY cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_DRIVING_KEY as 

SELECT
	meta_inserted_at
	,pipeline_name
	,lower(table_name) table_name
	,upper(driving_key) driving_key
FROM
	dv_pipeline_description.dvpd_pipeline_dv_table_driving_key_raw;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;