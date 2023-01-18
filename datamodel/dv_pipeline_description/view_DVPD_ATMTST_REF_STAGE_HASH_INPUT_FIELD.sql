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


--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_STAGE_HASH_INPUT_FIELD;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_STAGE_HASH_INPUT_FIELD as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_hash_input_field') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 process_block
	,table_row->>1 stage_column_name
	,table_row->>2 field_name
	,(table_row->>3)::int prio_in_key_hash
	,(table_row->>4)::int prio_in_diff_hash
from parsed_dvmodel_column 

);
 
 
comment on view dv_pipeline_description.DVPD_ATMTST_REF_STAGE_HASH_INPUT_FIELD IS
	'[Automated Testing]: Technical view to convert reference data from json array into a table (contains postgres json syntax)'; 