-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_DRIVING_KEY cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_DRIVING_KEY as 

SELECT
	meta_inserted_at
	,pipeline_name
	,lower(table_name) table_name
	,upper(driving_key) driving_key
FROM
	dv_pipeline_description.dvpd_pipeline_dv_table_driving_key_raw;

;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;