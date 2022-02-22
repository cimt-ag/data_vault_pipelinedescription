-- drop view if exists dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS as

with bk_count_for_tables as (
select 
	dmtpp.pipeline 
	,dmtpp.table_name  
	,count (sfm.field_name ) bk_count
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp 
left join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING sfm ON dmtpp.table_name = lower(sfm.target_table  )
			and sfm.pipeline = dmtpp.pipeline 
			and not sfm.exclude_from_key_hash
where dmtpp.stereotype ='hub'   
group by 1,2
)
select 
	pipeline 
 	,'Table'::TEXT  object_type 
 	, table_name  object_name 
 	,'DVPD_CHECK_HUB_SPECIFICS'::text  check_ruleset
	, case when bk_count = 0 THEN 'No business key defined for the table'
		else 'ok' end :: text message
from bk_count_for_tables;

comment on view dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS IS
	'Test for hub specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS order by 1,2,3



