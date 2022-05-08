-- drop table dv_pipeline_description.DVPD_DATA_VAULT_MODEL_PROFILE cascade;

Create table if not exists dv_pipeline_description.DVPD_DATA_VAULT_MODEL_PROFILE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  data_vault_model_profile_name VARCHAR(100),
  property_name VARCHAR(60),
  property_value VARCHAR(60),
  PRIMARY KEY(data_vault_model_profile_name,property_name)
  ); 

TRUNCATE TABLE dv_pipeline_description.DVPD_DATA_VAULT_MODEL_PROFILE;
INSERT INTO dv_pipeline_description.DVPD_DATA_VAULT_MODEL_PROFILE
(data_vault_model_profile_name, property_name, property_value)
VALUES('_default', 'table_key_column_type', 'CHAR(28)')
	  ,('_default', 'table_key_hash_type', 'sha-1')
	  ,('_default', 'table_key_hash_encoding', 'BASE64')
	  ,('_default', 'diff_hash_column_type', 'CHAR(28)')
	  ,('_default', 'diff_hash_type', 'sha-1')
	  ,('_default', 'diff_hash_encoding', 'BASE64')
	  ,('_default', 'xenc_encryption_key_column_type', 'CHAR(28)')
	  ,('_default', 'xenc_encryption_key_index_column_type', 'INT8')
	 ;

	
