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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test09_check_no_common_relation_names_on_linked_hubs';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test09_check_no_common_relation_names_on_linked_hubs','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test09_check_no_common_relation_names_on_linked_hubs",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["RELAAA"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["RELBBB"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB_L3", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_bbb_hub"
																					,"column_name": "BK_BBB"
																				 	,"relation_names":["RELCCC"]}]}		 
		      ,{"field_name": "F4_BK_BBB_L4", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_bbb_hub"
																					,"column_name": "BK_BBB"
																				 	,"relation_names":["RELDDD"]}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_09_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_09_aaa"}
				,{"table_name": "rtjj_09_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_09_aaa_bbb",
																				"link_parent_tables": ["rtjj_09_aaa_hub","rtjj_09_bbb_hub"]}
				,{"table_name": "rtjj_09_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_09_aaa_bbb_lnk"}
				,{"table_name": "rtjj_09_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_09_bbb"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test09_check_no_common_relation_names_on_linked_hubs');

