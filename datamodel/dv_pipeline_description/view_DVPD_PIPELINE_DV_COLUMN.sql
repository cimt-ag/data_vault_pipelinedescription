--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN as (



 select * from dv_pipeline_description.dvpd_pipeline_dv_column_core
 
);
 
 
-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN ddmc  order by 1,2,3,4,5;