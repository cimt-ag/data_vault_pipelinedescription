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



Create table if not exists dv_processing.DVPC_META_COLUMN_CONTENT (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  meta_column_name VARCHAR(60),
  meta_column_content VARCHAR(60),
  PRIMARY KEY(meta_column_name)
  ); 

TRUNCATE TABLE dv_processing.DVPC_META_COLUMN_CONTENT;
INSERT INTO dv_processing.DVPC_META_COLUMN_CONTENT
( meta_column_name, meta_column_content)
VALUES('META_INSERTED_AT', '{a_insert_timestamp}'),
	  ('META_RECORD_SOURCE', '{a_record_source}'),	
	  ('META_JOB_INSTANCE_ID', '{a_load_id}'),	
	  ('META_VALID_BEFORE', '''2299-12-30 23:00:00'''),	
	  ('META_IS_DELETED', 'META_IS_DELETED')	
	 ;
