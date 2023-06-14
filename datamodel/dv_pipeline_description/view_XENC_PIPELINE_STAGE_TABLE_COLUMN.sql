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


--drop view if exists dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN as

with  pipeline_model_profile AS (
select distinct pipeline_name ,model_profile_name
from dv_pipeline_description.dvpd_pipeline_dv_table
)
,pipelines as (
select distinct epdtp.pipeline_name, pmp.model_profile_name 
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name 
left join pipeline_model_profile pmp on pmp.pipeline_name= epdtp.pipeline_name 
where table_stereotype like 'xenc%'
)
select distinct 
	pipeline_name 
	,stage_column_name
	,column_type 
	,min(column_block) column_block
	,false is_meta
	,content_stage_hash_column
	,content_table_name
from  dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping
where column_class not in ('meta')
group by 1,2,3,5,6,7
union 
select
	pp.pipeline_name 
	,mpmcl.meta_column_name 
	,mpmcl.meta_column_type 
	, 1
	,true is_meta
	,null content_stage_hash_column 
	,null content_table_name 
from pipelines pp
left join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl 
										on mpmcl.model_profile_name = pp.model_profile_name
									and mpmcl.table_stereotype ='_xenc_stg-ek' ;


comment on view dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN is
 '[Encryption Extention] All columns, needed to stage columns of the encryption key store';
														 
-- select * from dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN order by pipeline_name,column_block ,stage_column_name 										