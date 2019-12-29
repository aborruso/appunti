# QGIS: generare un atlante basato su campi

L'**atlante** di **QGIS** consente di creare in modo automatico delle pubblicazioni cartografiche multipagina. Proprio come i meravigliosi atlanti del tempo della **scuola** (in cui ci si perdeva letteralmente dentro, specie "noi di quando non c'era l'internèt").

![](imgs/atlante.jpg)

Ci sono tanti tutorial sul come farne uno e non replicherò. Documenterò però una modalità un po' atipica, ma a mio avviso di grande utilità. Tutto nasce da questo messaggio ricevuto qualche giorno fa:

> *Borruso, sei la mia ultima speranza, stile Obi Wan. Posso chiederti una domanda QGIS? :)
Sto cercando di capire se mi stia sfuggendo qualcosa di ovvio sulla generazione di un Atlas [...]. Ho un dataset che mostra le precipitazione storiche in UK in termini di decili, per mostrare quando le precipitazioni sono state fuori dal comune.[...]<br>
Posso trasporlo, splittare le coordinate (in easting, northing), etc... ma faccio fatica a pensare a una struttura che sia compatibile con Atlas per cui possa alla fine ottenere una mappa per anno*

![](imgs/dataset.jpg)

A partire da un dataset come quello soprastante si vuole realizzare un **atlante** con una pagina per anno, senza cambiare l'area geografica. Quindi **per oguna** si farà **riferimento** a un **diverso campo**, a una diversa fonte dati.<br>
Mentre di solito la variazione di pagina è in base alle righe (ad esempio un cambio di nome nella colonna "nome regione"), con taglio geografico diverso per ognuna.

L'obiettivo è quindi ottenere qualcosa come quella di sotto (le `n` pagine corrispondenti agli anni dei dati sorgente).

![](imgs/griglia.png)

## Come creare l'atlante

Il punto di partenza è quello di caricare i layer cartografici di base. Nell'esempio creato per descrivere la procedura faccio uso soltanto di un [file CSV](./atlante/decilesNE.csv) (denominato `decilesNE.csv`), con una struttura come quella dell'immagine soprastante, più due colonne con le coordinate.<br>
Una volta aggiunto, formatto il layer sfruttando i valori di una delle colonne `year...`, che contengono valori da `0` a `9`. <br>
Sono **dieci classi** a cui associo dei toni dal bianco al blu, al passaggio da `0` a `9`. Si tratta di punti che rappresentano un quadrato di 5 chilometri e gli assocerò pertanto un simbolo quadrato di 5 km di lato.

![](imgs/qgis-atlas-color-settings.png)

Per poter **paginare per anno** devo avere un layer con i valori **distinti per anno**, ma **disposti in righe**. Basta quindi trasporre la riga con il nome delle colonne del file di input e ottenere un CSV come [questo](./atlante/at.csv) (che ho chiamato `at.csv`).<br>
Una volta creato si dovrà aggiunge al progetto.

Si potrà procedere quindi all'attivazione dell'atlante, iniziando dal creare un nuovo *layout* e poi attivando la **generazione** dell'atlante.<br>
Due i paramentri importanti in questa fase:

1. quale *layer* sarà il layer che farà da `coverage`, ovvero quale comanderà il cambio pagina. Per questo progetto sarà `at`;
2. quale campo utilizzare per ordinare le pagine. Sarà `item`, l'unico del file `at.csv`, che contiene l'elenco dei nomi delle colonne (che corrispondono agli anni).

![](imgs/atlasSetting.png)

In questo modo QGIS sa come paginare (vedi sotto).

![](imgs/pagine.png)

Rimane però un **PROBLEMA**: come fare in modo che al cambio pagina la **formattazione** della **mappa** sia **basata** sul **campo** **corrispondente** all'**anno selezionato**?

Al momento la formattazione è basata su una delle colonne del *layer*. Quindi **al cambio pagina non varierà**.<br>
QGIS espone alcune **variabili** legate agli atlanti, una è denominata [`@atlas_pagename`](http://hfcqgis.opendatasicilia.it/it/latest/gr_funzioni/variabili/README.html) e contiene il valore del nome della **pagina corrente**.<br>
Quindi basterebbe usare questa variabile al posto del nome della colonna, e fare in modo che vari al cambio di pagina.

Per farlo bisogna aprire il pannello di formattazione del layer e sostituire il nome del campo con l'espressione `eval(@atlas_pagename)` (vedi sotto). <br>
Si usa la funzione [`eval`](http://hfcqgis.opendatasicilia.it/it/latest/gr_funzioni/generale/eval.html) per fare in modo che il valore della variabile (ad esempio `year1958`) sia mappato come nome campo e non come una stringa.

![](imgs/attivareFormattazioneCambioPagina.png)

A questo punto si potrà esportare l'atlante in `PDF`, in `SVG` e in `PNG`.

Ho creato una [copia del file progetto](./atlante/atlante.zip), con le risorse correlate, in modo che sia possibile testare il tutto in autonomia.<br>
**NOTA BENE**: all'apertura del progetto il *layer* non sarà visualizzato, perché l'atlante non è attivo e quindi QGIS non sa quale sia la pagina e quindi il campo da usare per formattare il layer. Quindi una volta aperto il progetto, si dovrà aprire il layout e attivare l'anteprima dell'atlante.
