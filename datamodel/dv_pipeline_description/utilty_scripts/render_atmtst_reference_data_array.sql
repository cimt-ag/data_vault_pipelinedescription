/* DV_MODEL_COLUMN REFERENCE DATA ARRAY */
select '["' 
 || dptt.schema_name  || '","'
 || dmc.table_name || '",'
 || coalesce(dmc.column_block,-1) || ',"'
 || coalesce(dmc.dv_column_class,'') || '","'
 || coalesce(dmc.column_name,'') || '","'
 || coalesce(dmc.column_type,'') || '"],'
from dv_pipeline_description.dvpd_pipeline_target_table dptt  
join dv_pipeline_description.dvpd_dv_model_column dmc  on  dmc.table_name =dptt.table_name 
   													and dmc.dv_column_class  <> 'meta'											
where dptt.pipeline like 'test27%'  													




/* STAGE_TABLE_COLUMN REFERENCE DATA ARRAY */
select '["' 
 || stage_column_name || '","'
 || coalesce(column_type,'null') || '",'
 || coalesce(column_block,-1) || ','
 || coalesce('"'||field_name||'"','null') || ','
 || coalesce('"'||field_type||'"','null') || ','
 || coalesce(is_encrypted::varchar,'false') || '],'
from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN								
where not is_meta   
and   pipeline like 'test27%'  													


/* STAGE_HASH_INPUT_FIELD DATA ARRAY */
select 1 block, ' "stage_hash_input_field": [' script
union
select 2 block
,'         ["' 
 || coalesce(process_block,'null') || '","'
 || stage_column_name || '","'
 || field_name || '",'
 || prio_in_hashkey || ','
 || prio_in_diff_hash  || '],' script
from dv_pipeline_description.dvpd_pipeline_stage_hash_input_field								
where   pipeline like 'test99%'  	
order by block,script