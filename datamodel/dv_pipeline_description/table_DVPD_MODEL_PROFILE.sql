-- drop table dv_pipeline_description.DVPD_MODEL_PROFILE cascade;

Create table if not exists dv_pipeline_description.DVPD_MODEL_PROFILE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  data_vault_model_profile_name VARCHAR(100),
  property_name VARCHAR(60),
  property_value VARCHAR(60),
  PRIMARY KEY(data_vault_model_profile_name,property_name)
  ); 
