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
create or replace view dv_pipeline_description.DVPD_CHECK_ALL as

select * FROM dv_pipeline_description.dvpd_check_field_specifics
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_model_relations
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_model_stereotype_and_parameters
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_sat_specifics  
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_hub_specifics  
where message <>'ok'
UNION
select * FROM dv_pipeline_description.dvpd_check_link_specifics  
where message <>'ok'
union
select * FROM dv_pipeline_description.dvpd_check_stage_specifics dcss  
where message <>'ok'
union
select * FROM dv_pipeline_description.dvpd_check_relation_specifics
where message <>'ok'
union
select * FROM dv_pipeline_description.xenc_check_properties 
where message <>'ok'
union
select * FROM dv_pipeline_description.xenc_check_properties  
where message <>'ok'
union
select * FROM dv_pipeline_description.xenc_check_relations 
where message <>'ok'

ORDER BY 1,2,3;


comment on view dv_pipeline_description.DVPD_CHECK_ALL IS
	'Shows all errors from incomplete or wrong configured pipeline descriptions, including the errors created on purpose by testsets';


-- select * from dv_pipeline_description.DVPD_CHECK_ALL order by 1,2,3



