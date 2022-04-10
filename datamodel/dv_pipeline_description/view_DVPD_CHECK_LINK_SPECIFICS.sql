-- drop view if exists dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS as


with lk_count as (
select 
	pipeline_name 
	,link_key_column_name 
	,count(1) lk_count
	,string_agg(table_name ,', ') table_list 
from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE
where stereotype = 'lnk' and link_key_column_name is not null 
group by 1,2
)
select 
	pipeline_name 
 	,'Link Key'::TEXT  object_type 
 	, link_key_column_name object_name 
 	,'DVPD_CHECK_LINK_SPECIFICS'::text  check_ruleset
	, case when lk_count > 1 THEN 'LK Name used for multiple links: '||table_list
		else 'ok' end :: text message
FROM lk_count;

comment on view dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS IS
	'Test for link specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS order by 1,2,3



