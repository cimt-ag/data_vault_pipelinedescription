
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test69_fg_drive_scenario_9_simple_hierarchy';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test70_fg_drive_stest69_fg_drive_scenario_9_simple_hierarchycenario_10','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test69_fg_drive_scenario_9_simple_hierarchy",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_69_aaa_hub"
																					,"target_column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_HRCHY1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_69_aaa_hub"
																					,"target_column_name": "BK_AAA"
																					,"hierarchy_key_suffix": "HRCHY1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_69_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_69_aaa"}
				,{"table_name": "rtjj_69_aaa_aaa1_lnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_69_aaa_aaa1"
																			,"link_parent_tables": ["rtjj_69_aaa_hub"]
																			,"hierarchical_parents": [ {"table_name":"rtjj_69_aaa_hub"
																										,"hierarchy_key_suffix": "HRCHY1"}]}
				,{"table_name": "rtjj_69_aaa_aaa1_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_69_aaa_aaa1_lnk"}

				]
		}
	]
}
');

	