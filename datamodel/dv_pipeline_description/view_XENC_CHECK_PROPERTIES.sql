-- drop view if exists dv_pipeline_description.XENC_CHECK_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_CHECK_PROPERTIES as

with check_major_properties as (

select
  pdtp.pipeline_name
  ,'Encryption key Table'::TEXT  object_type 
  ,pdtp.table_name object_name
  ,'XENC_CHECK'::text  check_ruleset
  ,case when pdtp.table_name is null then 'Table name is missing for encryption key table'  
  		when xenc_content_table_name is null then 'Content table name not declared'
    	else 'ok' 
    end  message
from dv_pipeline_description.xenc_pipeline_dv_table_properties pdtp
left join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = pdtp.pipeline_name 
														and (pdt.table_name = pdtp.table_name)
														--where pdt.stereotype like 'xenc%'

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
  ,'Table'::TEXT  object_type 
  ,ttwec.table_name object_name
  ,'XENC_CHECK'::text  check_ruleset
  ,case when cetc.coverage_count is null then 'Table with encryted data has no partner'
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

comment on view dv_pipeline_description.XENC_CHECK_PROPERTIES IS
	'Check for encryption extention specific properties';

-- select * from dv_pipeline_description.XENC_CHECK_PROPERTIES order by 1,2,3



