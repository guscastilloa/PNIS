/*
ooutputs IPM
*/
* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos IPM/_heterogeneidad grupos armados/estimaciones"
global output_path "${projectfolder}/Output/Modelos IPM/_heterogeneidad grupos armados/graficos"


* Pegarle a la base de estimaciones la información de grupos armados por municipio
tempfile panel armed_presence 

use "${projectfolder}/Datos/armed_presence.dta", clear

rename cod_dane_mpio cod_mpio
rename d grupos_armados
label variable grupos_armados "Presencia de grupos armados"
label define larmed 0 "Sin presencia" 1 "Un grupo armado" 2 "En disputa", replace
label values grupos_armados larmed 
save `armed_presence'

use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear
save `panel'

merge m:1 cod_mpio using `armed_presence'
sort cub year

* Fijar globals con value labels de d_ati para títulos 
global ARMED0: label larmed 0
global ARMED1: label larmed 1
global ARMED2: label larmed 2

mata st_global("ARMED0", st_vlmap("larmed", 0))
mata st_global("ARMED1", st_vlmap("larmed", 1))
mata st_global("ARMED2", st_vlmap("larmed", 2))

di "$ARMED0"
di "$ARMED1"
di "$ARMED2"



*-------------------------------------------------------------------------------
**# Crear 2 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
//esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados0.ster

* * ** * * **. ** * * * ARMED 0

* IPM 1
matrix E4ARMED0 = J(4,2,.)
matrix rownames E4ARMED0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED0 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0


coefplot matrix(E4ARMED0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED0") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g1, replace)  
	
* * ** * * **. ** * * * ARMED 1	
	
* IPM 1
matrix E4ARMED1 = J(4,2,.)
matrix rownames E4ARMED1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED1 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1


coefplot matrix(E4ARMED1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED1") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g2, replace)  

* * ** * * **. ** * * * ARMED 2
	
* IPM 1
matrix E4ARMED1 = J(4,2,.)
matrix rownames E4ARMED1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED1 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados2.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados2.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1


coefplot matrix(E4ARMED1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED2") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g3, replace)  

* * ** * * **. ** * * *

graph combine g1 g2 g3, ycommon title("PP&SA vs AAI") ///
name(combinado4, replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%.")

graph export "/Users/upar/Library/CloudStorage/OneDrive-UniversidaddelosAndes/03 MONEY/CESED/Cuanti-PNIS/Output/Modelos IPM/_heterogeneidad grupos armados/graficos/heterogeneidad-armed_esp4-AAI_PPSA.jpg", replace
graph drop _all	
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 4 Especificación 4
*-------------------------------------------------------------------------------		
global modelo "model4"
global E=4
* Sin grupos armados (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Sin presencia") subtitle("Sin truncar") name(One, replace)
	graph export "${output_path}/efectos_dinamicos-armed0-AAI_PPSA-esp4.jpg", replace		
	
	
* Con un grupo armado (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Un grupo armado") subtitle("Sin truncar") name(Two, replace)
	graph export "${output_path}/efectos_dinamicos-armed1-AAI_PPSA-esp4.jpg", replace		

* Con más de 1 grupo armado (2) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados2.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(e, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-grupos_armados2.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(f, replace)
	
	grc1leg e f, ycommon row(1) title("Dos o más grupos armados") subtitle("Sin truncar") name(Three, replace) 
	graph export "${output_path}/efectos_dinamicos-armed2-AAI_PPSA-esp4.jpg", replace		
	