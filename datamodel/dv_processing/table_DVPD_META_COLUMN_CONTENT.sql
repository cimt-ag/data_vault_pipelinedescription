
Create table if not exists dv_processing.DVPC_META_COLUMN_CONTENT (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  meta_column_name VARCHAR(60),
  meta_column_content VARCHAR(60),
  PRIMARY KEY(meta_column_name)
  ); 

TRUNCATE TABLE dv_processing.DVPC_META_COLUMN_CONTENT;
INSERT INTO dv_processing.DVPC_META_COLUMN_CONTENT
( meta_column_name, meta_column_content)
VALUES('META_INSERTED_AT', '{a_insert_timestamp}'),
	  ('META_RECORD_SOURCE', '{a_record_source}'),	
	  ('META_JOB_INSTANCE_ID', '{a_load_id}'),	
	  ('META_VALID_BEFORE', '''2299-12-30 23:00:00'''),	
	  ('META_IS_DELETED', 'META_IS_DELETED')	
	 ;
