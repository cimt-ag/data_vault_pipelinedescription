--drop functiondv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(varchar);
create or replace function dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(
   profile_to_load varchar
)
returns boolean
language plpgsql    
as 
$$
begin
	
	/* Load json scripts into relational raw model */
truncate table dv_pipeline_description.dvpd_model_profile;
INSERT INTO dv_pipeline_description.dvpd_model_profile
(model_profile_name,
property_name,
property_value)
SELECT
	model_profile_name,
property_name,
property_value
FROM
	dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE;

return true;

end;
$$;
