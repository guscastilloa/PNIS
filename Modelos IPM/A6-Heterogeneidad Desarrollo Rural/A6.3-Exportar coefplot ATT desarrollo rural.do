/*
ooutputs IPM
*/
* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos IPM/_heterogeneidad proyectos rural/estimaciones"
global output_path "${projectfolder}/Output/Modelos IPM/_heterogeneidad proyectos rural/graficos"


* Pegarle a la base la información de aquellos CUBs con programas de desarrollo rural
tempfile original using
use "${projectfolder}/Datos/db_proyectos_rurales.dta", clear
save `using'

use "${projectfolder}/Datos/base_estimaciones_pp.dta", clear
merge m:1 cub using `using'

* Arreglar variable proyectos_rural para segmentar muestra
recode proyectos_rural .=0
tab year proyectos_rural, miss
label var proyectos_rural "Recibió proyectos desarrollo rural"
label define lproyecto 1 "1 o más proyectos" ///
					   0 "No recibió proyectos", replace
label values proyectos_rural lproyecto

drop if year==.

* Fijar globals con value labels de d_ati para títulos 
global RURAL0: label lproyecto 0
global RURAL1: label lproyecto 1

mata st_global("RURAL0", st_vlmap("lproyecto", 0))
mata st_global("RURAL1", st_vlmap("lproyecto", 1))

di "$RURAL0"
di "$RURAL1"

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |   / ____ `.  | || |     | |      | |
// | |   `'  __) |  | || |     \_|      | |
// | |   _  |__ '.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
*-------------------------------------------------------------------------------
**# Crear 2 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
* IPM 1
matrix E4prural0 = J(4,2,.)
matrix rownames E4prural0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4prural0 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 1-con_outliers-prural0.ster"
estat simple
matrix E4prural0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural0

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 2-con_outliers-prural0.ster"
estat simple
matrix E4prural0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural0


coefplot matrix(E4prural0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$RURAL0") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g1, replace)  
	
	
	
* IPM 1
matrix E4prural1 = J(4,2,.)
matrix rownames E4prural1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4prural1 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 1-con_outliers-prural1.ster"
estat simple
matrix E4prural1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural1

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 2-con_outliers-prural1.ster"
estat simple
matrix E4prural1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural1


coefplot matrix(E4prural1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$RURAL1") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g2, replace)  


graph combine g1 g2, ycommon title("PP vs AAI") ///
name(combinado3, replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%.")

graph export "${output_path}/heterogeneidad-prural_esp4-AAI_PP.jpg", replace
graph drop _all	
	
	
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 3 Especificación 4
*-------------------------------------------------------------------------------		
global modelo "model4"
global E=4
* prural0 (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 1-con_outliers-prural0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 2-con_outliers-prural0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No recibió proyectos") name(One, replace)
	
* prural1 (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 1-con_outliers-prural1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PP-IPM 2-con_outliers-prural1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("1 o más proyectos") name(Two, replace)
	
* Unir y exportar
	grc1leg One Two, title("Sin truncar") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-prural-AAI_PP-esp${E}.jpg", replace	


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _    _     | || |      _       | |
// | |  | |  | |    | || |     | |      | |
// | |  | |__| |_   | || |     \_|      | |
// | |  |____   _|  | || |              | |
// | |      _| |_   | || |              | |
// | |     |_____|  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
*-------------------------------------------------------------------------------
**# Crear 2 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
* IPM 1
matrix E4prural0 = J(4,2,.)
matrix rownames E4prural0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4prural0 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-prural0.ster"
estat simple
matrix E4prural0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural0

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-prural0.ster"
estat simple
matrix E4prural0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural0


coefplot matrix(E4prural0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$RURAL0") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g1, replace)  
	
	
	
* IPM 1
matrix E4prural1 = J(4,2,.)
matrix rownames E4prural1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4prural1 = "IPM 1" "IPM 2"

local col 1
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-prural1.ster"
estat simple
matrix E4prural1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural1

* IPM 2
local col 2
estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-prural1.ster"
estat simple
matrix E4prural1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4prural1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4prural1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4prural1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4prural1


coefplot matrix(E4prural1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$RURAL1") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g2, replace)  


graph combine g1 g2, ycommon title("PP&SA vs AAI") ///
name(combinado4, replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%.")

graph export "${output_path}/heterogeneidad-prural_esp4-AAI_PPSA.jpg", replace
graph drop _all	
	
	
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 4 Especificación 4
*-------------------------------------------------------------------------------		
global modelo "model4"
global E=4
* prural0 (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-prural0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-prural0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No recibió proyectos") name(One, replace)
	
* prural1 (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 1-con_outliers-prural1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp4-AAI_PPSA-IPM 2-con_outliers-prural1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("1 o más proyectos") name(Two, replace)
	
* Unir y exportar
	grc1leg One Two, title("Sin truncar") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-prural-AAI_PPSA-esp${E}.jpg", replace		
	
