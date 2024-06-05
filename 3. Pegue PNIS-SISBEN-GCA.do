/// Pegue del panel del SISBEN 2002 - 2023 con el panel de ejecución del PNIS 2017 - 2022 

/*
DESCRIPCIÓN:

En este script se crean las variables de ejecución de los componentes del PNIS,
i.e. variables que son 1 si consideramos que el cub recibió el componente. 
En la sección de *TRATAMIENTOS* se crea una variable que identifique el nivel de
ejecución de cada componente, después de haber revisado que la ejecución de
ciertos componentes es excluyente de otros.

*/	

cls
clear all
use "${datafolder}/SISBEN/db_sisben_panel_VF.dta", clear 
// Instalar paquetes necesarios
capture net install ereplace.pkg

***************************
***						***
***      LIMPIEZA 1 	***
***						***
***************************

merge 1:1 cub year using "${datafolder}/SISPNIS/db_pnis_panel_VF.dta", gen(u1) force

drop if year == 2023

// Crear edad a partir de fecha de nacimiento
bysort cub: ereplace year_nacimiento_titular = mean(year_nacimiento_titular)

sort cub year

drop edad 

gen edad = year - year_nacimiento_titular

// Construir grupos de recepción de componentes 
rename (aai_total ati_total sa_total pp_total_cc pp_total_cl) (aai_montos ati_montos sa_montos ppcc_montos ppcl_montos)

// 1. Variable que mida el total ejecutado y que no varie en el tiempo
global componentes aai ati sa ppcc ppcl 

foreach x of global componentes { 
	
	bysort cub: egen `x'_total = total(`x'_montos)
	
}

// 2. Crear porcentajes de ejecución total para cada componente

gen aai_porc = aai_total / 12000000 * 100
gen ati_porc = ati_total / 3200000 * 100
gen sa_porc = sa_total / 1800000 * 100
gen ppcc_porc = ppcc_total / 9000000 * 100
gen ppcl_porc = ppcl_total / 10000000 * 100

// Hay valores que superan el 100% de ejecución, esos se remplazan por 100%

// SA 7.2%
// ATI 0.5%
// PP 0.7%
// PP_CC 0.7%
// PP_CL 0.3%

foreach x of varlist aai_porc sa_porc ati_porc ppcc_porc ppcl_porc {
	
	replace `x' = 100 if `x' > 100 & `x' != .
	
}

// 3. Crear variables de ejecución del programa a partir de definiciones a partir de distribución de ejecución
// AAI: superior a la mediana (excluyendo ceros y 100%) que es 16.667%
	// NOTA: Dado que la mediana es 100/6 y STATA no puede usar el valor como una
	// condición para crear una variable, se usará el valor de la mediana del total
	// (aai_total==2000000) que es 2 millones de pesos, en vez del 16.667%
// SA, PPCC, PPCL: recibir más del 90%

gen d_aai = 1 if aai_total >= 2000000 & aai_porc != . 
replace d_aai = 0 if aai_total < 2000000
// br cub year aai_porc aai_total d_aai  //if aai_total ==2000000

global componentes2 sa ppcc ppcl 

foreach x of global componentes2 { 

	gen d_`x' = 1 if `x'_porc >= 90 & `x'_porc != . 
	replace d_`x' = 0 if `x'_porc < 90

}
// Revisando que cada componente haya quedado bien:
// 	gsort -sa_porc
// 	br cub year sa_porc sa_total if sa_porc>88 & sa_porc<94 //d_sa
//	
// 	gsort -ppcc_porc
// 	br cub year ppcc_porc ppcc_total d_ppcc if ppcc_porc>88 & ppcc_porc<94
//	
// 	gsort -ppcl_porc
// 	br cub year ppcl_porc ppcl_total d_ppcl if ppcl_porc>88 & ppcl_porc<94

// ATI
gen d_ati = 2 if ati_porc == 100
replace d_ati = 1 if ati_porc > 0 & ati_porc < 100
replace d_ati = 0 if ati_porc == 0
label define ati 0 "Nada" 1 "Parcialmente" 2 "Total"
label values d_ati ati

