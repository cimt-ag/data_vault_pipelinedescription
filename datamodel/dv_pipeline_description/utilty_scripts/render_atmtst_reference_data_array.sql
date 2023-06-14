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



with target as (
select distinct pipeline_name
from dv_pipeline_description.dvpd_pipeline_DV_table
where pipeline_name like 'test25%'
) /* */
select 1 block
,1 reverse_order
,'-- vvvvv Reference data for automated testing of dvpd implementation vvvv' script
from target
union
select 5 block
,1 reverse_order
,'DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = '''||pipeline_name||''';' script
from target
union
select 8 block
,1 reverse_order
,'INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES' script
union
select 9 block
,1 reverse_order
,'('''||pipeline_name||''',''{' script
from target
union
-- >>> DV_MODEL_COLUMN REFERENCE DATA ARRAY <<<
select 10 block 
,1 reverse_order 
,' "dv_model_column": [' script
union
select 11 block
,reverse_order
,'      ["' 
 || schema_name  || '","'
 || table_name || '",'
 || column_block || ',"'
 || column_class || '","'
 || column_name || '","'
 || column_type || '"]'
 ||(case when reverse_order=1 then '' else ',' end)
from (
	select 
	rank () OVER (order by dmc.pipeline_name desc, schema_name desc, dmc.table_name desc, column_block desc, column_name desc ) reverse_order
	, dptt.schema_name  
	, dmc.table_name 
	,coalesce(dmc.column_block,-1) column_block
	,coalesce(dmc.column_class,'') column_class
	,coalesce(dmc.column_name,'')  column_name
	,coalesce(dmc.column_type,'')  column_type
	from dv_pipeline_description.dvpd_pipeline_dv_table dptt  
	join dv_pipeline_description.dvpd_pipeline_dv_column dmc  on  dmc.table_name =dptt.table_name 
	   													--and dmc.column_class  <> 'meta'	
	   													and dmc.pipeline_name =dptt.pipeline_name 
where dptt.pipeline_name in (select pipeline_name from target) 
) the_data
union
select 12 block
,1 reverse_order
,' ],'
union
-- >>> PROCESS COLUMN MAPPING DATA ARRAY <<<<
select 15 block
,1 reverse_order
, ' "process_column_mapping": [' script
union 
select 16 block
,reverse_order
,'         ["' 
 || table_name || '","'
 || process_block  || '","'
 || column_name || '","'
 || stage_column_name || '",'
 || coalesce('"'||field_name||'"','null') || ']'
 ||(case when reverse_order=1 then '' else ',' end)
from (
	select 
	 rank () OVER (order by table_name desc ,process_block desc ,column_block desc, column_name desc ) reverse_order
	,table_name 
	,process_block 
	,column_name 
	,stage_column_name
	,field_name 
	from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping								
	where  column_class not in ('meta')
	and  pipeline_name in (select pipeline_name from target) 
	) the_data
union
select 17 block
,1 reverse_order
,' ],'
union
-- >>> STAGE_TABLE_COLUMN REFERENCE DATA ARRAY <<<<
select 20 block
,1 reverse_order 
, ' "stage_table_column": [' script
union 
select 21 block
,reverse_order 
,'         ["' 
 || stage_column_name || '","'
 || coalesce(column_type,'null') || '",'
 ||column_block || ','
 || coalesce('"'||field_name||'"','null') || ','
 || coalesce('"'||field_type||'"','null') || ','
 || needs_encryption || ']'
 ||(case when reverse_order=1 then '' else ',' end) 
from (
	select 
		rank () OVER (order by column_block desc,stage_column_name desc ) reverse_order
		,stage_column_name
		,column_type
		,coalesce(column_block,-1) column_block
		,field_name
		,field_type
		,coalesce(needs_encryption::varchar,'false') needs_encryption
	from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN								
	where not is_meta   
	and   pipeline_name in (select pipeline_name from target) 
	) the_data
union
select 22 block
,1 reverse_order 
,' ],'
union
-- >>> STAGE_HASH_INPUT_FIELD DATA ARRAY <<<
select 30 block
,1 reverse_order 
, ' "stage_hash_input_field": [' script
union
select 31 block
,reverse_order 
,'         ["' 
 || coalesce(process_block,'null') || '","'
 || stage_column_name || '","'
 || field_name || '",'
 || prio_in_key_hash || ','
 || prio_in_diff_hash  || ']'
 ||(case when reverse_order=1 then '' else ',' end) 
from ( 	
	select 
	 rank () OVER (order by process_block  desc,stage_column_name desc, field_name desc ) reverse_order
	 ,process_block
	 , stage_column_name 
	 , field_name 
	 , prio_in_key_hash 
	 , prio_in_diff_hash  
	from dv_pipeline_description.dvpd_pipeline_stage_hash_input_field								
	where   pipeline_name in (select pipeline_name from target) 	
	) the_data 
union
select 32 block
,1 reverse_order 
,' ],'
union
-- >>> XENC PROCESS COLUMN MAPPING DATA ARRAY <<<<
select 60 block
,1 reverse_order
, ' "xenc_process_column_mapping": [' script
union 
/**/
select 61 block
,reverse_order
,'         ["' 
 || table_name || '","'
 || process_block  || '","'
 || column_name || '","'
 || column_type || '","'
 || column_class || '","'
 || stage_column_name || '",'
 || coalesce('"'||content_stage_hash_column||'"','null') ||','
 || coalesce('"'||content_table_name||'"','null') || ']'
 ||(case when reverse_order=1 then '' else ',' end)
from (
	select 
	 rank () OVER (order by table_name desc ,process_block desc ,column_block desc, column_name desc ) reverse_order
	,table_name 
	,process_block 
	,column_name 
	,column_type
	,column_class 
	,stage_column_name
	,content_stage_hash_column
	,content_table_name
	from dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping								
	where  column_class not in ('meta')
	and  pipeline_name in (select pipeline_name from target) 
	) the_data
	union
select 63 block
,1 reverse_order 
,' ],'
union
-- >>> XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING ARRAY<<<<
select 64 block
,1 reverse_order
, ' "xenc_process_field_to_encryption_key_mapping": [' script
union 
/* */
select 65 block
,reverse_order
,'         ["' 
 || process_block  || '","'
 || field_name || '","'
 || content_stage_column_name || '","'
 || encryption_key_stage_column_name || '",'
 || stage_map_rank ||  ']'
 ||(case when reverse_order=1 then '' else ',' end)
from (
	select 
	 rank () OVER (partition by pipeline_name order by process_block desc ,field_name desc, content_stage_column_name desc ) reverse_order
	,pipeline_name  
	,process_block 
	,field_name  
	,content_stage_column_name
	,encryption_key_stage_column_name 
	,stage_map_rank
	from dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING								
	where  pipeline_name in (select pipeline_name from target) 
	) the_data
union	
select 80 block
,1 reverse_order 
,'  ]    }'');' script
order by block,reverse_order desc

