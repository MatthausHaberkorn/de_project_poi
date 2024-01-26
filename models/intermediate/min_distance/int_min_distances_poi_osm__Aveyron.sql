-- depends_on: {{ ref('stg_osm__points') }}
-- depends_on: {{ ref('int_refined__pois') }}

{{ config(materialized='table') }}

{{ min_dist('Aveyron') }}


