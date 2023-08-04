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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_ALL cascade;
create or replace view dv_pipeline_description.DVPD_CHECK as

select * FROM dv_pipeline_description.DVPD_CHECK_ALL
where pipeline_name not like '%test0%' 
and pipeline_name not like '%test1%' 
and pipeline_name not like 'ctst%'
ORDER BY 1,2,3;

comment on view dv_pipeline_description.DVPD_CHECK IS
	'Shows all errors from incomplete or wrong configured pipeline descriptions (Empt if everything is fine)';

-- select * from dv_pipeline_description.DVPD_CHECK order by 1,2,3



