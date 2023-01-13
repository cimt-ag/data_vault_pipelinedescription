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


--drop view if exists dv_pipeline_description.XENC_ATMTST_ISSUE_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.XENC_ATMTST_ISSUE_PROCESS_COLUMN_MAPPING as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_process_column_mapping
)
,result_data as (
select 
 pwad.pipeline_name 
	,table_name 
	,process_block 
	,column_name 
	,column_type 
	,dv_column_class 
	,stage_column_name
	,content_stage_hash_column
	,content_table_name
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping ppstdmmc on ppstdmmc.pipeline_name  =pwad.pipeline_name 
where dv_column_class <>'meta'
)   													
, reference_data as ( 
select 
 pipeline_name  
	,table_name 
	,process_block 
	,column_name 
	,column_type 
	,dv_column_class 
	,stage_column_name
	,content_stage_hash_column
	,content_table_name
from dv_pipeline_description.xenc_atmtst_ref_process_column_mapping darpcm 
)
,not_in_reference as (
select * from result_data 
except 
select * from reference_data 
)
,only_in_reference as (
select * from reference_data
except 
select * from result_data 
)
select *,'not in reference' atmtst_issue_message
from not_in_reference 
union
select *,'only in reference' atmtst_issue_message
from only_in_reference 

);


comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_PROCESS_COLUMN_MAPPING IS
	'Shows all issues from automated testing of process_column_mapping, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


