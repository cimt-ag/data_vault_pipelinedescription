
Create table dv_pipeline_description.DVPD_META_COLUMN_LOOKUP (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  stereotype VARCHAR(10),
  meta_column_name VARCHAR(60),
  meta_column_type VARCHAR(60),
  PRIMARY KEY(stereotype,meta_column_name)
  ); */

TRUNCATE TABLE dv_pipeline_description.dvpd_meta_column_lookup;
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(stereotype, meta_column_name, meta_column_type)
VALUES('hub', 'META_INSERTED_AT', 'TIMESTAMP'),
	  ('sat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('link', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('msat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('esat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('hub',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('link', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('sat',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('esat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('msat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('hub', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('link', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('sat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('esat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('msat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('sat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('sat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('msat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('msat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('esat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('esat', 'META_IS_DELETED', 'BOOLEAN')	
	 ;
*/