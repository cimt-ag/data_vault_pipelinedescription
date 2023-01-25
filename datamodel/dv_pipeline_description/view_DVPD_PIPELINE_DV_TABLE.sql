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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE as 

select 
 lower(pdt.pipeline_name) as pipeline_name 
, lower(schema_name) as schema_name
, lower(table_name) as table_name
, lower(stereotype) as stereotype
, upper(hub_key_column_name)  as hub_key_column_name
, upper(link_key_column_name) as link_key_column_name
, upper(diff_hash_column_name) as diff_hash_column_name
, lower(satellite_parent_table) as satellite_parent_table
, coalesce(is_link_without_sat::bool,false) as is_link_without_sat
, coalesce(is_enddated ::bool,mp_is_endated_default.property_value ::bool) as is_enddated 
, lower(coalesce( pdt.model_profile_name,pp.model_profile_name )) model_profile_name
, table_content_comment
from dv_pipeline_description.dvpd_pipeline_dv_table_raw pdt
join dv_pipeline_description.dvpd_pipeline_properties pp on pp.pipeline_name =lower(pdt.pipeline_name )
left join dv_pipeline_description.dvpd_model_profile mp_is_endated_default on mp_is_endated_default.model_profile_name = lower(coalesce( pdt.model_profile_name,pp.model_profile_name )) 
													   and mp_is_endated_default.property_name ='is_enddated_default'
;

comment on view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE is
 'Tables of the pipeline. (cleansed and normalized)'; 

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE ;