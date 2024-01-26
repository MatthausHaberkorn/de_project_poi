```{mermaid}
flowchart TB
    subgraph  id10 [Ingestion]
    id1>datatourisme.fr]-- Extract: Download from Website AS ZipStream --> id2{{Data Loader\nPOI'S AS JSON \n Map AS CSV}}
    id3>OpenstreetMaps]-- Extract: Download -->id2
    end
    subgraph id11 [ELT_DISTRIBUTED managed by Spark]
    id4(Objectstore: Minio)-->
    id5{{Spark \n Transform POI Data}}
    end
    subgraph id14 [ELT_LOCAL managed by DBT]
    id21(Local Store Bronze)-->
    id22{{DUCKDB \n Transform POI Data}}-->
    id23(Local Store Gold\nPOI data with nearest osmnx point)
    end
    id2 -- Ingest Data to Bronze Layer --> id11
    id2 -- Manual Ingest Data to Bronze Layer --> id14
    subgraph id12 [Modeling]
    id6(GraphDB: Neo4j) --> id7[API FastAPI]
    id8(SearchDB: ElasticSearch) --> id7
    end
    id11 -- Transform POI Location Data --> id6
    id11 -- Transform POI Search Data --> id8
    id14 -- Transform POI Location Data --> id6
    id14 -- Transform POI Search Data --> id8
    id6 -- Modeling --> id6
    id8 -- Modeling --> id8
    subgraph id13 [Serving]
    id9>FrontEnd: Dash / Leaflet]
    end
    id7 --> id9
```
