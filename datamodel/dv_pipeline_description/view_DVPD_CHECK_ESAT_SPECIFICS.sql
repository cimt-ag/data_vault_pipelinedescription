-- drop view if exists dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS as


select 
	dmtpp.pipeline 
 	,'Field'::TEXT  object_type 
 	, sfm.field_name object_name 
 	,'DVPD_CHECK_ESAT_SPECIFICS'::text  check_ruleset
	, 'a field cannot be mapped to an effecitivy satellite (esat)':: text message
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp 
join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING sfm ON dmtpp.table_name = lower(sfm.target_table  )
			and sfm.pipeline = dmtpp.pipeline 
where dmtpp.stereotype ='esat' ;


comment on view dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS IS
	'Test for esat specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_ESAT_SPECIFICS order by 1,2,3



