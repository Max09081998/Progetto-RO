#dichiarazione dei set
set varietà;
set terreni;
set dipendenti;


#dichiarazione dei parametri

#resa per ogni di varietà di semente
param resa{varietà};

#densità ottimale per ogni varietà di semi per mq
param densità{varietà};

#prezzo di vendita in €/Kg per ogni varietà di radicchio
param prezzo{varietà};

#costo in €/Kg per ogni varietà di semi acquistati
param costo{varietà};

#disponibilità massima di semi per ogni varietà
param disponibilità{varietà};

#dimensione in mq per ogni appezzamento di terreno
param dimensione{terreni};

#incremento in % dato dall'utilizzo di fertilizzante per ogni varietà
param incremento{varietà};

#ore lavorative per ogni dipendente
param ore_lavorative{dipendenti};

#richiesta minima di radicchio per ogni varietà
param richiesta{varietà};

#canone per l'utilizzo dell'acqua
param canone_acqua > 0;

#canone per l'utilizzo del gasolio
param canone_gasolio > 0;

#ore massime previste per la quantità di gasolio fornito
param ore_max_gasolio > 0 integer;

#canone per l'utilizzo di gasolio extra
param canone_gasolio_extra > 0;

#canone per la manutenzione dei macchinari
param canone_manutenzione > 0;

#ore massime previste per rientrare nella manutenzione ordinaria
param ore_max_manutenzione > 0 integer;

#canone per la manutenzione extra dei macchinari
param canone_manutenzione_extra > 0;

#costo del fertilizzante
param costo_fertilizzante > 0;

#salario annuo uguale per ogni dipendente compreso di tassazione
param salario_dipendente > 0;

#ore annue uguali per ogni dipendente
param ore_dipendente > 0 integer;

#costo straordinaro per ogni dipendente
param straordinario_dipendente > 0;

#ore straordinario uguali per ogni dipendente
param ore_straordinario_dipendente > 0 integer;

#big M
param M = 1000000;


#dichiarazione delle variabili

#quantità di semi per ogni varietà seminati in ogni terreno
var x{varietà, terreni} integer >= 0;

#1 sse la varietà viene seminata in un determinato terreno
var y{varietà, terreni} binary;

#1 sse uso il fertilizzante sulla varietà
var z{varietà} binary;

#1 sse il dipendente fa gli straordinari
var w{dipendenti} binary;

#1 sse acquisto gasolio agricolo extra
var u binary;

#1 sse ho costo per eventuale manutenzione extra
var v binary;



#funzione obiettivo

maximize profitto_finale :
#ricavi dalla vendita
(sum{i in varietà, j in terreni} x[i,j] * prezzo[i] * (resa[i] + incremento[i] * resa[i] * z[i]))
(sum{i in varietà} (sum{j in terreni} x[i,j]) * prezzo[i] * (resa[i] + incremento[i] * resa[i] * z[i]))



-(sum{i in varietà} costo[i] * (sum{j in terreni} x[i,j])) #costo delle sementi
-(sum{i in varietà} costo_fertilizzante * z[i]) #costo per il fertilizzante
-(sum{i in dipendenti} salario_dipendente) #costo del salario dei dipendenti compreso di tassazione
-(sum{i in dipendenti} straordinario_dipendente* w[i]) #costo degli straordinari dei dipendenti
-(canone_gasolio + canone_gasolio_extra * u) #costo del gasolio
- canone_acqua
-(canone_manutenzione + canone_manutenzione_extra * v); #costo di manutenzione dei mezzi


#vincoli

#disponibilità massima di semi per ogni varietà
s.t. vincolo_disponibilità_max{i in varietà}: sum{j in terreni} x[i,j] <= disponibilità[i];

#non posso seminare sia la varietà LIN che la varietà 
s.t. vincolo_limiti_semina{i in varietà, j in terreni}: y["LIN",j] + y["FELTRIN",j] <= 1;

#attivazione della variabile y
s.t. vincolo_attivazione_y{i in varietà. j in terreni}: x[i,j] <= M * y[i,j];

#numero massimo di semi per ogni campo per ogni varietà
s.t. vincolo_massimo_semi{i in varietà, j in terreni}: x[i,j] <= densità[i] * dimensione[j];

#utilizzo del fertilizzante
s.t. vincolo_fertilizzante: sum{i in varietà}: z[i] <= 1;

#numero massimo delle ore totali dei dipendenti
s.t. vincolo_massimo_ore_dipendenti: sum{i in varietà, j in terreni} x[i,j] <= sum{k in dipendenti} (ore_dipendente + ore_straordinario_dipendente*w[k]);

#numero massimo di dipendenti che possono fare gli straordinari
s.t. vincolo_massimo_straordinari: sum{i in dipendenti} w[i] <= 4;

#attivazione variabile u
s.t. vincolo_attivazione_u: sum{i in varietà, j in terreni} x[i,j] >= ore_max_gasolio * u;

#attivazione variabile v
s.t. vincolo_attivazione_v: sum{i in varietà, j in terreni} x[i,j] >= ore_max_manutenzione * v;

#richiesta minima di radicchio per ogni varietà
s.t. vincolo_richiesta_minima{i in varietà}: (resa[i] + resa[i] * incremento[i] * z[i]) * sum{j in terreni} x[i,j] >= richiesta[i];

#VALORI SPURI??
