{{ config(materialized='table') }}
with
    raw_data as (
        select
            id,
            location_department,
            coalesce(long_description, short_description, comment) as poi_description,
            coalesce(label_en, label_fr) as label,
            location_name,
            cast(location_postal_code as integer) as location_postal_code,
            location_street,
            cast(location_longitude as double precision) as location_longitude,
            cast(location_latitude as double precision) as location_latitude,
            rating,
            features,
        from {{ ref('stg_datagov__pois') }}
        where
            (location_latitude is not null and location_latitude != '')
            and (location_longitude is not null and location_longitude != '')

        qualify
            row_number() over (
                partition by location_latitude, location_longitude, label order by id
            )
            = 1

    )

select
    id,
    poi_description,
    label,
    location_department,
    location_name,
    location_postal_code,
    location_street,
    location_longitude,
    location_latitude,
    rating,
    features,
    st_transform(
        st_point(location_latitude, location_longitude), 'EPSG:4326', 'EPSG:3857'
    ) as node
from raw_data
