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
,"key_for_null_ghost_record": 	  "0000000000000000000000000000"
,"key_for_missing_ghost_record": "FFFFFFFFFFFFFFFFFFFFFFFFFFFF"
,"far_future_timestamp" : "2299-12-30 00:00:00"
,"diff_hash_required":"true"
,"diff_hash_column_type"	: "CHAR(28)"
,"diff_hash_function"			: "sha-1"
,"diff_hash_encoding"		: "BASE64"
,"is_enddated_default"   :  "true"
,"load_date_column_name" : "META_INSERTED_AT"
,"load_date_column_type" : "TIMESTAMP"
,"load_enddate_column_name" : "META_VALID_BEFORE"
,"load_enddate_column_type" : "TIMESTAMP"
,"deletion_flag_column_name" : "META_IS_DELETED"
,"deletion_flag_column_type" : "BOOLEAN"
,"record_source_column_name" : "META_RECORD_SOURCE"
,"record_source_column_type" : "VARCHAR(255)"
,"load_process_id_column_name" : "META_JOB_INSTANCE_ID"
,"load_process_id_column_type" : "INT8"
,"xenc_encryption_key_column_type"		: "CHAR(28)"
,"xenc_encryption_key_index_column_type": "INT8"
,"xenc_content_hash_column_type"		: "CHAR(28)"
,"xenc_content_hash_function"				: "sha-1"
,"xenc_content_hash_encoding"			: "BASE64"
}
');

select dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE('_default');


--select object_json->>'model_profile_name' model_profile_name ,json_object_keys(object_json) property_name ,object_json->>json_object_keys(object_json) property_value from dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile'
