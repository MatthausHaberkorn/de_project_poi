{{ config(materialized='table') }}

{% set departments = [
    'Dordogne',
    'Vienne',
    'Aveyron',
    "Côte-d'Or",
    'Alpes-Maritimes',
    'Savoie',
    'Lot-et-Garonne',
    'Lot',
    'Tarn-et-Garonne',
    'Hautes-Pyrénées',
    'Ille-et-Vilaine',
    'Isère'
    ] %}

{% set union_sql = [] %}

{% for department in departments %}
    {% do union_sql.append("select * from " ~ ref('int_min_distances_poi_osm__' ~ department)) %}
{% endfor %}

with unioned as (
    {{ union_sql|join(' union all ') }}
),
joined as (
    select poi.* exclude (node), unioned.osmid, unioned.min_distance
    from {{ref('int_refined__pois')}} as poi
    join unioned on poi.id = unioned.poi_id
)
select * from joined



