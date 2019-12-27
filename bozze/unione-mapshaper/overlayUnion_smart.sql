--
-- algoritmo proiezioni, the Spatialite way
-- di Salvatore Fiandaca
-- e-mail: pigrecoinfinito@gmail.com
-- è stato di aiuto: http://blog.cleverelephant.ca/2019/07/postgis-overlays.html

-- crea geotabella polygonize
CREATE TABLE polygonize AS
SELECT St_Polygonize(t.geom) as geom
FROM
(
SELECT id, St_Union(st_boundary(geometry)) as geom
FROM inputLayer) t;
SELECT RecoverGeometryColumn('polygonize','geom',4326,'MULTIPOLYGON','XY');

-- crea geotabella dalle componenti elementari della geotabella polygonize
SELECT DropGeoTable('elementi');
SELECT ElementaryGeometries( 'elementi' ,
                             'geom' , 'polygonize' ,'out_pk' , 'out_multi_id', 1 ) as num, 'polygon splitted' as label;

-- crea poligoni di output con attributi
SELECT DropGeoTable( "OUTPUT");
CREATE TABLE OUTPUT AS
SELECT Group_Concat(id) as id, e.geom
FROM inputLayer p, elementi e
where st_intersects (ST_PointOnSurface(e.geom), p.geom) = 1
GROUP BY e.geom;
SELECT RecoverGeometryColumn('OUTPUT','geom',4326,'POLYGON','XY');

--
-- aggiorna statistiche e VACUUM
--
UPDATE geometry_columns_statistics set last_verified = 0;
SELECT UpdateLayerStatistics('geometry_table_name');
VACUUM;