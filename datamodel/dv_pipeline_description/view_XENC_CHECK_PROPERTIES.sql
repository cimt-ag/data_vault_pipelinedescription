-- drop view if exists dv_pipeline_description.XENC_CHECK_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_CHECK_PROPERTIES as


select
  pdtp.pipeline_name
  ,'encryption key table'::TEXT  object_type 
  ,pdtp.table_name object_name
  ,'XENC_CHECK_PROPERTIES'::text  check_ruleset
  ,case when xenc_content_table_name is null then 'Content table name not declared'
    	else 'ok' 
    end  message
from dv_pipeline_description.xenc_pipeline_dv_table_properties pdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = pdtp.pipeline_name 
														and (pdt.table_name = pdtp.table_name)
where pdt.stereotype like 'xenc%';


comment on view dv_pipeline_description.XENC_CHECK_PROPERTIES IS
	'Check for encryption extention specific properties';

-- select * from dv_pipeline_description.XENC_CHECK_PROPERTIES order by 1,2,3



