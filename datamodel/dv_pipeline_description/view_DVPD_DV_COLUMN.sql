drop view if exists dv_pipeline_description.DVPD_DV_COLUMN cascade;
create or replace view dv_pipeline_description.DVPD_DV_COLUMN as 

SELECT
	DISTINCT
	table_name,
	column_block,
	dv_column_class,
	column_name,
	column_type
FROM
	dv_pipeline_description.dvpd_pipeline_dv_column;


-- select * From dv_pipeline_description.DVPD_DV_COLUMN;


