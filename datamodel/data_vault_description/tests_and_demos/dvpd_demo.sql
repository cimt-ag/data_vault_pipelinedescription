/*
Create table dvpd_meta_lookup (
  stereotype VARCHAR(10),
  meta_column_name VARCHAR(60),
  meta_column_type VARCHAR(60)
  ); */

/*
TRUNCATE TABLE public.dvpd_meta_lookup;
INSERT INTO public.dvpd_meta_lookup
(stereotype, meta_column_name, meta_column_type)
VALUES('hub', 'META_INSERTED_AT', 'TIMESTAMP'),
	  ('sat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('link', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('msat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('esat', 'META_INSERTED_AT', 'TIMESTAMP'),	
	  ('hub',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('link', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('sat',  'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('esat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('msat', 'META_RECORD_SOURCE', 'VARCHAR(255)'),	
	  ('hub', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('link', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('sat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('esat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('msat', 'META_JOB_INSTANCE_ID', 'LONG'),	
	  ('sat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('sat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('msat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('msat', 'META_IS_DELETED', 'BOOLEAN'),	
	  ('esat', 'META_VALID_BEFORE', 'TIMESTAMP'),	
	  ('esat', 'META_IS_DELETED', 'BOOLEAN')	
	 ;
*/


/*
  drop table  dvpd_dictionary cascade;
  create table dvpd_dictionary (
  pipeline_name VARCHAR(100),
  dvpd_json json,
  PRIMARY KEY ( pipeline_name)
  );
*/

truncate table public.dvpd_dictionary;

