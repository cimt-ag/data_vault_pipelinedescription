/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test63_fg_drive_scenario_3';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test63_fg_drive_scenario_3','{
	"dvpd_version": "1.0",
	"pipeline_name": "test63_fg_drive_scenario_3",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_63_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_63_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_63_bbb_hub"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_63_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_63_aaa"}
				,{"table_name": "rtjj_63_aaa_bbb_lnk",	"stereotype": "lnk"	,"link_key_column_name": "LK_rtjj_63_aaa_bbb"
																			,"link_parent_tables": ["rtjj_63_aaa_hub","rtjj_63_bbb_hub"]
																			,"tracked_field_groups": ["fg1"]}
				,{"table_name": "rtjj_63_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_63_bbb"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test63_fg_drive_scenario_3');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test63_fg_drive_scenario_3';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test63_fg_drive_scenario_3','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",2,"key","LK_RTJJ_63_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_63_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_63_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_63_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_63_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_63_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_63_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_63_aaa_hub",2,"key","HK_RTJJ_63_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_63_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_63_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_63_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_63_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_63_bbb_hub",2,"key","HK_RTJJ_63_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_63_bbb_hub",8,"business_key","F3_BK_BBB","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_63_aaa_bbb_lnk","_FG1","LK_RTJJ_63_AAA_BBB","LK_RTJJ_63_AAA_BBB_FG1",null],
         ["rtjj_63_aaa_bbb_lnk","_FG1","HK_RTJJ_63_AAA","HK_RTJJ_63_AAA_FG1",null],
         ["rtjj_63_aaa_bbb_lnk","_FG1","HK_RTJJ_63_BBB","HK_RTJJ_63_BBB",null],
         ["rtjj_63_aaa_hub","_FG1","HK_RTJJ_63_AAA","HK_RTJJ_63_AAA_FG1",null],
         ["rtjj_63_aaa_hub","_FG1","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rtjj_63_aaa_hub","_FG2","HK_RTJJ_63_AAA","HK_RTJJ_63_AAA_FG2",null],
         ["rtjj_63_aaa_hub","_FG2","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rtjj_63_bbb_hub","_A_","HK_RTJJ_63_BBB","HK_RTJJ_63_BBB",null],
         ["rtjj_63_bbb_hub","_A_","F3_BK_BBB","F3_BK_BBB","F3_BK_BBB"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_63_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_63_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_63_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_63_AAA_BBB_FG1","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_BK_BBB","VARCHAR(20)",8,"F3_BK_BBB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_63_BBB","F3_BK_BBB",0,0],
         ["_FG1","HK_RTJJ_63_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_63_AAA_BBB_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_63_AAA_BBB_FG1","F3_BK_BBB",0,0],
         ["_FG2","HK_RTJJ_63_AAA_FG2","F2_BK_AAA_L2",0,0]
  ]    }');