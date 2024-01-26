{% macro min_dist(department) %}
    {% set escaped_department = department | replace("'", "''") %}
    with
        distance as (
            select osm.osmid, poi.id, st_distance(poi.node, osm.node) as distance
            from {{ ref('int_refined__pois') }} as poi
            join
                {{ ref('stg_osm__points') }} as osm
                on poi.location_department = osm.department
            where poi.location_department = '{{ escaped_department }}'
        ),
        ranked_distances as (
            select
                osmid,
                id as poi_id,
                distance as min_distance,
                row_number() over (partition by id order by distance) as rank
            from distance
            qualify rank = 1
        )
    select *
    from ranked_distances
{% endmacro %}
