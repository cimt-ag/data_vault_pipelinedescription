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

DELETE FROM dv_pipeline_description.dvpd_json_storage where object_name  = 'TEST00' and object_class ='model_profile';

INSERT INTO dv_pipeline_description.dvpd_json_storage 
(object_class,object_name,object_json)
VALUES
('model_profile','TEST00','{
 "model_profile_name" : "TEST00"
,"table_key_column_type"	: "VARCHAR(100)"
,"table_key_hash_function"		: "sha-1"
,"table_key_hash_encoding"	: "BASE64"
,"hash_concatenation_seperator" : "_T00_"
,"hash_timestamp_format_sqlstyle" : "_T00"
,"hash_null_value_string" : "_T00"
,"key_for_null_ghost_record": 	  "T00_0000"
,"key_for_missing_ghost_record": "T00_FFFF"
,"far_future_timestamp" : "2400-01-01 00:00:01"
,"compare_criteria_default":"key+current"
,"uses_diff_hash_default":"true"
,"diff_hash_column_type"	: "VARCHAR(100)"
,"diff_hash_function"			: "sha-1"
,"diff_hash_encoding"		: "BASE64"
,"is_enddated_default"   :  "true"
,"load_date_column_name" : "IA_T00"
,"load_date_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"load_enddate_column_name" : "VB_T00"
,"load_enddate_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"has_deletion_flag_default": "false"
,"deletion_flag_column_name" : "ID_T00"
,"deletion_flag_column_type" : "integer"
,"record_source_column_name" : "RS_T00"
,"record_source_column_type" : "VARCHAR(100)"
,"load_process_id_column_name" : "LI_T00"
,"load_process_id_column_type" : "INT8"
,"xenc_encryption_key_column_type"		: "VARCHAR(100)"
,"xenc_encryption_key_index_column_type": "INT8"
,"xenc_content_hash_column_type"		: "VARCHAR(100)"
,"xenc_content_hash_function"				: "sha-1"
,"xenc_content_hash_encoding"			: "BASE64"
}
');

select dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE('TEST00');


--select object_json->>'model_profile_name' model_profile_name ,json_object_keys(object_json) property_name ,object_json->>json_object_keys(object_json) property_valuefrom dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile'
