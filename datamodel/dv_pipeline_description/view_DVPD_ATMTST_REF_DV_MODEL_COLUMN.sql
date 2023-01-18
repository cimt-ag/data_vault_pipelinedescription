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


--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN cascade;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'dv_model_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 schema_name
	,table_row->>1 table_name
	,(table_row->>2) :: int column_block
	,table_row->>3 dv_column_class
	,table_row->>4 column_name
	,table_row->>5 column_type
from parsed_dvmodel_column 

);
 

comment on view dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN IS
	'[Automated Testing]: Determine all issues about dv_model_columns';

-- select * from dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN ddmc  order by 1,2,3,4,5;