/* test jsons*/
INSERT INTO public.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES('rkpsf_auftrag_p1', '{
	"DVPD_Version": "1.0",
	"pipeline_name": "rkpsf_auftrag_p1",
	"record_source_name_expression": "knuppisoft.auftrag",
	"data_fetch_module": {
		"fetch_module_name": "read_file_delimted",
		"search_expression": "$PipelineInputDirectory/Auftrag*.csv",
		"file_archive_path": "$PipelineArchiveDirectory"
	},
	"data_parse_module": {
		"parse_module_name": "delimited_text",
		"codepage": "UTF_8",
		"columnseparator": "|",
		"rowseparator": "\n",
		"skip_first_rows": "1",
		"reject_processing": "reject_container"
	},
	"fields": [{
			"field_name": "FI_ID",
			"technical_type": "Varchar(20)",
			"parsing_expression": "1",
			"uniqeness_groups": ["key"],
			"targets": [{
				"table_name": "rkpsf_auftrag_hub"
			}]
		}, {
			"field_name": "AUFTRAGSNR",
			"technical_type": "Decimal(10,0)",
			"parsing_expression": "2",
			"uniqeness_groups": ["key"],
			"targets": [{
				"table_name": "rkpsf_auftrag_hub",
				"target_column_name": "A_NUMMER"
			}]
		}, {
			"field_name": "KUNDE_NR",
			"technical_type": "DECIMAL(10,0)",
			"parsing_expression": "3",
			"targets": [{
				"table_name": "rsfrc_kunde_hub",
				"field_groups": ["haupt_kunde"]
			}]
		}, {
			"field_name": "CO_KUNDE_NR",
			"technical_type": "DECIMAL(10,0)",
			"parsing_expression": "4",
			"targets": [{
				"table_name": "rsfrc_kunde_hub",
				"target_column_name": "KUNDE_NR",
				"field_groups": ["co_kunde"]
			}]
		}, {
			"field_name": "AUFTRAGSART",
			"technical_type": "Varchar(20)",
			"parsing_expression": "6",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		}, {
			"field_name": "PREIS_NETTO",
			"technical_type": "DECIMAL(12,2)",
			"parsing_expression": "7",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		},
		{
			"field_name": "STATUS",
			"technical_type": "VARCHAR(10)",
			"parsing_expression": "8",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		},
		{
			"field_name": "SYSTEMMODTIME",
			"technical_type": "TIMESTAMP",
			"parsing_expression": "9",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat",
				"exclude_from_diff_hash": "true"
			}]
		}
	],
	"data_vault_modell": [{
			"schema_name": "rvlt_salesforce",
			"tables": [{
				"table_name": "rsfrc_kunde_hub",
				"stereotype": "hub",
				"hub_key_column_name": "HK_RSFRC_KUNDE"
			}, {
				"table_name": "rsfrc_kunde_p1_sat",
				"stereotype": "sat",
				"satellite_parent_table": "rsfrc_kunde_hub",
				"diff_hash_column_name": "RH_KUNDE_P1_SAT"
			}]
		},
		{
			"schema_name": "rvlt_knuppisoft",
			"tables": [{
					"table_name": "rkpsf_auftrag_hub",
					"stereotype": "hub",
					"hub_key_column_name": "HK_RKPSF_AUFTRAG"
				}, {
					"table_name": "rkpsf_auftrag_p1_sat",
					"stereotype": "sat",
					"satellite_parent_table": "rkpsf_auftrag_hub",
					"diff_hash_column_name": "RH_AUFTRAG_P1_SAT"
				}, {
					"table_name": "rkpsf_auftrag_kunde_lnk",
					"stereotype": "link",
					"link_key_column_name": "LK_RKPSF_AUFTRAG_KUNDE",
					"link_parent_tables": ["rkpsf_auftrag_hub","rsfrc_kunde_hub"]
				}, {
					"table_name": "rkpsf_auftrag_kunde_esat",
					"stereotype": "esat",
					"satellite_parent_table": "rkpsf_auftrag_kunde_lnk",
					"tracked_field_groups": ["hauptkunde"],
					"driving_hub_keys": ["hk_rkpsf_auftrag"]
				},
				{
					"table_name": "rkpsf_auftrag_co_kunde_esat",
					"stereotype": "esat",
					"satellite_parent_table": "rkpsf_auftrag_kunde_lnk",
					"tracked_field_groups": ["co_kunde"],
					"driving_hub_keys": ["hk_rkpsf_auftrag"]
				}
			]
		}
	]
}'),
('rsfrc_kunde_master','{
 	"DVPD_Version": "1.0",
 	"pipeline_name": "rsfrc_kunde_master",
 	"record_source_name_expression": "salesforce.kundenmaster",
 	"data_fetch_module": {
 		"fetch_module_name": "read_file_delimted",
 		"search_expression": "$PipelineInputDirectory/kunde_master*.csv",
 		"file_archive_path": "$PipelineArchiveDirectory"
 	},
 	"data_parse_module": {
 		"parse_module_name": "delimited_text",
 		"codepage": "UTF_8",
 		"columnseparator": "|",
 		"rowseparator": "\n",
 		"skip_first_rows": "1",
 		"reject_processing": "reject_container"
 	},
 	"fields": [{
 		"field_name": "KUNDE_NR",
 		"technical_type": "DECIMAL(10,0)",
 		"parsing_expression": "3",
 		"targets": [{
 			"table_name": "rsfrc_kunde_hub"
 		}]
 	}, {
 		"field_name": "MASTER_KUNDE_NR",
 		"technical_type": "DECIMAL(10,0)",
 		"parsing_expression": "4",
 		"targets": [{
 			"table_name": "rsfrc_kunde_hub",
 			"target_column_name": "KUNDE_NR",
 			"hierarchy_key_suffix": "master"
 		}]

 	}],
 	"data_vault_modell": [{
 		"schema_name": "rvlt_salesforce",
 		"tables": [{
 				"table_name": "rsfrc_kunde_hub",
 				"stereotype": "hub",
 				"hub_key_column_name": "HK_RSFRC_KUNDE"
 			}, {
 				"table_name": "rkpsf_kunde_kunde_master_lnk",
 				"stereotype": "link",
 				"link_key_column_name": "LK_RKPSF_AUFTRAG_KUNDE",
 				"link_parent_tables": ["rsfrc_kunde_hub"]
 			},
 			{
 				"table_name": "rkpsf_kunde_kunde_master_esat",
				"satellite_parent_table": "rkpsf_kunde_kunde_master_lnk",
 				"stereotype": "esat",
 				"satellite_parent": "rkpsf_kunde_kunde_master_lnk",
 				"driving_hub_keys": ["HK_RSFRC_KUNDE"]
 			}
 		]
 	}]
 }');





