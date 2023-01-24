-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================


-- drop view if exists dv_pipeline_description.XENC_CHECK_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_CHECK_PROPERTIES as


select
  pdtp.pipeline_name
  ,'encryption key table'::TEXT  object_type 
  ,pdtp.table_name object_name
  ,'XENC_CHECK_PROPERTIES'::text  check_ruleset
  ,case when xenc_content_table_name is null then 'Content table name not declared'
    	else 'ok' 
    end  message
from dv_pipeline_description.xenc_pipeline_dv_table_properties pdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = pdtp.pipeline_name 
														and (pdt.table_name = pdtp.table_name)
where pdt.stereotype like 'xenc%';


comment on view dv_pipeline_description.XENC_CHECK_PROPERTIES IS
	'Check for encryption extention specific properties';

-- select * from dv_pipeline_description.XENC_CHECK_PROPERTIES order by 1,2,3



