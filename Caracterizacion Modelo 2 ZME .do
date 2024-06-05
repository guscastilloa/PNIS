/*
DESCRIPCIÓN:
	En este script se busca hacer la caracterización de la muestra que recibió 
	SA y se encuentra en ZME, que corresponde a 373 CUBs. 
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"
use "${datafolder}/base_estimaciones_simci.dta", clear
capture label define lzme 1 "En ZME" 0 "No ZME"
label values zme lzme


* Crear variable para identificar CUBs de interés
tab year_t_SA_AAI ejecucion_PNIS if (ejecucion_PNIS ==2) ///
	& year==2017 & zme==1
	
gen bandera=1 if ejecucion_PNIS==2 & year==2017 & zme==1

* Revisando en qué ZME están ubicados
tab zona_zme if bandera==1

* Revisando municipios y departamentos
capture drop mpio_cnmbr_d
egen mpio_cnmbr_d = concat(mpio_cnmbr dpto_cnmbr), punct(", ")

estpost tab mpio_cnmbr_d zona_zme if bandera==1 //, rowsort
esttab using "${projectfolder}/Output/Modelos Coca/tablas/caracterizacion_zme_municipio.csv", ///
	replace cells("b" "pct(fmt(2) par)") ///
	wide unstack compress nonum noobs ///
	note("Porcentaje en paréntesis") varlabels(`e(labels)')


estpost tab mpio_cnmbr_d zona_zme if bandera==1


