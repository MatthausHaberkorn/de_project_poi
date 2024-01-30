select *
from
    (
        select
            osm_id,
            st_y(osm_point::geometry) as lat,
            st_x(osm_point::geometry) as lon,
            count(*) over (partition by osm_id) as count
        from {{ ref('stg_osm__points') }}
    ) t
where t.count > 1
