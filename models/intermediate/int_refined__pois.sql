{{ config(materialized='table') }}
with
    raw_data as (
        select
            poi_id,
            poi_location_department,
            coalesce(
                poi_long_description, poi_short_description, poi_comment
            ) as poi_description,
            coalesce(poi_label_en, poi_label_fr) as poi_label,
            poi_location_name,
            cast(poi_location_postal_code as integer) as poi_location_postal_code,
            poi_location_street,
            cast(poi_location_longitude as double precision) as poi_location_longitude,
            cast(poi_location_latitude as double precision) as poi_location_latitude,
            poi_rating,
            poi_features,
            poi_types,
        from {{ ref('stg_datagov__pois') }}
        where
            (poi_location_latitude is not null and poi_location_latitude != '')
            and (poi_location_longitude is not null and poi_location_longitude != '')

        qualify
            row_number() over (
                partition by poi_location_latitude, poi_location_longitude, poi_label
                order by poi_id
            )
            = 1

    )

select
    poi_id,
    poi_types,
    poi_description,
    poi_label,
    poi_location_department,
    poi_location_name,
    poi_location_postal_code,
    poi_location_street,
    poi_location_longitude,
    poi_location_latitude,
    poi_rating,
    poi_features,
    st_transform(
        st_point(poi_location_latitude, poi_location_longitude),
        'EPSG:4326',
        'EPSG:3857'
    ) as poi_point
from raw_data
