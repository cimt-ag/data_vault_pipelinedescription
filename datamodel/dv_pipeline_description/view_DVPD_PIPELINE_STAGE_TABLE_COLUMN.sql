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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN as

with pipeline_model_profile AS (
select distinct pipeline_name ,model_profile_name
from dv_pipeline_description.dvpd_pipeline_dv_table
)
, pipelines AS(
select distinct pp.pipeline_name ,pmp.model_profile_name
from dv_pipeline_description.dvpd_pipeline_properties_raw pp
left join pipeline_model_profile pmp on pmp.pipeline_name= pp.pipeline_name 
)
select distinct 
	pipeline_name 
	,stage_column_name
	,column_type 
	,false is_meta
	,(ppstdmm.column_class  in ('content','business_key','content_untracked')) is_nullable
	,field_name
	,field_type
	,needs_encryption
	,min(coalesce(cbc.stage_column_block,999)) column_block
	,min(table_name) min_table_name
	,min(column_name) min_column_name
from  dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm
left join dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION cbc on cbc.column_class = ppstdmm.column_class 
																and (cbc.table_stereotype =  ppstdmm.table_stereotype  or cbc.table_stereotype is null)
group by 1,2,3,4,5,6,7,8
union 
select
	pp.pipeline_name 
	,mpmcl.meta_column_name 
	,mpmcl.meta_column_type 
	,true is_meta
	,false is_nullable
	,null field_name 
	,null field_type 
	,false needs_encryption 
	, 1 as column_block
	,'-' min_table_name
	,'-' min_column_name
from pipelines pp
left join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl 
										on mpmcl.model_profile_name = pp.model_profile_name 
										and mpmcl.table_stereotype ='_stg' ;

comment on view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN is
 'list of columns, that need to be in the stage table of the pipeline.';
									
									
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline_name,column_block,min_column_class,min_table_name,min_column_name,stage_column_name									