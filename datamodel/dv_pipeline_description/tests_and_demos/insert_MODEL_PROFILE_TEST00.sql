
DELETE FROM dv_pipeline_description.dvpd_json_storage where object_name  = 'TEST00' and object_class ='model_profile';

INSERT INTO dv_pipeline_description.dvpd_json_storage 
(object_class,object_name,object_json)
VALUES
('model_profile','TEST00','{
 "model_profile_name" : "TEST00"
,"table_key_column_type"	: "VARCHAR(100)"
,"table_key_hash_type"		: "sha-1"
,"table_key_hash_encoding"	: "BASE64"
,"hash_concatenation_seperator" : "_T00_"
,"hash_timestamp_format_sqlstyle" : "_T00"
,"hash_null_value_string" : "_T00"
,"key_for_null_ghost_record": 	  "T00_0000"
,"key_for_missing_ghost_record": "T00_FFFF"
,"far_future_timestamp" : "2400-01-01 00:00:01"
,"diff_hash_column_type"	: "VARCHAR(100)"
,"diff_hash_type"			: "sha-1"
,"diff_hash_encoding"		: "BASE64"
,"load_date_column_name" : "IA_T00"
,"load_date_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"load_enddate_column_name" : "VB_T00"
,"load_enddate_column_type" : "TIMESTAMP WITHOUT TIME ZONE"
,"deletion_flag_column_name" : "ID_T00"
,"deletion_flag_column_type" : "integer"
,"record_source_column_name" : "RS_T00"
,"record_source_column_type" : "VARCHAR(100)"
,"load_process_id_column_name" : "LI_T00"
,"load_process_id_column_type" : "INT8"
,"xenc_encryption_key_column_type"		: "VARCHAR(100)"
,"xenc_encryption_key_index_column_type": "INT8"
,"xenc_content_hash_column_type"		: "VARCHAR(100)"
,"xenc_content_hash_type"				: "sha-1"
,"xenc_content_hash_encoding"			: "BASE64"
}
');

select dv_pipeline_description.DVPD_LOAD_MODEL_PROFILE('TEST00');


--select object_json->>'model_profile_name' model_profile_name ,json_object_keys(object_json) property_name ,object_json->>json_object_keys(object_json) property_valuefrom dv_pipeline_description.dvpd_json_storage where object_name  = '_default' and object_class ='model_profile'
