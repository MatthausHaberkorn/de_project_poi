{{ config(materialized='table') }}


with
    extracted as (
        select
            "dc:identifier" as id,
            "rdfs:label" ->> ['$.en[0]', '$.fr[0]'] as label_list,
            "rdfs:comment" ->> '$.en[0]' as comment,
            "hasDescription" ->> [
                '$[0].shortDescription.en[0]', '$[0]."dc:description".en[0]'
            ] as description_list,
            "isLocatedAt" ->> [
                '$[0]."schema:address"[0]."schema:addressLocality"',
                '$[0]."schema:address"[0]."schema:postalCode"',
                '$[0]."schema:address"[0]."schema:streetAddress"[0]',
                '$[0]."schema:address"[0].hasAddressCity.isPartOfDepartment."rdfs:label".en[0]',
                '$[0]."schema:geo"."schema:latitude"',
                '$[0]."schema:geo"."schema:longitude"'
            ] as location_list,
            "hasReview" ->> '$[0].hasReviewValue."schema:ratingValue"' as rating,
            "hasFeature" ->> [
                '$[0].features[0]."rdfs:label".en[0]',
                '$[0].features[1]."rdfs:label".en[0]',
                '$[0].features[2]."rdfs:label".en[0]',
                '$[0].features[3]."rdfs:label".en[0]'
            ] as feature_list
        from
            read_json(
                'seeds1/*.json',
                columns = {
                    'dc:identifier':'VARCHAR',
                    'rdfs:comment':'STRUCT(en VARCHAR[])',
                    'rdfs:label':'STRUCT(en VARCHAR[], fr VARCHAR[])',
                    'hasDescription':'STRUCT(shortDescription STRUCT(en VARCHAR[]), "dc:description" STRUCT(en VARCHAR[]))[]',
                    'isLocatedAt':'STRUCT("schema:address" STRUCT("schema:addressLocality" VARCHAR, "schema:postalCode" VARCHAR, "schema:streetAddress" VARCHAR[], hasAddressCity STRUCT("rdfs:label" STRUCT(en VARCHAR[]), "isPartOfDepartment" STRUCT("rdfs:label" STRUCT(en VARCHAR[]))))[], "schema:geo" STRUCT("schema:latitude" VARCHAR, "schema:longitude" VARCHAR, "@type" VARCHAR[], "schema:elevation" VARCHAR),  "@type" VARCHAR[], petsAllowed BOOLEAN, altInsee VARCHAR[], internetAccess BOOLEAN, airConditioning BOOLEAN, noSmoking BOOLEAN)[]',
                    'hasReview':'STRUCT(hasReviewValue STRUCT("@id" VARCHAR, "@type" VARCHAR[], "rdfs:label" STRUCT(en VARCHAR[]), isCompliantWith VARCHAR[], "schema:ratingValue" VARCHAR), reviewDeliveryDate DATE)[]',
                    'hasArchitectualStyle':'STRUCT("@type" VARCHAR[], "rdfs:label" STRUCT(en VARCHAR[]))[]',
                    'hasFeature':'STRUCT(features STRUCT("@type" VARCHAR[], "rdfs:label" STRUCT(en VARCHAR[]))[])[]'
                },
                format = 'auto'
            )

    )
select
    id as poi_id,
    comment as poi_comment,
    label_list[1] as poi_label_en,
    label_list[2] as poi_label_fr,
    description_list[1] as poi_short_description,
    description_list[2] as poi_long_description,
    location_list[1] as poi_location_name,
    location_list[2] as poi_location_postal_code,
    location_list[3] as poi_location_street,
    location_list[5] as poi_location_latitude,
    location_list[6] as poi_location_longitude,
    location_list[4] as poi_location_department,
    rating as poi_rating,
    concat_ws(
        ', ',
        trim(feature_list[1], ' ,'),
        trim(feature_list[2], ' ,'),
        trim(feature_list[3], ' ,'),
        trim(feature_list[4], ' ,')
    ) as poi_features,
from extracted
