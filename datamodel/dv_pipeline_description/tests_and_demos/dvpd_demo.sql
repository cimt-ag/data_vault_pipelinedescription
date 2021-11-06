



drop view dv_pipeline_description.DVPD_DV_MODEL_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_TABLE as 
with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline
, json_array_elements(dvpd_json->'data_vault_modell')->>'schema_name' as schema_name
, json_array_elements(dvpd_json->'data_vault_modell')->'tables' as tables
from dv_pipeline_description.dvpd_dictionary dt 
)
select
  lower(pipeline) as  pipeline
, lower(schema_name) as schema_name
, lower(table_name) as table_name
, lower(stereotype) as stereotype
, upper(hub_key_column_name)  as hub_key_column_name
, upper(link_key_column_name) as link_key_column_name
, upper(diff_hash_column_name) as diff_hash_column_name
, lower(satellite_parent_table) as satellite_parent_table
, link_parent_tables
, driving_hub_keys
, tracked_field_groups
from (
	select 
	 pipeline 
	,schema_name
	, json_array_elements(tables)->>'table_name'  as table_name
	, json_array_elements(tables)->>'stereotype' as stereotype
	, json_array_elements(tables)->>'hub_key_column_name' as hub_key_column_name
	, json_array_elements(tables)->>'link_key_column_name' as link_key_column_name
	, json_array_elements(tables)->>'diff_hash_column_name' as diff_hash_column_name
	, json_array_elements(tables)->>'satellite_parent_table' as satellite_parent_table
	, json_array_elements(tables)->'link_parent_tables' as link_parent_tables
	, json_array_elements(tables)->'driving_hub_keys' as driving_hub_keys
	, json_array_elements(tables)->'tracked_field_groups' as tracked_field_groups
	from data_vault_schema_basics
) json_parsed;

select * from dvpd_dv_model_table ;



drop view dvpd_dv_model_column;
create or replace view dvpd_dv_model_column as (
with link_parent_tables as (
select distinct
 pipeline 
 ,table_name 
 ,parent_table_name
from (
	select 
	 pipeline 
	 ,table_name 
	 ,json_array_elements_text(link_parent_tables) as parent_table_name
	from dvpd_dv_model_table
	where stereotype ='link'
	) json_parsed
)
,suffixed_key_parents as (
select distinct fm.pipeline
,table_name
,parent_table_name 
,hierarchy_key_suffix 
from dvpd_field_mapping  fm
join link_parent_tables pt on pt.pipeline=fm.pipeline and pt.parent_table_name = fm.target_table 
where length(hierarchy_key_suffix)>0
)
,link_columns as (
 select -- meta columns
 	pipeline 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type as column_type
 from dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_lookup dml on dml.stereotype ='link'
 where tb.stereotype ='link'
union 
 select -- own key column
 	pipeline 
   ,table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,tb.link_key_column_name column_name 
   ,'CHAR(28)' as column_type
 from dvpd_dv_model_table tb
 where tb.stereotype ='link'
 union
select -- keys of parents
 lpt.pipeline 
 ,lpt.table_name 
 ,3 as column_block
 ,'parent_key' as dv_column_class
 ,tb.hub_key_column_name as column_name
 ,'CHAR(28)' as column_type
 from link_parent_tables lpt
 join dvpd_dv_model_table tb on tb.pipeline = lpt.pipeline 
 									and tb.table_name = lpt.parent_table_name
 union 									
select -- suffixed keys of parents
 lpt.pipeline 
 ,lpt.table_name 
 ,4 as column_block
 ,'parent_key' as dv_column_class
 ,tb.hub_key_column_name||'_'||lpt.hierarchy_key_suffix as column_name
 ,'CHAR(28)' as column_type
 from suffixed_key_parents lpt
 join dvpd_dv_model_table tb on tb.pipeline = lpt.pipeline 
 									and tb.table_name = lpt.parent_table_name
-- content 
 -- #TBD# 								   
 )
,hub_columns as (
 select -- meta columns
 	pipeline 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type 
 from dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_lookup dml on dml.stereotype ='hub'
 where tb.stereotype ='hub'
 union 
 select -- own key column
 	pipeline 
   ,table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,tb.hub_key_column_name  
   ,'CHAR(28)' as column_type
 from dvpd_dv_model_table tb
 where tb.stereotype ='hub'
 union
 select -- content
 	tb.pipeline 
   ,tb.table_name
   ,8 as column_block
   ,case when dfm.exclude_from_key_hash then 'content' ELSE 'business_key' end as dv_column_class
   ,dfm.target_column_name  
   ,dfm.target_column_type 
 from dvpd_dv_model_table tb
 left join dvpd_field_mapping dfm on dfm.pipeline=tb.pipeline 
 								 and dfm.target_table = tb.table_name 
 where tb.stereotype ='hub'
)
,sat_parent_table_ref as (
	select 
	 pipeline 
	 ,table_name 
	 ,satellite_parent_table as parent_table
	from dvpd_dv_model_table
	where stereotype in ('sat','esat','msat')
)
,sat_columns as (
 select -- meta columns
 	pipeline 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type as column_type
 from dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_lookup dml on dml.stereotype = tb.stereotype 
 where tb.stereotype in ('sat','esat','msat')
 union 
select -- own key column
 	sr.pipeline 
   ,sr.table_name
   ,2 as column_block
   ,'parent_key' as dv_column_class
   ,coalesce (pa.hub_key_column_name  ,pa.link_key_column_name ) key_column_name
   ,'CHAR(28)' as column_type
 from sat_parent_table_ref sr
 join dvpd_dv_model_table pa  on pa.pipeline = sr.pipeline 
 					     and pa.table_name  =sr.parent_table
 union
 select -- diff_hash_column
 	pipeline 
   ,table_name
   ,3 as column_block
   ,'diff_hash' as dv_column_class
   ,tb.diff_hash_column_name  
   ,'CHAR(28)' as column_type
 from dvpd_dv_model_table tb
 where tb.stereotype in ('sat','msat')
 union
 select -- content
 	tb.pipeline 
   ,tb.table_name
   ,8 as column_block
   ,'content' as dv_column_class
   ,dfm.target_column_name  
   ,dfm.target_column_type 
 from dvpd_dv_model_table tb
 left join dvpd_field_mapping dfm on dfm.pipeline = tb.pipeline 
 							and dfm.target_table = tb.table_name 
 where tb.stereotype in ('sat','msat')
 )
 select * from link_columns
 union
 select * from hub_columns
 union
 select * from sat_columns
);
 
 
select * from dvpd_dv_model_column ddmc 
 order by 1,2,3,4,5;
 



