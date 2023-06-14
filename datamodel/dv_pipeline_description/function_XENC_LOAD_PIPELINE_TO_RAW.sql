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

--drop function XENC_LOAD_PIPELINE_TO_RAW(varchar);
create or replace function dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW(
   pipeline_to_load varchar
)
returns boolean
language plpgsql    
as 
$$
declare
   update_persisted_elements varchar; 
begin
	
/* Dont do anything when compiler is disabled */	
select property_value
INTO update_persisted_elements
FROM dv_pipeline_description.DVPD_COMPILER_SETTING
where property_name='update_persisted_elements';

if (not(update_persisted_elements::bool)) then
  return false;
end if;

	
	/* Load json scripts into relational raw model */
truncate table dv_pipeline_description.xenc_pipeline_dv_table_properties_raw ;

insert
	into
	dv_pipeline_description.xenc_pipeline_dv_table_properties_raw
(
 pipeline_name,
	table_name,
	xenc_content_hash_column_name,
	xenc_content_salted_hash_column_name,
	xenc_content_table_name,
	xenc_encryption_key_column_name,
	xenc_encryption_key_index_column_name,
	xenc_table_key_column_name)
select
	pipeline_name,
	table_name,
	xenc_content_hash_column_name,
	xenc_content_salted_hash_column_name,
	xenc_content_table_name,
	xenc_encryption_key_column_name,
	xenc_encryption_key_index_column_name,
	xenc_table_key_column_name
from
	dv_pipeline_description.xenc_transform_to_pipeline_dv_table_properties_raw;


REFRESH MATERIALIZED VIEW dv_pipeline_description.DVPD_PIPELINE_DV_TABLE;

REFRESH MATERIALIZED VIEW dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN;


return true;

end;
$$;


 comment on function dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW (profile_to_load varchar) is
 	'Helper function to convert and load encryption extenrion properties of the dvpd document into the relational tables';