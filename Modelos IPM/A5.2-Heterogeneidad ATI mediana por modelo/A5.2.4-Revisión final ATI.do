/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN:
	En este script se hace una revisión del número de observaciones que debían
	entrar en cada uno de los modelos de IPM que se estimaron para el ejercicio
	de heterogeneidad de ATI.

*/

* Preámbolo luego de ejecutar _master.do
capture log close
global output_path "${projectfolder}/Output/Construccion Tratamientos/_heterogeneidad ati" 
// log using "${projectfolder}/Log/Heterogeneidad ATI Mediana por modelo", replace
use "${datafolder}/base_estimaciones_gus.dta", clear
	
	
* Modelo 1
preserve 
keep if ejecucion_PNIS ==1 | ejecucion_PNIS ==0
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
	
estpost tab year_t_AAI_Nada d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model1-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs

restore

* Modelo 2
preserve
keep if ejecucion_PNIS==1 | ejecucion_PNIS==2
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
	
estpost tab year_t_SA_AAI d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model2-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
	
restore

* Modelo 3
preserve
keep if ejecucion_PNIS ==1 | ejecucion_PNIS ==3
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
	
estpost tab year_t_PPCC_AAI d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model3-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
restore



* Modelo 4
preserve
keep if ejecucion_PNIS ==1 | ejecucion_PNIS ==4
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
	
estpost tab year_t_PPCCySA d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model4-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
restore

* Modelo 5
preserve 
keep if ejecucion_PNIS ==2 | ejecucion_PNIS ==4
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

estpost tab year_t_PPCCySA d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model5-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
restore
* Modelo 6
preserve
keep if ejecucion_PNIS ==3 | ejecucion_PNIS ==4
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

estpost tab year_t_PPCCySA d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model6-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
restore

* Modelo 7 
preserve
keep if ejecucion_PNIS ==4 | ejecucion_PNIS ==5
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
	
estpost tab year_t_PPCL_PPCCySA d_ati if year==2017
esttab using "${output_path}/revision_cohortes-model7-p50modelo.tex", replace ///
	wide unstack compress nonum ///
	nonote noobs
restore

capture log close