/* dvpd_processing_plan */
create view dvpd_processing_plan_per_leaf_table as

/* determine all tables, touched by source mapping
 * sats/msats are directly targeted , probably by multiple field groups
 * esats and links whithout esat are adressed, when all business keys of hubs related to the esat/link 
 * hubs are always adressed as parents of sats and links
 * are adressed by a consistent field group */

/* create explicit fieldsets for all field groups */
with field_groups_of_pipeline as (
	select distinct pipeline ,field_group 
	from dvpd_field_mapping dfm
)
--, explicit_fieldsets as(
select fgop.pipeline,fgop.field_group,dfm2.field_group source_group,target_table ,target_column_name ,field_name 
from dvpd_field_mapping dfm2 
join field_groups_of_pipeline fgop on fgop.pipeline=dfm2.pipeline and (
									fgop.field_group = dfm2.field_group 
									 or dfm2.field_group ='##all##')
order by pipeline ,fgop.field_group 	,target_table ,field_name 								 

)
select pipeline ,target_table ,target_column_name 
,count(distinct field_group ) field_group_count
,count(distinct field_name ) field_name_count
from explicit_fieldsets
group by 1,2,3

with link_parent_hubs as (
	select distinct
		pipeline
		,table_name as link_table_name
		,json_array_elements_text(link_parent_tables) as hub_table_name 
	from dvpd_dv_model_table 
	where stereotype ='link'
) -- link_parent_business_keys
select lph.pipeline ,link_table_name,hub_table_name,ddmc.column_name 
from link_parent_hubs lph 
join dvpd_dv_model_column ddmc on ddmc.pipeline = lph.pipeline
							  and ddmc.table_name = lph.hub_table_name
							  and ddmc.dv_column_class = 'business_key'
   
											 )
											 
 /* Determine solutions to fill satellites and links without 

with target_leafs as (
	select distinct 
		pipeline 
		,target_table as table_name
		,target_table as leaf_table
		from (
			select  distinct
			pipeline,
			 target_table
			from dv_pipeline_description.dvpd_field_mapping dfm  
		) direct_mapped_tables
)
, sat_parents as (
select tl.pipeline 
,tb.satellite_parent  as table_name 
,leaf_table
from target_leafs tl
join dv_pipeline_description.dvpd_dv_model_table_basics tb on tb.pipeline =tl.pipeline
										 and tb.table_name=tl.table_name
)
, 
select *
from sat_parents
union
select *
from target_leafs
union
select *
from link_parents;

select * from dvpd_processing_plan_per_leaf_table
order by leaf_table; 

