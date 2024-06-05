/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN:
	En este script se hace una revisión del número de observaciones que debían
	entrar en cada uno de los modelos de IPM que se estimaron para el ejercicio
	de heterogeneidad de ATI.

*/

global output_path "${projectfolder}/Output/Construccion Tratamientos/_heterogeneidad ati" 

use "${datafolder}/base_estimaciones_gus.dta", clear
	sum ati_porc if ati_porc !=0, d
	scalar med = r(p50)
	di med
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	assert r(N) ==491580

* Modelo 1
estpost tab year_t_AAI_Nada d_ati if ///
	(ejecucion_PNIS ==1 | ejecucion_PNIS ==0) & year==2017
	
esttab using "${output_path}/revision_cohortes-model1-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs


* Modelo 2
estpost tab year_t_SA_AAI d_ati if ///
	(ejecucion_PNIS==1 | ejecucion_PNIS==2) & year==2017
esttab using "${output_path}/revision_cohortes-model2-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
	
	
* Modelo 3
estpost tab year_t_PPCC_AAI d_ati if ///
	(ejecucion_PNIS ==1 | ejecucion_PNIS ==3) & year==2017
esttab using "${output_path}/revision_cohortes-model3-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs

	
* Modelo 4
estpost tab year_t_PPCCySA d_ati if ///
	(ejecucion_PNIS ==1 | ejecucion_PNIS ==4) & year==2017
esttab using "${output_path}/revision_cohortes-model4-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
	
	
* Modelo 5
estpost tab year_t_PPCCySA d_ati if ///
	(ejecucion_PNIS ==2 | ejecucion_PNIS ==4) & year==2017
esttab using "${output_path}/revision_cohortes-model5-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
	
	
* Modelo 6
estpost tab year_t_PPCCySA d_ati if ///
	(ejecucion_PNIS ==3 | ejecucion_PNIS ==4) & year==2017
esttab using "${output_path}/revision_cohortes-model6-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
	
	
* Modelo 7 
estpost tab year_t_PPCL_PPCCySA d_ati if ///
	(ejecucion_PNIS ==4 | ejecucion_PNIS ==5) & year==2017
esttab using "${output_path}/revision_cohortes-model7-p50total.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
