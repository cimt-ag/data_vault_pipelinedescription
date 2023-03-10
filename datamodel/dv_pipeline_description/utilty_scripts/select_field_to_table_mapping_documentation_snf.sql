/* render mapping documentation */
with prepared_field_list as (	
select pipeline_name ,field_name
	,field_type
	,target_table
	,case when field_name <> target_column_name then '.['||target_column_name ||'] ' else '' end extra_target_name
	,case when exclude_from_diff_hash then '(not in diff hash)' else '' end diff_hash_text 
	,case when exclude_from_key_hash then '(in in key hash)' else '' end key_hash_text
	,case when field_group <> '_A_' then '(fieldgroup: '||field_group||')' else '' end field_group_text 
	from dv_pipeline_description.dvpd_pipeline_field_target_expansion
	where pipeline_name = 'rvis_invoice_billing_method_p1'
	order by 1,2,3,4
)
select --pipeline_name 
field_name Feldname
,field_type Typ
,array_to_string(array_agg(target_table || extra_target_name||diff_hash_text||key_hash_text||field_group_text),','||chr(13)) Ziel 
from prepared_field_list
group by 1,2
order by 1,2