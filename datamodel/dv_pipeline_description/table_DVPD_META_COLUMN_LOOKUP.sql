-- drop table dv_pipeline_description.DVPD_META_COLUMN_LOOKUP cascade;

Create table if not exists dv_pipeline_description.DVPD_META_COLUMN_LOOKUP (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  stereotype VARCHAR(20),
  meta_column_name VARCHAR(60),
  meta_column_type VARCHAR(60),
  PRIMARY KEY(stereotype,meta_column_name)
  ); 

TRUNCATE TABLE dv_pipeline_description.dvpd_meta_column_lookup;
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(stereotype, meta_column_name, meta_column_type)
VALUES('hub', 'META_INSERTED_AT', 'TIMESTAMP'),
	  ('sat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('lnk', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('msat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('esat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('ref', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('_stg', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('hub',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('lnk', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('sat',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('esat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('msat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('ref', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('_stg', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('hub', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('lnk', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('sat', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('esat', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('msat', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('ref', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('_stg', 'META_JOB_INSTANCE_ID', 'INT8'),	
	  ('xsat_hist', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('xsat_hist', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('_stg', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('msat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('msat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('esat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('esat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('ref_hist', 'META_VALID_BEFORE', 'TIMESTAMP')	
	 ;

	
