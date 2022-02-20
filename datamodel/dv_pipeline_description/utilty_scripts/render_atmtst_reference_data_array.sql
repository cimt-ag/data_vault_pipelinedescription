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
