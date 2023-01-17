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


--drop view if exists dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES as 

with normalized_declared_properties as (
select 
 lower(epdtp.pipeline_name) as pipeline_name 
, lower(epdtp.table_name) as table_name
, upper(case when pdt.stereotype ='xenc_hub-ek' 
		then coalesce(xenc_content_hash_column_name,'bkh_'||pdt.table_name)
      when pdt.stereotype ='xenc_lnk-ek' 
		then coalesce(xenc_content_hash_column_name,'dch_'||pdt.table_name)
		else null end)  as xenc_content_hash_column_name
, upper(case when pdt.stereotype ='xenc_hub-ek' 
		then coalesce(xenc_content_salted_hash_column_name,'bkh_'||pdt.table_name||'_st')
      when pdt.stereotype ='xenc_lnk-ek' 
		then coalesce(xenc_content_salted_hash_column_name,'dch_'||pdt.table_name||'_st')
		else null end)	as xenc_content_salted_hash_column_name
, lower(xenc_content_table_name) as xenc_content_table_name
, upper(coalesce(xenc_encryption_key_column_name,'EK_'||cpdt.table_name )) as xenc_encryption_key_column_name
, upper(case when pdt.stereotype in ('xenc_sat-ek','xenc_msat-ek')  
		then  coalesce(xenc_encryption_key_index_column_name,'EKI_'||cpdt.table_name )
		else null end) as xenc_encryption_key_index_column_name
, coalesce(pdt.diff_hash_column_name ,cpdt.diff_hash_column_name ) as xenc_diff_hash_column_name
, upper(coalesce(xenc_table_key_column_name, 
			case when pdt.stereotype = 'xenc_hub-ek' then cpdt.hub_key_column_name 
				 when pdt.stereotype = 'xenc_lnk-ek' then cpdt.link_key_column_name
				 when pdt.stereotype in ('xenc_sat-ek','xenc_msat-ek') then coalesce(pcpdt.hub_key_column_name ,pcpdt.link_key_column_name )
				 end
				 )) as xenc_table_key_column_name
from dv_pipeline_description.xenc_pipeline_dv_table_properties_raw epdtp
join  dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name  
															 and pdt.table_name = epdtp.table_name 
left join  dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = epdtp.pipeline_name  
															 and cpdt.table_name = epdtp.xenc_content_table_name 
left join dv_pipeline_description.dvpd_pipeline_dv_table pcpdt on pcpdt.pipeline_name = cpdt.pipeline_name 
														and pcpdt.table_name = cpdt.satellite_parent_table														 
)
,default_content_table_properties as (
select 
	ndp.pipeline_name
	,ndp.xenc_content_table_name as table_name 
	, null::text as xenc_content_hash_column_name
	, null::text as xenc_content_salted_hash_column_name
	, null::text as xenc_content_table_name
	, null::text as xenc_encryption_key_column_name
	, xenc_encryption_key_index_column_name
	, null::text as xenc_diff_hash_column_name
	, null::text as xenc_table_key_column_name
from normalized_declared_properties ndp
left join  dv_pipeline_description.dvpd_pipeline_dv_table cpdt on cpdt.pipeline_name = ndp.pipeline_name  
															 and cpdt.table_name = ndp.xenc_content_table_name 
where xenc_content_table_name not in (Select table_name from normalized_declared_properties)
and cpdt.stereotype in ('sat','msat')
)
-- final select
select * from normalized_declared_properties
union
select * from default_content_table_properties
;

comment on view dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES is
 '[Encryption Extention] All encryption specific table properties ';

-- select * from dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES ;