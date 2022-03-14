DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test30_hub_dlink_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test30_hub_dlink_sat','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test30_hub_dlink_sat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_30_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_30_aaa_hub"}]},
		 	  {"field_name": "F3_DC_AAA_DDD_VARCHAR",		"technical_type": "DATE",			"targets": [{"table_name": "rtjj_30_aaa_ddd_dlnk"}]},
			  {"field_name": "F4_AAA_DDD_SP1_DECIMAL",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_30_aaa_ddd_p1_sat"}]},
			  {"field_name": "F5_AAA_DDD_SP1_DECIMAL",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_30_aaa_ddd_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_30_aaa_hub",		"stereotype": "hub",			"hub_key_column_name": "HK_rtjj_30_aaa"},
				{"table_name": "rtjj_30_aaa_ddd_dlnk",		"stereotype": "lnk",	"link_key_column_name": "LK_rtjj_30_aaa_ddd",
																 				"link_parent_tables":["rtjj_30_aaa_hub"]},
				{"table_name": "rtjj_30_aaa_ddd_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_30_aaa_ddd_dlnk","diff_hash_column_name": "RH_rtjj_30_aaa_ddd_p1_sat"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test30_hub_dlink_sat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test30_hub_dlink_sat','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_30_aaa_ddd_dlnk",2,"key","LK_RTJJ_30_AAA_DDD","CHAR(28)"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_dlnk",3,"parent_key","HK_RTJJ_30_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_dlnk",8,"dependent_child_key","F3_DC_AAA_DDD_VARCHAR","DATE"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_p1_sat",2,"parent_key","LK_RTJJ_30_AAA_DDD","CHAR(28)"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_p1_sat",3,"diff_hash","RH_RTJJ_30_AAA_DDD_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_p1_sat",8,"content","F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_30_aaa_ddd_p1_sat",8,"content","F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_30_aaa_hub",2,"key","HK_RTJJ_30_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_30_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_30_aaa_hub",8,"business_key","F2_BK_AAA_DECIMAL","DECIMAL(20,0)"]
],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_AAA_DECIMAL","DECIMAL(20,0)",8,"F2_BK_AAA_DECIMAL","DECIMAL(20,0)",false],
		["F3_DC_AAA_DDD_VARCHAR","DATE",8,"F3_DC_AAA_DDD_VARCHAR","DATE",false],
		["F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",8,"F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",false],
		["HK_RTJJ_30_AAA","CHAR(28)",2,null,null,false],
		["LK_RTJJ_30_AAA_DDD","CHAR(28)",2,null,null,false],
		["RH_RTJJ_30_AAA_DDD_P1_SAT","CHAR(28)",3,null,null,false]
]
}');                                                                                                              
