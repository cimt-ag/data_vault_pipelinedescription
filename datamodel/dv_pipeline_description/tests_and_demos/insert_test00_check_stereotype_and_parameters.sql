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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test00_check_stereotype_and_parameters';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test00_check_stereotype_and_parameters','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test00_check_stereotype_and_parameters",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      	{"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_AAA_XXX_BAD_STEREOTYPE"}]}
		 	  ,	{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_00_BBB_XXX_HUB_WITHOUT_HUB_KEY_COLUMN"}]}
			  ,	{"field_name": "F3_CCC_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_00_CCC_XXX_SAT_WITHOUT_PARENT_DECLARATION"}]}
		      , {"field_name": "F4_BK_FFF_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_FFF_HUB"}]}
		      , {"field_name": "F5_BK_GGG_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_GGG_HUB"}]}
		      , {"field_name": "F6_DC_FFF_GGG_XXX_DLINK_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN"}]}
		      , {"field_name": "F7_XXX_FIELD_WITHOUT_TYPE", "targets": [{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN"}]}
		      , {"field_name": "F8_XXX_FIELD_WITH_EMPTY_TYPE", 		"field_type": " ", "targets": [{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_00_AAA_XXX_BAD_STEREOTYPE",		"table_stereotype": "xx","hub_key_column_name": "HK_rtjj_00_AAA_XXX_BAD_STEREOTYPE"}
			,	{"table_name": "rtjj_00_BBB_XXX_HUB_WITHOUT_HUB_KEY_COLUMN",		"table_stereotype": "hub"}
			,	{"table_name": "rtjj_00_CCC_XXX_SAT_WITHOUT_PARENT_DECLARATION",	"table_stereotype": "sat","diff_hash_column_name": "rtjj_00_XX_SAT_WITHOUT_PARENT"}
			,	{"table_name": "rtjj_00_DDD_EEE_XXX_LNK_WITHOUT_PARENT_DECLARATION", "table_stereotype": "lnk","link_key_column_name": "LK_rtjj_00_DDD_EEE_XXX_LINK_WITHOUT_PARENT_DECLARATION"}
			,	{"table_name": "rtjj_00_FFF_HUB",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_00_FFF_HUB"}
			,	{"table_name": "rtjj_00_GGG_HUB",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_00_GGG_HUB"}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_LNK_WITHOUT_LINK_KEY_COLUMN", "table_stereotype": "lnk","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN", "table_stereotype": "lnk","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_LNK", "table_stereotype": "lnk","link_key_column_name": "LK_rtjj_00_FFF_GGG","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_ESAT_WITHOUT_PARENT", "table_stereotype": "esat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test00_check_stereotype_and_parameters');