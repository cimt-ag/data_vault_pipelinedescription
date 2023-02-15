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

-- THIS IS THE ADAPTED SYNTAX FOR SNOWFLAKE DATABASES

--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE as 


select JSON_EXTRACT_PATH_TEXT(object_json,'model_profile_name') model_profile_name
 --,object_keys(parse_json(object_json)) property_value
 ,fj.value::text property_name
 ,JSON_EXTRACT_PATH_TEXT(object_json,fj.value ) property_value
from dv_pipeline_description.dvpd_json_storage
, lateral flatten(input=>object_keys(parse_json (object_json))) fj
where object_class ='model_profile';


comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';

/*
truncate table dv_pipeline_description.DVPD_MODEL_PROFILE_RAW;
insert into dv_pipeline_description.DVPD_MODEL_PROFILE_RAW (model_profile_name,property_name,property_value) 
SELECT model_profile_name,property_name,property_value FROM dv_pipeline_description.DVPD_TRANSFORM_TO_MODEL_PROFILE
*/