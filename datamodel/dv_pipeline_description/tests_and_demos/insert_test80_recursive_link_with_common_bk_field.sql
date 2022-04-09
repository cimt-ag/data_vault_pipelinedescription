/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test80_recursive_link_with_common_bk_field','{
 	"dvpd_version": "1.0",
 	"pipeline_name": "test80_recursive_link_with_common_bk_field",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
		      {"field_name": "F1_BK_AAA_COMMON", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"target_column_name": "BK_AAA_CM"}]}
		      ,{"field_name": "F2_BK_AAA_ORIGIN", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"target_column_name": "BK_AAA_SPLIT"}]}		 	  
		      ,{"field_name": "F3_BK_AAA_RECURSE1", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_80_aaa_hub"
																					,"target_column_name": "BK_AAA_SPLIT"
																					,"recursion_suffix": "RCS1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_80_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_80_aaa"}
				,{"table_name": "rtjj_80_aaa_aaa1_lnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_80_aaa_aaa1"
																			,"link_parent_tables": ["rtjj_80_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_80_aaa_hub"
																										,"recursion_suffix": "RCS1"}]}
				,{"table_name": "rtjj_80_aaa_aaa1_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_80_aaa_aaa1_lnk"}

				]
		}
 ]
 }');
 

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test80_recursive_link_with_common_bk_field','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_80_aaa_aaa1_esat",2,"parent_key","LK_RTJJ_80_AAA_AAA1","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_aaa1_lnk",2,"key","LK_RTJJ_80_AAA_AAA1","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_aaa1_lnk",3,"parent_key","HK_RTJJ_80_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_aaa1_lnk",4,"parent_key","HK_RTJJ_80_AAA_RCS1","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_hub",2,"key","HK_RTJJ_80_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_80_aaa_hub",8,"business_key","BK_AAA_CM","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_80_aaa_hub",8,"business_key","BK_AAA_SPLIT","VARCHAR(20)"]
 ],
 "stage_table_column": [
         ["BK_AAA_CM","VARCHAR(20)",8,"F1_BK_AAA_COMMON","VARCHAR(20)",false],
         ["BK_AAA_SPLIT","VARCHAR(20)",8,"F2_BK_AAA_ORIGIN","VARCHAR(20)",false],
         ["BK_AAA_SPLIT_RCS1","VARCHAR(20)",8,"F3_BK_AAA_RECURSE1","VARCHAR(20)",false],
         ["HK_RTJJ_80_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_80_AAA_RCS1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_80_AAA_AAA1","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_80_AAA","F1_BK_AAA_COMMON",0,0],
         ["_A_","HK_RTJJ_80_AAA","F2_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_80_AAA_AAA1","F1_BK_AAA_COMMON",0,0],
         ["_A_","LK_RTJJ_80_AAA_AAA1","F2_BK_AAA_ORIGIN",0,0],
         ["_A_","LK_RTJJ_80_AAA_AAA1","F3_BK_AAA_RECURSE1",0,0],
         ["_RCS1","HK_RTJJ_80_AAA_RCS1","F1_BK_AAA_COMMON",0,0],
         ["_RCS1","HK_RTJJ_80_AAA_RCS1","F3_BK_AAA_RECURSE1",0,0]
  ]    }');