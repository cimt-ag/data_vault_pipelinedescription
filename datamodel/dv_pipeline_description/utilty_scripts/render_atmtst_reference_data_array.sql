with target as (
select distinct pipeline
from dv_pipeline_description.dvpd_pipeline_target_table
where pipeline like 'test70%'
)
select 1 block
,'DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = '''||pipeline||''';' script
from target
union
select 2 block
,'INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES' script
union
select 9 block
,'('''||pipeline||''',''{' script
from target
union
-- >>> DV_MODEL_COLUMN REFERENCE DATA ARRAY <<<
select 10 block, ' "dv_model_column": [' script
union
select 11 block
,'         ["' 
 || dptt.schema_name  || '","'
 || dmc.table_name || '",'
 || coalesce(dmc.column_block,-1) || ',"'
 || coalesce(dmc.dv_column_class,'') || '","'
 || coalesce(dmc.column_name,'') || '","'
 || coalesce(dmc.column_type,'') || '"],'
from dv_pipeline_description.dvpd_pipeline_target_table dptt  
join dv_pipeline_description.dvpd_dv_model_column dmc  on  dmc.table_name =dptt.table_name 
   													and dmc.dv_column_class  <> 'meta'											
where pipeline in (select pipeline from target) 
union
select 12 block
,' ],'
union
-- >>> STAGE_TABLE_COLUMN REFERENCE DATA ARRAY <<<<
select 20 block, ' "stage_table_column": [' script
union 
select 21 block
,'         ["' 
 || stage_column_name || '","'
 || coalesce(column_type,'null') || '",'
 || coalesce(column_block,-1) || ','
 || coalesce('"'||field_name||'"','null') || ','
 || coalesce('"'||field_type||'"','null') || ','
 || coalesce(needs_encryption::varchar,'false') || '],'
from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN								
where not is_meta   
and   pipeline in (select pipeline from target) 
union
select 22 block
,' ],'union
-- >>> STAGE_HASH_INPUT_FIELD DATA ARRAY <<<
select 30 block, ' "stage_hash_input_field": [' script
union
select 31 block
,'         ["' 
 || coalesce(process_block,'null') || '","'
 || stage_column_name || '","'
 || field_name || '",'
 || prio_in_key_hash || ','
 || prio_in_diff_hash  || '],' script
from dv_pipeline_description.dvpd_pipeline_stage_hash_input_field								
where   pipeline in (select pipeline from target) 	
union
select 80 block
,'  ]    }'');' script
order by block,script

