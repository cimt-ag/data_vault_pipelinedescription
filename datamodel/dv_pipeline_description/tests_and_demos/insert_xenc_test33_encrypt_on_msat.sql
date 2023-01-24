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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test33_encrypt_on_msat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test33_encrypt_on_msat','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test33_encrypt_on_msat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA", 	"field_type": "Varchar(20)"
														,"targets": [{"table_name": "rxecd_33_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_33_aaa_msat"}]}
		 	  ,{"field_name": "F3_AAA_SP1_ENCRYPT_ME",	"field_type": "VARCHAR(200)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_33_aaa_msat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_33_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_33_aaa"}
				,{"table_name": "rxecd_33_aaa_msat",		"stereotype": "msat","satellite_parent_table": "rxecd_33_aaa_hub","diff_hash_column_name": "GH_rxecd_33_aaa_msat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_33_aaa_msat_ek",	"stereotype": "xenc_msat-ek", "xenc_content_table_name":"rxecd_33_aaa_msat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test33_encrypt_on_msat');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test33_encrypt_on_msat');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test33_encrypt_on_msat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test33_encrypt_on_msat','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_33_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_33_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_33_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_33_aaa_hub",2,"key","HK_RXECD_33_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_33_aaa_hub",8,"business_key","F1_BK_AAA","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",2,"parent_key","HK_RXECD_33_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",3,"diff_hash","GH_RXECD_33_AAA_MSAT","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",6,"xenc_encryption_key_index","EKI_RXECD_33_AAA_MSAT","INT8"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",8,"content","F2_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_33_aaa_msat",8,"content","F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",2,"key","HK_RXECD_33_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",3,"diff_hash","GH_RXECD_33_AAA_MSAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",5,"xenc_encryption_key","EK_RXECD_33_AAA_MSAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_33_aaa_msat_ek",6,"xenc_encryption_key_index","EKI_RXECD_33_AAA_MSAT","INT8"]
 ],
 "process_column_mapping": [
         ["rxecd_33_aaa_hub","_A_","HK_RXECD_33_AAA","HK_RXECD_33_AAA",null],
         ["rxecd_33_aaa_hub","_A_","F1_BK_AAA","F1_BK_AAA","F1_BK_AAA"],
         ["rxecd_33_aaa_msat","_A_","HK_RXECD_33_AAA","HK_RXECD_33_AAA",null],
         ["rxecd_33_aaa_msat","_A_","GH_RXECD_33_AAA_MSAT","GH_RXECD_33_AAA_MSAT",null],
         ["rxecd_33_aaa_msat","_A_","EKI_RXECD_33_AAA_MSAT","EKI_RXECD_33_AAA_MSAT",null],
         ["rxecd_33_aaa_msat","_A_","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR"],
         ["rxecd_33_aaa_msat","_A_","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME"]
 ],
 "stage_table_column": [
         ["HK_RXECD_33_AAA","CHAR(28)",2,null,null,false],
         ["GH_RXECD_33_AAA_MSAT","CHAR(28)",3,null,null,false],
         ["EKI_RXECD_33_AAA_MSAT","INT8",6,null,null,false],
         ["F1_BK_AAA","VARCHAR(20)",8,"F1_BK_AAA","VARCHAR(20)",false],
         ["F2_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F2_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",8,"F3_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",true]
 ],
 "stage_hash_input_field": [
         ["_A_","GH_RXECD_33_AAA_MSAT","F2_AAA_SP1_VARCHAR",0,0],
         ["_A_","GH_RXECD_33_AAA_MSAT","F3_AAA_SP1_ENCRYPT_ME",0,0],
         ["_A_","HK_RXECD_33_AAA","F1_BK_AAA",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_33_aaa_msat_ek","_A_","HK_RXECD_33_AAA","CHAR(28)","key","HK_RXECD_33_AAA","HK_RXECD_33_AAA","rxecd_33_aaa_msat"],
         ["rxeck_33_aaa_msat_ek","_A_","GH_RXECD_33_AAA_MSAT","CHAR(28)","diff_hash","GH_RXECD_33_AAA_MSAT","GH_RXECD_33_AAA_MSAT","rxecd_33_aaa_msat"],
         ["rxeck_33_aaa_msat_ek","_A_","EK_RXECD_33_AAA_MSAT","CHAR(28)","xenc_encryption_key","EK_RXECD_33_AAA_MSAT",null,null],
         ["rxeck_33_aaa_msat_ek","_A_","EKI_RXECD_33_AAA_MSAT","INT8","xenc_encryption_key_index","EKI_RXECD_33_AAA_MSAT",null,null]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_A_","F3_AAA_SP1_ENCRYPT_ME","F3_AAA_SP1_ENCRYPT_ME","EK_RXECD_33_AAA_MSAT",1]
  ]    }');
