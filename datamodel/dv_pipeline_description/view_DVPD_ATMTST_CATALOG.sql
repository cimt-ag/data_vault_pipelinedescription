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


--drop view if exists dv_pipeline_description.DVPD_ATMTST_CATALOG;
create or replace view dv_pipeline_description.DVPD_ATMTST_CATALOG as 

with expanded_dv_model_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'dv_model_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_dv_model_table_count as (
select distinct
	pipeline_name 
	,count(distinct table_row->>0 ) table_count
from expanded_dv_model_column 
group by pipeline_name 
)
, expanded_process_column_mapping as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'process_column_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_process_column_mapping as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_process_column_mapping 
)
, expanded_stage_table_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_table_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_stage_table_count as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_stage_table_column 
)
, expanded_stage_hash_input_field as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_hash_input_field') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_stage_hash_input_field as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_stage_hash_input_field 
)
, expanded_xenc_process_column_mapping as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'xenc_process_column_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_xenc_process_column_mapping as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_xenc_process_column_mapping 
)
, expanded_xenc_process_field_to_encryption_key_mapping as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'xenc_process_field_to_encryption_key_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_xenc_process_field_to_encryption_key_mapping as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_xenc_process_field_to_encryption_key_mapping 
)
select 
 coalesce(admtc.pipeline_name ,astc.pipeline_name ) pipeline_name 
 , admtc.table_count  dv_model_test_count
 , apcm.table_count  process_column_mapping_test_count
 , astc.table_count  stage_model_test_count
 ,ashif.table_count  stage_input_field_test_count
 ,asxpcm.table_count  xecn_process_column_mapping_test_count
 ,asxpfek.table_count  xecn_process_field_to_encryption_key_mapping
from atmtst_dv_model_table_count admtc
full outer join atmtst_process_column_mapping  apcm using(pipeline_name) 
full outer join atmtst_stage_table_count  astc using(pipeline_name) 
full outer join atmtst_stage_hash_input_field ashif using(pipeline_name)
full outer join atmtst_xenc_process_column_mapping asxpcm using(pipeline_name)
full outer join atmtst_xenc_process_field_to_encryption_key_mapping asxpfek using(pipeline_name)
order by pipeline_name 
;
 
comment on view dv_pipeline_description.DVPD_ATMTST_CATALOG IS
	'[Automated Testing]: Overview about available reference data used for automated test of dvpd implementation';
 
-- select * from dv_pipeline_description.DVPD_ATMTST_CATALOG ddmc  order by 1;