foreach x of varlist d_aai d_sa d_ati d_ppcc d_ppcl { 
	
	replace `x' = . if activo == 0 | actividad == "Recolector" // Nos quedamos solo con activos y que no sean recolectores
	
}

***************************
***						***
***     TRATAMIENTOS 	***
***						***
***************************

/// Calcular % de ejecución por componente
label var d_aai	"Ejecución AAI"
label var d_sa	"Ejecución SA"
label var d_ppcc "Ejecución PP CC"
label var d_ppcl "Ejecución PP CL"
est clear
estpost sum d_aai d_sa d_ppcc d_ppcl if year == 2022


ereturn list
esttab using "~/Downloads/component_execution.tex", replace cells("mean(fmt(3))") label ///
	nonum collabels("Promedio") nomtitle booktabs

// AAI 99.8% han recibido por encima de la mediana (sin 0 y sin 100) de ejecución de AAI 
// SA 96.5% han recibido más del 90%
// PPCC 96.7% han recibido más del 90%
// PPCL 2.5% han recibido más del 90%

/// Calcular intersecciones entre componentes para cultivadores y no cultivadores activos
* AAI
estpost tab d_aai d_sa if year == 2022
est store aai_sa  
estpost tab d_aai d_ppcc if year == 2022
est store aai_ppcc
qui estpost tab d_aai d_ppcl if year == 2022
qui est store aai_ppcl

esttab aai_sa using "~/Downloads/aai_sa.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución AAI"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución SA") ///
	booktabs

esttab aai_ppcc using "~/Downloads/aai_ppcc.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución AAI"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución PP CC") ///
	booktabs

esttab aai_ppcl using "~/Downloads/aai_ppcl.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución AAI"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución PP CL") ///
	booktabs	

// 0.028% han recibido SA pero no AAI
// 0.017% han recibido PPCC pero no AAI
// 0 han recibido PPCL pero no AAI


* SA
qui estpost tab d_sa d_ppcc if year == 2022
est store sa_ppcc
qui estpost tab d_sa d_ppcl if year == 2022
est store sa_ppcl

esttab sa_ppcc using "~/Downloads/sa_ppcc.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución SA"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución PP CC") ///
	booktabs	
	
esttab sa_ppcl using "~/Downloads/sa_ppcl.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución SA"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución PP CL") ///
	booktabs	
// 3.158% han recibido PPCC pero no SA
// 0.391% han recibido PPCL pero no SA

* PPs
qui estpost tab d_ppcc d_ppcl if year == 2022
qui est store ppcc_ppcl

esttab ppcc_ppcl using "~/Downloads/ppcc_ppcl.tex", replace ///
	cells("b" "pct(fmt(2) par([ ]))") unstack nonum label noobs compress ///
	eqlabels(, lhs("Ejecución PP CC"))	 ///
	note("Porcentaje sobre el total entre corchetes")  mtitle("Ejecución PP CL") ///
	booktabs	

// 0.098% han recibido PPCL pero no PPCC


// 4. Crear una variable que identifique nivel de ejecución para cada cub donde las categorías son excluyentes 
gen ejecucion_PNIS = 0 if d_aai == 0 & d_sa == 0 & d_ppcc == 0 & d_ppcl == 0
replace ejecucion_PNIS = 1 if d_aai == 1
replace ejecucion_PNIS = 2 if d_sa == 1 // AAI + SA
replace ejecucion_PNIS = 3 if d_ppcc == 1 // AAI + PPCC
replace ejecucion_PNIS = 4 if d_sa == 1 & d_ppcc == 1 // AAI + SA + PPCC
replace ejecucion_PNIS = 5 if d_ppcl == 1  // AAI + SA + PPCC + PPCL
label define ejecucion 0 "No ha recibido nada" 1 "Recibió solo AAI" 2 "Recibió SA" 3 "Recibió PPCC" 4 "Recibió SA y PPCC" 5 "Recibió PPCL"
label values ejecucion_PNIS ejecucion

replace ejecucion_PNIS = . if activo == 0 | actividad == "Recolector" // Nos quedamos solo con activos y que no sean recolectores



save "${datafolder}/db_sisben_pnis_panel_VF.dta", replace
* End
