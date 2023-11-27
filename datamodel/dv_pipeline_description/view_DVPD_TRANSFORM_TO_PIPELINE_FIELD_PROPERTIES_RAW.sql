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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_PROPERTIES_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_PROPERTIES_RAW as

with raw_field_list as( 
Select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
	,json_array_elements(dvpd_json->'fields')->>'field_type' as field_type
	,json_array_elements(dvpd_json->'fields')->>'field_position' as explicit_field_position
	,json_array_elements(dvpd_json->'fields')->>'parsing_expression' as parsing_expression
	,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
	,json_array_elements(dvpd_json->'fields')->>'needs_encryption' as needs_encryption
	,row_number() over (PARTITION BY dvpd_json ->>'pipeline_name') as keep_array_order -- must onyl exist to provide originalarray order in resulset
from dv_pipeline_description.dvpd_dictionary dt
)
select
 pipeline_name
 ,field_name
 ,field_type
 ,coalesce(explicit_field_position::integer,row_number() over (PARTITION BY pipeline_name )) field_position
 ,parsing_expression
 ,needs_encryption :: boolean
 ,field_comment
from raw_field_list;


comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_PROPERTIES_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';


-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD order by pipeline ,field_position;

