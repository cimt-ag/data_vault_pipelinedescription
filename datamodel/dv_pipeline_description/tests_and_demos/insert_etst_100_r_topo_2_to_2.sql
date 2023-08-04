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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'etst_100_r_topo_2_to_2';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('etst_100_r_topo_2_to_2','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "etst_100_r_topo_2_to_2",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1_Q1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_hub","column_name": "ID_AAA1"
																				 	,"relation_names":["Q111"]} ]}
		      ,{"field_name": "F01_ID_AAA1_Q2",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_hub","column_name": "ID_AAA1"
																				 	,"relation_names":["Q222"]} ]}
		      ,{"field_name": "F02_S_AAA1_Q2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_sat","column_name": "S_AAA1"
																					,"relation_names":["Q222"]}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R1", "field_type": "Varchar(20)","targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB1_R2", "field_type": "Varchar(20)","targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R222"]} ]}		 	  
		      ,{"field_name": "F06_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F07_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
	 
		      ,{"field_name": "F09_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F10_S_BBB1_R2",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F12_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F13_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_ee", 
		 "tables":  [
				{"table_name": "rtee_220_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtee_220_aaa"}
				,{"table_name": "rtee_220_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_aaa_hub"
																				,"diff_hash_column_name": "RH_rtee_220_aaa_sat"}
				,{"table_name": "rtee_220_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtee_220_aaa_bbb",
												"link_parent_tables": [	{"table_name":"rtee_220_aaa_hub","relation_name":"Q111"}
																	   ,{"table_name":"rtee_220_aaa_hub","relation_name":"Q222"}
																	   ,{"table_name":"rtee_220_bbb_hub","relation_name":"R111"}
																	   ,{"table_name":"rtee_220_bbb_hub","relation_name":"R222"}
																	     ]}
				,{"table_name": "rtee_220_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_aaa_bbb_lnk"}
				,{"table_name": "rtee_220_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtee_220_bbb"}
				,{"table_name": "rtee_220_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_bbb_hub"
																			,"diff_hash_column_name": "RH_rtee_220_bbb_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('etst_100_r_topo_2_to_2');

