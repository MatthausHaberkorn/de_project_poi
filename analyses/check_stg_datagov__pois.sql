with
    dup_ids as (
        select
            *, count(*) over (partition by poi_id, poi_label_en, poi_label_fr) as count
        from {{ ref('stg_datagov__pois') }}
        qualify count > 1
    )

select *
from dup_ids
