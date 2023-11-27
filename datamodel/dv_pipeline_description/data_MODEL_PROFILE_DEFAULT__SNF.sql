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

DELETE FROM dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile';

INSERT INTO dv_pipeline_description.dvpd_json_storage 
(object_class,object_name,object_json)
VALUES
('model_profile','_default','{
 "model_profile_name" : "_default"
,"table_key_column_type"	: "CHAR(28)"
,"table_key_hash_function"		: "sha-1"
,"table_key_hash_encoding"	: "BASE64"
,"hash_concatenation_seperator" : "|"
,"hash_timestamp_format_sqlstyle" : "YYYY-MM-DD HH24:MI:SS.US"
,"hash_null_value_string" : ""
,"key_for_null_ghost_record": 	  "0000000000000000000000000001"
,"key_for_missing_ghost_record": "FFFFFFFFFFFFFFFFFFFFFFFFFFFE"
,"far_future_timestamp" : "2299-12-30 00:00:00"
,"compare_criteria_default":"key+current"
,"uses_diff_hash_default":"true"
,"diff_hash_column_type"	: "CHAR(28)"
,"diff_hash_function"			: "sha-1"
,"diff_hash_encoding"		: "BASE64"
,"is_enddated_default"   :  "true"
,"load_date_column_name" : "MD_INSERTED_AT"
,"load_date_column_type" : "TIMESTAMP"
,"load_enddate_column_name" : "MD_VALID_BEFORE"
,"load_enddate_column_type" : "TIMESTAMP"
,"has_deletion_flag_default": "true"
,"deletion_flag_column_name" : "MD_IS_DELETED"
,"deletion_flag_column_type" : "BOOLEAN"
,"record_source_column_name" : "MD_RECORD_SOURCE"
,"record_source_column_type" : "VARCHAR(255)"
,"load_process_id_column_name" : "MD_RUN_ID"
,"load_process_id_column_type" : "INT"
,"xenc_encryption_key_column_type"		: "CHAR(28)"
,"xenc_encryption_key_index_column_type": "INT"
,"xenc_content_hash_column_type"		: "CHAR(28)"
,"xenc_content_hash_function"				: "sha-1"
,"xenc_content_hash_encoding"			: "BASE64"
}
');


-- Translate the json into the raw table for model profiles
DELETE FROM dv_pipeline_description.DVPD_MODEL_PROFILE_RAW where model_profile_name  = '_default';

INSERT INTO DVF_DEV_MWG.DV_PIPELINE_DESCRIPTION.DVPD_MODEL_PROFILE_RAW
(MODEL_PROFILE_NAME, PROPERTY_NAME, PROPERTY_VALUE)
with parsed_json as (
select parse_json(object_json) object_json 
     from dv_pipeline_description.dvpd_json_storage 
     where object_name  = '_default' and object_class ='model_profile'
)
select object_json:"model_profile_name"::string model_profile_name
,value::string property_name
,get(object_json,value)::string property_value
from parsed_json, Lateral flatten(input=> object_keys(object_json))
where value not in ('model_profile_name')
order by key;

-- refresh model profile cache
delete from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP;
insert into dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP 
 select * from dv_pipeline_description.DVPD_MODEL_PROFILE_META_COLUMN_LOOKUP_CVIEW
;
  


