/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test68_fg_drive_scenario_8';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test68_fg_drive_scenario_8','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test68_fg_drive_scenario_8",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_G1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_68_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_G2", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_68_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB_G2", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_68_bbb_hub"
																					,"target_column_name": "BK_BBB"
																				 	,"field_groups":["fg2"]}]}		 
		      ,{"field_name": "F4_BK_BBB_G3", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_68_bbb_hub"
																					,"target_column_name": "BK_BBB"
																				 	,"field_groups":["fg3"]}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_68_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_68_aaa"}
				,{"table_name": "rtjj_68_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_68_aaa_bbb",
																				"link_parent_tables": ["rtjj_68_aaa_hub","rtjj_68_bbb_hub"]}
				,{"table_name": "rtjj_68_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_68_aaa_bbb_lnk"}
				,{"table_name": "rtjj_68_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_68_bbb"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test68_fg_drive_scenario_8';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test68_fg_drive_scenario_8','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_68_aaa_bbb_esat",2,"parent_key","LK_RTJJ_68_AAA_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_aaa_bbb_lnk",2,"key","LK_RTJJ_68_AAA_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_68_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_68_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_aaa_hub",2,"key","HK_RTJJ_68_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_68_bbb_hub",2,"key","HK_RTJJ_68_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_68_bbb_hub",8,"business_key","BK_BBB","VARCHAR(20)"]
 ],
 "stage_table_column": [
         ["BK_AAA_FG1","VARCHAR(20)",8,"F1_BK_AAA_G1","VARCHAR(20)",false],
         ["BK_AAA_FG2","VARCHAR(20)",8,"F2_BK_AAA_G2","VARCHAR(20)",false],
         ["BK_BBB_FG2","VARCHAR(20)",8,"F3_BK_BBB_G2","VARCHAR(20)",false],
         ["BK_BBB_FG3","VARCHAR(20)",8,"F4_BK_BBB_G3","VARCHAR(20)",false],
         ["HK_RTJJ_68_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_68_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_68_BBB_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_68_BBB_FG3","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_68_AAA_BBB_FG2","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["FG1","HK_RTJJ_68_AAA_FG1","F1_BK_AAA_G1",0,0],
         ["FG2","HK_RTJJ_68_AAA_FG2","F2_BK_AAA_G2",0,0],
         ["FG2","HK_RTJJ_68_BBB_FG2","F3_BK_BBB_G2",0,0],
         ["FG2","LK_RTJJ_68_AAA_BBB_FG2","F2_BK_AAA_G2",0,0],
         ["FG2","LK_RTJJ_68_AAA_BBB_FG2","F3_BK_BBB_G2",0,0],
         ["FG3","HK_RTJJ_68_BBB_FG3","F4_BK_BBB_G3",0,0]
  ]    }');