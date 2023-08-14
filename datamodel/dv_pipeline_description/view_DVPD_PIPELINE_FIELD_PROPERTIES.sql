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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES as


select
 lower(pipeline_name) as  pipeline_name
 ,upper(field_name) as field_name
 ,upper(trim(field_type)) as field_type
 ,field_position  
 ,parsing_expression
 ,coalesce (needs_encryption,false) needs_encryption 
 ,field_comment
from dv_pipeline_description.dvpd_pipeline_field_properties_raw;

comment on view dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES is
 'Fields of the pipeline and their basic properties. (cleansed and normalized)';

-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD order by pipeline ,field_position;

