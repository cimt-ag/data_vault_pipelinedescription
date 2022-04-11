
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test24_one_satellite_on_linked_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test24_one_satellite_on_linked_hub','{
	"dvpd_version": "1.0",
	"pipeline_name": "test24_one_satellite_on_linked_hub",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_24_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_24_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_24_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_24_aaa_p1_sat"}]}
			  ,{"field_name": "F5__FIELD_NAME",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_24_aaa_p1_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
		 	  ,{"field_name": "F6_BBB_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_24_bbb_p1_sat"}]}
			  ,{"field_name": "F7_BBB_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_24_bbb_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_24_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_24_aaa"}
				,{"table_name": "rtjj_24_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_24_aaa_hub","diff_hash_column_name": "RH_rtjj_24_aaa_p1_sat"}
				,{"table_name": "rtjj_24_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_24_aaa_bbb",
																				"link_parent_tables": ["rtjj_24_aaa_hub","rtjj_24_bbb_hub"]}
				,{"table_name": "rtjj_24_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_24_aaa_bbb_lnk"}
				,{"table_name": "rtjj_24_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_24_bbb"}
				,{"table_name": "rtjj_24_bbb_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_24_bbb_hub","diff_hash_column_name": "RH_rtjj_24_bbb_p1_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test24_one_satellite_on_linked_hub');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test24_one_satellite_on_linked_hub';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test24_one_satellite_on_linked_hub','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_24_aaa_bbb_esat",2,"parent_key","LK_RTJJ_24_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_bbb_lnk",2,"key","LK_RTJJ_24_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_24_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_24_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_hub",2,"key","HK_RTJJ_24_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_24_aaa_p1_sat",2,"parent_key","HK_RTJJ_24_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_p1_sat",3,"diff_hash","RH_RTJJ_24_AAA_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_aaa_p1_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_24_aaa_p1_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_24_aaa_p1_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_24_bbb_hub",2,"key","HK_RTJJ_24_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"],
		["rvlt_test_jj","rtjj_24_bbb_p1_sat",2,"parent_key","HK_RTJJ_24_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_bbb_p1_sat",3,"diff_hash","RH_RTJJ_24_BBB_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_24_bbb_p1_sat",8,"content","F6_BBB_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_24_bbb_p1_sat",8,"content","F7_BBB_SP1_DECIMAL","DECIMAL(5,0)"]
],
 "process_column_mapping": [
         ["rtjj_24_aaa_bbb_esat","_A_","LK_RTJJ_24_AAA_BBB","LK_RTJJ_24_AAA_BBB",null],
         ["rtjj_24_aaa_bbb_lnk","_A_","LK_RTJJ_24_AAA_BBB","LK_RTJJ_24_AAA_BBB",null],
         ["rtjj_24_aaa_bbb_lnk","_A_","HK_RTJJ_24_AAA","HK_RTJJ_24_AAA",null],
         ["rtjj_24_aaa_bbb_lnk","_A_","HK_RTJJ_24_BBB","HK_RTJJ_24_BBB",null],
         ["rtjj_24_aaa_hub","_A_","HK_RTJJ_24_AAA","HK_RTJJ_24_AAA",null],
         ["rtjj_24_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_24_aaa_p1_sat","_A_","HK_RTJJ_24_AAA","HK_RTJJ_24_AAA",null],
         ["rtjj_24_aaa_p1_sat","_A_","RH_RTJJ_24_AAA_P1_SAT","RH_RTJJ_24_AAA_P1_SAT",null],
         ["rtjj_24_aaa_p1_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rtjj_24_aaa_p1_sat","_A_","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL"],
         ["rtjj_24_aaa_p1_sat","_A_","F5_AAA_SP1_VARCHAR","F5__FIELD_NAME","F5__FIELD_NAME"],
         ["rtjj_24_bbb_hub","_A_","HK_RTJJ_24_BBB","HK_RTJJ_24_BBB",null],
         ["rtjj_24_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"],
         ["rtjj_24_bbb_p1_sat","_A_","HK_RTJJ_24_BBB","HK_RTJJ_24_BBB",null],
         ["rtjj_24_bbb_p1_sat","_A_","RH_RTJJ_24_BBB_P1_SAT","RH_RTJJ_24_BBB_P1_SAT",null],
         ["rtjj_24_bbb_p1_sat","_A_","F6_BBB_SP1_VARCHAR","F6_BBB_SP1_VARCHAR","F6_BBB_SP1_VARCHAR"],
         ["rtjj_24_bbb_p1_sat","_A_","F7_BBB_SP1_DECIMAL","F7_BBB_SP1_DECIMAL","F7_BBB_SP1_DECIMAL"]
 ],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5__FIELD_NAME","VARCHAR(200)",8,"F5__FIELD_NAME","VARCHAR(200)",false],
		["F6_BBB_SP1_VARCHAR","VARCHAR(200)",8,"F6_BBB_SP1_VARCHAR","VARCHAR(200)",false],
		["F7_BBB_SP1_DECIMAL","DECIMAL(5,0)",8,"F7_BBB_SP1_DECIMAL","DECIMAL(5,0)",false],
		["HK_RTJJ_24_AAA","CHAR(28)",2,null,null,false],
		["HK_RTJJ_24_BBB","CHAR(28)",2,null,null,false],
		["LK_RTJJ_24_AAA_BBB","CHAR(28)",2,null,null,false],
		["RH_RTJJ_24_AAA_P1_SAT","CHAR(28)",3,null,null,false],
		["RH_RTJJ_24_BBB_P1_SAT","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_24_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_24_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RTJJ_24_AAA_BBB","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_24_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","RH_RTJJ_24_AAA_P1_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_24_AAA_P1_SAT","F4_AAA_SP1_DECIMAL",0,0],
         ["_A_","RH_RTJJ_24_AAA_P1_SAT","F5__FIELD_NAME",0,0],
         ["_A_","RH_RTJJ_24_BBB_P1_SAT","F6_BBB_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_24_BBB_P1_SAT","F7_BBB_SP1_DECIMAL",0,0]
  ]    }');                                                                                                              

