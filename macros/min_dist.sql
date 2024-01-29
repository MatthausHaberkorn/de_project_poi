{% macro min_dist(department) %}
    {% set escaped_department = department | replace("'", "''") %}
    with
        distance as (
            select osm.osm_id, poi.poi_id, st_distance(poi.poi_point, osm.osm_point) as distance
            from {{ ref('int_refined__pois') }} as poi
            join
                {{ ref('stg_osm__points') }} as osm
                on poi.poi_location_department = osm.osm_department
            where poi.poi_location_department = '{{ escaped_department }}'
        ),
        ranked_distances as (
            select
                osm_id,
                poi_id,
                distance as min_distance,
                row_number() over (partition by poi_id order by distance) as rank
            from distance
            qualify rank = 1
        )
    select *
    from ranked_distances
{% endmacro %}
