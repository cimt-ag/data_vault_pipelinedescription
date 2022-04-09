/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test66_fg_drive_scenario_6';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test66_fg_drive_scenario_6','{
	"dvpd_version": "1.0",
	"pipeline_name": "test66_fg_drive_scenario_6",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_G1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_66_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_G2", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_66_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_66_bbb_hub"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_66_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_66_aaa"}
				,{"table_name": "rtjj_66_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_66_aaa_bbb",
																				"link_parent_tables": ["rtjj_66_aaa_hub","rtjj_66_bbb_hub"]}
				,{"table_name": "rtjj_66_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_66_aaa_bbb_lnk"}
				,{"table_name": "rtjj_66_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_66_bbb"}
				]
		}
	]
}
');