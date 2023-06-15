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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test81_recursive_link_with_normal_satellite';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test81_recursive_link_with_normal_satellite','{
 	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
 	"pipeline_name": "test81_recursive_link_with_normal_satellite",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
			   {"field_name": "F1_BK_AAA_ORIGIN", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_81_aaa_hub"
																					,"column_name": "BK_AAA"}]}		 	  
		      ,{"field_name": "F2_BK_AAA_RECURSE1", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_81_aaa_hub"
																					,"column_name": "BK_AAA"
																					,"recursion_name": "RCS1"}]}
			  ,{"field_name": "F3_AAA_RECU_CONTENT", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_81_aaa_RECU_sat"}]}		  
			  ,{"field_name": "F4_AAA_RECU_CONTENT2", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_81_aaa_RECU_sat"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_81_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_81_aaa"}
				,{"table_name": "rtjj_81_aaa_RECU_lnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_81_aaa_RECU"
																			,"link_parent_tables": ["rtjj_81_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_81_aaa_hub"
																										,"recursion_name": "RCS1"}]}
				,{"table_name": "rtjj_81_aaa_RECU_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_81_aaa_RECU_lnk","diff_hash_column_name":"rh_rtjj_81_aaa_RECU_sat"}
				]
		}
 ]
 }');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test81_recursive_link_with_normal_satellite');
 

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test81_recursive_link_with_normal_satellite';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test81_recursive_link_with_normal_satellite','{
  "dv_model_column": [
         ["rvlt_test_jj","rtjj_81_aaa_hub",2,"key","HK_RTJJ_81_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_lnk",2,"key","LK_RTJJ_81_AAA_RECU","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_lnk",3,"parent_key","HK_RTJJ_81_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_lnk",4,"parent_key","HK_RTJJ_81_AAA_RCS1","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_sat",2,"parent_key","LK_RTJJ_81_AAA_RECU","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_sat",3,"diff_hash","RH_RTJJ_81_AAA_RECU_SAT","CHAR(28)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_sat",8,"content","F3_AAA_RECU_CONTENT","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_81_aaa_recu_sat",8,"content","F4_AAA_RECU_CONTENT2","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_81_aaa_hub","_A_","HK_RTJJ_81_AAA","HK_RTJJ_81_AAA",null],
         ["rtjj_81_aaa_hub","_A_","BK_AAA","F1_BK_AAA_ORIGIN","F1_BK_AAA_ORIGIN"],
         ["rtjj_81_aaa_hub","_RCS1","HK_RTJJ_81_AAA","HK_RTJJ_81_AAA_RCS1",null],
         ["rtjj_81_aaa_hub","_RCS1","BK_AAA","F2_BK_AAA_RECURSE1","F2_BK_AAA_RECURSE1"],
         ["rtjj_81_aaa_recu_lnk","_A_","LK_RTJJ_81_AAA_RECU","LK_RTJJ_81_AAA_RECU",null],
         ["rtjj_81_aaa_recu_lnk","_A_","HK_RTJJ_81_AAA","HK_RTJJ_81_AAA",null],
         ["rtjj_81_aaa_recu_lnk","_A_","HK_RTJJ_81_AAA_RCS1","HK_RTJJ_81_AAA_RCS1",null],
         ["rtjj_81_aaa_recu_sat","_A_","LK_RTJJ_81_AAA_RECU","LK_RTJJ_81_AAA_RECU",null],
         ["rtjj_81_aaa_recu_sat","_A_","RH_RTJJ_81_AAA_RECU_SAT","RH_RTJJ_81_AAA_RECU_SAT",null],
         ["rtjj_81_aaa_recu_sat","_A_","F3_AAA_RECU_CONTENT","F3_AAA_RECU_CONTENT","F3_AAA_RECU_CONTENT"],
         ["rtjj_81_aaa_recu_sat","_A_","F4_AAA_RECU_CONTENT2","F4_AAA_RECU_CONTENT2","F4_AAA_RECU_CONTENT2"]
 ],
 "stage_table_column": [
         ["F1_BK_AAA_ORIGIN","VARCHAR(20)",8,"F1_BK_AAA_ORIGIN","VARCHAR(20)",false],
         ["F2_BK_AAA_RECURSE1","VARCHAR(20)",8,"F2_BK_AAA_RECURSE1","VARCHAR(20)",false],
         ["F3_AAA_RECU_CONTENT","VARCHAR(20)",8,"F3_AAA_RECU_CONTENT","VARCHAR(20)",false],
         ["F4_AAA_RECU_CONTENT2","VARCHAR(20)",8,"F4_AAA_RECU_CONTENT2","VARCHAR(20)",false],
         ["HK_RTJJ_81_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_81_AAA_RCS1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_81_AAA_RECU","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_81_AAA_RECU_SAT","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_81_AAA","F1_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_81_AAA_RECU","F1_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_81_AAA_RECU","F2_BK_AAA_RECURSE1",0,0],
         ["_A_","RH_RTJJ_81_AAA_RECU_SAT","F3_AAA_RECU_CONTENT",0,0],
         ["_A_","RH_RTJJ_81_AAA_RECU_SAT","F4_AAA_RECU_CONTENT2",0,0],
         ["_RCS1","HK_RTJJ_81_AAA_RCS1","F2_BK_AAA_RECURSE1",0,0]
  ]    }');