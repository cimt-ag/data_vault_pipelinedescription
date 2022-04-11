-- drop view if exists dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS as

with bk_count_for_tables as (
select 
	pdt.pipeline_name 
	,pdt.table_name  
	,count (sfm.field_name ) bk_count
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm ON pdt.table_name = lower(sfm.target_table  )
			and sfm.pipeline_name = pdt.pipeline_name 
			and not sfm.exclude_from_key_hash
where pdt.stereotype ='hub'   
group by 1,2
)
select 
	pipeline_name 
 	,'Table'::TEXT  object_type 
 	, table_name  object_name 
 	,'DVPD_CHECK_HUB_SPECIFICS'::text  check_ruleset
	, case when bk_count = 0 THEN 'No business key defined for the table'
		else 'ok' end :: text message
from bk_count_for_tables
union
(with hk_count as (
select 
	pipeline_name 
	,hub_key_column_name 
	,count(1) hk_count
	,string_agg(table_name ,', ') table_list 
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
where stereotype = 'hub' and hub_key_column_name is not null
group by 1,2
)
select 
	pipeline_name 
 	,'Hub Key'::TEXT  object_type 
 	, hub_key_column_name object_name 
 	,'DVPD_CHECK_HUB_SPECIFICS'::text  check_ruleset
	, case when hk_count > 1 THEN 'HK Name used for multiple hubs: '||table_list
		else 'ok' end :: text message
FROM hk_count);

comment on view dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS IS
	'Test for hub specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS order by 1,2,3



