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

 -- drop table  dv_pipeline_description.DVPD_ATMTST_REFERENCE cascade;

  create table dv_pipeline_description.DVPD_ATMTST_REFERENCE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  pipeline_name VARCHAR(100),
  reference_data_json json,
  PRIMARY KEY ( pipeline_name)
  );
  
 comment on table dv_pipeline_description.DVPD_ATMTST_REFERENCE is
 	'Reference data for the automatic test of the dvpd implementation;'