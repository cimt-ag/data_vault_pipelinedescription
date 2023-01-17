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


-- drop table if exists dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX cascade;

Create table if not exists dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  stereotype VARCHAR(20),
  needs_hub_key_column_name int,
  needs_link_key_column_name int,
  needs_sattelite_parent_table int,
  needs_link_parent_tables int
  ); 

TRUNCATE TABLE dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX;
INSERT INTO dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX
(stereotype, needs_hub_key_column_name, needs_link_key_column_name, needs_link_parent_tables, needs_sattelite_parent_table)
VALUES('hub', 1, 0, 0, 0),
	  ('lnk', 0, 1, 1, 0),	
	  ('sat', 0, 0, 0, 1),	
	  ('msat', 0, 0, 0, 1),	
	  ('esat', 0, 0, 0, 1),
	  ('ref', 0, 0, 0, 0)
	 ;

comment on table dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX is
 'Declaration of mandatory parameters for every stereotype.';