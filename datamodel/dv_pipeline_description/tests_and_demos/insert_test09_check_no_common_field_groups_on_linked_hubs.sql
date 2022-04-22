/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test09_check_no_common_field_groups_on_linked_hubs';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test09_check_no_common_field_groups_on_linked_hubs','{
	"dvpd_version": "1.0",
	"pipeline_name": "test09_check_no_common_field_groups_on_linked_hubs",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB_L3", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_bbb_hub"
																					,"target_column_name": "BK_BBB"
																				 	,"field_groups":["fg3"]}]}		 
		      ,{"field_name": "F4_BK_BBB_L4", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_09_bbb_hub"
																					,"target_column_name": "BK_BBB"
																				 	,"field_groups":["fg4"]}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_09_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_09_aaa"}
				,{"table_name": "rtjj_09_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_09_aaa_bbb",
																				"link_parent_tables": ["rtjj_09_aaa_hub","rtjj_09_bbb_hub"]}
				,{"table_name": "rtjj_09_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_09_aaa_bbb_lnk"}
				,{"table_name": "rtjj_09_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_09_bbb"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test09_check_no_common_field_groups_on_linked_hubs');

