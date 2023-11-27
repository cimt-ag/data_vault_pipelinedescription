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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test05_one_link_one_esat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test05_one_link_one_esat','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test05_one_link_one_esat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_05_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_05_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat"}]}
			  ,{"field_name": "F5__FIELD_NAME",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat",
																									 "column_name":"F5_AAA_SP1_VARCHAR"}]}
		 	  ,{"field_name": "F6_BK_CCC_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_05_ccc_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_05_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_05_aaa"}
				,{"table_name": "rtjj_05_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_05_aaa_HUB","diff_hash_column_name": "RH_rtjj_05_aaa_P1_SAT"}
				,{"table_name": "rtjj_05_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_05_bbb"}
				,{"table_name": "rtjj_05_ccc_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_05_bbb"}
				,{"table_name": "rtjj_05_aaa_bbb_XXX_with_same_lk_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_05_XXX_same_LK",
																				"link_parent_tables": ["rvlt_test_jj","rtjj_05_aaa_hub","rtjj_05_bbb_hub"]}
				,{"table_name": "rtjj_05_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_05_aaa_bbb_XXX_with_same_lk_lnk"}
				,{"table_name": "rtjj_05_aaa_ccc_XXX_with_same_lk_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_05_XXX_same_LK",
																				"link_parent_tables": ["rvlt_test_jj","rtjj_05_aaa_hub","rtjj_05_ccc_hub"]}
				,{"table_name": "rtjj_05_aaa_ccc_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_05_aaa_ccc_XXX_with_same_lk_lnk"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test05_one_link_one_esat');
                                                                   

