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

create or replace procedure dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE(
   profile_to_load varchar
)
returns boolean
as 
$$
begin

truncate table  dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP ; 	
insert into dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP  
	select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP_CVIEW ;

return true;
end;
$$;

 comment on procedure  dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE (varchar) is
 	'Helper function to convert and load the dvpd model profile document into the relational tables';
 	
--call   dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE('hello');