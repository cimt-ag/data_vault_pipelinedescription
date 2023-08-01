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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test_622_rc_topo_sat_subset';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test_622_rc_topo_sat_subset','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test_622_rc_topo_sat_subset",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F03_ID_BBB1", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB1"} ]}
		      ,{"field_name": "F04_ID_BBB1_R2", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB1" ,"relation_names":["R222"]} ]}		 	  
		      ,{"field_name": "F05_ID_BBB1_R3","field_type": "Varchar(20)",  "targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB1","relation_names":["R333"]} ]}		 	  

		      ,{"field_name": "F06_ID_BBB2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB2"} ]}
		      ,{"field_name": "F07_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB2","relation_names":["R222"]} ]}	 
		      ,{"field_name": "F08_ID_BBB2_R3", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_622_bbb_hub" ,"column_name": "ID_BBB2","relation_names":["R333"]} ]}
	 
		      ,{"field_name": "F09_S_BBB1_R12",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_622_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["/","R222"]} ]}
		      ,{"field_name": "F10_S_BBB1_R3",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_622_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R333"]} ]}
		      ,{"field_name": "F11_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_622_bbb_sat" ,"column_name": "S_BBB2"} ]}
		      ,{"field_name": "F12_S_BBB2_R23",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_622_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222","R333"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables":  [
				{"table_name": "rtjj_622_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_622_bbb"}
				,{"table_name": "rtjj_622_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_622_bbb_hub"
																			,"diff_hash_column_name": "RH_rtjj_622_bbb_sat"}
				,{"table_name": "rtjj_622_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_622_aaa_bbb",
												"link_parent_tables": [	{"table_name":"rtjj_622_bbb_hub"}
																	   ,{"table_name":"rtjj_622_bbb_hub","relation_name":"R222"}
																	   ,{"table_name":"rtjj_622_bbb_hub","relation_name":"R333"
																			,"hub_key_column_name_in_link":"HK_rtjj_622_bbb_R333EXTRA"}  ]}
				,{"table_name": "rtjj_622_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_622_aaa_bbb_lnk"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test_622_r_topo_sat_subset');

