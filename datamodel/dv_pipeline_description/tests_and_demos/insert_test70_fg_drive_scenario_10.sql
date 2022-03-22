/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test70_fg_drive_scenario_10';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test70_fg_drive_scenario_10','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test70_fg_drive_scenario_10",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA_FG1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_FG2", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_H1_FG1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]
																					,"recursion_suffix": "HRCHY1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_70_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_70_aaa"}
				,{"table_name": "rtjj_70_aaa_aaa1_lnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_70_aaa_aaa1"
																			,"link_parent_tables": ["rtjj_70_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_70_aaa_hub"
																										,"recursion_suffix": "HRCHY1"}]}
				,{"table_name": "rtjj_70_aaa_aaa1_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_70_aaa_aaa1_lnk"
																				 ,"tracked_field_groups":["fg1"]}

				]
		}
 ],
 "stage_hash_input_field": [
         ["FG1","HK_RTJJ_70_AAA_FG1","F1_BK_AAA_FG1",0,0],
         ["FG1","LK_RTJJ_70_AAA_AAA1_FG1","F1_BK_AAA_FG1",0,0],
         ["FG1","LK_RTJJ_70_AAA_AAA1_FG1","F3_BK_AAA_H1_FG1",0,0],
         ["FG1_HRCHY1","HK_RTJJ_70_AAA_FG1_HRCHY1","F3_BK_AAA_H1_FG1",0,0],
         ["FG2","HK_RTJJ_70_AAA_FG2","F2_BK_AAA_FG2",0,0]
  ]    }');

	