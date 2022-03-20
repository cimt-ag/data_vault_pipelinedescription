
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test27_dependent_child_key_link_one_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test27_dependent_child_key_link_one_hub','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test27_dependent_child_key_link_one_hub",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_27_aaa_hub"}]}
		 	  ,{"field_name": "F2_DPCK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_27_aaa_dpc_dlnk"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_27_aaa_dpc_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_27_aaa_dpc_sat"}]}
			  ,{"field_name": "F5_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_27_aaa_dpc_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_27_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_27_aaa"}
				,{"table_name": "rtjj_27_aaa_dpc_dlnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_27_aaa_dpc",
																				"link_parent_tables": ["rtjj_27_aaa_hub"]}
				,{"table_name": "rtjj_27_aaa_dpc_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_27_aaa_dpc_dlnk","diff_hash_column_name": "RH_rtjj_27_aaa_dpc_sat"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test27_dependent_child_key_link_one_hub';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test27_dependent_child_key_link_one_hub','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_27_aaa_dpc_dlnk",2,"key","LK_RTJJ_27_AAA_DPC","CHAR(28)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_dlnk",3,"parent_key","HK_RTJJ_27_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_dlnk",8,"dependent_child_key","F2_DPCK_BBB_DECIMAL","DECIMAL(20,0)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_sat",2,"parent_key","LK_RTJJ_27_AAA_DPC","CHAR(28)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_sat",3,"diff_hash","RH_RTJJ_27_AAA_DPC_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_27_aaa_dpc_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_27_aaa_hub",2,"key","HK_RTJJ_27_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_27_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"]
],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_DPCK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_DPCK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F5_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["HK_RTJJ_27_AAA","CHAR(28)",2,null,null,false],
		["LK_RTJJ_27_AAA_DPC","CHAR(28)",2,null,null,false],
		["RH_RTJJ_27_AAA_DPC_SAT","CHAR(28)",3,null,null,false]
]
}');                                                                                                              

