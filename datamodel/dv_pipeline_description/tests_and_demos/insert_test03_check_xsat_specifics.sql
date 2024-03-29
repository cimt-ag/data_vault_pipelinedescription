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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test03_check_xsat_specifics';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test03_check_xsat_specifics','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test03_check_xsat_specifics",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_03_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_03_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_03_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_03_aaa_p1_sat"}]}
			  ,{"field_name": "F5_XXX_BAD_FIELD_FOR_ESAT_XXX",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_03_aaa_bbb_p1_esat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_03_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_03_aaa"}
				,{"table_name": "rtjj_03_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_03_aaa_HUB","diff_hash_column_name": "RH_rtjj_03_aaa_P1_SAT"}
				,{"table_name": "rtjj_03_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_03_bbb"}
				,{"table_name": "rtjj_03_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_03_aaa_bbb",
																				"link_parent_tables": ["rtjj_03_aaa_hub","rtjj_03_bbb_hub"]}
				,{"table_name": "rtjj_03_aaa_bbb_p1_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_03_aaa_bbb_lnk"}
				,{"table_name": "rtjj_03_aaa_bbb_p2_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_03_aaa_bbb_lnk"
																				 ,"driving_keys": ["HK_XXX_NOT_IN_LINK_XXX"]}	
				,{"table_name": "rtjj_03_aaa_p2_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_03_aaa_HUB","diff_hash_column_name": "RH_rtjj_03_aaa_P1_SAT"
																	,"driving_keys": ["HK_rtjj_03_aaa"]}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test03_check_xsat_specifics');