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


--drop view if exists dv_pipeline_description.DVPD_DV_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_DV_LINK_PARENT as 

SELECT
	DISTINCT 
 	table_name,
	link_parent_table,
	case when relation_name not in ('/','*') then hub_key_column_name||'_'||relation_name 
			else hub_key_column_name end hub_key_column_name_in_link,
	relation_name
FROM
	dv_pipeline_description.dvpd_pipeline_dv_table_link_parent;


comment on view dv_pipeline_description.DVPD_DV_LINK_PARENT is
 'Link parents in the dv model';

-- select * From dv_pipeline_description.DVPD_DV_LINK_PARENT;


