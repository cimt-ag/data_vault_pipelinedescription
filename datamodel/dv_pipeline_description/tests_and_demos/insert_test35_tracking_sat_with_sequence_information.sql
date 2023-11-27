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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test35_tracking_sat_with_sequence_information';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test35_tracking_sat_with_sequence_information','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test35_tracking_sat_with_sequence_information",
	"record_source_name_expression": "dvpd implementation test",
	"stage_properties" : [{"storage_component":"PostgresDWH","stage_schema":"stage_rvlt"}],
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_35_aaa_hub"}]},
		 	  {"field_name": "F2_TIMESTAMP",	"field_type": "timestamp",	"targets": [{"table_name": "rtjj_35_aaa_p1_trsat","column_name":"TIME_SEQUENCE"}]},
		 	  {"field_name": "F3_OPERATION",	"field_type": "CHAR(1)",	"targets": [{"table_name": "rtjj_35_aaa_p1_trsat","column_name":"OPERATION"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_35_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_35_aaa"}
				,{"table_name": "rtjj_35_aaa_p1_trsat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_35_aaa_HUB"
															,"uses_diff_hash": "false","has_deletion_flag":"false"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test35_tracking_sat_with_sequence_information');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name like 'test35%';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test35_tracking_sat_with_sequence_information','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_35_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_35_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_35_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_35_aaa_hub",2,"key","HK_RTJJ_35_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_35_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",2,"parent_key","HK_RTJJ_35_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",8,"content","OPERATION","CHAR(1)"],
      ["rvlt_test_jj","rtjj_35_aaa_p1_trsat",8,"content","TIME_SEQUENCE","TIMESTAMP"]
 ],
 "process_column_mapping": [
         ["rtjj_35_aaa_hub","_A_","HK_RTJJ_35_AAA","HK_RTJJ_35_AAA",null],
         ["rtjj_35_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_35_aaa_p1_trsat","_A_","HK_RTJJ_35_AAA","HK_RTJJ_35_AAA",null],
         ["rtjj_35_aaa_p1_trsat","_A_","OPERATION","F3_OPERATION","F3_OPERATION"],
         ["rtjj_35_aaa_p1_trsat","_A_","TIME_SEQUENCE","F2_TIMESTAMP","F2_TIMESTAMP"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_35_AAA","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_TIMESTAMP","TIMESTAMP",8,"F2_TIMESTAMP","TIMESTAMP",false],
         ["F3_OPERATION","CHAR(1)",8,"F3_OPERATION","CHAR(1)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_35_AAA","F1_BK_AAA_VARCHAR",0,0]
  ]    }');