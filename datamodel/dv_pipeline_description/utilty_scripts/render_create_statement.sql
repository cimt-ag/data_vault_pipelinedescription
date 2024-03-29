/* render DDL statements for a pipeline */
with target as (
select distinct 
	  dpdt.pipeline_name
	, dpsp.stage_schema stage_schema_name
	, dpsp.stage_table_name
	, xpsp.xenc_stage_schema xenc_stage_schema_name
	, xpsp.xenc_stage_table_name
from dv_pipeline_description.dvpd_pipeline_DV_table dpdt
join dv_pipeline_description.dvpd_pipeline_stage_properties dpsp on dpsp.pipeline_name =dpdt.pipeline_name 
left join dv_pipeline_description.xenc_pipeline_stage_properties xpsp on xpsp.pipeline_name =dpdt.pipeline_name 
--where pipeline_name like 'test20%'
where dpdt.pipeline_name like '%test22%'
) /* */
, model_profile as (select property_value load_date_column_name 
from target tgt
join dv_pipeline_description.dvpd_pipeline_properties pp on pp.pipeline_name = tgt.pipeline_name 
join dv_pipeline_description.dvpd_model_profile mp on mp.model_profile_name = pp.model_profile_name 
where mp.property_name = 'load_date_column_name'
)
, script_renderer as (
/* Start of the union */
select tbl.table_name , 5 block
,1 reverse_order
,'-- >>> begin of: table_'||tbl.table_name||'.sql in '||tbl.schema_name||' <<<'  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 10 block
,1 reverse_order
,'-- DROP TABLE '||tbl.schema_name ||'.'||tbl.table_name  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 19 block
,1 reverse_order
,' '  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 20 block
,1 reverse_order
,'CREATE TABLE '||tbl.schema_name ||'.'||tbl.table_name   || '(' script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name  
union
select table_name , 30 block
,reverse_order
, '  '|| column_name || '     '
 || column_type || '   ' 
 ||  column_constraint
 ||(case when reverse_order=1 then '' else ',' end) script
from (
	select 
	rank () OVER (partition by dmc.pipeline_name, dmc.table_name order by   column_block desc, column_name desc ) reverse_order
	, dmc.table_name 
	,coalesce(dmc.column_block,-1) column_block
	,coalesce(dmc.column_name,'')  column_name
	,coalesce(dmc.column_type,'')  column_type
	,case when dmc.is_nullable  then ' ' else ' NOT NULL ' end as column_constraint
	from dv_pipeline_description.dvpd_pipeline_dv_table dptt  
	join dv_pipeline_description.dvpd_pipeline_dv_column dmc  on  dmc.table_name =dptt.table_name 
	   													and dmc.pipeline_name =dptt.pipeline_name 
where dptt.pipeline_name in (select pipeline_name from target) 
) the_columns
union
select tbl.table_name , 31 block
,1 reverse_order
,'); 'script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 33 block
,1 reverse_order
,'COMMENT ON TABLE '||tbl.schema_name ||'.'||tbl.table_name   || ' IS '''|| table_content_comment || '''; 'script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
where table_content_comment is not null
union
select tbl.table_name , 39 block
,1 reverse_order
,' '  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 40 block
,1 reverse_order
	,'ALTER TABLE '||tbl.schema_name ||'.'||tbl.table_name   
	|| ' ADD CONSTRAINT '|| tbl.table_name || '_PK '
	|| ' PRIMARY KEY (' || coalesce (tbl.hub_key_column_name,tbl.link_key_column_name )|| ');' script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name 
where tbl.table_stereotype in ('hub','lnk')
union
select distinct tbl.table_name , 41 block
,1 reverse_order
	,'ALTER TABLE '||tbl.schema_name ||'.'||tbl.table_name   
	|| ' ADD CONSTRAINT '|| tbl.table_name || '_PK '
	|| ' PRIMARY KEY (' || pdc.column_name  || ',' || mp.load_date_column_name||');' script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name 
join dv_pipeline_description.dvpd_pipeline_dv_column pdc  on pdc.pipeline_name =tgt.pipeline_name 
													and pdc.table_name = tbl.table_name 
													and pdc.column_class ='parent_key'
join model_profile mp on 1=1
where tbl.table_stereotype in ('sat','esat') and tbl.table_name not like '%_csat'
union
select tbl.table_name , 48 block
,1 reverse_order
,'-- >>> end of: table_'||tbl.table_name||'.sql <<<'  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
select tbl.table_name , 49 block
,1 reverse_order
,' '  script
from target tgt
join dv_pipeline_description.dvpd_pipeline_dv_table tbl on tbl.pipeline_name =tgt.pipeline_name
union
-- Stage section
select stage_table_name , 50 block
,1 reverse_order
,'-- >>> begin of: table_'||stage_table_name||'.sql in '||tgt.stage_schema_name ||' <<<'  script
from target tgt
union
select stage_table_name table_name, 51 block
,1 reverse_order
,'-- DROP TABLE '||tgt.stage_schema_name ||'.'||stage_table_name  script
from target tgt
--join dv_pipeline_description.dvpd_pipeline_stage_table_column tbl on tbl.pipeline_name =tgt.pipeline_name  
union
select stage_table_name  , 59 block
,1 reverse_order
,' '  script
from target tgt
union
select stage_table_name table_name, 60 block  --<<<< STAGE TABLE
,1 reverse_order
,'CREATE TABLE '||tgt.stage_schema_name ||'.'|| tgt.stage_table_name || '(' script
from target tgt
union
select stage_table_name table_name, 70 block
,reverse_order
, '  '|| column_name || '      '
 || column_type || column_constraint
 ||(case when reverse_order=1 then '' else ',' end) script
from (
	select 
	rank () OVER (partition by stc.pipeline_name order by  column_block desc,min_table_name desc ,min_column_name desc ,stage_column_name desc	 ) reverse_order
	, stage_table_name  
	,coalesce(stc.column_block ,-1) column_block
	,coalesce(stc.stage_column_name ,'')  column_name
	,coalesce(stc.column_type,'')  column_type
	, case when stc.is_nullable then ' ' else ' NOT NULL ' end as column_constraint
	from dv_pipeline_description.dvpd_pipeline_stage_table_column stc  
	join target tgt on tgt.pipeline_name = stc.pipeline_name  
) the_columns
union
select stage_table_name , 72 block
,1 reverse_order
,');'
from target tgt 
union
select stage_table_name , 79 block
,1 reverse_order
,'-- >>> end of: table_'||stage_table_name||'.sql <<<'  script
from target tgt
)
-- ========== XENC part ====================================================================================
, xenc_relevance_check as (
select distinct tgt.pipeline_name
from dv_pipeline_description.dvpd_pipeline_dv_table dpdt
join target tgt on tgt.pipeline_name = dpdt.pipeline_name
where table_stereotype like 'xenc%'
)
, xenc_script_renderer as (
select xenc_stage_table_name table_name, 80 block
,1 reverse_order
,'-- >>> begin of: table_'||xenc_stage_table_name||'.sql in '||tgt.xenc_stage_schema_name ||' <<<'  script
from target tgt join xenc_relevance_check xrc using(pipeline_name)
union
select xenc_stage_table_name table_name, 81 block
,1 reverse_order
,'-- DROP TABLE '||tgt.xenc_stage_schema_name ||'.'||xenc_stage_table_name  script
from target tgt join xenc_relevance_check xrc using(pipeline_name)
--join dv_pipeline_description.dvpd_pipeline_stage_table_column tbl on tbl.pipeline_name =tgt.pipeline_name  
union
select xenc_stage_table_name  table_name , 84 block
,1 reverse_order
,' '  script
from target tgt join xenc_relevance_check xrc using(pipeline_name)
union
select xenc_stage_table_name table_name, 90 block 
,1 reverse_order
,'CREATE TABLE '||tgt.xenc_stage_schema_name ||'.'|| tgt.xenc_stage_table_name || '(' script
from target tgt join xenc_relevance_check xrc using(pipeline_name)
union 
select xenc_stage_table_name table_name, 91 block
,reverse_order
, '  '|| column_name || '      '
 || column_type || column_constraint
 ||(case when reverse_order=1 then '' else ',' end) script
from (
	select 
	rank () OVER (partition by stc.pipeline_name order by  column_block desc,content_table_name desc ,stage_column_name desc	 ) reverse_order
	, xenc_stage_table_name  
	,coalesce(stc.column_block ,-1) column_block
	,coalesce(stc.stage_column_name ,'')  column_name
	,coalesce(stc.column_type,'')  column_type
	, ' NOT NULL '::text as column_constraint
	from dv_pipeline_description.xenc_pipeline_stage_table_column stc  
	join target tgt on tgt.pipeline_name = stc.pipeline_name  
) the_columns
union
select xenc_stage_table_name  table_name , 95 block
,1 reverse_order
,');'
from target tgt  join xenc_relevance_check xrc using(pipeline_name)
union
select xenc_stage_table_name  table_name, 99 block
,1 reverse_order
,'-- >>> end of: table_'||xenc_stage_table_name||'.sql <<<'  script
from target tgt join xenc_relevance_check xrc using(pipeline_name)
)
-- ========= Final assembly ==============
select table_name,block,reverse_order,script
from script_renderer 
union
select table_name,block,reverse_order,script 
from xenc_script_renderer xsr ,
 xenc_relevance_check xrc 
order by table_name,block,reverse_order desc

