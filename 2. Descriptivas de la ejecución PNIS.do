* Preámbulo luego de ejecutar _master.do
clear
set more off
set scheme s1mono

use "${datafolder}/SISPNIS/db_pnis_panel.dta", clear

* Proceso para Identificar número de actualizaciones d
log using "~/Downloads/lucas.log", replace
use "${datafolder}/SISBEN/db_sisben_panel_VF.dta", clear 
keep if fecham!=.
contract cub fecham
save "~/Downloads/algo.dta", replace
use "~/Downloads/algo.dta", clear
qui statsby size=r(N), by(cub): sum _freq
tab size
log close


***************************
***						***
***      LIMPIEZA 1 	***
***						***
***************************

// Arreglo variables de códigos DANE
destring dpto_ccdgo mpio_ccdgo cod_mpio, replace

// Arreglo variable de sexo 
replace sexo_titular = "1" if sexo_titular == "FEMENINO"
replace sexo_titular = "0" if sexo_titular == "MASCULINO"
replace sexo_titular = "." if sexo_titular == "NO INFORMA" | sexo_titular == "NULL" 
destring sexo_titular, replace
label define sexo 0 "Hombre" 1 "Mujer"
label values sexo_titular sexo 

// save "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Cuanti-PNIS/Datos/SISPNIS/db_pnis_panel_VF.dta", replace


keep if activo == 1

gen aai_porc = c_aai_total / 12000000 * 100
gen ati_porc = c_ati_total / 3200000 * 100
gen sa_porc = c_sa_total / 1800000 * 100
gen pp_porc = c_pp_total / 19000000 * 100
gen pp_cc_porc = c_pp_total_cc / 9000000 * 100
gen pp_cl_porc = c_pp_total_cl / 10000000 * 100

// Hay valores que superan el 100% de ejecución, esos se remplazan por 100%

// SA 7.2%
// ATI 0.5%
// PP 0.7%
// PP_CC 0.7%
// PP_CL 0.3%

foreach x of varlist aai_porc sa_porc ati_porc pp_porc pp_cc_porc pp_cl_porc {
	
	replace `x' = 100 if `x' > 100 & `x' != .
	
}


***************************
***						***
***  PRODUCING GRAPHS 1 ***
***						***
***************************

cd "${path}/Gráficos/Ejecución del PNIS"
graph drop _all
/// Construir la distribución de la ejecución del programa para cada componente y para cada año 

// AAI 
global componente "AAI"
global titulo_componente "Ejecución de Asistencia Alimentaria Inmediata"
forvalues i = 2017(1)2022 {
	
	hist aai_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("`i'")  ///
		name("${componente}_`i'", replace) nodraw
// 	graph export "AAI_`i'.png", replace as(png)	
}
capture graph drop Graph
graph dir 
return list 
display r(list)
graph combine `r(list)', xcommon ycommon ///
	title("${titulo_componente}") name("${componente}_all_years")
graph export "${componente}_all_years.png", replace

// SA 
global componente "SA"
global titulo_componente "Ejecución de Seguridad Alimentaria"
graph drop _all
forvalues i = 2017(1)2022 {
	
	hist sa_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("`i'")   ///
		name("${componente}_`i'", replace) nodraw
// 	graph export "SA_`i'.png", replace as(png)
}
capture graph drop Graph
graph dir 
return list 
display r(list)
graph combine `r(list)', xcommon ycommon ///
	title("${titulo_componente}") name("${componente}_all_years")
graph export "${componente}_all_years.png", replace

// PP 
forvalues i = 2017(1)2022 {
	
	hist pp_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("Ejecución de Proyecto Productivo - `i'") 
	graph export "PP_`i'.png", replace as(png)
	
}

// PP - Ciclo Corto
global componente "PP_CC"
global titulo_componente "Ejecución de Proyecto Productivo Ciclo Corto"
graph drop _all
forvalues i = 2017(1)2022 {
	
	hist pp_cc_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("`i'")  ///
		name("${componente}_`i'", replace) nodraw
// 	graph export "PP_CC_`i'.png", replace as(png)
}
capture graph drop Graph
graph dir 
return list 
display r(list)
graph combine `r(list)', xcommon ycommon ///
	title("${titulo_componente}") name("${componente}_all_years")
graph export "${componente}_all_years.png", replace

// PP - Ciclo Largo
global componente "PP_CL"
global titulo_componente "Ejecución de Proyecto Productivo Ciclo Largo"
graph drop _all
forvalues i = 2017(1)2022 {
	
	hist pp_cl_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("`i'") ///
		name("${componente}_`i'", replace) nodraw
