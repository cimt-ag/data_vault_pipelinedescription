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

DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test42_ref_simple_with_history_no_diff_hash';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test42_ref_simple_with_history_no_diff_hash','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test42_ref_simple_with_history_no_diff_hash",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_42_aaa_ref"}]},
		 	  {"field_name": "F2_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_42_aaa_ref"}]},
		 	  {"field_name": "F3_CCC_FIELDNAME_DATE",		"field_type": "DATE",			"targets": [{"table_name": "rtjj_42_aaa_ref"
																											,"column_name":"F3_CCC_DATE"}]},
			  {"field_name": "F4_DDD_NOT_IN_RH__DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_42_aaa_ref","exclude_from_change_detection": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_42_aaa_ref",		"table_stereotype": "ref","uses_diff_hash":false}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test42_ref_simple_with_history_no_diff_hash');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test42_ref_simple_with_history_no_diff_hash';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test42_ref_simple_with_history_no_diff_hash','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_42_aaa_ref",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",8,"content","F1_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",8,"content","F2_BBB_DECIMAL","DECIMAL(20,0)"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",8,"content","F3_CCC_DATE","DATE"],
      ["rvlt_test_jj","rtjj_42_aaa_ref",8,"content_untracked","F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)"]
 ],
 "process_column_mapping": [
         ["rtjj_42_aaa_ref","/","F1_AAA_VARCHAR","F1_AAA_VARCHAR","F1_AAA_VARCHAR"],
         ["rtjj_42_aaa_ref","/","F2_BBB_DECIMAL","F2_BBB_DECIMAL","F2_BBB_DECIMAL"],
         ["rtjj_42_aaa_ref","/","F3_CCC_DATE","F3_CCC_FIELDNAME_DATE","F3_CCC_FIELDNAME_DATE"],
         ["rtjj_42_aaa_ref","/","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL"]
 ],
 "stage_table_column": [
         ["F1_AAA_VARCHAR","VARCHAR(20)",8,"F1_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BBB_DECIMAL","DECIMAL(20,0)",false],
         ["F3_CCC_FIELDNAME_DATE","DATE",8,"F3_CCC_FIELDNAME_DATE","DATE",false],
         ["F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",8,"F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",false]
 ],
 "stage_hash_input_field": [
 ],
 "xenc_process_column_mapping": [
 ],
 "xenc_process_field_to_encryption_key_mapping": [
  ]    }');