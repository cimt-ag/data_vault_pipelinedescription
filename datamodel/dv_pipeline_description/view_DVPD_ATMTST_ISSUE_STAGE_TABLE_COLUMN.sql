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


--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_stage_table_column
)
,result_data as (
select 
 pstc.pipeline_name
 ,stage_column_name
 ,column_type
 ,column_block
 ,coalesce(field_name,'') field_name
 ,coalesce(field_type,'')  field_type
 ,coalesce(pstc.needs_encryption ,false) encrypt
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.dvpd_pipeline_stage_table_column pstc on pstc.pipeline_name  =pwad.pipeline_name 
	   													and not pstc.is_meta 			   													
)   													
, reference_data as ( 
select 
 pipeline_name  
 ,stage_column_name
 ,column_type
 ,column_block
 ,coalesce(field_name,'') field_name 
 ,coalesce(field_type,'') field_type
 ,encrypt
from dv_pipeline_description.dvpd_atmtst_ref_stage_table_column
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


comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN IS
	'Shows all issues from automated testing of stage_table_columns, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


