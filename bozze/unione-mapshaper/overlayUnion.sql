--
-- algoritmo proiezioni, the Spatialite way
-- di Salvatore Fiandaca
-- e-mail: pigrecoinfinito@gmail.com
--

-- crea geotabella perimetri dei poligoni di input
SELECT DropGeoTable( "perimetri");
create table "perimetri" AS
select id, CastToMulti(st_boundary(geometry)) as geom
from inputLayer;
SELECT RecoverGeometryColumn('perimetri','geom',4326,'MULTILINESTRING','XY');

-- crea geotabella con i punti di intersezione tra i vari perimetri
SELECT DropGeoTable( "points_intersects");
create table "points_intersects" AS
select a.id, st_intersection(a.geom,b.geom)  as geom
from perimetri a, perimetri b
where st_intersects(a.geom,b.geom) = 1 and a.id != b.id;
SELECT RecoverGeometryColumn('points_intersects','geom',4326,'MULTIPOINT','XY');

-- crea geotabella dalle componenti elementari della geotabella points_intersects
SELECT DropGeoTable('points_split');
SELECT ElementaryGeometries( 'points_intersects' ,
                             'geom' , 'points_split' ,'out_pk' , 'out_multi_id', 1 ) as num, 'lines splitted' as label;
							 

-- aggiorna geotabella 'perimetri' aggiunge nodi alla geometria
UPDATE "perimetri" SET geom=
    CastToMulti(
                RemoveRepeatedPoints(
                                    ST_Snap( 
                                            "perimetri".geom,
                                            (SELECT CastToMultipoint(st_collect(b.geom)) 
                                            FROM "points_split" as b
                                            WHERE b."id" = "perimetri"."id"
                                            GROUP BY b."id") , 0.01 
                                            ), 0.01 
                                    )
                ) 
WHERE EXISTS(
            SELECT 1 FROM "points_split" as b
            WHERE  b."id" = "perimetri"."id" limit 1
            );

-- aggiorna la geotabella 'perimetri' splitta le geometrie
UPDATE "perimetri" SET geom=
    CastToMulti(
                ST_Split(
                        "perimetri".geom,
                        (SELECT CastToMultiPoint(st_collect(b.geom)) 
                        FROM "points_split" as b
                        WHERE  b."id" = "perimetri"."id"
                        GROUP BY b."id")
                        )
                )
WHERE EXISTS(
            SELECT 1 FROM "points_split" as b
            WHERE  b."id" = "perimetri"."id" limit 1
            );
			
-- crea geotabella dalle componenti elementari della geotabella perimetri
SELECT DropGeoTable('perimetri_split');
SELECT ElementaryGeometries( 'perimetri' ,
                             'geom' , 'perimetri_split' ,'out_pk' , 'out_multi_id', 1 ) as num, 'lines splitted' as label;

-- crea geotabella poligoni							 
SELECT DropGeoTable( "polygonize");
create table polygonize AS
select st_polygonize(geom) as geom
from perimetri_split;
SELECT RecoverGeometryColumn('polygonize','geom',4326,'MULTIPOLYGON','XY');

-- crea geotabella dalle componenti elementari della geotabella polygonize
SELECT DropGeoTable('elementi');
SELECT ElementaryGeometries( 'polygonize' ,
                             'geom' , 'elementi' ,'out_pk' , 'out_multi_id', 1 ) as num, 'polygon splitted' as label;

-- crea poligoni di output con attributi
SELECT DropGeoTable( "OUTPUT");
CREATE TABLE OUTPUT AS
SELECT Group_Concat(id) as id, e.geom
FROM inputLayer p, elementi e
where st_intersects (ST_PointOnSurface(e.geom), p.geom) = 1
GROUP BY e.geom;
SELECT RecoverGeometryColumn('OUTPUT','geom',4326,'POLYGON','XY');

-- calcella le geotabelle inutili
SELECT DropGeoTable('elementi');
SELECT DropGeoTable('perimetri');
SELECT DropGeoTable('perimetri_split');
SELECT DropGeoTable('points_intersects');
SELECT DropGeoTable('points_split');
SELECT DropGeoTable('polygonize');

--
-- aggiorna statistiche e VACUUM
--
UPDATE geometry_columns_statistics set last_verified = 0;
SELECT UpdateLayerStatistics('geometry_table_name');
VACUUM;
 

							 