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


--drop view if exists dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_STAGE_PROPERTIES_RAW cascade;
create or replace view dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_STAGE_PROPERTIES_RAW as

with raw as (
Select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,json_array_elements(dvpd_json->'stage_properties')->>'storage_component' as storage_component
	,json_array_elements(dvpd_json->'stage_properties')->>'xenc_stage_schema' as xenc_stage_schema
	,json_array_elements(dvpd_json->'stage_properties')->>'xenc_stage_table_name' as xenc_stage_table_name
from dv_pipeline_description.dvpd_dictionary dt
)
select
pipeline_name ,
coalesce(storage_component,'') storage_component,
xenc_stage_schema,
xenc_stage_table_name
from raw;


comment on view dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_STAGE_PROPERTIES_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';


-- select * from dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_STAGE_PROPERTIES_RAW order by pipeline_name ,storage_component;

