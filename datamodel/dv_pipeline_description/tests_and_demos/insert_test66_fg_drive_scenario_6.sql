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
		      {"field_name": "F1_BK_AAA_L1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_66_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_66_aaa_hub"
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


DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test66_fg_drive_scenario_6';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test66_fg_drive_scenario_6','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_66_aaa_bbb_esat",2,"parent_key","LK_RTJJ_66_AAA_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_aaa_bbb_lnk",2,"key","LK_RTJJ_66_AAA_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_66_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_66_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_aaa_hub",2,"key","HK_RTJJ_66_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_66_bbb_hub",2,"key","HK_RTJJ_66_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_66_bbb_hub",8,"business_key","F3_BK_BBB","VARCHAR(20)"]
 ],
  "stage_table_column": [
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_BK_BBB","VARCHAR(20)",8,"F3_BK_BBB","VARCHAR(20)",false],
         ["HK_RTJJ_66_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_66_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_66_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_66_AAA_BBB_FG1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_66_AAA_BBB_FG2","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_66_BBB","F3_BK_BBB",0,0],
         ["_FG1","HK_RTJJ_66_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_66_AAA_BBB_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_66_AAA_BBB_FG1","F3_BK_BBB",0,0],
         ["_FG2","HK_RTJJ_66_AAA_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RTJJ_66_AAA_BBB_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RTJJ_66_AAA_BBB_FG2","F3_BK_BBB",0,0]
  ]    }');