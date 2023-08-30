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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_PROPERTIES cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_PROPERTIES as 

SELECT
	lower(dpspr.pipeline_name) pipeline_name
	,storage_component
	,lower(stage_schema) stage_schema 
	,coalesce(lower(stage_table_name),'s'||lower(dpspr.pipeline_name)) stage_table_name
FROM 
	dv_pipeline_description.DVPD_PIPELINE_STAGE_PROPERTIES_RAW dpspr;

comment on view dv_pipeline_description.DVPD_PIPELINE_STAGE_PROPERTIES is
 'stage table properties of the pipeline. (cleansed and normalized)';


--  select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_PROPERTIES

