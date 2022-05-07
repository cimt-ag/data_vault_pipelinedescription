Delete from dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX where stereotype like 'xenc%';
INSERT INTO dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX
(stereotype, needs_hub_key_column_name, needs_link_key_column_name, needs_link_parent_tables, needs_sattelite_parent_table)
VALUES('xenc_hub-ek', 0, 0, 0, 0),
	  ('xenc_lnk-ek', 0, 0, 0, 0),	
	  ('xenc_sat-ek', 0, 0, 0, 0),	
	  ('xenc_msat-ek', 0, 0, 0, 0),	
	  ('xenc_ref-ek', 0, 0, 0, 0)
	 ;
