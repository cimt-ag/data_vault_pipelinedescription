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

DELETE FROM dv_pipeline_description.dvpd_meta_column_lookup where table_stereotype like '%xenc%';	
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(table_stereotype, meta_column_name, meta_column_type)
VALUES('xenc_hub-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_sat-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_lnk-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_ref-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('_xenc_stg-ek', 'load_date_column_name', 'load_date_column_type'),
	  ('xenc_hub-ek',  'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_lnk-ek', 'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_sat-ek',  'record_source_column_name', 'record_source_column_type'),	
	  ('xenc_ref-ek', 'record_source_column_name', 'record_source_column_type'),		
	  ('_xenc_stg-ek', 'record_source_column_name', 'record_source_column_type'),		
	  ('xenc_hub-ek', 'load_process_id_column_name', 'load_process_id_column_type'),		
	  ('xenc_lnk-ek', 'load_process_id_column_name', 'load_process_id_column_type'),		
	  ('xenc_sat-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('xenc_ref-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('_xenc_stg-ek', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  --('xsat_hist', 'load_enddate_column_name', 'load_enddate_column_type'), part of core	
	  ('xenc_ref_hist-ek', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('_xenc_stg-ek', 'deletion_flag_column_name', 'deletion_flag_column_type')	
	 ;	