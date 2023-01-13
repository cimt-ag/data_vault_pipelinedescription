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

/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test62_fg_drive_scenario_2';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test62_fg_drive_scenario_2','{
	"dvpd_version": "1.0",
	"pipeline_name": "test62_fg_drive_scenario_2",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_p1_sat"}]}		 
		      ,{"field_name": "F4_AAA_S1_COLB","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_p1_sat"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_62_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_62_aaa"}
				,{"table_name": "rtjj_62_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_62_aaa_hub"
																			,"diff_hash_column_name": "RH_rtjj_62_aaa_p1_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test62_fg_drive_scenario_2');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test62_fg_drive_scenario_2';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test62_fg_drive_scenario_2','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_62_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_62_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_62_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_62_aaa_hub",2,"key","HK_RTJJ_62_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_62_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",2,"parent_key","HK_RTJJ_62_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",3,"diff_hash","RH_RTJJ_62_AAA_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",8,"content","F3_AAA_S1_COLA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_62_aaa_p1_sat",8,"content","F4_AAA_S1_COLB","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_62_aaa_hub","_FG1","HK_RTJJ_62_AAA","HK_RTJJ_62_AAA_FG1",null],
         ["rtjj_62_aaa_hub","_FG1","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rtjj_62_aaa_hub","_FG2","HK_RTJJ_62_AAA","HK_RTJJ_62_AAA_FG2",null],
         ["rtjj_62_aaa_hub","_FG2","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rtjj_62_aaa_p1_sat","_FG1","HK_RTJJ_62_AAA","HK_RTJJ_62_AAA_FG1",null],
         ["rtjj_62_aaa_p1_sat","_FG1","RH_RTJJ_62_AAA_P1_SAT","RH_RTJJ_62_AAA_P1_SAT_FG1",null],
         ["rtjj_62_aaa_p1_sat","_FG1","F3_AAA_S1_COLA","F3_AAA_S1_COLA","F3_AAA_S1_COLA"],
         ["rtjj_62_aaa_p1_sat","_FG1","F4_AAA_S1_COLB","F4_AAA_S1_COLB","F4_AAA_S1_COLB"],
         ["rtjj_62_aaa_p1_sat","_FG2","HK_RTJJ_62_AAA","HK_RTJJ_62_AAA_FG2",null],
         ["rtjj_62_aaa_p1_sat","_FG2","RH_RTJJ_62_AAA_P1_SAT","RH_RTJJ_62_AAA_P1_SAT_FG2",null],
         ["rtjj_62_aaa_p1_sat","_FG2","F3_AAA_S1_COLA","F3_AAA_S1_COLA","F3_AAA_S1_COLA"],
         ["rtjj_62_aaa_p1_sat","_FG2","F4_AAA_S1_COLB","F4_AAA_S1_COLB","F4_AAA_S1_COLB"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_62_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_62_AAA_FG2","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_62_AAA_P1_SAT_FG1","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_62_AAA_P1_SAT_FG2","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_AAA_S1_COLA","VARCHAR(20)",8,"F3_AAA_S1_COLA","VARCHAR(20)",false],
         ["F4_AAA_S1_COLB","VARCHAR(20)",8,"F4_AAA_S1_COLB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_FG1","HK_RTJJ_62_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","RH_RTJJ_62_AAA_P1_SAT_FG1","F3_AAA_S1_COLA",0,0],
         ["_FG1","RH_RTJJ_62_AAA_P1_SAT_FG1","F4_AAA_S1_COLB",0,0],
         ["_FG2","HK_RTJJ_62_AAA_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","RH_RTJJ_62_AAA_P1_SAT_FG2","F3_AAA_S1_COLA",0,0],
         ["_FG2","RH_RTJJ_62_AAA_P1_SAT_FG2","F4_AAA_S1_COLB",0,0]
  ]    }');