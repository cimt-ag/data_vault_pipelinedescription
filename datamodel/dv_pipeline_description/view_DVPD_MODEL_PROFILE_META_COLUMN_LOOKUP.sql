-- drop materialized view  dv_pipeline_description.dvpd_model_profile_meta_column_lookup cascade;

Create materialized view dv_pipeline_description.dvpd_model_profile_meta_column_lookup as 
	
select mp_n.model_profile_name 
,stereotype 
, mp_n.property_value meta_column_name 
, mp_t.property_value meta_column_type 
from dv_pipeline_description.dvpd_meta_column_lookup mcl
join dv_pipeline_description.dvpd_model_profile mp_n on mp_n.property_name = mcl.meta_column_name 
join dv_pipeline_description.dvpd_model_profile mp_t on mp_t.property_name =mcl.meta_column_type 
													and mp_t.model_profile_name = mp_n.model_profile_name 
;			

-- select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;