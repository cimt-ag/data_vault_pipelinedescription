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


drop view if exists dv_pipeline_description.DVPD_DV_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_DV_TABLE as 

select distinct 
	schema_name
	,table_name
	,stereotype
	,hub_key_column_name
	,link_key_column_name
	,diff_hash_column_name
	,satellite_parent_table 
	,is_link_without_sat
	,is_historized
from dv_pipeline_description.dvpd_pipeline_dv_table;

-- select * From dv_pipeline_description.DVPD_DV_MODEL_TABLE;


