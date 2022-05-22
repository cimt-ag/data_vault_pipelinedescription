/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test70_hierarchy_and_fg_with_encrypted_bk';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test70_hierarchy_and_fg_with_encrypted_bk','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test70_hierarchy_and_fg_with_encrypted_bk",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,	"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_H1_L1", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,	"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]
																					,"recursion_name": "HRCHY1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_70_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_70_aaa"}
				,{"table_name": "rxecd_70_aaa_hierarchy_hlnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rxecd_70_aaa_hierarchy"
																			,"link_parent_tables": ["rxecd_70_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rxecd_70_aaa_hub"
																										,"recursion_name": "HRCHY1"}]}
				,{"table_name": "rxecd_70_aaa_hierarchy_esat",	"stereotype": "esat","satellite_parent_table": "rxecd_70_aaa_hierarchy_hlnk"
																				 ,"tracked_field_groups":["fg1"]}

				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_70_aaa_hub_ek",	"stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_70_aaa_hub"}
				]
		}
 ]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test70_hierarchy_and_fg_with_encrypted_bk');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test70_hierarchy_and_fg_with_encrypted_bk');


-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test70_hierarchy_and_fg_with_encrypted_bk';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test70_hierarchy_and_fg_with_encrypted_bk','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",2,"parent_key","LK_RXECD_70_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",2,"key","LK_RXECD_70_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",3,"parent_key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",4,"parent_key","HK_RXECD_70_AAA_HRCHY1","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",2,"key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",2,"key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_70_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",7,"xenc_bk_hash","BKH_rxeck_70_aaa_hub_ek","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_rxeck_70_aaa_hub_ek_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_70_aaa_hierarchy_esat","_FG1","LK_RXECD_70_AAA_HIERARCHY","LK_RXECD_70_AAA_HIERARCHY_FG1",null],
         ["rxecd_70_aaa_hierarchy_hlnk","_FG1","LK_RXECD_70_AAA_HIERARCHY","LK_RXECD_70_AAA_HIERARCHY_FG1",null],
         ["rxecd_70_aaa_hierarchy_hlnk","_FG1","HK_RXECD_70_AAA","HK_RXECD_70_AAA_FG1",null],
         ["rxecd_70_aaa_hierarchy_hlnk","_FG1","HK_RXECD_70_AAA_HRCHY1","HK_RXECD_70_AAA_HRCHY1_FG1",null],
         ["rxecd_70_aaa_hub","_FG1","HK_RXECD_70_AAA","HK_RXECD_70_AAA_FG1",null],
         ["rxecd_70_aaa_hub","_FG1","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rxecd_70_aaa_hub","_FG2","HK_RXECD_70_AAA","HK_RXECD_70_AAA_FG2",null],
         ["rxecd_70_aaa_hub","_FG2","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rxecd_70_aaa_hub","_HRCHY1_FG1","HK_RXECD_70_AAA","HK_RXECD_70_AAA_HRCHY1_FG1",null],
         ["rxecd_70_aaa_hub","_HRCHY1_FG1","BK_AAA","F3_BK_AAA_H1_L1","F3_BK_AAA_H1_L1"]
 ],
 "stage_table_column": [
         ["HK_RXECD_70_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RXECD_70_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RXECD_70_AAA_HRCHY1_FG1","CHAR(28)",2,null,null,false],
         ["LK_RXECD_70_AAA_HIERARCHY_FG1","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",true],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",true],
         ["F3_BK_AAA_H1_L1","VARCHAR(20)",8,"F3_BK_AAA_H1_L1","VARCHAR(20)",true]
 ],
 "stage_hash_input_field": [
         ["_FG1","HK_RXECD_70_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RXECD_70_AAA_HIERARCHY_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RXECD_70_AAA_HIERARCHY_FG1","F3_BK_AAA_H1_L1",0,0],
         ["_FG2","HK_RXECD_70_AAA_FG2","F2_BK_AAA_L2",0,0],
         ["_HRCHY1_FG1","HK_RXECD_70_AAA_HRCHY1_FG1","F3_BK_AAA_H1_L1",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_70_aaa_hub_ek","_FG1","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA_FG1","HK_RXECD_70_AAA_FG1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_FG1","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB_FG1",null,null],
         ["rxeck_70_aaa_hub_ek","_FG1","BKH_rxeck_70_aaa_hub_ek","CHAR(28)","xenc_bk_hash","BKH_rxeck_70_aaa_hub_ek_FG1","HK_RXECD_70_AAA_FG1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_FG1","BKH_rxeck_70_aaa_hub_ek_ST","CHAR(28)","xenc_bk_salted_hash","BKH_rxeck_70_aaa_hub_ek_ST_FG1","HK_RXECD_70_AAA_FG1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_FG2","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA_FG2","HK_RXECD_70_AAA_FG2","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_FG2","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB_FG2",null,null],
         ["rxeck_70_aaa_hub_ek","_FG2","BKH_rxeck_70_aaa_hub_ek","CHAR(28)","xenc_bk_hash","BKH_rxeck_70_aaa_hub_ek_FG2","HK_RXECD_70_AAA_FG2","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_FG2","BKH_rxeck_70_aaa_hub_ek_ST","CHAR(28)","xenc_bk_salted_hash","BKH_rxeck_70_aaa_hub_ek_ST_FG2","HK_RXECD_70_AAA_FG2","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_HRCHY1_FG1","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA_HRCHY1_FG1","HK_RXECD_70_AAA_HRCHY1_FG1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_HRCHY1_FG1","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB_HRCHY1_FG1",null,null],
         ["rxeck_70_aaa_hub_ek","_HRCHY1_FG1","BKH_rxeck_70_aaa_hub_ek","CHAR(28)","xenc_bk_hash","BKH_rxeck_70_aaa_hub_ek_HRCHY1_FG1","HK_RXECD_70_AAA_HRCHY1_FG1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","_HRCHY1_FG1","BKH_rxeck_70_aaa_hub_ek_ST","CHAR(28)","xenc_bk_salted_hash","BKH_rxeck_70_aaa_hub_ek_ST_HRCHY1_FG1","HK_RXECD_70_AAA_HRCHY1_FG1","rxecd_70_aaa_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_FG1","F1_BK_AAA_L1","F1_BK_AAA_L1","EK_RXECD_70_AAA_HUB_FG1",1],
         ["_FG2","F2_BK_AAA_L2","F2_BK_AAA_L2","EK_RXECD_70_AAA_HUB_FG2",1],
         ["_HRCHY1_FG1","F3_BK_AAA_H1_L1","F3_BK_AAA_H1_L1","EK_RXECD_70_AAA_HUB_HRCHY1_FG1",1]
  ]    }');