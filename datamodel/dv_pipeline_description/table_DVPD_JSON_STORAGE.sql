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

 -- drop table dv_pipeline_description.DVPD_JSON_STORAGE cascade;

  create table dv_pipeline_description.DVPD_JSON_STORAGE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  object_class VARCHAR(100),
  object_name VARCHAR(100),
  object_json json,
  PRIMARY KEY ( object_class, object_name )
  );
  
 comment on table  dv_pipeline_description.DVPD_JSON_STORAGE is 
 'Table to store the json input texts for pipelines and profiles';