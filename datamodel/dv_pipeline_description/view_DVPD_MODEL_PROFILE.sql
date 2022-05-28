-- drop materialized view  dv_pipeline_description.dvpd_model_profile cascade;

Create materialized view dv_pipeline_description.dvpd_model_profile as 
	
SELECT
	meta_inserted_at,
	lower(model_profile_name) model_profile_name,
	lower(property_name) property_name,
	property_value
FROM
	dv_pipeline_description.dvpd_model_profile_raw;

-- select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;