drop view dvpd_dv_model_table cascade;
create or replace view dvpd_dv_model_table as 
with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline
, json_array_elements(dvpd_json->'data_vault_modell')->>'schema_name' as schema_name
, json_array_elements(dvpd_json->'data_vault_modell')->'tables' as tables
from public.dvpd_dictionary dt 
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

drop view dvpd_field_mapping cascade;
create or replace view dvpd_field_mapping as
with source_fields AS (
Select 
dvpd_json ->>'pipeline_name' as pipeline
,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
,json_array_elements(dvpd_json->'fields')->>'technical_type' as field_type
,json_array_elements(dvpd_json->'fields')->>'parsing_expression' as parsing_expression
,json_array_elements(dvpd_json->'fields')->'targets' as targets
,json_array_elements(dvpd_json->'fields')->'uniqeness_groups' as uniqeness_groups
,json_array_elements(dvpd_json->'fields')->'field_comment' as field_comment
from public.dvpd_dictionary dt 
)
,target_expansion AS (
select 
 pipeline
,field_name
,field_type
,parsing_expression
,json_array_elements(targets)->>'table_name' as target_table
,json_array_elements(targets)->>'target_column_name' as target_column_name
,json_array_elements(targets)->>'target_column_type' as target_column_type
,json_array_elements(targets)->'field_groups' as field_groups
,json_array_elements(targets)->>'prio_in_key_hash' as prio_in_key_hash
,json_array_elements(targets)->>'exclude_from_key_hash' as exclude_from_key_hash
,json_array_elements(targets)->>'hierarchy_key_suffix' as hierarchy_key_suffix
,json_array_elements(targets)->>'prio_in_diff_hash' as prio_in_diff_hash
,json_array_elements(targets)->>'exclude_from_diff_hash' as exclude_from_diff_hash
,json_array_elements(targets)->>'is_encrypted' as is_encrypted
,json_array_elements(targets)->'hash_cleansing_rules' as hash_cleansing_rules
from source_fields
)
-- finale structure
select 
 lower(pipeline) as  pipeline
,upper(field_name) as field_name
,upper(field_type) as field_type
,parsing_expression
,lower(target_table) as target_table
,upper(coalesce (target_column_name,field_name)) as target_column_name
,upper(coalesce (target_column_type,field_type)) as target_column_type
,case when field_groups is not null then json_array_elements_text(field_groups) else '##all##' end as field_group
,coalesce(to_number(prio_in_key_hash,'9'),0) as prio_in_hashkey
,coalesce(exclude_from_key_hash::bool,false) as exclude_from_key_hash
,upper(coalesce(hierarchy_key_suffix,'')) as hierarchy_key_suffix
,coalesce(to_number(prio_in_diff_hash,'9'),0) as prio_in_diff_hash
,coalesce(exclude_from_diff_hash::bool,false) as exclude_from_diff_hash
,coalesce(is_encrypted::bool,false) as is_encrypted
,hash_cleansing_rules
from target_expansion;

select * from dvpd_field_mapping
order by pipeline ,field_name,target_table;

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
 join public.dvpd_meta_lookup dml on dml.stereotype ='link'
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
 join public.dvpd_meta_lookup dml on dml.stereotype ='hub'
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
 join public.dvpd_meta_lookup dml on dml.stereotype = tb.stereotype 
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
			from public.dvpd_field_mapping dfm  
		) direct_mapped_tables
)
, sat_parents as (
select tl.pipeline 
,tb.satellite_parent  as table_name 
,leaf_table
from target_leafs tl
join public.dvpd_dv_model_table_basics tb on tb.pipeline =tl.pipeline
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

