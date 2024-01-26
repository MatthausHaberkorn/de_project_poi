{{ config(materialized='table') }}

with osm as (select * from 'seeds1/osm.parquet')
select
    osmid,
    st_transform(st_point(y, x), 'EPSG:4326', 'EPSG:3857') as node,
    location_department as department
from osm
