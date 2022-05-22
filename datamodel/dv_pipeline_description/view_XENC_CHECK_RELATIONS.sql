-- drop view if exists dv_pipeline_description.XENC_CHECK_RELATIONS cascade;
create or replace view dv_pipeline_description.XENC_CHECK_RELATIONS as

with target_tables_with_encrypted_columns as (
select  distinct 
	pfte.pipeline_name 
	, pfte.target_table table_name
from dv_pipeline_description.dvpd_pipeline_field_properties pfp 
join dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte on pfte.pipeline_name =pfp.pipeline 
																	and pfte.field_name = pfp.field_name 
where pfp.needs_encryption 
)
, check_content_table_relation as (
select
  epdtp.pipeline_name
  ,'encryption key table'::TEXT  object_type 
  ,epdtp.table_name object_name
  ,'XENC_CHECK_RELATIONS'::text  check_ruleset
  ,case when cpdt.table_name is null then 'Unknown xenc_content_table_name: '|| epdtp.xenc_content_table_name  
  		when ttwec.table_name is null then 'Target table has no encrypted columns:' || epdtp.xenc_content_table_name
    	else 'ok' 
    end  message
from dv_pipeline_description.xenc_pipeline_dv_table_properties_raw epdtp
left join  dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = epdtp.pipeline_name  
															 and cpdt.table_name = epdtp.xenc_content_table_name 
left join target_tables_with_encrypted_columns  ttwec on ttwec.pipeline_name = epdtp.pipeline_name 
													 and ttwec.table_name = epdtp .xenc_content_table_name														 
)
, count_encryption_table_coverage as (
select
  ttwec.pipeline_name
  ,ttwec.table_name 
  ,count(1) coverage_count
  ,string_agg(epdtp.table_name,',') covering_table_names
from dv_pipeline_description.xenc_pipeline_dv_table_properties_raw epdtp
join target_tables_with_encrypted_columns  ttwec on ttwec.pipeline_name = epdtp.pipeline_name 
													 and ttwec.table_name = epdtp .xenc_content_table_name
group by 1,2													 
)
, check_encrytion_coverage_content as (
select
  ttwec.pipeline_name
  ,'encryption key table'::TEXT  object_type 
  ,ttwec.table_name object_name
  ,'XENC_CHECK_RELATIONS'::text  check_ruleset
  ,case when cetc.coverage_count is null then 'Table with encrypted data has no partner'
  		when cetc.coverage_count > 1 then 'Table is covered by multiple encryption tables:'|| cetc.covering_table_names
    	else 'ok' 
    end  message
from target_tables_with_encrypted_columns ttwec
left join count_encryption_table_coverage  cetc on cetc.pipeline_name = ttwec.pipeline_name 
												and cetc.table_name = ttwec .table_name 														 
)
select * from check_content_table_relation
union
select * from check_encrytion_coverage_content

													 ;

comment on view dv_pipeline_description.XENC_CHECK_RELATIONS IS
	'Check for encryption extention specific relations';

-- select * from dv_pipeline_description.XENC_CHECK_RELATIONS order by 1,2,3


