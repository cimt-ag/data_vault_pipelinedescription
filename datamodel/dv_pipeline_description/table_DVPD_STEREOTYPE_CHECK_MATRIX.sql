-- drop table if exists dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX 

Create table if not exists dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  stereotype VARCHAR(10),
  needs_hub_key_column_name int,
  needs_link_key_column_name int,
  needs_sattelite_parent_table int,
  needs_link_parent_tables int
  ); 

TRUNCATE TABLE dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX;
INSERT INTO dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX
(stereotype, needs_hub_key_column_name, needs_link_key_column_name, needs_link_parent_tables, needs_sattelite_parent_table)
VALUES('hub', 1, 0, 0, 0),
	  ('lnk', 0, 1, 1, 0),	
	  ('sat', 0, 0, 0, 1),	
	  ('msat', 0, 0, 0, 1),	
	  ('esat', 0, 0, 0, 1),
	  ('ref', 0, 0, 0, 0)
	 ;
