--drop function DVPC_GENERATE_HUB_INSERT(varchar,varchar,varchar,bigint,timestamp,varchar);
create or replace function dv_processing.DVPC_GENERATE_HUB_INSERT(
   a_pipeline_name varchar, a_table_name varchar, a_process_block varchar,
   a_insert_timestamp timestamp,a_record_source varchar,a_load_id bigint) 

returns varchar
language plpgsql    
as 
$$

DECLARE 
elt_statement varchar := '';
dv_column_list varchar :='';
stage_column_list varchar :='';
stage_meta_column_list varchar :='';
join_clause varchar :='';
stage_table_name varchar := a_pipeline_name ;
table_key_name varchar := '';
table_schema_name varchar := '';

BEGIN

select schema_name 
into table_schema_name
from dv_pipeline_description.dvpd_pipeline_dv_table dpdt 
where pipeline_name  = a_pipeline_name
and table_name = a_table_name;

Select column_name
INTO  table_key_name
from dv_pipeline_description.dvpd_pipeline_dv_column dpdt 
where dv_column_class  = 'key'
and pipeline_name = a_pipeline_name
and table_name = a_table_name;

Select string_agg( column_name,',' order by column_block ,column_name)
INTO  dv_column_list
from dv_pipeline_description.dvpd_pipeline_dv_column dpdc 
where pipeline_name = a_pipeline_name
and table_name = a_table_name;

--where pipeline_name like 'test50%'
--and table_name = 'rtjj_50_aaa_hub'
--and process_block='_A_'

Select 
string_agg( meta_column_content || ' AS ' || column_name  ,',' order by column_name)
INTO  stage_meta_column_list
from dv_pipeline_description.dvpd_pipeline_dv_column pdc 
join dv_processing.dvpd_meta_column_content mcc on mcc.meta_column_name = pdc.column_name
--where pdc.pipeline_name like 'test50%'
--and pdc.table_name = 'rtjj_50_aaa_hub'
where pipeline_name = a_pipeline_name
and table_name = a_table_name
;

stage_meta_column_list:= replace(stage_meta_column_list, '{a_record_source}', ''''||a_record_source||'''');
stage_meta_column_list:= replace(stage_meta_column_list, '{a_insert_timestamp}',''''||to_char(a_insert_timestamp,'YYYY-MM-DD HH24-MI-SS.US')||'''');
stage_meta_column_list:= replace(stage_meta_column_list, '{a_load_id}',a_load_id::varchar);

Select 
string_agg( stage_column_name ,',' order by column_block,column_name)
INTO  stage_column_list
from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping  
--where pipeline_name like 'test50%'
--and table_name = 'rtjj_50_aaa_hub'
--and process_block = '_A_' ;
where pipeline_name = a_pipeline_name
and table_name = a_table_name
and process_block = a_process_block ;

Select string_agg( 'hub.'||column_name||'=stage.'||stage_column_name ,' AND ' order by column_name)
INTO  join_clause
from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping
where dv_column_class  = 'business_key'
and pipeline_name = a_pipeline_name
and table_name = a_table_name
and process_block = a_process_block ;

elt_statement = 'INSERT INTO '||a_table_name || '('||dv_column_list||')'||
				' SELECT DISTINCT'||stage_meta_column_list ||','||stage_column_list ||
				' FROM ' || stage_table_name  || ' stage'
				' LEFT JOIN ' || a_table_name || ' hub  ON ' || join_clause ||
				' WHERE hub.'||table_key_name||' IS NULL -- ## Exculsion of Ghost records must be added';



			return elt_statement;

END;
$$;

-- test 
select dv_processing.DVPC_GENERATE_HUB_INSERT('test50_double_esat_field_group'::varchar,
											'rtjj_50_aaa_hub'::varchar,
											'_A_'::varchar,
											now()::timestamp without time zone ,
											'test50.dummy record source'::varchar,
											-1) ;