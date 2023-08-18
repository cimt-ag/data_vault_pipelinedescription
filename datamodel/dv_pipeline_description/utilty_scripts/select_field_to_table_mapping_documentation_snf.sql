/* render mapping documentation */
with prepared_field_list as (	
select pipeline_name ,field_name
	,field_type
	,table_name
	,case when field_name <> column_name then '.['||column_name ||'] ' else '' end extra_target_name
	,case when exclude_from_change_detection then '(not in diff hash)' else '' end diff_hash_text 
	,case when exclude_from_key_hash then '(in in key hash)' else '' end key_hash_text
	,case when relation_name not in ('*','/') then '(relation: '||relation_name||')' else '' end relation_name_text 
	from dv_pipeline_description.dvpd_pipeline_field_target_expansion
	where pipeline_name = 'test_220_r_topo_sat'
	order by 1,2,3,4
)
select --pipeline_name 
field_name Feldname
,field_type Typ
,array_to_string(array_agg(table_name || extra_target_name||diff_hash_text||key_hash_text||relation_name_text),','||chr(13)) Ziel 
from prepared_field_list
group by 1,2
order by 1,2