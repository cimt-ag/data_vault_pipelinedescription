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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test01_check_model_relations';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test01_check_model_relations','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test01_check_model_relations",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      	{"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_01_AAA_HUB"}]}
		 	  ,	{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_01_BBB_HUB"}]}
			  ,	{"field_name": "F3_CCC_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT"}]}
		      , {"field_name": "F4_DC_FFF_GGG_XXX_DLINK_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_01_AAA_HUB",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_01_AAA_HUB"}
			,	{"table_name": "rtjj_01_BBB_HUB",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_01_BBB_HUB"}
			,	{"table_name": "rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT",	"table_stereotype": "sat","satellite_parent_table":"rtjj_01_CCC_XXX_UNKNOWN_HUB","diff_hash_column_name": "rh_rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT"}
			,	{"table_name": "rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_PARENT", "table_stereotype": "lnk",	"link_key_column_name": "LK_rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_PARENT",
																									"link_parent_tables":["rtjj_01_AAA_HUB","rtjj_01_CCC_XXX_UNKNOWN_HUB"]}
			,	{"table_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT", "table_stereotype": "lnk","link_key_column_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT",
																									"link_parent_tables":["rtjj_01_AAA_HUB","rtjj_01_CCC_XXX_UNKNOWN_HUB"]}
			,	{"table_name": "rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_RECURSIVE_PARENT", "table_stereotype": "lnk","link_key_column_name": "rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_RECURSIVE_PARENT",
																									"link_parent_tables":["rtjj_01_AAA_HUB"]
																								,"recursive_parents": [ {"table_name":"rtjj_XXX_UNKNOWN_HUB"
																										,"recursion_name": "PARENT"}]}
			,	{"table_name": "rtjj_01_BBB_CCC_XXX_ESAT_WITH_UNKNOWN_PARENT", "table_stereotype": "esat","satellite_parent_table":"rtjj_01_CCC_XXX_UNKNOWN_HUB"}
			,	{"table_name": "rtjj_01_AAA_EEE_DONT_USE_AS_PARENT",	"table_stereotype": "sat","satellite_parent_table":"rtjj_01_AAA_HUB","diff_hash_column_name": "rh_rtjj_01_AAA_EEE_DONT_USE_AS_PARENT"}
			,	{"table_name": "rtjj_01_FFF_XXX_SAT_WITH_BAD_PARENT",	"table_stereotype": "sat","satellite_parent_table":"rtjj_01_AAA_EEE_DONT_USE_AS_PARENT","diff_hash_column_name": "rh_rtjj_01_FFF_XXX_SAT_WITH_BAD_PARENT"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test01_check_model_relations');