// 	graph export "PP_CL_`i'.png", replace as(png)
}
capture graph drop Graph
graph dir 
return list 
display r(list)
graph combine `r(list)', xcommon ycommon ///
	title("${titulo_componente}") name("${componente}_all_years")
graph export "${componente}_all_years.png", replace

// ATI
global componente "ATI"
global titulo_componente "Ejecución de Asistencia Técnica Integral"
graph drop _all
forvalues i = 2017(1)2022 {
	
	hist ati_porc if actividad != "Recolector" & year == `i', frac ///
		ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
		ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente (%)", size(small)) ///
		subtitle("`i'")  ///
		name("${componente}_`i'", replace) nodraw
// 	graph export "ATI_`i'.png", replace as(png)
}
capture graph drop Graph
graph dir 
return list 
display r(list)
graph combine `r(list)', xcommon ycommon ///
	title("${titulo_componente}") name("${componente}_all_years")
graph export "${componente}_all_years.png", replace


***************************
***						***
***  PRODUCING GRAPHS 2 ***
***						***
***************************

/// Se colapsa la base a nivel de cub para graficar la ejecución total del programa 

collapse (sum) aai_total ati_total sa_total pp_total pp_total_cc pp_total_cl, by(cub actividad)

gen aai_porc = aai_total / 12000000 * 100
gen ati_porc = ati_total / 3200000 * 100
gen sa_porc = sa_total / 1800000 * 100
gen pp_porc = pp_total / 19000000 * 100
gen pp_cc_porc = pp_total_cc / 9000000 * 100
gen pp_cl_porc = pp_total_cl / 10000000 * 100

// Hay valores que superan el 100% de ejecución, esos se remplazan por 100%

// SA 7.2%
// ATI 0.5%
// PP 0.7%
// PP_CC 0.7%
// PP_CL 0.3%

foreach x of varlist aai_porc sa_porc ati_porc pp_porc pp_cc_porc pp_cl_porc {
	
	replace `x' = 100 if `x' > 100 & `x' != .
	
}



// Crear los histogramas de la distribución 
// AAI
sum aai_porc if actividad != "Recolector", d 

hist aai_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(100 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Asistencia Alimentaria Inmediata") ///
	note("Nota: p10 = 100%, p25 = 100%, p75 = 100%, p90 = 100%.", size(vsmall))
// graph export "ACUM_AAI.png", replace as(png)

// SA
sum sa_porc if actividad != "Recolector", d 

hist sa_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(100 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Seguridad Alimentaria") ///
	note("Nota: p10 = 99%, p25 = 99.8%, p75 = 100%, p90 = 100%.", size(vsmall))
graph export "ACUM_SA.png", replace as(png)

// PP
sum pp_porc if actividad != "Recolector", d 

hist pp_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(47.4 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Proyecto Productivo") ///
	note("Nota: p10 = 47.4%, p25 = 47.4%, p75 = 47.4%, p90 = 48.1%.", size(vsmall))
graph export "ACUM_PP.png", replace as(png)

// PP CC
sum pp_cc_porc if actividad != "Recolector", d 

hist pp_cc_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(100 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Proyecto Productivo - Ciclo Corto") ///
	note("Nota: p10 = 100%, p25 = 100%, p75 = 100%, p90 = 100%.", size(vsmall))
graph export "ACUM_PP_CC.png", replace as(png)

// PP CL
sum pp_cl_porc if actividad != "Recolector", d 

hist pp_cl_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)1, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(0 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Proyecto Productivo - Ciclo Largo") ///
	note("Nota: p10 = 0%, p25 = 0%, p75 = 0%, p90 = 1.4%.", size(vsmall))
graph export "ACUM_PP_CL.png", replace as(png)
	
// ATI
sum ati_porc if actividad != "Recolector", d 

hist ati_porc if actividad != "Recolector", frac ///
	xaxis (1 2) ylabel(0(0.1)0.6, grid labsize(small)) xlabel(0(10)100, axis(1) labsize(small)) ///
	ytitle("Proporción de beneficiarios activos", size(small)) xtitle("Nivel de ejecución del componente a diciembre de 2022 (%)", size(small)) ///
	xlabel(59.4 "Mediana", labsize(vsmall) axis(2) grid) xtitle("", axis(2)) ///
	subtitle("Ejecución de Asistencia Técnica Integral") ///
	note("Nota: p10 = 40%, p25 = 54.2%, p75 = 59.6%, p90 = 66%.", size(vsmall))
graph export "ACUM_ATI.png", replace as(png)
* End
