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

--drop procedure dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(varchar);

create or replace procedure dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW(
   profile_to_load varchar
)
returns boolean
comment = 
 	'Helper function to convert and load the dvpd  document into the relational tables'

as 
$$
begin

truncate table  dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN; 	
insert into dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN  select * from dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CVIEW;
	
truncate table dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ;
insert into  dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN 
 select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_CVIEW;

truncate table dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING ;
insert into  dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING 
 select * from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_core;
insert into dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING 
select * from dv_pipeline_description.xenc_pipeline_process_stage_to_dv_model_mapping_addition;


return true;
end;
$$;

 	
--call   dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('hello');