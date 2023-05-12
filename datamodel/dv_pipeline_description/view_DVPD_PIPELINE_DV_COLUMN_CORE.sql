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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CORE cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CORE as (


with link_columns as (   -- <<<<<<<<<<<<<<<<<<<<<<<<< LINK
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.stereotype ='lnk'
 																	and mpmcl.model_profile_name =pdt .model_profile_name 
 where pdt.stereotype ='lnk'
union 
 select -- own key column
 	pipeline_name 
   ,table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,pdt.link_key_column_name  as column_name 
   ,mp.property_value  as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='table_key_column_type' 
 where pdt.stereotype ='lnk'
 union
select -- keys of parents
  pdt.pipeline_name 
 ,pdtlp.table_name 
 ,case when pdtlp.is_recursive_relation then 4 else 3 end as column_block
 ,'parent_key' as dv_column_class
 ,case when pdtlp.is_recursive_relation then  pdt.hub_key_column_name||'_'||pdtlp.recursion_name
 		else pdt.hub_key_column_name end as column_name
 ,mp.property_value  as column_type
 ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
 join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.table_name = pdtlp.link_parent_table 
 														and pdt.pipeline_name =pdtlp.pipeline_name 
 left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='table_key_column_type'  														
 union 									
 select -- content
 	pdt.pipeline_name 
   ,pdt.table_name
   ,8 as column_block
   ,case when pfte.exclude_from_key_hash then 'content_untracked' ELSE 'dependent_child_key' end as dv_column_class
   ,pfte.target_column_name   as column_name
   ,pfte.target_column_type 
   ,true as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte on pfte.pipeline_name=pdt.pipeline_name 
 								 and pfte.target_table = pdt.table_name 
 where pdt.stereotype ='lnk'		
 )
,hub_columns as ( -- <<<<<<<<<<<<<<<<<<<<<<<<< HUB
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.stereotype ='hub'
 																	and mpmcl.model_profile_name =pdt .model_profile_name 
 where pdt.stereotype ='hub'
 union 
 select -- own key column
 	pdt.pipeline_name 
   ,table_name
   ,2 as column_block
   ,'key' as dv_column_class
   ,pdt.hub_key_column_name   as column_name
   ,mp.property_value  as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
  left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='table_key_column_type' 
 where pdt.stereotype ='hub'
 union
 select -- content
 	pdt.pipeline_name 
   ,pdt.table_name
   ,8 as column_block
   ,case when pfte.exclude_from_key_hash then 'content_untracked' ELSE 'business_key' end as dv_column_class
   ,pfte.target_column_name   as column_name
   ,pfte.target_column_type 
   ,true as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte on pfte.pipeline_name=pdt.pipeline_name 
 								 and pfte.target_table = pdt.table_name 
 where pdt.stereotype ='hub'
)
,sat_parent_table_ref as (  -- <<<<<<<<<<<<<<<<<<<<<<<<< SAT
	select 
	 pipeline_name 
	 ,table_name 
	 ,satellite_parent_table as parent_table
	from  dv_pipeline_description.dvpd_pipeline_dv_table pdt
	where stereotype in ('sat','esat','msat')
)
,sat_columns as (
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.model_profile_name =pdt .model_profile_name 
			 								and (mpmcl.stereotype = pdt.stereotype or ( mpmcl.stereotype = 'xsat_hist' and pdt.is_enddated )
			 								or (mpmcl.stereotype = 'xsat_delflag' and pdt.has_deletion_flag))
 where pdt.stereotype in ('sat','esat','msat')
 union 
select -- own key column
 	pdt.pipeline_name 
	,sr.table_name
   ,2 as column_block
   ,'parent_key' as dv_column_class
   ,coalesce (pdt.hub_key_column_name  ,pdt.link_key_column_name )  as column_name
   ,mp.property_value  as column_type
   ,false as is_nullable
 from sat_parent_table_ref sr
 join dv_pipeline_description.dvpd_pipeline_dv_table pdt   on pdt.pipeline_name = sr.pipeline_name 
 					     and pdt.table_name  =sr.parent_table
 left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='table_key_column_type'  	 					     
 union
 select -- diff_hash_column
 	pdt.pipeline_name 
   ,table_name
   ,3 as column_block
   ,'diff_hash' as dv_column_class
   ,pdt.diff_hash_column_name   as column_name
   ,mp.property_value  as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='diff_hash_column_type'  
 where pdt.stereotype in ('sat','msat') and pdt.diff_hash_column_name is not null
 union
 select -- content
 	pdt.pipeline_name 
   ,pdt.table_name
   ,8 as column_block
   ,case when pfte.exclude_from_diff_hash then 'content_untracked' else 'content' end as dv_column_class
   ,pfte.target_column_name  as column_name
   ,pfte.target_column_type 
   ,true as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte on pfte.pipeline_name = pdt.pipeline_name 
 							and pfte.target_table = pdt.table_name 
 where pdt.stereotype in ('sat','msat')
 )
 ,ref_columns as (-- <<<<<<<<<<<<<<<<<<<<<<<<< REF
 select -- meta columns
 	pipeline_name 
   ,table_name
   ,1 as column_block
   ,'meta' as dv_column_class
   ,mpmcl.meta_column_name  as column_name
   ,mpmcl.meta_column_type as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
 join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl on mpmcl.model_profile_name =pdt .model_profile_name 
			 								and( mpmcl.stereotype = 'ref' or ( mpmcl.stereotype = 'ref_hist' and pdt.is_enddated ) )
 where pdt.stereotype in ('ref')
 union 
 select -- diff_hash_column
 	pdt.pipeline_name 
   ,table_name
   ,3 as column_block
   ,'diff_hash' as dv_column_class
   ,pdt.diff_hash_column_name   as column_name
   ,mp.property_value  as column_type
   ,false as is_nullable
 from dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.DVPD_MODEL_PROFILE mp on mp.model_profile_name =pdt.model_profile_name 
 				and mp.property_name ='diff_hash_column_type' 
 where pdt.stereotype in ('ref') and pdt.is_enddated 
 union
 select -- content
 	pdt.pipeline_name 
   ,pdt.table_name
   ,8 as column_block
   ,case when pfte.exclude_from_diff_hash then 'content_untracked' else 'content' end as dv_column_class
   ,pfte.target_column_name  as column_name
   ,pfte.target_column_type 
   ,true as is_nullable
 from   dv_pipeline_description.dvpd_pipeline_dv_table pdt
 left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte on pfte.pipeline_name = pdt.pipeline_name 
 							and pfte.target_table = pdt.table_name 
 where pdt.stereotype in ('ref')
 
 )
 select * from link_columns
 union
 select * from hub_columns
 union
 select * from sat_columns
 union 
 select * from ref_columns
 
);
 
comment on view dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CORE is
 'table columns of the pipeline derived by the dvpd core implementation'; 
 
-- select * from dv_pipeline_description.DVPD_DV_MODEL_COLUMN ddmc  order by 1,2,3,4,5;