

DELETE FROM dv_pipeline_description.dvpd_meta_column_lookup where stereotype like '%xenc%';	
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(stereotype, meta_column_name, meta_column_type)
VALUES('xenc_hub-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_sat-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_lnk-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_msat-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_ref-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('_xenc_stg-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_hub-ek',  'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_lnk-ek', 'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_sat-ek',  'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_msat-ek', 'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_ref-ek', 'record_source_column_name', 'record_source_column_type'),		
	  ('_xenc_stg-ek', 'record_source_column_name', 'record_source_column_type'),		
	  ('xenc_hub-ek', 'load_process_id_column_name', 'load_process_id_column_type'),		
	  ('xenc_lnk-ek', 'load_process_id_column_name', 'load_process_id_column_type'),		
	  ('xenc_sat-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('xenc_msat-ek','load_process_id_column_name', 'load_process_id_column_type'),	
	  ('xenc_ref-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('_xenc_stg-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('_xenc_stg-ek', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('xenc_msat-ek', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('xenc_msat-ek', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('xenc_ref_hist-ek', 'load_enddate_column_name', 'load_enddate_column_type')	
	 ;	