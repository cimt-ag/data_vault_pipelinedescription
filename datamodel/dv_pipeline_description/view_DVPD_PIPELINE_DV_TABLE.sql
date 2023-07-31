-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================


-- drop materialized view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE cascade;
create materialized view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE as 

with profile_settings as (
	 select pdt.pipeline_name , 
	    pdt.table_name ,
	    lower(coalesce( pdt.model_profile_name,pp.model_profile_name )) model_profile_name ,
	    profile.property_name ,
	    profile.property_value
	 from dv_pipeline_description.dvpd_pipeline_dv_table_raw pdt
	 join dv_pipeline_description.dvpd_pipeline_properties pp on pp.pipeline_name =lower(pdt.pipeline_name )
	 left join dv_pipeline_description.dvpd_model_profile profile on profile.model_profile_name = lower(coalesce( pdt.model_profile_name,pp.model_profile_name ))
	 where property_name in ('is_enddated_default','has_deletion_flag_default','uses_diff_hash_default','compare_criteria_default')
 )
 , column_count as (
	 select  dpdtr.pipeline_name
	 	, dpdtr.table_name
		 ,count(column_name) column_count
	 from dv_pipeline_description.dvpd_pipeline_dv_table_raw  dpdtr
	 left join  dv_pipeline_description.dvpd_pipeline_field_target_expansion dpfte on dpfte.pipeline_name = lower(dpdtr.pipeline_name )
	 																			 and dpfte.table_name =lower(dpdtr.table_name )
	 group by 1,2
  )
select 
 lower(pdt.pipeline_name) as pipeline_name 
, lower(schema_name) as schema_name
, lower(pdt.table_name) as table_name
, lower(table_stereotype) as table_stereotype
, upper(hub_key_column_name)  as hub_key_column_name
, upper(link_key_column_name) as link_key_column_name
, upper(diff_hash_column_name) as diff_hash_column_name
, lower(satellite_parent_table) as satellite_parent_table
, upper(tracked_relation_name) as tracked_relation_name
, coalesce(is_link_without_sat::boolean,false) as is_link_without_sat
, coalesce(is_enddated ::boolean,mp_is_endated_default.property_value ::boolean) as is_enddated 
, coalesce(has_deletion_flag ::boolean,has_deletion_flag_default.property_value ::boolean) as has_deletion_flag 
, coalesce(uses_diff_hash ::boolean,uses_diff_hash_default.property_value ::boolean) as uses_diff_hash
, coalesce(lower(compare_criteria) ,lower(compare_criteria_default.property_value)) as compare_criteria
, case when table_stereotype = 'sat' and column_count=0 then true 
	   when table_stereotype = 'sat' and column_count>0 then false 
	   else null 															end   	is_effectivity_sat
, mp_is_endated_default.model_profile_name
, table_content_comment
from dv_pipeline_description.dvpd_pipeline_dv_table_raw pdt
join column_count cc on cc.pipeline_name=pdt.pipeline_name 
					and cc.table_name=pdt.table_name 
left join profile_settings mp_is_endated_default on mp_is_endated_default.pipeline_name=pdt.pipeline_name  
												and mp_is_endated_default.table_name=pdt.table_name 
												and mp_is_endated_default.property_name ='is_enddated_default'
left join profile_settings has_deletion_flag_default on has_deletion_flag_default.pipeline_name=pdt.pipeline_name  
												and has_deletion_flag_default.table_name=pdt.table_name 
												and has_deletion_flag_default.property_name ='has_deletion_flag_default'
left join profile_settings uses_diff_hash_default on uses_diff_hash_default.pipeline_name=pdt.pipeline_name  
												and uses_diff_hash_default.table_name=pdt.table_name 
												and uses_diff_hash_default.property_name ='uses_diff_hash_default'
left join profile_settings compare_criteria_default on compare_criteria_default.pipeline_name=pdt.pipeline_name  
												and compare_criteria_default.table_name=pdt.table_name 
												and compare_criteria_default.property_name ='compare_criteria_default'
;

comment on materialized  view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE is
 'Tables of the pipeline. (cleansed and normalized)'; 

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE ;