drop view if exists dv_pipeline_description.DVPD_PIPELINE_COLUMN_MAPPING_WITH_FIELD_GROUP_EXTENTION cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_COLUMN_MAPPING_WITH_FIELD_GROUP_EXTENTION as 

with dv_columns as (
select table_name ,column_name ,dv_column_class,column_block 
from dv_pipeline_description.dvpd_dv_model_column ddmc 
where ddmc.dv_column_class not in ('meta')
)
,stage_and_dv_columns_basic as(
select distinct pipeline 
	,field_group 
	,target_table 
	,case when field_group = '##all##' OR dv_column_class not in ('key','parent_key','diff_hash')   then dc.column_name
	else dc.column_name||'___'||UPPER(field_group) END stage_column_name_basic
	,column_name 
	,dv_column_class
	,column_block 
from dv_pipeline_description.dvpd_source_field_mapping dsfm 
join dv_columns dc on dc.table_name = dsfm.target_table 
)
select  sadcb.pipeline 
	,sadcb.field_group 
	,sadcb.target_table
	,field_name
	,case when sadcb.stage_column_name_basic=field_name or field_name is null 
			then  sadcb.stage_column_name_basic
			else sadcb.stage_column_name_basic||'__X__'||field_name
		end stage_column_name
	,sadcb.column_name
	,sadcb.dv_column_class
	,sadcb.column_block 
from stage_and_dv_columns_basic sadcb 
left join dv_pipeline_description.dvpd_source_field_mapping dsfm on dsfm.pipeline = sadcb.pipeline
										and dsfm.target_table=sadcb.target_table
										and dsfm.field_group=sadcb.field_group
										and dsfm.target_column_name=sadcb.column_name
order by pipeline ,field_group,target_table ,column_block ,dv_column_class ,column_name
;

comment on view dv_pipeline_description.DVPD_PIPELINE_COLUMN_MAPPING_WITH_FIELD_GROUP_EXTENTION 
is 'For every pipeline render stage_column name and provide columns_name for all theoretical field group and table combinations';

											
-- select * from dv_pipeline_description.DVPD_PIPELINE_COLUMN_MAPPING_WITH_FIELD_GROUP_EXTENTION ;										
