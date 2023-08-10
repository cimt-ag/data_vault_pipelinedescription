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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CVIEW cascade;
--drop table if exists dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN;

create or replace  view dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CVIEW as (
 select * from dv_pipeline_description.dvpd_pipeline_dv_column_core
-- union
-- select * from dv_pipeline_description.xenc_pipeline_dv_column
);

create or replace table dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN as select * from dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN_CVIEW;

comment on table dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN is
 'All table columns of the pipeline'; 
-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN ddmc  order by 1,2,3,4,5;