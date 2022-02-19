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
ORDER BY 1,2,3

-- select * from dv_pipeline_description.DVPD_CHECK_ALL order by 1,2,3



