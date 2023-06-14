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


--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN as (
 
with 
pipelines_with_atmtst_data as (
select pipeline_name
, sum(case when column_class = 'meta' then 1 else 0 end) ref_meta_count
from dv_pipeline_description.dvpd_atmtst_ref_dv_model_column
group by pipeline_name
)
,result_data as (
select 
 pwad.pipeline_name 
 ,pdt.schema_name 
 ,pdc.table_name 
 ,pdc.column_block 
 ,pdc.column_class 
 ,pdc.column_name 
 ,pdc.column_type 
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN pdc  on  pdc.pipeline_name =pwad.pipeline_name 
   													and (pdc.column_class  <> 'meta' or 	ref_meta_count>0) -- ignore meta columns in result when no meta column is in reference
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.pipeline_name =  pwad.pipeline_name 
													and pdt.table_name = pdc.table_name 
)   													
, reference_data as ( 
select 
 pipeline_name 
 ,schema_name
 ,table_name 
 ,column_block 
 ,column_class 
 ,column_name 
 ,column_type 
from dv_pipeline_description.dvpd_atmtst_ref_dv_model_column
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

comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN IS
	'[Automated Testing]: Determine all issues about  dv_model_column';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


