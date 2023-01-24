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


-- drop table dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION cascade;


Create table if not exists dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  dv_column_class VARCHAR(40),
  stereotype VARCHAR(40),
  stage_column_block int4
  ); 

COMMENT on TABLE dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION 
     is 'Table to determine the major order of columns in the stage table ddl';

-- talend tHashRow optimized version
TRUNCATE TABLE dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION;

INSERT INTO dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION
( dv_column_class, stereotype,stage_column_block)
VALUES
	  ('key','hub', 10),
	  ('parent_key','lnk', 11),	
	  ('key','lnk', 20),	
	  ('parent_key', 'sat', 30),	
	  ('parent_key', 'msat', 30),	
	  ('parent_key', 'esat', 30),	
	  ('diff_hash', null, 40),	
	  ('business_key', null, 50),	
	  ('dependent_child_key', null, 55),	
	  ('content', null, 60),	
	  ('content_untracked', null, 65)
;


-- Base Version used in automated tests  <<<<<<<<<<<<< LAST ONE WINS on automated install

TRUNCATE TABLE dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION;

INSERT INTO dv_pipeline_description.DVPD_STAGE_COLUMN_BLOCK_CONFIGURATION
( dv_column_class, stereotype,stage_column_block)
VALUES

	  ('key','hub', 2),
	  ('parent_key','lnk', 3),	
	  ('key','lnk', 2),	
	  ('parent_key', 'sat', 2),	
	  ('parent_key', 'msat', 2),	
	  ('parent_key', 'esat', 2),	
	  ('xenc_encryption_key_index',null,6),
	  ('diff_hash', null, 3),	
	  ('business_key', null, 8),	
	  ('dependent_child_key', null, 8),	
	  ('content', null, 8),	
	  ('content_untracked', null, 8)   
 ;
	

