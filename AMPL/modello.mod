#dichiarazione dei set
set variet�;
set terreni;
set dipendenti;


#dichiarazione dei parametri

#resa per ogni di variet� di semente
param resa{variet�} >= 0;

#densit� ottimale per ogni variet� di semi per mq
param densit�{variet�} >= 0;

#prezzo di vendita in �/Kg per ogni variet� di radicchio
param prezzo_vendita{variet�} >= 0;

#costo in �/Kg per ogni variet� di semi acquistati
param costo_semi{variet�} >= 0;

#disponibilit� massima di semi per ogni variet�
param disponibilit�_semi{variet�} >= 0;

#dimensione in mq per ogni appezzamento di terreno
param dimensione_terreni{terreni} >= 0;

#ore necessarie a partire dal seme per avere il prodotto finale, per ogni variet�
param ore_variet�{variet�} >= 0 integer;

#ore totali annue per ogni dipendente
param ore_dipendente{dipendenti} >= 0 integer;

#salario in �/h uguale per ogni dipendente compreso di tassazione
param salario_dipendente >= 0;

#richiesta minima di radicchio per ogni variet�
param richiesta{variet�} >= 0;

#canone annuo per l'utilizzo dell'acqua
param canone_acqua >= 0;

#canone annuo base per l'utilizzo del gasolio
param canone_gasolio >= 0;

#ore massime previste per la quantit� di gasolio fornito
param ore_max_gasolio >= 0 integer;

#canone annuo per l'utilizzo di gasolio extra
param canone_gasolio_extra >= 0;

#canone annuo per la manutenzione dei macchinari
param canone_manutenzione >= 0;

#ore massime previste per rientrare nella manutenzione ordinaria
param ore_max_manutenzione >= 0 integer;

#canone annuo per la manutenzione extra dei macchinari
param canone_manutenzione_extra >= 0;

#costo fisso per l'utilizzo di prodotti chimici
param costo_prodotti_chimici >= 0;

#big M
param M = 1000000;


#dichiarazione delle variabili

#quantit� di semi per ogni variet� seminati in ogni terreno
var x{variet�, terreni} >= 0 integer;

#numero di mq di terreno seminato per ogni variet�
var t{variet�, terreni} >= 0 integer;

#1 sse la variet� viene seminata in un determinato terreno
var y{variet�, terreni} binary;

#1 sse acquisto gasolio agricolo extra
var u binary;

#1 sse ho costo per eventuale manutenzione extra
var v binary;



#funzione obiettivo

maximize profitto_finale :
(sum{i in variet�} (sum{j in terreni} x[i,j]) * prezzo_vendita[i] * resa[i]) #ricavi dalla vendita del radicchio
-(sum{i in variet�} costo_semi[i] * (sum{j in terreni} x[i,j])) #costo delle sementi
-(sum{i in dipendenti} salario_dipendente * ore_dipendente[i]) #costo del salario dei dipendenti compreso di tassazione
-(canone_gasolio + canone_gasolio_extra * u) #costo per il gasolio agricolo
- canone_acqua #canone per l'acqua
-(canone_manutenzione + canone_manutenzione_extra * v) #costo di manutenzione dei macchiari
- costo_prodotti_chimici; #costo per i prodotti chimici


#vincoli

#disponibilit� massima di semi per ogni variet�
s.t. vincolo_disponibilit�_max{i in variet�}: sum{j in terreni} x[i,j] <= disponibilit�_semi[i];

#non posso seminare sia la variet� LIN che la variet� FELTRIN
s.t. vincolo_limiti_semina{j in terreni}: y["LIN",j] + y["FELTRIN",j] <= 1;

#attivazione della variabile y prima parte
s.t. vincolo_uno_attivazione_y{i in variet�, j in terreni}: x[i,j] <= M * y[i,j];

#attivazione della variabile y seconda parte
s.t. vincolo_due_attivazione_y{i in variet�, j in terreni}: x[i,j] >= y[i,j];

#numero massimo di semi distribuibili in ogni terreno, rispetto alla densit� ottimale
s.t. vincolo_massimo_semi{i in variet�, j in terreni}: x[i,j] = densit�[i] * t[i,j];

#estensione massima del terreno coltivabile
s.t. vincolo_terreno_piantabile{j in terreni}: sum{i in variet�} t[i,j] <= dimensione_terreni[j];

#numero massimo delle ore totali dei dipendenti
s.t. vincolo_massimo_ore_dipendenti: sum{i in variet�} (sum{j in terreni} x[i,j]) * ore_variet�[i] <= sum{k in dipendenti} ore_dipendente[k];

#attivazione variabile u prima parte
s.t. vincolo_uno_attivazione_u: sum{i in variet�} (sum{j in terreni} x[i,j]) * ore_variet�[i] >= ore_max_gasolio * u;

#attivazione variabile u seconda parte
s.t. vincolo_due_attivazione_u: sum{i in variet�} (sum{j in terreni} x[i,j]) * ore_variet�[i] <= ore_max_gasolio * (1-u) + M * u;

#attivazione variabile v prima parte
s.t. vincolo_uno_attivazione_v: sum{i in variet�} (sum{j in terreni} x[i,j]) * ore_variet�[i] >= ore_max_manutenzione * v;

#attivazione variabile v seconda parte
s.t. vincolo_due_attivazione_v: sum{i in variet�} (sum{j in terreni} x[i,j]) * ore_variet�[i] <= ore_max_manutenzione * (1-v) + M * v;

#richiesta minima di radicchio per ogni variet�
s.t. vincolo_richiesta_minima{i in variet�}: resa[i] * (sum{j in terreni} x[i,j]) >= richiesta[i];
