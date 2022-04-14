/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test29_link_without_esat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test29_link_without_esat','{
	"dvpd_version": "1.0",
	"pipeline_name": "test29_link_without_esat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_29_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_29_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_29_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_29_aaa_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_29_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_29_aaa"}
				,{"table_name": "rtjj_29_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_29_aaa_HUB","diff_hash_column_name": "RH_rtjj_29_aaa_P1_SAT"}
				,{"table_name": "rtjj_29_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_29_bbb"}
				,{"table_name": "rtjj_29_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_29_aaa_bbb",
																				"link_parent_tables": ["rtjj_29_aaa_hub","rtjj_29_bbb_hub"]}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test29_link_without_esat');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test29_link_without_esat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test29_link_without_esat','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",2,"key","LK_RTJJ_29_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_29_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_29_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_29_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_29_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_29_aaa_hub",2,"key","HK_RTJJ_29_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",2,"parent_key","HK_RTJJ_29_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",3,"diff_hash","RH_RTJJ_29_AAA_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_test_jj","rtjj_29_aaa_p1_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
      ["rvlt_test_jj","rtjj_29_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_29_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_29_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_29_bbb_hub",2,"key","HK_RTJJ_29_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_29_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"]
 ],
 "process_column_mapping": [
         ["rtjj_29_aaa_bbb_lnk","_A_","LK_RTJJ_29_AAA_BBB","LK_RTJJ_29_AAA_BBB",null],
         ["rtjj_29_aaa_bbb_lnk","_A_","HK_RTJJ_29_AAA","HK_RTJJ_29_AAA",null],
         ["rtjj_29_aaa_bbb_lnk","_A_","HK_RTJJ_29_BBB","HK_RTJJ_29_BBB",null],
         ["rtjj_29_aaa_hub","_A_","HK_RTJJ_29_AAA","HK_RTJJ_29_AAA",null],
         ["rtjj_29_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_29_aaa_p1_sat","_A_","HK_RTJJ_29_AAA","HK_RTJJ_29_AAA",null],
         ["rtjj_29_aaa_p1_sat","_A_","RH_RTJJ_29_AAA_P1_SAT","RH_RTJJ_29_AAA_P1_SAT",null],
         ["rtjj_29_aaa_p1_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rtjj_29_aaa_p1_sat","_A_","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL"],
         ["rtjj_29_bbb_hub","_A_","HK_RTJJ_29_BBB","HK_RTJJ_29_BBB",null],
         ["rtjj_29_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_29_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_29_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_29_AAA_BBB","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_29_AAA_P1_SAT","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
         ["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_29_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_29_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RTJJ_29_AAA_BBB","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_29_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","RH_RTJJ_29_AAA_P1_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_29_AAA_P1_SAT","F4_AAA_SP1_DECIMAL",0,0]
  ]    }');