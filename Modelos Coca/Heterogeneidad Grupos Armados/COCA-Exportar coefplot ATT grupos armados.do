/*
ooutputs IPM
*/
* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${output}/Modelos Coca Spillovers/_heterogeneidad grupos armados/estimaciones"
global dir_spill "${dir_estimaciones}/SPILL"
global dir_roll "${dir_estimaciones}/ROLL"
global output_path "${output}/Modelos Coca Spillovers/_heterogeneidad grupos armados/graficos"


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
**# SPILL: Crear 2 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
/*modelos SPILL (9):
	- d_PPSA_AAI_X.ster (3) (grilla pnis)
	- v_PPSA_AAI_X.ster (3) (vecina)
	- vv_PPSA_AAI_X.ster (3) (veci veci)
	
para X=0,1,2 representando los 3 tipos de municipio que dan en total 9 modelos.*/
//esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados0.ster

* * ** * * **. ** * * * ARMED 0

matrix E4ARMED0 = J(4,3,.)
matrix rownames E4ARMED0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED0 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_spill}/d_PPSA_AAI_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0

* Vecina
local col 2
estimates use "${dir_spill}/v_PPSA_AAI_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0

* Vecina de Vecina
local col 3
estimates use "${dir_spill}/vv_PPSA_AAI_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0


matlist E4ARMED0

coefplot matrix(E4ARMED0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED0") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g1, replace)  
	
	
	
	
* * ** * * **. ** * * * ARMED 1

matrix E4ARMED1 = J(4,3,.)
matrix rownames E4ARMED1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED1 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_spill}/d_PPSA_AAI_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* Vecina
local col 2
estimates use "${dir_spill}/v_PPSA_AAI_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* Vecina de Vecina
local col 3
estimates use "${dir_spill}/vv_PPSA_AAI_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1


matlist E4ARMED1

coefplot matrix(E4ARMED1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED1") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g2, replace)  	
	
	
	
	
* * ** * * **. ** * * * ARMED 2

matrix E4ARMED2 = J(4,3,.)
matrix rownames E4ARMED2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED2 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_spill}/d_PPSA_AAI_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2

* Vecina
local col 2
estimates use "${dir_spill}/v_PPSA_AAI_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2

* Vecina de Vecina
local col 3
estimates use "${dir_spill}/vv_PPSA_AAI_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2


matlist E4ARMED2

coefplot matrix(E4ARMED2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED2") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stc6) recast(rcap)) ///
	mlabcolor(stc6) mcolor(stc6) msymbol(D) aspect(1.4) name(g3, replace)  		

graph combine g1 g2 g3, ycommon title("PP&SA vs AAI") ///
name(combinado4, replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%.") ///
caption("SPILL", color(gs15%30))

graph export "${output_path}/coca-armed-esp4-AAI_PPSA-SPILL.jpg", replace
graph drop _all	
	
	

	
	
*-------------------------------------------------------------------------------
**# ROLL: Crear 2 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
/*
- modelos ROLL (9):
	- d_PPSA_ROLL_X.ster (3) (grilla pnis)
	- v_PPSA_ROLL_X.ster (3) (vecina)
	- vv_PPSA_ROLL_X.ster (3) (veci veci)
X=0,1,2, 9 modelos
*/

//esp4-AAI_PPSA-IPM 1-con_outliers-grupos_armados0.ster

* * ** * * **. ** * * * ARMED 0

matrix E4ARMED0 = J(4,3,.)
matrix rownames E4ARMED0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED0 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_roll}/d_PPSA_ROLL_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0

* Vecina
local col 2
estimates use "${dir_roll}/v_PPSA_ROLL_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0

* Vecina de Vecina
local col 3
estimates use "${dir_roll}/vv_PPSA_ROLL_0.ster"
estat simple
matrix E4ARMED0[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED0[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED0[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED0[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED0


matlist E4ARMED0

coefplot matrix(E4ARMED0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED0") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stred) recast(rcap)) ///
	mlabcolor(stred) mcolor(stred) msymbol(D) aspect(1.4) name(g1, replace)  
	
	
	
	
* * ** * * **. ** * * * ARMED 1

matrix E4ARMED1 = J(4,3,.)
matrix rownames E4ARMED1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED1 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_roll}/d_PPSA_ROLL_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* Vecina
local col 2
estimates use "${dir_roll}/v_PPSA_ROLL_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1

* Vecina de Vecina
local col 3
estimates use "${dir_roll}/vv_PPSA_ROLL_1.ster"
estat simple
matrix E4ARMED1[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED1[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED1[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED1[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED1


matlist E4ARMED1

coefplot matrix(E4ARMED1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED1") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stred) recast(rcap)) ///
	mlabcolor(stred) mcolor(stred) msymbol(D) aspect(1.4) name(g2, replace)  	
	
	
	
	
* * ** * * **. ** * * * ARMED 2

matrix E4ARMED2 = J(4,3,.)
matrix rownames E4ARMED2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames E4ARMED2 = "Grilla PNIS" "Vecina" "V de Vecina"

* grilla pnis
local col 1
estimates use "${dir_roll}/d_PPSA_ROLL_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2

* Vecina
local col 2
estimates use "${dir_roll}/v_PPSA_ROLL_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2

* Vecina de Vecina
local col 3
estimates use "${dir_roll}/vv_PPSA_ROLL_2.ster"
estat simple
matrix E4ARMED2[1, `col']=r(table)[1,1] // Guardar ATT
matrix E4ARMED2[2, `col']=r(table)[5,1] // Guardar LB
matrix E4ARMED2[3, `col']=r(table)[6,1] // Guardar UB
matrix E4ARMED2[4, `col']=r(table)["pvalue",1] // Guardar p-valor
matlist E4ARMED2


matlist E4ARMED2

coefplot matrix(E4ARMED2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("$ARMED2") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(stred) recast(rcap)) ///
	mlabcolor(stred) mcolor(stred) msymbol(D) aspect(1.4) name(g3, replace)  		

graph combine g1 g2 g3, ycommon title("PP&SA vs AAI") ///
name(combinado4, replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%.") ///
caption("ROLL", color(gs15%30))

graph export "${output_path}/coca-armed-esp4-AAI_PPSA-ROLL.jpg", replace
graph drop _all	
	
	