--drop view if exists dv_pipeline_description.DVPD_DV_MODEL_COLUMN;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_COLUMN as (

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
	from dv_pipeline_description.dvpd_dv_model_table_per_pipeline
	where stereotype ='lnk'
	) json_parsed
)
,suffixed_key_parents as (
select distinct 
table_name
,parent_table_name 
,hierarchy_key_suffix 
from dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING  fm
join link_parent_tables pt on pt.pipeline=fm.pipeline and pt.parent_table_name = fm.target_table 
where length(hierarchy_key_suffix)>0
)
,link_columns as (   -- <<<<<<<<<<<<<<<<<<<<<<<<< LINK
 select -- meta columns
 	table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name  as column_name
   ,dml.meta_column_type as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype ='lnk'
 where tb.stereotype ='lnk'
union 
 select -- own key column
 	table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,tb.link_key_column_name  as column_name 
   ,'CHAR(28)' as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 where tb.stereotype ='lnk'
 union
select -- keys of parents
 lpt.table_name 
 ,3 as column_block
 ,'parent_key' as dv_column_class
 ,tb.hub_key_column_name  as column_name
 ,'CHAR(28)' as column_type
 from link_parent_tables lpt
 join dv_pipeline_description.dvpd_dv_model_table tb on tb.table_name = lpt.parent_table_name
 union 									
select -- suffixed keys of parents
 lpt.table_name 
 ,4 as column_block
 ,'parent_key' as dv_column_class
 ,tb.hub_key_column_name||'_'||lpt.hierarchy_key_suffix  as column_name
 ,'CHAR(28)' as column_type
 from suffixed_key_parents lpt
 join dv_pipeline_description.dvpd_dv_model_table tb on  tb.table_name = lpt.parent_table_name
 union
 select -- content
 	tb.table_name
   ,8 as column_block
   ,case when dfm.exclude_from_key_hash then 'content_untracked' ELSE 'dependent_child_key' end as dv_column_class
   ,dfm.target_column_name   as column_name
   ,dfm.target_column_type 
 from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tb
 join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING dfm on dfm.pipeline=tb.pipeline 
 								 and dfm.target_table = tb.table_name 
 where tb.stereotype ='lnk'								   
 )
,hub_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< HUB
 select -- meta columns
 	table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name  as column_name
   ,dml.meta_column_type 
 from dv_pipeline_description.dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype ='hub'
 where tb.stereotype ='hub'
 union 
 select -- own key column
 	table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,tb.hub_key_column_name   as column_name
   ,'CHAR(28)' as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 where tb.stereotype ='hub'
 union
 select -- content
 	tb.table_name
   ,8 as column_block
   ,case when dfm.exclude_from_key_hash then 'content_untracked' ELSE 'business_key' end as dv_column_class
   ,dfm.target_column_name   as column_name
   ,dfm.target_column_type 
 from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tb
 left join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING dfm on dfm.pipeline=tb.pipeline 
 								 and dfm.target_table = tb.table_name 
 where tb.stereotype ='hub'
)
,sat_parent_table_ref as (
	select 
	 pipeline 
	 ,table_name 
	 ,satellite_parent_table as parent_table
	from dv_pipeline_description.dvpd_dv_model_table_per_pipeline
	where stereotype in ('sat','esat','msat')
)
,sat_columns as (
 select -- meta columns
 	table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype = tb.stereotype 
 where tb.stereotype in ('sat','esat','msat')
 union 
select -- own key column
 	sr.table_name
   ,2 as column_block
   ,'parent_key' as dv_column_class
   ,coalesce (pa.hub_key_column_name  ,pa.link_key_column_name )  as column_name
   ,'CHAR(28)' as column_type
 from sat_parent_table_ref sr
 join dv_pipeline_description.dvpd_dv_model_table_per_pipeline pa  on pa.pipeline = sr.pipeline 
 					     and pa.table_name  =sr.parent_table
 union
 select -- diff_hash_column
 	table_name
   ,3 as column_block
   ,'diff_hash' as dv_column_class
   ,tb.diff_hash_column_name   as column_name
   ,'CHAR(28)' as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 where tb.stereotype in ('sat','msat')
 union
 select -- content
 	tb.table_name
   ,8 as column_block
   ,case when dfm.exclude_from_diff_hash then 'content_untracked' else 'content' end as dv_column_class
   ,dfm.target_column_name  as column_name
   ,dfm.target_column_type 
 from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tb
 left join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING dfm on dfm.pipeline = tb.pipeline 
 							and dfm.target_table = tb.table_name 
 where tb.stereotype in ('sat','msat')
 )
 ,ref_columns as (
 
 select -- meta columns
 	table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype = 'ref' or ( dml.stereotype = 'ref_hist' and tb.is_historized ) 
 where tb.stereotype in ('ref')
 union 
 select -- diff_hash_column
 	table_name
   ,3 as column_block
   ,'diff_hash' as dv_column_class
   ,tb.diff_hash_column_name   as column_name
   ,'CHAR(28)' as column_type
 from dv_pipeline_description.dvpd_dv_model_table tb
 where tb.stereotype in ('ref') and tb.is_historized 
 union
 select -- content
 	tb.table_name
   ,8 as column_block
   ,case when dfm.exclude_from_diff_hash then 'content_untracked' else 'content' end as dv_column_class
   ,dfm.target_column_name  as column_name
   ,dfm.target_column_type 
 from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tb
 left join dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING dfm on dfm.pipeline = tb.pipeline 
 							and dfm.target_table = tb.table_name 
 where tb.stereotype in ('ref')
 
 )
 select * from link_columns
 union
 select * from hub_columns
 union
 select * from sat_columns
 union 
 select * from ref_columns
 
 
);
 
 
-- select * from dv_pipeline_description.DVPD_DV_MODEL_COLUMN ddmc  order by 1,2,3,4,5;