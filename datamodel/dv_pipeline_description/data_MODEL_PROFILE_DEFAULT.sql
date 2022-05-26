
DELETE FROM dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile';
															;
INSERT INTO dv_pipeline_description.dvpd_json_storage 
(object_class,object_name,object_json)
VALUES
('model_profile','_default','{
 "data_vault_model_profile_name" : "_default"
,"table_key_column_type"	: "CHAR(28)"
,"table_key_hash_type"		: "sha-1"
,"table_key_hash_encoding"	: "BASE64"
,"hash_concatenation_seperator" : "|"
,"hash_timestamp_format_sqlstyle" : "#do be defined#"
,"hash_null_value_string" : ""
,"diff_hash_column_type"	: "CHAR(28)"
,"diff_hash_type"			: "sha-1"
,"diff_hash_encoding"		: "BASE64"
,"load_date_column_name" : "META_INSERTED_AT"
,"load_date_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"load_enddate_column_name" : "META_VALID_BEFORE"
,"load_enddate_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"deletion_flag_column_name" : "META_IS_DELETED"
,"deletion_flag_column_type" : "BOOLEAN"
,"record_source_column_name" : "META_RECORD_SOURCE"
,"record_source_column_type" : "VARCHAR(200)"
,"load_process_id_column_name" : "META_JOB_INSTANCE_ID"
,"load_process_id_column_type" : "INT8"
,"xenc_encryption_key_column_type"		: "CHAR(28)"
,"xenc_encryption_key_index_column_type": "INT8"
,"xenc_content_hash_column_type"		: "CHAR(28)"
,"xenc_content_hash_type"				: "sha-1"
,"xenc_content_hash_encoding"			: "BASE64"
}
');

select dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE('_default');


--select object_json->>'data_vault_model_profile_name' data_vault_model_profile_name ,json_object_keys(object_json) property_name ,object_json->>json_object_keys(object_json) property_valuefrom dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile';
