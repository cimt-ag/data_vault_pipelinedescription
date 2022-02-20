/* DV_MODEL_COLUMN REFERENCE DATA ARRAY */
select '["' 
 || dmc.table_name || '",'
 || coalesce(dmc.column_block,-1) || ',"'
 || coalesce(dmc.dv_column_class,'') || '","'
 || coalesce(dmc.column_name,'') || '","'
 || coalesce(dmc.column_type,'') || '"],'
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp
join dv_pipeline_description.dvpd_dv_model_column dmc  on  dmc.table_name =dmtpp.table_name 
   													and dmc.dv_column_class  <> 'meta'											
where dmtpp.pipeline ='test30_hub_dlink_sat'  													




/* STAGE_TABLE_COLUMN REFERENCE DATA ARRAY */
select '["' 
 || stage_column_name || '","'
 || coalesce(column_type,'null') || '",'
 || coalesce(column_block,-1) || ','
 || coalesce('"'||field_name||'"','null') || ','
 || coalesce('"'||field_type||'"','null') || ','
 || coalesce(encrypt::varchar,'null') || '],'
from dv_pipeline_description.dvpd_pipeline_stage_table_column									
where not is_meta   
and   pipeline ='test30_hub_dlink_sat'  													

