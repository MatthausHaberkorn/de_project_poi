{{ config(materialized='table') }}

with osm as (select * from 'seeds1/osm.parquet')
select
    osmid as osm_id,
    st_transform(st_point(y, x), 'EPSG:4326', 'EPSG:3857') as osm_point,
    location_department as osm_department
from osm
