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

-- drop table dv_pipeline_description.DVPD_MODEL_PROFILE_RAW cascade;

Create table if not exists dv_pipeline_description.DVPD_MODEL_PROFILE_RAW (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  model_profile_name VARCHAR(100),
  property_name VARCHAR(60),
  property_value VARCHAR(60),
  PRIMARY KEY(model_profile_name,property_name)
  ); 
