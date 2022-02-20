-- drop view if exists dv_pipeline_description.DVPD_CHECK_ALL cascade;
create or replace view dv_pipeline_description.DVPD_CHECK as

select * FROM dv_pipeline_description.DVPD_CHECK_ALL
where pipeline not like 'test0%' 
and pipeline not like 'test1%' 
ORDER BY 1,2,3

-- select * from dv_pipeline_description.DVPD_CHECK_ALL order by 1,2,3



