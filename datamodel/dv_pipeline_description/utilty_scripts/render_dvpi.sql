/*
 *    JUST SOME FIRST NOTES HOW TO IMPLEMENT IT IN POSTGRES
 */

with target as (
select distinct pipeline_name
from dv_pipeline_description.dvpd_pipeline_DV_table
where pipeline_name like 'test35%'
) /* */
select  t.pipeline_name,'dvpd_pipeline_process_plan' as dvpi_section,json_agg(row_to_json(ppp.*)) section_json
from 
(select table_name
		,table_stereotype
		,relation_to_process
		,relation_origin
 from  dv_pipeline_description.dvpd_pipeline_process_plan ppp 
 join target t on t.pipeline_name = ppp.pipeline_name
 ) ppp,  target t 
 group by 1,2
 

join dv_pipeline_description.dvpd_pipeline_properties pp
) d
group by 1,2
