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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test24_encrypt_on_non_hist_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test24_encrypt_on_non_hist_sat','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "xenc_test24_encrypt_on_non_hist_sat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)"
														,"targets": [{"table_name": "rxecd_24_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_24_aaa_sat"}]}
		 	  ,{"field_name": "F3_AAA_SP1_ENCRYPT_ME",	"field_type": "VARCHAR(200)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_24_aaa_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_24_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_24_aaa"}
				,{"table_name": "rxecd_24_aaa_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_24_aaa_hub", "is_enddated":false,"has_deletion_flag":false}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_24_aaa_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_24_aaa_sat", "has_deletion_flag":false}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test24_encrypt_on_non_hist_sat');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test24_encrypt_on_non_hist_sat');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test24_encrypt_on_non_hist_sat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test24_encrypt_on_non_hist_sat','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_24_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_24_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_24_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_24_aaa_hub",2,"key","HK_RXECD_24_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_24_aaa_hub",8,"business_key","F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",2,"parent_key","HK_RXECD_24_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",6,"xenc_encryption_key_index","EKI_RXECD_24_AAA_SAT","INT8"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",8,"content","F2_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_24_aaa_sat",8,"content","F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",2,"key","HK_RXECD_24_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",5,"xenc_encryption_key","EK_RXECD_24_AAA_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_24_aaa_sat_ek",6,"xenc_encryption_key_index","EKI_RXECD_24_AAA_SAT","INT8"]
 ],
 "process_column_mapping": [
         ["rxecd_24_aaa_hub","_A_","HK_RXECD_24_AAA","HK_RXECD_24_AAA",null],
         ["rxecd_24_aaa_hub","_A_","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME"],
         ["rxecd_24_aaa_sat","_A_","HK_RXECD_24_AAA","HK_RXECD_24_AAA",null],
         ["rxecd_24_aaa_sat","_A_","EKI_RXECD_24_AAA_SAT","EKI_RXECD_24_AAA_SAT",null],
         ["rxecd_24_aaa_sat","_A_","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR"],
         ["rxecd_24_aaa_sat","_A_","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME"]
 ],
 "stage_table_column": [
         ["HK_RXECD_24_AAA","CHAR(28)",2,null,null,false],
         ["EKI_RXECD_24_AAA_SAT","INT8",6,null,null,false],
         ["F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",8,"F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",false],
         ["F2_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F2_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",8,"F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",true]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RXECD_24_AAA","F1_BK_AAA_ENCRYPT_ME",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_24_aaa_sat_ek","_A_","HK_RXECD_24_AAA","CHAR(28)","key","HK_RXECD_24_AAA","HK_RXECD_24_AAA","rxecd_24_aaa_sat"],
         ["rxeck_24_aaa_sat_ek","_A_","EK_RXECD_24_AAA_SAT","CHAR(28)","xenc_encryption_key","EK_RXECD_24_AAA_SAT",null,null],
         ["rxeck_24_aaa_sat_ek","_A_","EKI_RXECD_24_AAA_SAT","INT8","xenc_encryption_key_index","EKI_RXECD_24_AAA_SAT",null,null]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_A_","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME","EK_RXECD_24_AAA_SAT",1]
  ]    }');