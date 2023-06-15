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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test04_check_hub_specifics';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test04_check_hub_specifics','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test04_check_hub_specifics",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		 	  {"field_name": "F5_BK_BBB_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_bbb_xxx_same_hk_hub"}]}
  		 	  ,{"field_name": "F6_BK_CCC_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_ccc_xxx_same_hk_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_04_aaa_xxx_no_bk_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_04_aaa"}
				,{"table_name": "rtjj_04_bbb_xxx_same_hk_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_XXX_SAME_HK"}
				,{"table_name": "rtjj_04_ccc_xxx_same_hk_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_XXX_SAME_HK"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test04_check_hub_specifics');