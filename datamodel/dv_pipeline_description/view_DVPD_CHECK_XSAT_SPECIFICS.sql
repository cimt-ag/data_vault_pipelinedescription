-- drop view if exists dv_pipeline_description.DVPD_CHECK_XSAT_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_XSAT_SPECIFICS as


with no_columns_on_esat as (
	select 
		dmtpp.pipeline_name 
	 	,'Field'::TEXT  object_type 
	 	, sfm.field_name object_name 
	 	,'DVPD_CHECK_XSAT_SPECIFICS'::text  check_ruleset
		, 'a field cannot be mapped to an effecitivy satellite (esat)':: text message
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE dmtpp 
	join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm ON dmtpp.table_name = lower(sfm.target_table  )
				and sfm.pipeline_name = dmtpp.pipeline_name 
	where dmtpp.stereotype ='esat'
)
/*,driving_key_per_pipeline_and_sat_table as (
	select 
		pipeline_name 
		,table_name 
		,upper(json_array_elements_text(driving_keys)) driving_key
		,satellite_parent_table 
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE
	where stereotype in ('sat','esat','msat')
)
,do_driving_keys_exist_in_parent as (
select 
	dkppast.pipeline_name 
 	,'Table'::TEXT  object_type 
 	, dkppast.table_name   object_name 
 	,'DVPD_CHECK_XSAT_SPECIFICS'::text  check_ruleset
	, case when dmc.column_name is null then 'driving key "'||dkppast.driving_key ||'" does not exist in parent table':: text
			else 'ok' end message
from driving_key_per_pipeline_and_sat_table dkppast 
left join dv_pipeline_description.dvpd_dv_model_column dmc ON dmc.table_name = dkppast.satellite_parent_table
and dmc.column_name =dkppast.driving_key 

) */
select * from no_columns_on_esat
/*union
select * from do_driving_keys_exist_in_parent ;
*/

comment on view dv_pipeline_description.DVPD_CHECK_XSAT_SPECIFICS IS
	'Test for satellite specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_XSAT_SPECIFICS order by 1,2,3



