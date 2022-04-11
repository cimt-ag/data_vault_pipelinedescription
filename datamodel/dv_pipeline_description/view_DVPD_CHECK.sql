-- drop view if exists dv_pipeline_description.DVPD_CHECK_ALL cascade;
create or replace view dv_pipeline_description.DVPD_CHECK as

select * FROM dv_pipeline_description.DVPD_CHECK_ALL
where pipeline_name not like 'test0%' 
and pipeline_name not like 'test1%' 
ORDER BY 1,2,3;

comment on view dv_pipeline_description.DVPD_CHECK IS
	'Shows all errors from incomplete or wrong configured pipeline descriptions (Empt if everything is fine)';

-- select * from dv_pipeline_description.DVPD_CHECK_ALL order by 1,2,3



