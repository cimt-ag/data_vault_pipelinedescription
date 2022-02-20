--drop view if exists dv_pipeline_description.DVPD_ATMTST_CATALOG;
create or replace view dv_pipeline_description.DVPD_ATMTST_CATALOG as (

with expanded_dv_model_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'dv_model_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_dv_model_table_count as (
select distinct
	pipeline_name 
	,count(distinct table_row->>0 ) table_count
from expanded_dv_model_column 
group by pipeline_name 
)
, expanded_stage_table_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_table_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
,atmtst_stage_table_count as (
select distinct
	pipeline_name 
	, 1 table_count
from expanded_stage_table_column 
)
select 
 coalesce(admtc.pipeline_name ,astc.pipeline_name ) pipeline_name 
 , admtc.table_count  dv_model_test_count
 , astc.table_count  stage_model_test_count
from atmtst_dv_model_table_count admtc
full outer join atmtst_stage_table_count  astc on astc.pipeline_name = admtc.pipeline_name 

);
 
comment on view dv_pipeline_description.DVPD_ATMTST_CATALOG IS
	'Provide overview about available reference data used for automated test of dvpd implementation';
 
-- select * from dv_pipeline_description.DVPD_ATMTST_CATALOG ddmc  order by 1;
