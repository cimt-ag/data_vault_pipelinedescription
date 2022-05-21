-- drop view if exists dv_pipeline_description.DVPD_CHECK_ALL cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_ALL as

select * FROM dv_pipeline_description.dvpd_check_field_target_table
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_model_relations
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_model_stereotype_and_parameters
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_xsat_specifics  
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_hub_specifics  
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_link_specifics  
where message <>'ok'
union
select * FROM dv_pipeline_description.xenc_check_properties 
where message <>'ok'
union
select * FROM dv_pipeline_description.xenc_check_relations 
where message <>'ok'

ORDER BY 1,2,3;


comment on view dv_pipeline_description.DVPD_CHECK_ALL IS
	'Shows all errors from incomplete or wrong configured pipeline descriptions, including the errors created on purpose by testsets';


-- select * from dv_pipeline_description.DVPD_CHECK_ALL order by 1,2,3



