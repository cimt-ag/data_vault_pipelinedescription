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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test70_fg_drive_scenario_10';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test70_fg_drive_scenario_10','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test70_fg_drive_scenario_10",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_H1_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["HRCHY1"]
																					}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_70_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_70_aaa"}
				,{"table_name": "rtjj_70_aaa_hierarchy_hlnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_70_aaa_hierarchy"
																			,"link_parent_tables": [{"table_name":"rtjj_70_aaa_hub","relation_name": "/"},
																									{"table_name":"rtjj_70_aaa_hub","relation_name": "HRCHY1"}]}
				,{"table_name": "rtjj_70_aaa_hierarchy_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_70_aaa_hierarchy_hlnk"}

				]
		}
 ]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test70_fg_drive_scenario_10');


DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test70_fg_drive_scenario_10';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test70_fg_drive_scenario_10','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_70_aaa_hierarchy_esat",2,"parent_key","LK_RTJJ_70_AAA_HIERARCHY","CHAR(28)"],
         ["rvlt_test_jj","rtjj_70_aaa_hierarchy_hlnk",2,"key","LK_RTJJ_70_AAA_HIERARCHY","CHAR(28)"],
         ["rvlt_test_jj","rtjj_70_aaa_hierarchy_hlnk",3,"parent_key","HK_RTJJ_70_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_70_aaa_hierarchy_hlnk",4,"parent_key","HK_RTJJ_70_AAA_HRCHY1","CHAR(28)"],
         ["rvlt_test_jj","rtjj_70_aaa_hub",2,"key","HK_RTJJ_70_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_70_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_70_aaa_hierarchy_esat","/","LK_RTJJ_70_AAA_HIERARCHY","LK_RTJJ_70_AAA_HIERARCHY",null],
         ["rtjj_70_aaa_hierarchy_hlnk","/","LK_RTJJ_70_AAA_HIERARCHY","LK_RTJJ_70_AAA_HIERARCHY",null],
         ["rtjj_70_aaa_hierarchy_hlnk","/","HK_RTJJ_70_AAA","HK_RTJJ_70_AAA",null],
         ["rtjj_70_aaa_hierarchy_hlnk","/","HK_RTJJ_70_AAA_HRCHY1","HK_RTJJ_70_AAA_HRCHY1",null],
         ["rtjj_70_aaa_hub","/","HK_RTJJ_70_AAA","HK_RTJJ_70_AAA",null],
         ["rtjj_70_aaa_hub","/","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rtjj_70_aaa_hub","R222","HK_RTJJ_70_AAA","HK_RTJJ_70_AAA_R222",null],
         ["rtjj_70_aaa_hub","R222","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rtjj_70_aaa_hub","HRCHY1","HK_RTJJ_70_AAA","HK_RTJJ_70_AAA_HRCHY1",null],
         ["rtjj_70_aaa_hub","HRCHY1","BK_AAA","F3_BK_AAA_H1_L1","F3_BK_AAA_H1_L1"]
 ], 
"stage_table_column": [
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_BK_AAA_H1_L1","VARCHAR(20)",8,"F3_BK_AAA_H1_L1","VARCHAR(20)",false],
         ["HK_RTJJ_70_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_70_AAA_R222","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_70_AAA_HRCHY1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_70_AAA_HIERARCHY","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["/","HK_RTJJ_70_AAA","F1_BK_AAA_L1",0,0],
         ["/","LK_RTJJ_70_AAA_HIERARCHY","F1_BK_AAA_L1",0,0],
         ["/","LK_RTJJ_70_AAA_HIERARCHY","F3_BK_AAA_H1_L1",0,0],
         ["R222","HK_RTJJ_70_AAA_R222","F2_BK_AAA_L2",0,0],
         ["HRCHY1","HK_RTJJ_70_AAA_HRCHY1","F3_BK_AAA_H1_L1",0,0]
  ]    }');