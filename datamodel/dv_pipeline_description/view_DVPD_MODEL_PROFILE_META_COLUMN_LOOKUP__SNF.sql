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


-- drop  view  dv_pipeline_description.dvpd_model_profile_meta_column_lookup cascade;

Create  view dv_pipeline_description.dvpd_model_profile_meta_column_lookup as 
	
select mp_n.model_profile_name 
,table_stereotype 
, mp_n.property_value meta_column_name 
, mp_t.property_value meta_column_type 
from dv_pipeline_description.dvpd_meta_column_lookup mcl
join dv_pipeline_description.dvpd_model_profile mp_n on mp_n.property_name = mcl.meta_column_name 
join dv_pipeline_description.dvpd_model_profile mp_t on mp_t.property_name =mcl.meta_column_type 
													and mp_t.model_profile_name = mp_n.model_profile_name 
;			


comment on  view dv_pipeline_description.dvpd_model_profile_meta_column_lookup is
 'Profile specific naming and type of the meta columns needed for every data vault table table_stereotype';

-- select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;