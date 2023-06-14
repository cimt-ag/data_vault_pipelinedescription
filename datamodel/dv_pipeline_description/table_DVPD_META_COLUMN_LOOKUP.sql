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

-- drop table dv_pipeline_description.DVPD_META_COLUMN_LOOKUP cascade;

Create table if not exists dv_pipeline_description.DVPD_META_COLUMN_LOOKUP (
  meta_inserted_at TIMESTAMP DEFAULT current_timestamp,
  table_stereotype VARCHAR(20),
  meta_column_name VARCHAR(60),
  meta_column_type VARCHAR(60),
  PRIMARY KEY(table_stereotype,meta_column_name)
  ); 
 
comment on table dv_pipeline_description.DVPD_META_COLUMN_LOOKUP is 
	'Definition of the meta columns needed for every data vault table table_stereotype';

TRUNCATE TABLE dv_pipeline_description.dvpd_meta_column_lookup;
INSERT INTO dv_pipeline_description.dvpd_meta_column_lookup
(table_stereotype, meta_column_name, meta_column_type)
VALUES('hub', 'load_date_column_name', 'load_date_column_type'),
	  ('sat', 'load_date_column_name', 'load_date_column_type'),	
	  ('lnk', 'load_date_column_name', 'load_date_column_type'),	
	  ('msat', 'load_date_column_name', 'load_date_column_type'),	
	  ('ref', 'load_date_column_name', 'load_date_column_type'),	
	  ('_stg', 'load_date_column_name', 'load_date_column_type'),	
	  ('hub',  'record_source_column_name', 'record_source_column_type'),	
	  ('lnk', 'record_source_column_name', 'record_source_column_type'),	
	  ('sat',  'record_source_column_name', 'record_source_column_type'),	
	  ('msat', 'record_source_column_name', 'record_source_column_type'),	
	  ('ref', 'record_source_column_name', 'record_source_column_type'),	
	  ('_stg', 'record_source_column_name', 'record_source_column_type'),	
	  ('hub', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('lnk', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('sat', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('msat', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('ref', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('_stg', 'load_process_id_column_name', 'load_process_id_column_type'),	
	  ('xsat_hist', 'load_enddate_column_name', 'load_enddate_column_type'),	
	  ('xsat_delflag', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
--	  ('sat', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('_stg', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
--	  ('msat', 'load_enddate_column_name', 'load_enddate_column_type'),	
--	  ('msat', 'deletion_flag_column_name', 'deletion_flag_column_type'),	
	  ('ref_hist', 'load_enddate_column_name', 'load_enddate_column_type')	
	 ;


	
