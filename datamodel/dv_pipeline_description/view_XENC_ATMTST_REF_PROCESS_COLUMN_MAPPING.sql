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


--drop view if exists dv_pipeline_description.XENC_ATMTST_REF_PROCESS_COLUMN_MAPPING;
create or replace view dv_pipeline_description.XENC_ATMTST_REF_PROCESS_COLUMN_MAPPING as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'xenc_process_column_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 table_name
	,table_row->>1 process_block
	,table_row->>2 column_name
	,table_row->>3 column_type
	,table_row->>4 dv_column_class
	,table_row->>5 stage_column_name
	,table_row->>6 content_stage_hash_column
	,table_row->>7 content_table_name
from parsed_dvmodel_column 

);
 
 comment on view dv_pipeline_description.XENC_ATMTST_REF_PROCESS_COLUMN_MAPPING IS
	'[Automated Testing/encryption]: Technical view to convert reference data from json array into a table (contains postgres json syntax)';
