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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test_185_n_topo_hub_subset_sat_incomplete';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test_185_n_topo_hub_subset_sat_incomplete','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test_185_n_topo_hub_subset_sat_incomplete",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_185_aaa_hub"}]}
		      ,{"field_name": "F02_S_AAA1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_185_aaa_sat"}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R1", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_185_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB1_R23","field_type": "Varchar(20)",  "targets": [{"table_name": "rtjj_185_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R222","R333"]} ]}		 	  
		      ,{"field_name": "F05_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_185_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F06_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_185_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
		      ,{"field_name": "F07_ID_BBB2_R3", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_185_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R333"]} ]}
	 
		      ,{"field_name": "F08_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_185_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F09_S_BBB1_R2",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_185_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F10_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_185_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F11_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_185_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables":  [
				{"table_name": "rtjj_185_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_185_aaa"}
				,{"table_name": "rtjj_185_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_185_aaa_hub"
																				,"diff_hash_column_name": "RH_rtjj_185_aaa_sat"}
				,{"table_name": "rtjj_185_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_185_aaa_bbb",
												"link_parent_tables": [	"rtjj_185_aaa_hub","rtjj_185_bbb_hub"]}
				,{"table_name": "rtjj_185_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_185_aaa_bbb_lnk"}
				,{"table_name": "rtjj_185_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_185_bbb"}
				,{"table_name": "rtjj_185_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_185_bbb_hub"
																			,"diff_hash_column_name": "RH_rtjj_185_bbb_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test_185_n_topo_hub_subset_sat_incomplete');

