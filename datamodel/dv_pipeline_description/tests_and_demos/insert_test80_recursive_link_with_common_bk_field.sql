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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test80_recursive_link_with_common_bk_field','{
 	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
 	"pipeline_name": "test80_recursive_link_with_common_bk_field",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
		      {"field_name": "F1_BK_AAA_COMMON", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"column_name": "BK_AAA_CM"}]}
		      ,{"field_name": "F2_BK_AAA_ORIGIN", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"column_name": "BK_AAA_SPLIT"}]}		 	  
		      ,{"field_name": "F3_BK_AAA_RECURSE1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"column_name": "BK_AAA_SPLIT"
																					,"recursion_name": "RCS1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_80_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_80_aaa"}
				,{"table_name": "rtjj_80_aaa_recu_lnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_80_aaa_recu"
																			,"link_parent_tables": ["rtjj_80_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_80_aaa_hub"
																										,"recursion_name": "RCS1"}]}
				,{"table_name": "rtjj_80_aaa_recu_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_80_aaa_recu_lnk"}

				]
		}
 ]
 }');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test80_recursive_link_with_common_bk_field');
 

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test80_recursive_link_with_common_bk_field','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_80_aaa_hub",2,"key","HK_RTJJ_80_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_hub",8,"business_key","BK_AAA_CM","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_80_aaa_hub",8,"business_key","BK_AAA_SPLIT","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_80_aaa_recu_esat",2,"parent_key","LK_RTJJ_80_AAA_RECU","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_recu_lnk",2,"key","LK_RTJJ_80_AAA_RECU","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_recu_lnk",3,"parent_key","HK_RTJJ_80_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_recu_lnk",4,"parent_key","HK_RTJJ_80_AAA_RCS1","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rtjj_80_aaa_hub","_A_","HK_RTJJ_80_AAA","HK_RTJJ_80_AAA",null],
         ["rtjj_80_aaa_hub","_A_","BK_AAA_CM","F1_BK_AAA_COMMON","F1_BK_AAA_COMMON"],
         ["rtjj_80_aaa_hub","_A_","BK_AAA_SPLIT","F2_BK_AAA_ORIGIN","F2_BK_AAA_ORIGIN"],
         ["rtjj_80_aaa_hub","_RCS1","HK_RTJJ_80_AAA","HK_RTJJ_80_AAA_RCS1",null],
         ["rtjj_80_aaa_hub","_RCS1","BK_AAA_CM","F1_BK_AAA_COMMON","F1_BK_AAA_COMMON"],
         ["rtjj_80_aaa_hub","_RCS1","BK_AAA_SPLIT","F3_BK_AAA_RECURSE1","F3_BK_AAA_RECURSE1"],
         ["rtjj_80_aaa_recu_esat","_A_","LK_RTJJ_80_AAA_RECU","LK_RTJJ_80_AAA_RECU",null],
         ["rtjj_80_aaa_recu_lnk","_A_","LK_RTJJ_80_AAA_RECU","LK_RTJJ_80_AAA_RECU",null],
         ["rtjj_80_aaa_recu_lnk","_A_","HK_RTJJ_80_AAA","HK_RTJJ_80_AAA",null],
         ["rtjj_80_aaa_recu_lnk","_A_","HK_RTJJ_80_AAA_RCS1","HK_RTJJ_80_AAA_RCS1",null]
 ],
 "stage_table_column": [
         ["F1_BK_AAA_COMMON","VARCHAR(20)",8,"F1_BK_AAA_COMMON","VARCHAR(20)",false],
         ["F2_BK_AAA_ORIGIN","VARCHAR(20)",8,"F2_BK_AAA_ORIGIN","VARCHAR(20)",false],
         ["F3_BK_AAA_RECURSE1","VARCHAR(20)",8,"F3_BK_AAA_RECURSE1","VARCHAR(20)",false],
         ["HK_RTJJ_80_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_80_AAA_RCS1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_80_AAA_RECU","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_80_AAA","F1_BK_AAA_COMMON",0,0],
         ["_A_","HK_RTJJ_80_AAA","F2_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_80_AAA_RECU","F1_BK_AAA_COMMON",0,0],
         ["_A_","LK_RTJJ_80_AAA_RECU","F2_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_80_AAA_RECU","F3_BK_AAA_RECURSE1",0,0],
         ["_RCS1","HK_RTJJ_80_AAA_RCS1","F1_BK_AAA_COMMON",0,0],
         ["_RCS1","HK_RTJJ_80_AAA_RCS1","F3_BK_AAA_RECURSE1",0,0]
  ]    }');