- [&quot;Unire&quot; i poligoni di un layer con grande semplicità: è un lavoro (soltanto?) per mapshaper](#quotunirequot-i-poligoni-di-un-layer-con-grande-semplicit%c3%a0-%c3%a8-un-lavoro-soltanto-per-mapshaper)
  - [Fare l'unione dei poligoni di un layer con mapshaper](#fare-lunione-dei-poligoni-di-un-layer-con-mapshaper)
- [Altre modalità](#altre-modalit%c3%a0)
  - [GeoPandas](#geopandas)
  - [QGIS](#qgis)
  - [SQL](#sql)
- [Per concludere](#per-concludere)

# "Unire" i poligoni di un layer con grande semplicità: è un lavoro (soltanto?) per mapshaper


Quando si lavora con dati spaziali alle volte si ha come obiettivo quello di creare nuove geometrie in base a come si sovrappongono. Queste procedure sono spesso indicate usando il **linguaggio** degli **insiemi**: intersezioni, **unioni** e differenze.

Qui sotto un'immagine con alcune delle operazioni "classiche" (questa immagine e il testo introduttivo dalla [guida](http://geopandas.org/set_operations.html) di GeoPandas).

![](imgs/overlay_operations.png)

In questo articolo verrà descritta una di queste e in particolare l'**unione**. È un'operazione realizzabile in diverse modalità e con diversi strumenti, ma diventa abbastanza complessa e/o non realizzabile se l'obiettivo è:

- realizzare l'unione tra oggetti di **uno stesso *layer* di input**;
- produrre in *output* non soltanto l'unione delle geometrie, ma **unire anche gli attributi** in base alla sovrapposizione degli oggetti.

Nell'immagine di sotto un esempio: a sinistra le geometrie di *input* e a destra l'output. I perimetri delle aree fanno da "lama" di ritaglio e laddove le aree si sovrappongono devono essere trasferiti gli attributi di input (in questo esempio i valori `A`, `B` e `C`).

![](imgs/goal.png)

Un'applicazione con cui è molto semplice realizzare quanto descritto è il fantastico [**mapshaper**](https://github.com/mbloch/mapshaper). È uno  strumento scritto in JavaScript, per modificare file Shapefile, GeoJSON, TopoJSON, CSV e altri formati, molto noto per le sue eccellenti doti nella semplificazione di geometrie.<br>
È uno strumento che fa molto molto di più e questo articolo è l'occasione per mostrarne una.

## Fare l'unione dei poligoni di un layer con mapshaper

Una volta [installato](https://github.com/mbloch/mapshaper#installation) è utilizzabile o a riga di comando o tramite un'interfaccia web ([questa](https://mapshaper.org/) la versione pubblica ufficiale).

Per replicare l'operazione descritta a seguire è stato predisposto [questo file GeoJSON](https://github.com/aborruso/appunti/raw/master/bozze/unione-mapshaper/inputLayer.geojson) di input d'esempio, che ha un solo campo (`id`) ed è composto da tre poligoni (con valori di `id` pari ad `A`, `B` e `C`).

Questo è il comando tipo da lanciare da shell:

```
mapshaper -i ./inputLayer.geojson -mosaic calc='output=collect(id).toString()' -o ./output.geojson
```

Per punti:

- con `-i` si imposta il file di *input*;
- poi si imposta il comando da eseguire - [`-mosaic`](https://github.com/mbloch/mapshaper/wiki/Command-Reference#-mosaic) - che in questo caso è appunto l'unione dei poligoni;
- al comando `mosaic` si associa l'opzione [`calc`](https://github.com/mbloch/mapshaper/wiki/Command-Reference#-calc), che consente di eseguire calcoli nelle aggregazioni molti-a-uno, utilizzando espressioni JavaScript. In questo caso viene generato un nuovo campo denominato `output`, in cui vengono aggregati i valori del campo `id` nei poligoni di intersezione risultanti;
- infine si definisce con `-o` il file di output.

Nell'immagine di sotto è rappresentato il processo. Si veda ad esempio come al poligono centrale, frutto dell'interesezione geometrica di tutti e tre i poligoni di input, venga associato il valore `A,B,C`.

![](imgs/union.png)

Tantissimi i campi di applicazione di un processo come questo. I tre poligoni di questo esempio potrebbero essere gli areali "impattati" dalla diffusione di inquinanti da tra punti sorgente, oppure le aree che distano una determinata distanza da una fontanella d'acqua potabile, ecc..<br>
L'unione, con intersezione geometrica e aggregazione di attributi, consente di produrre un *output* in cui è possibile leggere per ogni area il cotributo di tutti i poligoni di `input`.

# Altre modalità

Come dicevo in apertura, tutto questo è fattibile in altre modalità, ma non mi risulta ce ne sia una così semplice in altri ambienti. A seguire qualche esempio.

## GeoPandas

[**GeoPandas**](https://geopandas.readthedocs.io/en/latest/) è un progetto *open source* per semplificare il lavoro con i dati geospaziali in Python. È una gran bella libreria!

Consente di eseguire il [processo di unione](https://geopandas.readthedocs.io/en/latest/set_operations.html) (e altri), ma di base è pensato per essere eseguito tra due *layer* distinti di *input*.<br>
A seguito di [una *issue*](https://github.com/geopandas/geopandas/issues/1116) in merito, aperta sul *repository* di progetto, è stata fornita questa risposta, in cui si evidenzia come non ci sia un modo diretto per farlo:

>[...]there is right now no direct way to do this in geopandas. You could do a "cumulative" intersection manually rather easily in a loop, but that would need some more complexity to keep track of the values.[...]

È stato per l'occasione creato un bel [*notebook*](https://nbviewer.jupyter.org/gist/jorisvandenbossche/3a55a16fda9b3c37e0fb48b1d4019e65) in cui è mostrato come sia possibile eseguire l'intersezione tra i poligoni sovrapposti; da notare la maggiore complessità e sopratutto come comunque non sia gestita l'aggregrazione molti-a-uno degli attributi (nel senso che c'è da scrivere questa parte di codice).

## QGIS

A partire dalla versione [QGIS 3.2 Bonn](https://qgis.org/it/site/forusers/visualchangelog32/) è disponibile un geoalgoritmo `Unione con un singolo strato` che svolge (quasi tutto) il compito descritto sopra, unica cosa che non fa (ma è stata una scelta dello sviluppatore e non un bug) è quella di raggruppare le geometrie e di conseguenza gli attributi.

Quindi l'`output` è di questo tipo:

id|geom
--|----
A |geomA
A |geomAB
A |geomAC
A |geomABC
B |geomB
B |geomBA
B |geomBC
B |geomBAC
C |geomC
C |geomCA
C |geomCB
C |geomCAB

Per raggruppare le geometrie e gli attributi occorre un altro passaggio oppure creare un modello grafico che trovate [qui](overlayUnion.model3); nel modello si utilizza lo snapping e la riparazione delle geometrie, servono in casi molto più complessi di quello attuale.

**NOTE**: in casi semplici (come quello di questo esempio) non occorre usare lo snap e riparare le geometrie come descritto nel modello di sopra; la query utilizzata è la seguente:

```sql
SELECT group_concat ("id") AS ID, st_union (geometry) AS geometry
FROM input1
GROUP BY geometry
```

**PS**: la tabella `input1` rappresnte l'output dell'algoritmo Unione.

quindi la tabella di `output`:

id|geom
--|----
A |geomA
B |geomB
B,A |geomBA
C |geomC
C,A |geomCA
C,B |geomCB
A,B,C |geomABC


## SQL

Non esisite una funzione **SQL** (dialect SQLite) che risolta facilmente il quesito, occorre metterci un po' di testa ed usare il metodo `Borruso`, cioè occorre analizzare step by step cosa occorre fare per raggiungere l'obiettivo, quindi occorre:

1. estrarre i perimetri dai poligoni di input;
2. estrarre i punti di intersezione dei perimetri delle varie feature;
3. aggiungere i punti alla geometria dei perimetri;
4. splittare la geometria dei perimetri;
5. poligonalizzare a partire dai perimetri splittati;
6. associare gli attributi alle varie geometrie poligonalizzate.

per importare il file `inputLayer` e creare db spatialite

```bash
# importa file inputLayer e crea file spatialite
ogr2ogr -append -t_srs EPSG:4326 -f SQLite ./dbOverlayUnion.sqlite ./inputLayer.geojson -nln "inputLayer" -dsco SPATIALITE=YES
```

[qui scriptSQL](overlayUnion.sql)

quindi la tabella di `output`:

id|geom
--|----
A |geomA
B |geomB
B,A |geomBA
C |geomC
C,A |geomCA
C,B |geomCB
A,B,C |geomABC

# Per concludere

L'autore di mapshaper è [**Matthew Bloch**](https://github.com/mbloch). È uno sviluppatore con doti al di fuore del comune, sia in termini professionali, che in termini di attitudine all'ascolto e allo scambio con gli altri.<br>
Questa modalità così semplice per eseguire questo processo di unione è stata introdotta da poco ([il 18 novembre 2019](https://github.com/mbloch/mapshaper/releases/tag/v0.4.141)), grazie a una [richiesta ricevuta](https://github.com/mbloch/mapshaper/issues/353) nel *repository* del progetto.

Un **grande grazie** a **Matthew** per quello che realizza e mette a disposizione e per il modo in cui lo fa!

