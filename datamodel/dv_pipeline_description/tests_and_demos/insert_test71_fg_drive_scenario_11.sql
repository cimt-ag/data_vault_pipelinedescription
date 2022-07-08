/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test71_fg_drive_scenario_11';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test71_fg_drive_scenario_11','{
	"dvpd_version": "1.0",
	"pipeline_name": "test71_fg_drive_scenario_11",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"target_column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_R1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"target_column_name": "BK_AAA"
																					,"recursion_name": "RRRR"
																				 	,"field_groups":["fg1"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_R2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"target_column_name": "BK_AAA"
																					,"recursion_name": "RRRR"																				 	
																					,"field_groups":["fg2"]}]}		  
		      ,{"field_name": "F4_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_p1_sat"}]}		 
		      ,{"field_name": "F5_AAA_S1_COLB","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_p1_sat"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_71_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_71_aaa"}
				,{"table_name": "rtjj_71_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_71_aaa_hub"
																			,"diff_hash_column_name": "RH_rtjj_71_aaa_p1_sat"}
				,{"table_name": "rtjj_71_aaa_recursion_hlnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_71_aaa_recursion"
																			,"link_parent_tables": ["rtjj_71_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_71_aaa_hub"
																										,"recursion_name": "RRRR"}]}
				,{"table_name": "rtjj_71_aaa_rec1_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_71_aaa_recursion_hlnk"
																				 ,"tracked_field_groups":["fg1"]}
				,{"table_name": "rtjj_71_aaa_rec2_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_71_aaa_recursion_hlnk"
																				 ,"tracked_field_groups":["fg2"]}

				]
		}
 ]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test71_fg_drive_scenario_11');

