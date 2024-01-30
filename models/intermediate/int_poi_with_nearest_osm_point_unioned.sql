{{ config(materialized='table') }}

{% set departments = [
    'Dordogne',
    'Vienne',
    'Aveyron',
    "CotOr",
    'AlpMar',
    'Savoie',
    'LotGar',
    'Lot',
    'TarnGar',
    'HautPyr',
    'IlleVil',
    'Isere'
    ] %}

{% set union_sql = [] %}

{% for department in departments %}
    {% do union_sql.append("select * from " ~ ref('int_min_distances_poi_osm__' ~ department)) %}
{% endfor %}

with
    unioned as ({{ union_sql|join(' union all ') }}),
    joined as (
        select poi.* exclude (poi_point), unioned.osm_id, unioned.min_distance
        from {{ ref('int_refined__pois') }} as poi
        join unioned on poi.poi_id = unioned.poi_id
    )
select *, round(min_distance / (5000 / 60), 2) as duration
from joined
