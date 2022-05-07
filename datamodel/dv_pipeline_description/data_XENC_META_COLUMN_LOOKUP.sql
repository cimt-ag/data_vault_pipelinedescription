

DELETE FROM dv_pipeline_description.dvpd_meta_column_lookup where stereotype like '%xenc%';	
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(stereotype, meta_column_name, meta_column_type)
VALUES('xenc_hub-ek', 'META_INSERTED_AT', 'TIMESTAMP'),
	  ('xenc_sat-ek', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('xenc_lnk-ek', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('xenc_msat-ek', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('xenc_ref-ek', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('_xenc_stg-ek', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('xenc_hub-ek',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('xenc_lnk-ek', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('xenc_sat-ek',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('xenc_msat-ek', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('xenc_ref-ek', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('_xenc_stg-ek', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('xenc_hub-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('xenc_lnk-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('xenc_sat-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('xenc_msat-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('xenc_ref-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('_xenc_stg-ek', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('_xenc_stg-ek', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('xenc_msat-ek', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('xenc_msat-ek', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('xenc_ref_hist-ek', 'META_VALID_BEFORE', 'TIMESTAMP')	
	 ;	