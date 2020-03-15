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
param prezzo{variet�} >= 0;

#costo in �/Kg per ogni variet� di semi acquistati
param costo{variet�} >= 0;

#disponibilit� massima di semi per ogni variet�
param disponibilit�{variet�} >= 0;

#dimensione in mq per ogni appezzamento di terreno
param dimensione{terreni} >= 0;

#incremento in % fornito dall'utilizzo di fertilizzante per ogni variet�
param incremento{variet�} >= 0;

#ore annue per ogni dipendente
param ore_dipendente{dipendenti} >= 0 integer;

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

#costo del fertilizzante
param costo_fertilizzante >= 0;

#salario annuo uguale per ogni dipendente compreso di tassazione
param salario_dipendente >= 0;

#costo straordinaro per ogni dipendente
param straordinario_dipendente >= 0;

#ore straordinario uguali per ogni dipendente
param ore_straordinario_dipendente >= 0 integer;

#big M
param M = 1000000;


#dichiarazione delle variabili

#quantit� di semi per ogni variet� seminati in ogni terreno
var x{variet�, terreni} >= 0 integer;

#1 sse la variet� viene seminata in un determinato terreno
var y{variet�, terreni} binary;

#1 sse uso il fertilizzante sulla variet�
var z{variet�} binary;

#1 sse il dipendente fa gli straordinari
var w{dipendenti} binary;

#1 sse acquisto gasolio agricolo extra
var u binary;

#1 sse ho costo per eventuale manutenzione extra
var v binary;



#funzione obiettivo

maximize profitto_finale :
#ricavi dalla vendita del radicchio
(sum{i in variet�, j in terreni} x[i,j] * prezzo[i] * (resa[i] + incremento[i] * resa[i] * z[i]))
#(sum{i in variet�} (sum{j in terreni} x[i,j]) * prezzo[i] * (resa[i] + incremento[i] * resa[i] * z[i]))



-(sum{i in variet�, j in terreni} costo[i] * x[i,j]) #costo delle sementi
-(sum{i in variet�} costo_fertilizzante * z[i]) #costo per il fertilizzante
-(sum{i in dipendenti} salario_dipendente) #costo del salario dei dipendenti compreso di tassazione
-(sum{i in dipendenti} straordinario_dipendente* w[i]) #costo degli straordinari dei dipendenti
-(canone_gasolio + canone_gasolio_extra * u) #costo per il gasolio agricolo
- canone_acqua #canone per l'acqua
-(canone_manutenzione + canone_manutenzione_extra * v); #costo di manutenzione dei macchiari


#vincoli

#disponibilit� massima di semi per ogni variet�
s.t. vincolo_disponibilit�_max{i in variet�}: sum{j in terreni} x[i,j] <= disponibilit�[i];

#non posso seminare sia la variet� LIN che la variet� FELTRIN
s.t. vincolo_limiti_semina{i in variet�, j in terreni}: y["LIN",j] + y["FELTRIN",j] <= 1;

#attivazione della variabile y
s.t. vincolo_attivazione_y{i in variet�, j in terreni}: x[i,j] <= M * y[i,j];

#numero massimo di semi per ogni terreno per ogni variet�??
s.t. vincolo_massimo_semi{i in variet�, j in terreni}: x[i,j] <= densit�[i] * dimensione[j];

#utilizzo del fertilizzante
s.t. vincolo_fertilizzante: sum{i in variet�} z[i] <= 1;

#numero massimo delle ore totali dei dipendenti
s.t. vincolo_massimo_ore_dipendenti: sum{i in variet�, j in terreni} x[i,j] <= sum{k in dipendenti} (ore_dipendente[k] + ore_straordinario_dipendente * w[k]);

#numero massimo di dipendenti che possono fare gli straordinari
s.t. vincolo_massimo_straordinari: sum{i in dipendenti} w[i] <= 4;

#attivazione variabile u
s.t. vincolo_attivazione_u: sum{i in variet�, j in terreni} x[i,j] >= ore_max_gasolio * u;

#attivazione variabile v
s.t. vincolo_attivazione_v: sum{i in variet�, j in terreni} x[i,j] >= ore_max_manutenzione * v;

#richiesta minima di radicchio per ogni variet�
s.t. vincolo_richiesta_minima{i in variet�}: (resa[i] + resa[i] * incremento[i] * z[i]) * sum{j in terreni} x[i,j] >= richiesta[i];

#VALORI SPURI??
