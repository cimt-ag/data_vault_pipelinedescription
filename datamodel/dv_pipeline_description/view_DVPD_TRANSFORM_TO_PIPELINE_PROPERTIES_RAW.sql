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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_PROPERTIES_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_PROPERTIES_RAW as 

select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,dvpd_json ->>'dvpd_version' as dvpd_version
	,dvpd_json ->>'pipeline_revision_tag' as pipeline_revision_tag
	,dvpd_json ->>'pipeline_comment' as pipeline_comment
	,dvpd_json ->>'record_source_name_expression' as record_source_name_expression
	,dvpd_json ->'data_extraction'->>'fetch_module_name' as fetch_module_name
	,dvpd_json ->>'model_profile_name' as model_profile_name 
from dv_pipeline_description.dvpd_dictionary dt 
;

comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_PROPERTIES_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';

