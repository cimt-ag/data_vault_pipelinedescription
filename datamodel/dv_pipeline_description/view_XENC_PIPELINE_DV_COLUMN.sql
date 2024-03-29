-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================


--drop view if exists dv_pipeline_description.XENC_PIPELINE_DV_COLUMN cascade;
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
	, pdt.table_stereotype
	, pdt.model_profile_name 
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name 
)
, model_profile as (
select pdt.table_name ,dvmp.property_name ,dvmp.property_value 
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join dv_pipeline_description.DVPD_MODEL_PROFILE dvmp on dvmp.model_profile_name =pdt.model_profile_name 
)
,general_encryption_table_columns as (
 select -- own key column
 	extp.pipeline_name 
   ,extp.table_name
   ,2 as column_block
   ,'key' as column_class
   , xenc_table_key_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='table_key_column_type'
 where table_stereotype like 'xenc_%-ek'
 union
 select -- encryption key column
 	extp.pipeline_name 
   ,extp.table_name
   ,5 as column_block
   ,'xenc_encryption_key' as column_class
   , xenc_encryption_key_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_column_type'
 where table_stereotype like 'xenc_%-ek'
 )
, hub_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_HUB-EK
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.table_stereotype ='xenc_hub-ek'
 																	and mpmcl.model_profile_name =pdt .model_profile_name 
  where pdt.table_stereotype ='xenc_hub-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_bk_hash' as column_class
   , xenc_content_hash_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where table_stereotype ='xenc_hub-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_bk_salted_hash' as column_class
   , xenc_content_salted_hash_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where table_stereotype ='xenc_hub-ek'
)
, lnk_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_LNK-EK
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.table_stereotype ='xenc_lnk-ek'
 																	and mpmcl.model_profile_name =pdt .model_profile_name 
where pdt.table_stereotype ='xenc_lnk-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_dc_hash' as column_class
   , xenc_content_hash_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
 where table_stereotype ='xenc_lnk-ek'
 union 
 select -- content hash column
 	extp.pipeline_name 
   ,extp.table_name
   ,7 as column_block
   ,'xenc_dc_salted_hash' as column_class
   , xenc_content_salted_hash_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_content_hash_column_type'
where table_stereotype ='xenc_lnk-ek'
)
,sat_ek_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< XENC_SAT-EK
 select -- meta columns
 	extp.pipeline_name 
   ,extp.table_name
   ,1 as column_block
   ,'meta' as column_class
   ,mpmcl.meta_column_name as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 join dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = extp.pipeline_name 
 														and cpdt.table_name = extp.xenc_content_table_name
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.model_profile_name =extp.model_profile_name 
 														and (mpmcl.table_stereotype = extp.table_stereotype  or ( mpmcl.table_stereotype = 'xsat_hist' and cpdt.is_enddated )
 														or (mpmcl.table_stereotype = 'xsat_delflag' and cpdt.has_deletion_flag))
 where extp.table_stereotype in ('xenc_sat-ek')
 union 
  select -- encryption key index column
 	extp.pipeline_name 
   ,extp.table_name
   ,6 as column_block
   ,'xenc_encryption_key_index' as column_class
   , xenc_encryption_key_index_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_index_column_type'
 where table_stereotype like 'xenc_%sat-ek'
 union
  select -- diff hash
 	extp.pipeline_name 
   ,extp.table_name
   ,3 as column_block
   ,'diff_hash'::text as column_class
   , xenc_diff_hash_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='diff_hash_column_type'
 where table_stereotype like 'xenc_%sat-ek'
 and xenc_diff_hash_column_name is not null
 )
,sat_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< SAT
  select -- encryption key index column
 	extp.pipeline_name 
   ,extp.table_name
   ,6 as column_block
   ,'xenc_encryption_key_index'::text as column_class
   , xenc_encryption_key_index_column_name  as column_name
   ,mp.property_value as column_type
   ,false as is_nullable
 from enhance_xenc_table_properties extp
 left join model_profile mp on mp.table_name = extp.table_name 
 		and mp.property_name ='xenc_encryption_key_index_column_type'
 where table_stereotype in ('sat')

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
 
comment on view dv_pipeline_description.XENC_PIPELINE_DV_COLUMN is
 '[Encryption Extention] All additional columns, needed for encryption ';

 
-- select * from dv_pipeline_description.XENC_PIPELINE_DV_COLUMN ddmc  order by 1,2,3,4,5;