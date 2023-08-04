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
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_stage_hash_input_field
)
,result_data as (
select 
	pshif.pipeline_name 
	--,relation_to_process
	,stage_column_name
	,field_name
	,mod(prio_in_key_hash,50000) prio_in_key_hash
	,mod(prio_in_diff_hash,50000) prio_in_diff_hash
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.dvpd_pipeline_stage_hash_input_field pshif on pshif.pipeline_name  =pwad.pipeline_name 
)   													
, reference_data as ( 
select 
	pipeline_name 
	--,relation_to_process
	,stage_column_name
	,field_name
	,prio_in_key_hash
	,prio_in_diff_hash
from dv_pipeline_description.dvpd_atmtst_ref_stage_hash_input_field
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


comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD IS
	'[Automated Testing]: Determine all issues about stage_hash_input_field'; 

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD ddmcc  order by 1,2,3,4,5;


