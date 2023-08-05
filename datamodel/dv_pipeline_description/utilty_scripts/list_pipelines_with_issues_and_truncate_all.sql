
-- List pipelines wiss test issues
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_issue_all
order by 1;

-- remove all pipelines for faster testing
truncate table dv_pipeline_description.dvpd_dictionary;

truncate table dv_pipeline_description.dvpd_atmtst_reference;

