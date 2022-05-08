-- drop view if exists dv_pipeline_description.XENC_CHECK_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_CHECK_PROPERTIES as



select
  epdtp.pipeline_name
  ,'Table'::TEXT  object_type 
  ,epdtp.table_name object_name
  ,'XENC_CHECK'::text  check_ruleset
  ,case when cpdt.table_name is null then 'Unknown xenc_content_table_name: '|| epdtp.xenc_content_table_name  
    	else 'ok' 
    end  message
from dv_pipeline_description.xenc_pipeline_dv_table_properties_raw epdtp
left join  dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = epdtp.pipeline_name  
															 and cpdt.table_name = epdtp.xenc_content_table_name 
where cpdt.table_name is null															 
;

comment on view dv_pipeline_description.XENC_CHECK_PROPERTIES IS
	'Check for encryption extention specific properties';

-- select * from dv_pipeline_description.XENC_CHECK_PROPERTIES order by 1,2,3



