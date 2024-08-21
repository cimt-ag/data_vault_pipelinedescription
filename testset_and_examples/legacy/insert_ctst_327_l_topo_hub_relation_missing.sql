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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'ctst_327_l_topo_hub_relation_missing';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('ctst_327_l_topo_hub_relation_missing','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "ctst_327_l_topo_hub_relation_missing",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtcc_327_aaa_hub"}]}
		      ,{"field_name": "F02_S_AAA1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtcc_327_aaa_sat"}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R12", "field_type": "Varchar(20)","targets": [{"table_name": "rtcc_327_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111","R222"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtcc_327_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F05_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtcc_327_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
	 
		      ,{"field_name": "F06_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtcc_327_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F07_S_BBB1_R23",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtcc_327_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222","R333"]} ]}
		      ,{"field_name": "F08_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtcc_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F09_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtcc_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F10_S_BBB2_R3",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtcc_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R333"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_cc", 
		 "tables":  [
				{"table_name": "rtcc_327_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtcc_327_aaa"}
				,{"table_name": "rtcc_327_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtcc_327_aaa_hub"
																				,"diff_hash_column_name": "RH_rtcc_327_aaa_sat"}
				,{"table_name": "rtcc_327_aaa_bbb_r111_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtcc_327_aaa_bbb_r111",
												"link_parent_tables": [	"rtcc_327_aaa_hub","rtcc_327_bbb_hub"]}
				,{"table_name": "rtcc_327_aaa_bbb_r111_esat",	"table_stereotype": "sat","satellite_parent_table": "rtcc_327_aaa_bbb_r111_lnk"
																						,"tracked_relation_name":"R111"}
				,{"table_name": "rtcc_327_aaa_bbb_r222_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtcc_327_aaa_bbb_r222",
												"link_parent_tables": [	"rtcc_327_aaa_hub","rtcc_327_bbb_hub"]}
				,{"table_name": "rtcc_327_aaa_bbb_r222_esat",	"table_stereotype": "sat","satellite_parent_table": "rtcc_327_aaa_bbb_r222_lnk"
																						,"tracked_relation_name":"R222"}
				,{"table_name": "rtcc_327_aaa_bbb_r333_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtcc_327_aaa_bbb_r333",
												"link_parent_tables": [	"rtcc_327_aaa_hub","rtcc_327_bbb_hub"]}
				,{"table_name": "rtcc_327_aaa_bbb_r333_esat",	"table_stereotype": "sat","satellite_parent_table": "rtcc_327_aaa_bbb_r333_lnk"
																						,"tracked_relation_name":"R333"}
				,{"table_name": "rtcc_327_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtcc_327_bbb"}
				,{"table_name": "rtcc_327_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtcc_327_bbb_hub"
																			,"diff_hash_column_name": "RH_rtcc_327_bbb_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('ctst_327_l_topo_hub_relation_missing');

