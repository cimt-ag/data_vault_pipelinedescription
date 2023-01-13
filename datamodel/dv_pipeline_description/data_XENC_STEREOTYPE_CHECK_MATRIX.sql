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


Delete from dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX where stereotype like 'xenc%';
INSERT INTO dv_pipeline_description.DVPD_STEREOTYPE_CHECK_MATRIX
(stereotype, needs_hub_key_column_name, needs_link_key_column_name, needs_link_parent_tables, needs_sattelite_parent_table)
VALUES('xenc_hub-ek', 0, 0, 0, 0),
	  ('xenc_lnk-ek', 0, 0, 0, 0),	
	  ('xenc_sat-ek', 0, 0, 0, 0),	
	  ('xenc_msat-ek', 0, 0, 0, 0),	
	  ('xenc_ref-ek', 0, 0, 0, 0)
	 ;
