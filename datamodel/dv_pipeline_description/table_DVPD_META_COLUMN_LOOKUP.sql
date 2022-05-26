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
VALUES('hub', 'load_date_column_name', 'load_date_column_type'),
	  ('sat', 'load_date_column_name', 'load_date_column_type'),	
	  ('lnk', 'load_date_column_name', 'load_date_column_type'),	
	  ('msat', 'load_date_column_name', 'load_date_column_type'),	
	  ('esat', 'load_date_column_name', 'load_date_column_type'),	
	  ('ref', 'load_date_column_name', 'load_date_column_type'),	
	  ('_stg', 'load_date_column_name', 'load_date_column_type'),	
	  ('hub',  'record_source_column_name', 'record_source_column_type'),	
	  ('lnk', 'record_source_column_name', 'record_source_column_type'),	
	  ('sat',  'record_source_column_name', 'record_source_column_type'),	
	  ('esat', 'record_source_column_name', 'record_source_column_type'),	
	  ('msat', 'record_source_column_name', 'record_source_column_type'),	
	  ('ref', 'record_source_column_name', 'record_source_column_type'),	
	  ('_stg', 'record_source_column_name', 'record_source_column_type'),	
	  ('hub', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('lnk', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('sat', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('esat', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('msat', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('ref', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('_stg', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('xsat_hist', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('xsat_hist', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('_stg', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('msat', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('msat', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('esat', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('esat', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('ref_hist', 'load_enddate_column_name', 'load_enddate_column_type')	
	 ;

	
