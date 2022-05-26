--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE as 

select object_json->>'data_vault_model_profile_name' data_vault_model_profile_name
 ,json_object_keys(object_json) property_name
 ,object_json->>json_object_keys(object_json) property_value
from dv_pipeline_description.dvpd_json_storage 
where object_class ='model_profile';
;

