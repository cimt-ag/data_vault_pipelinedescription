--drop view if exists dv_pipeline_description.XENC_PIPELINE_DV_COLUMN;
create or replace view dv_pipeline_description.XENC_PIPELINE_DV_COLUMN as (

with enhance_xenc_table_properties as (
select epdtp.pipeline_name
	,epdtp.table_name
	,epdtp.xenc_content_hash_column_name
	,epdtp.xenc_content_salted_hash_column_name
	,epdtp.xenc_content_table_name
	,epdtp.xenc_encryption_key_column_name
	,epdtp.xenc_encryption_key_index_column_name
	,epdtp.xenc_diff_hash_column_name
	,epdtp.xenc_table_key_column_name
	, pdt.stereotype
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name 
)
, model_profile as (
select pdt.table_name ,dvmp.property_name ,dvmp.property_value 
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join dv_pipeline_description.dvpd_data_vault_model_profile dvmp on dvmp.data_vault_model_profile_name =pdt.data_vault_model_profile_name 
)
,general_encryption_table_columns as (
 select -- own key column
 	extp.pipeline_name 
   ,extp.table_name
   ,2 as column_block
   ,'key' as dv_column_class
   , xenc_table_key_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='table_key_column_type'
 where stereotype like 'xenc_%-ek'
 union
 select -- encryption key column
 	extp.pipeline_name 
   ,extp.table_name
   ,5 as column_block
   ,'xenc_encryption_key' as dv_column_class
   , xenc_encryption_key_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_column_type'
 where stereotype like 'xenc_%-ek'
 )
, hub_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_HUB-EK
 select -- meta columns
 	pdt.pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name  as column_name
   ,dml.meta_column_type 
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype ='xenc_hub-ek'
 where pdt.stereotype ='xenc_hub-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_bk_hash' as dv_column_class
   , xenc_content_hash_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where stereotype ='xenc_hub-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_bk_salted_hash' as dv_column_class
   , xenc_content_salted_hash_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where stereotype ='xenc_hub-ek'
)
, lnk_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_LNK-EK
 select -- meta columns
 	pdt.pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name  as column_name
   ,dml.meta_column_type 
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype ='xenc_lnk-ek'
 where pdt.stereotype ='xenc_lnk-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_dc_hash' as dv_column_class
   , xenc_content_hash_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
 where stereotype ='xenc_lnk-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_dc_salted_hash' as dv_column_class
   , xenc_content_salted_hash_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where stereotype ='xenc_lnk-ek'
)
,sat_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_SAT-EK
 select -- meta columns
 	extp.pipeline_name 
   ,extp.table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,dml.meta_column_name as column_name
   ,dml.meta_column_type as column_type
 from enhance_xenc_table_properties extp
 join dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = extp.pipeline_name 
 														and cpdt.table_name = extp.xenc_content_table_name
 join dv_pipeline_description.dvpd_meta_column_lookup dml on dml.stereotype = extp.stereotype 
 or ( dml.stereotype = 'xsat_hist' and cpdt.is_historized )
 where extp.stereotype in ('xenc_sat-ek','xenc_msat-ek')
 union 
  select -- encryption key index column
 	extp.pipeline_name 
   ,extp.table_name
   ,6 as column_block
   ,'xenc_encryption_key_index' as dv_column_class
   , xenc_encryption_key_index_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_index_column_type'
 where stereotype like 'xenc_%sat-ek'
 union
  select -- diff hash
 	extp.pipeline_name 
   ,extp.table_name
   ,3 as column_block
   ,'diff_hash'::text as dv_column_class
   , xenc_diff_hash_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='diff_hash_column_type'
 where stereotype like 'xenc_%sat-ek'
 and xenc_diff_hash_column_name is not null
 )
,sat_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< SAT
  select -- encryption key index column
 	extp.pipeline_name 
   ,extp.table_name
   ,6 as column_block
   ,'xenc_encryption_key_index'::text as dv_column_class
   , xenc_encryption_key_index_column_name  as column_name
   ,mp.property_value as column_type
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_index_column_type'
 where stereotype in ('sat','msat')
 
 )
-- ,ref_ek_columns as (-- <<<<<<<<<<<<<<<<<<<<<<<<< REF #TBD
--
-- ========== FINAL UNION =================
 select * from general_encryption_table_columns
 union
 select * from hub_ek_columns
 union
 select * from lnk_ek_columns
 union 
 select * from sat_ek_columns
 union 
 select * from sat_columns
 
);
 
 
-- select * from dv_pipeline_description.XENC_PIPELINE_DV_COLUMN ddmc  order by 1,2,3,4,5;