clear
set more off
set scheme s1mono

use "${datafolder}/db_sisben_pnis_panel_VF.dta", clear

drop if u1 == 2 // PNIS que no están en Sisbén o que no tienen información del Sisbén desde 2013

/// Quedarnos solo con cub con información desde 2013 

bysort cub: egen num_total = count(activo)
keep if num_total >= 10

/// Estadísticas descriptivas del IPM por grupo de ejecución del PNIS 

keep if activo == 1
keep if year > 2012

***************************
***						***
***   DESCRIPTIVAS IPM 	***
***						***
***************************

/// Estadísticas descriptivas del IPM por grupo de ejecución del PNIS 


/// Gráficas de evolución del IPM
preserve
collapse (mean) d_IPM_1 d_IPM_2, by(ejecucion_PNIS year)

twoway (tsline d_IPM_1 if ejecucion_PNIS == 0, lcolor(black)) (tsline d_IPM_1 if ejecucion_PNIS == 1, lcolor(gray)) (tsline d_IPM_1 if ejecucion_PNIS == 2, lcolor(green)) (tsline d_IPM_1 if ejecucion_PNIS == 3, lcolor(blue)) (tsline d_IPM_1 if ejecucion_PNIS == 4, lcolor(orange)) (tsline d_IPM_1 if ejecucion_PNIS == 5, lcolor(red)), ///
	legend(order(1 "No han recibido nada" 2 "AAI" 3 "AAI+SA" 4 "AAI+PPCC" 5 "AAI+SA+PPCC" 6 "Todo")) ///
	ytitle("Proporción de hogares en pobreza multidimensional", size(small)) ///
	xtitle("Años", size(small)) xlabel(2013(2)2021, labsize(small)) ylabel(, labsize(small)) ///
	xline(2017, lcolor(black) lpattern(dash)) ///
	note("Nota: AAI: Asistencia Alimentaria Inmediata, SA: Seguridad Alimentaria, PPCC: PP - Ciclo Corto, PPCL: PP - Ciclo Largo", size(vsmall)) ///
	subtitle("Evolución de la pobreza multidimensional por ejecución del PNIS")
graph export "${projectfolder}/Gráficos/IPM1_ejecución.png", as(png) replace

twoway (tsline d_IPM_2 if ejecucion_PNIS == 0, lcolor(black)) (tsline d_IPM_2 if ejecucion_PNIS == 1, lcolor(gray)) (tsline d_IPM_2 if ejecucion_PNIS == 2, lcolor(green)) (tsline d_IPM_2 if ejecucion_PNIS == 3, lcolor(blue)) (tsline d_IPM_2 if ejecucion_PNIS == 4, lcolor(orange)) (tsline d_IPM_2 if ejecucion_PNIS == 5, lcolor(red)), ///
	legend(order(1 "No han recibido nada" 2 "AAI" 3 "AAI+SA" 4 "AAI+PPCC" 5 "AAI+SA+PPCC" 6 "Todo")) ///
	ytitle("Proporción de hogares en pobreza multidimensional", size(small)) ///
	xtitle("Años", size(small)) xlabel(2013(2)2021, labsize(small)) ylabel(, labsize(small)) ///
	xline(2017, lcolor(black) lpattern(dash)) ///
	note("Nota: AAI: Asistencia Alimentaria Inmediata, SA: Seguridad Alimentaria, PPCC: PP - Ciclo Corto, PPCL: PP - Ciclo Largo", size(vsmall)) ///
	subtitle("Evolución de la pobreza multidimensional por ejecución del PNIS")
graph export "${projectfolder}/Gráficos/IPM2_ejecución.png", as(png) replace

restore 

***************************
***						***
***   TREATMENTS & IPM 	***
***						***
***************************

/// Comparación del IPM SISBÉN IV con el construido - Metodología 
estpost tab d_IPM_1 ipm_indice if ipm_indice != . // 85% de estimaciones iguales - Dimensiones
ereturn list
esttab using "~/Downloads/ipm1_comparison.tex", replace ////
	cells("b" "pct(fmt(%5.1f) par([ ]))") noobs unstack  nonumber ///
	eqlabels(, lhs("IPM Propuesto"))	 ///
	note("Porcentaje de la columna entre corchetes")  mtitle("IPM SISBÉN IV") ///
	booktabs

est clear 
estpost tab d_IPM_2 ipm_indice if ipm_indice != . // 81.4% de estimaciones iguales 
esttab using "~/Downloads/ipm2_comparison.tex", replace ////
	cells("b" "pct(fmt(%5.1f) par([ ]))") noobs unstack  nonumber ///
	eqlabels(, lhs("IPM Propuesto"))	 ///
	note("Porcentaje de la columna entre corchetes")  mtitle("IPM SISBÉN IV") ///
	booktabs


**# Bookmark: Cambios en los IPM por grupo de ejecución
	****************************** SUGERENCIA LUCAS:
	* Variables to test: d_IPM_1, d_IPM_2
	* Groups
		* By year:
			* Pre 2017: (year < 2017)
			* Post 2017: (year >= 2017)
		* By treatment:
			* 0 vs 1: (ejecucion_PNIS == 0 | ejecucion_PNIS == 1)
			* 1 vs 2: (ejecucion_PNIS == 1 | ejecucion_PNIS == 2)
			* 1 vs 3: (ejecucion_PNIS == 1 | ejecucion_PNIS == 3)
			* 1 vs 4: (ejecucion_PNIS == 1 | ejecucion_PNIS == 4)
			* 2 vs 4: (ejecucion_PNIS == 2 | ejecucion_PNIS == 4)
			* 3 vs 4: (ejecucion_PNIS == 3 | ejecucion_PNIS == 4)
			* 4 vs 5: (ejecucion_PNIS == 4 | ejecucion_PNIS == 5)
//Help with for loops: 
// https://www.stata.com/manuals13/m-2break.pdf			


* Definir matriz auxiliar para loop con grupos de tratamiento
matrix define N=J(7,2,.)
matrix N[1,1] = 0
matrix N[2,1] = 1
matrix N[3,1] = 1
matrix N[4,1] = 1
matrix N[5,1] = 2
matrix N[6,1] = 3
matrix N[7,1] = 4
matrix N[1,2] = 1
matrix N[2,2] = 2
matrix N[3,2] = 3
matrix N[4,2] = 4
matrix N[5,2] = 4
matrix N[6,2] = 4
matrix N[7,2] = 5
matlist N

* Definir programa para calcular número de estrellas de significancia
capture program drop get_stars
program get_stars, rclass
	capture scalar drop stars
		* Add significance stars to p-value:
		if `1'<0.01{
			*add 3 stars
			local stars="3"
		}
		else if `1'<0.05{
			*add 2 stars
			local stars="2"
		}
		else if `1'<0.1{
			*add 1 star
			local stars="1"
		}
		else{
			local stars=0
		}
	di `stars'
	return scalar sig_stars=`stars'
end

//  _____ ______  ______         __ 
// (_____|_____ \|  ___ \       /  |
//    _   _____) ) | _ | |     /_/ |
//   | | |  ____/| || || |       | |
//  _| |_| |     | || || |_______| |
// (_____)_|     |_||_||_(_______)_|
//                                 
//https://onlineasciitools.com/convert-text-to-ascii-art

* Definir matriz para exportar tabla
matrix define A=J(28,6,.)
matrix colnames A = "Media 1" "Media 2" "Dif. medias (p-valor)" ///
					"DiD (p-valor)" "sig_stars_dif" "sig_stars_did"
matrix rownames A = "Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" ""


cls
local f=1
local c=1
forvalues row=1/7{
	capture drop cat
	local g1=N[`row', 1]
	local g2= N[`row', 2]
	di "Groups: " `g1', `g2' "********************************"
	gen cat = .
	qui replace cat = 0 if ejecucion_PNIS == `g1' & year < 2017
	qui replace cat = 1 if ejecucion_PNIS == `g2' & year < 2017
	qui replace cat = 2 if ejecucion_PNIS == `g1' & year >= 2017
	qui replace cat = 3 if ejecucion_PNIS == `g2' & year >= 2017
	
	qui mean d_IPM_1, over(cat)
	scalar mu1=_b[c.d_IPM_1@0bn.cat]
	scalar mu2=_b[c.d_IPM_1@1bn.cat]
	scalar diff = _b[c.d_IPM_1@1bn.cat]-_b[c.d_IPM_1@0bn.cat] 

	* mu2,post - mu1,post- (mu2,pre-mu1,pre)
	scalar did=round( (_b[c.d_IPM_1@3bn.cat] - _b[c.d_IPM_1@2bn.cat]) - ///
					  (_b[c.d_IPM_1@1bn.cat] - _b[c.d_IPM_1@0bn.cat]) ///
					  ,0.001)
					  
	*******************
	* PRE 2017: <2017 *
	*******************
	display "pre: mu_1: " _b[c.d_IPM_1@0bn.cat]
	display "pre: mu_2: " _b[c.d_IPM_1@1bn.cat]
	display "pre: mu_1-mu_2: " _b[c.d_IPM_1@0bn.cat] - _b[c.d_IPM_1@1bn.cat]
	
	di "*...................."
	
	matrix A[`f',`c']=mu1
	matrix A[`f',`c'+1]=mu2
	matrix A[`f',`c'+2]=diff
	
	* Tests entre grupos de tratamiento
	qui ttest d_IPM_1 ///
	if (year < 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS) 
	
	scalar p1 = round(`r(p)',0.001)
	matrix A[`f',`c'+3]=did
	matrix A[`f'+1,`c'+2]=p1
	
	* Añadir p-valor de doble diferencia
	qui test _b[c.d_IPM_1@0bn.cat] - _b[c.d_IPM_1@1bn.cat] = _b[c.d_IPM_1@2bn.cat] - _b[c.d_IPM_1@3bn.cat]
	scalar p_did = round(`r(p)',0.001)
	matrix A[`f'+1,`c'+3]=p_did
	
	* Añadir estrellas de significancia para diferencia de medias
	get_stars p1
	matrix A[`f'+1,`c'+4]=r(sig_stars)
	
	* Añadir columna con estrellas de significancia para doble diferencia
	get_stars p_did
	matrix A[`f'+1,`c'+5]=r(sig_stars)
	
	********************
	* POST 2017: ≥2017 *
	********************
	local f=`f'+2	
	scalar mu1=_b[c.d_IPM_1@2bn.cat]
	scalar mu2=_b[c.d_IPM_1@3bn.cat]
	scalar diff = _b[c.d_IPM_1@3bn.cat] - _b[c.d_IPM_1@2bn.cat] 
	
	display "post: mu_1: " _b[c.d_IPM_1@2bn.cat]
	display "post: mu_2: " _b[c.d_IPM_1@3bn.cat]
	display "post: mu_1-mu_2: " _b[c.d_IPM_1@2bn.cat] - _b[c.d_IPM_1@3bn.cat]
	
	matrix A[`f',`c']=mu1
	matrix A[`f',`c'+1]=mu2
	matrix A[`f',`c'+2]=diff

	
	* Tests entre grupos de tratamiento
	qui ttest d_IPM_1 ///
	if (year >= 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS)
	
	scalar p2 = round(`r(p)',0.001)
	matrix A[`f'+1,`c'+2]=p2
	
	* Añadir estrellas de significancia para diferencia de medias
	get_stars p2
	matrix A[`f'+1,`c'+4]=r(sig_stars)
	
	* Prepare for next loop
	drop cat
	scalar drop _all
	local f=`f'+2	
}
matlist A
putexcel set "/Users/upar/Dropbox/02-MONEY/CESED/PNIS-documentos/Producto_3/Insumos/ipm_ttest_final.xlsx", sheet("import") modify
putexcel A1=matrix(A), names 

//  _____ ______  ______          ______  
// (_____|_____ \|  ___ \        (_____ \ 
//    _   _____) ) | _ | |         ____) )
//   | | |  ____/| || || |        /_____/ 
//  _| |_| |     | || || |_______ _______ 
// (_____)_|     |_||_||_(_______|_______)
//                                       
* Definir matriz para exportar tabla
matrix define B=J(28,6,.)
matrix colnames B = "Media 1" "Media 2" "Dif. medias (p-valor)" ///
					"DiD (p-valor)" "sig_stars_dif" "sig_stars_did"
matrix rownames B = "Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" ""
cls
local f=1
local c=1
forvalues row=1/7{
	capture drop cat
	local g1=N[`row', 1]
	local g2= N[`row', 2]
	di "Groups: " `g1', `g2' "********************************"
	gen cat = .
	qui replace cat = 0 if ejecucion_PNIS == `g1' & year < 2017
	qui replace cat = 1 if ejecucion_PNIS == `g2' & year < 2017
	qui replace cat = 2 if ejecucion_PNIS == `g1' & year >= 2017
	qui replace cat = 3 if ejecucion_PNIS == `g2' & year >= 2017
	
	qui mean d_IPM_2, over(cat)
	scalar mu1=_b[c.d_IPM_2@0bn.cat]
	scalar mu2=_b[c.d_IPM_2@1bn.cat]
	scalar diff = _b[c.d_IPM_2@1bn.cat] - _b[c.d_IPM_2@0bn.cat]
	scalar did=round( (_b[c.d_IPM_2@3bn.cat] - _b[c.d_IPM_2@2bn.cat]) - ///
					  (_b[c.d_IPM_2@1bn.cat] - _b[c.d_IPM_2@0bn.cat]) ///
					  ,0.001)
	*******************
	* PRE 2017: <2017 *
	*******************
	display "pre: mu_1: " _b[c.d_IPM_2@0bn.cat]
	display "pre: mu_2: " _b[c.d_IPM_2@1bn.cat]
	display "pre: mu_1-mu_2: " _b[c.d_IPM_2@0bn.cat] - _b[c.d_IPM_2@1bn.cat]
	
	di "*...................."
	
	matrix B[`f',`c']=mu1
	matrix B[`f',`c'+1]=mu2
	matrix B[`f',`c'+2]=diff
	
	* Tests entre grupos de tratamiento
// 	qui test _b[c.d_IPM_2@0bn.cat] = _b[c.d_IPM_2@1bn.cat]
	qui ttest d_IPM_2 ///
	if (year < 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS) 
	
	scalar p1 = round(`r(p)',0.001)
	matrix B[`f',`c'+3]=did
	matrix B[`f'+1,`c'+2]=p1
	
	* Añadir p-valor de doble diferencia
	qui test _b[c.d_IPM_2@0bn.cat] - _b[c.d_IPM_2@1bn.cat] = _b[c.d_IPM_2@2bn.cat] - _b[c.d_IPM_2@3bn.cat]
	scalar p_did = round(`r(p)',0.001)
	matrix B[`f'+1,`c'+3]=p_did
	
	* Añadir estrellas de significancia para diferencia de medias
	get_stars p1
	matrix B[`f'+1,`c'+4]=r(sig_stars)
	
	* Añadir columna con estrellas de significancia para doble diferencia
	get_stars p_did
	matrix B[`f'+1,`c'+5]=r(sig_stars)	
	
	********************
	* POST 2017: ≥2017 *
	********************
	local f=`f'+2	
	scalar mu1=_b[c.d_IPM_2@2bn.cat]
	scalar mu2=_b[c.d_IPM_2@3bn.cat]
	scalar diff = _b[c.d_IPM_2@3bn.cat]-_b[c.d_IPM_2@2bn.cat] 
	
	display "post: mu_1: " _b[c.d_IPM_2@2bn.cat]
	display "post: mu_2: " _b[c.d_IPM_2@3bn.cat]
	display "post: mu_1-mu_2: " diff
	
	matrix B[`f',`c']=mu1
	matrix B[`f',`c'+1]=mu2
	matrix B[`f',`c'+2]=diff

	
	* Tests entre grupos de tratamiento
// 	qui test _b[c.d_IPM_2@2bn.cat] = _b[c.d_IPM_2@3bn.cat]
	qui ttest d_IPM_2 ///
	if (year >= 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS)
	
	scalar p2 = round(`r(p)',0.001)
	matrix B[`f'+1,`c'+2]=p2
	
	* Añadir estrellas de significancia para diferencia de medias
	get_stars p2
	matrix B[`f'+1,`c'+4]=r(sig_stars)	
	
	* Prepare for next loop
	drop cat
	scalar drop _all
	local f=`f'+2	
}
matlist B
putexcel set "/Users/upar/Dropbox/02-MONEY/CESED/PNIS-documentos/Producto_3/Insumos/ipm_ttest_final.xlsx", sheet("import_2") modify
putexcel A1=matrix(B), names 


********************************************************
//
//
//  _______  _______           _       _________ _______  _       
// (  ____ )(  ____ \|\     /|( (    /|\__   __/(  ___  )( (    /|
// | (    )|| (    \/| )   ( ||  \  ( |   ) (   | (   ) ||  \  ( |
// | (____)|| (__    | |   | ||   \ | |   | |   | |   | ||   \ | |
// |     __)|  __)   | |   | || (\ \) |   | |   | |   | || (\ \) |
// | (\ (   | (      | |   | || | \   |   | |   | |   | || | \   |
// | ) \ \__| (____/\| (___) || )  \  |___) (___| (___) || )  \  |
// |/   \__/(_______/(_______)|/    )_)\_______/(_______)|/    )_)
//                                                               
//
* Done with:
* https://patorjk.com/software/taag/#p=display&h=0&v=0&f=Patorjk's%20Cheese&t=END
********************************************************


**# Bookmark #2 Test 
* Test 
* Reunión lunes 31 
* Comando que Lucas sugiere: test
estpost ttest d_IPM_1 if (year < 2017) & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 
estimates store comp_0_1_lt2017
estpost ttest d_IPM_1 if year >= 2017 & ejecucion_PNIS < 2, by(ejecucion_PNIS) 


qui ttest d_IPM_1 if (year < 2017) & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 
qui return list
di "diff" `r(mu_1)'-`r(mu_2)' " diff_se: "`r(se)'
ttest d_IPM_1 if (year >= 2017) & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 


gen cat = .
replace cat = 0 if ejecucion_PNIS==0 & year <2017
replace cat = 1 if ejecucion_PNIS==1 & year <2017
replace cat = 2 if ejecucion_PNIS==0 & year >=2017
replace cat = 3 if ejecucion_PNIS==1 & year >=2017

mean d_IPM_1, over(cat)
test 

* 1. Crear variable categórica que separe las 2 diferencias en 4 categorías, ver `cat'
* 2. Usando mean X, over(cat) obtenemos los 4 parámeetros que necesitamos
* 3. Usando el comando test y haciendo referencia a los parámetros luego de la 
* 	estimación 



// IPM 1
* Comparar Nada con AAI
preserve 

gen cat = . 
replace cat = 0 if ejecucion_PNIS == 0 & year < 2017
replace cat = 1 if ejecucion_PNIS == 1 & year < 2017
replace cat = 2 if ejecucion_PNIS == 0 & year >= 2017
replace cat = 3 if ejecucion_PNIS == 1 & year >= 2017

keep if ejecucion_PNIS < 2
ttest d_IPM_1 if year < 2017, by(ejecucion_PNIS) 
ttest d_IPM_1 if year >= 2017, by(ejecucion_PNIS) 

mean d_IPM_1, over(cat)
display _b[c.d_IPM_1@0bn.cat] - _b[c.d_IPM_1@1bn.cat] - _b[c.d_IPM_1@2bn.cat] + _b[c.d_IPM_1@3bn.cat]
test _b[c.d_IPM_1@0bn.cat] - _b[c.d_IPM_1@1bn.cat] = _b[c.d_IPM_1@2bn.cat] - _b[c.d_IPM_1@3bn.cat]

restore









//     ______ _   __ ____ 
//    / ____// | / // __ \
//   / __/  /  |/ // / / /
//  / /___ / /|  // /_/ / 
// /_____//_/ |_//_____/  
//                       
//


********************************************************************************
*********************** Break: The following code is now unused.
**# To Do: Revisar grupos de tratamiento



// IPM 1 --------------------------------------------------------
* Comparar Nada con AAI
est clear
estpost ttest d_IPM_1 if (year < 2017) & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 
estimates store comp_0_1_lt2017
estpost ttest d_IPM_1 if year >= 2017 & ejecucion_PNIS < 2, by(ejecucion_PNIS) 
estimates store comp_0_1_geq2017

* Comparar AAI con AAI + SA

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 2), by(ejecucion_PNIS)
est store comp_1_2_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 2), by(ejecucion_PNIS)
est store comp_1_2_geq2017

* Comparar AAI con AAI + PPCC

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 3), by(ejecucion_PNIS)
est store comp_1_3_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 3), by(ejecucion_PNIS)
est store comp_1_3_geq2017

* Comparar AAI con AAI + SA + PPCC

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_1_4_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_1_4_geq2017

* Comparar AAI + SA con AAI + SA + PPCC

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 2 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_2_4_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 2 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_2_4_geq2017

* Comparar AAI + PPCC con AAI + SA + PPCC

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 3 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_3_4_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 3 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
est store comp_3_4_geq2017

*Comparar AAI + SA + PPCC con AAI + SA + PPCC + PPCL

estpost ttest d_IPM_1 if year < 2017 & (ejecucion_PNIS == 4 | ejecucion_PNIS == 5), by(ejecucion_PNIS)
est store comp_4_5_lt2017
estpost ttest d_IPM_1 if year >= 2017 & (ejecucion_PNIS == 4 | ejecucion_PNIS == 5), by(ejecucion_PNIS)
est store comp_4_5_geq2017

* Exportar todos los estimates
est dir 

esttab comp_* using "~/Downloads/ipm1_ttests.csv", replace noobs compress nonum  ///
	cells("b(star fmt(2))" "se(par fmt(2))") ///
	 mtitles ///
	 note("Error estándar en paréntesis." "*** p<0.01, ** p<0.05 * p<0.1")

// IPM 2 --------------------------------------------------------
* Comparar Nada con AAI

est clear
estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 
estimates store comp_0_1_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS < 2), by(ejecucion_PNIS) 
estimates store comp_0_1_geq2017

* Comparar AAI con AAI + SA

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 2), by(ejecucion_PNIS)
estimates store comp_1_2_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 2), by(ejecucion_PNIS)
estimates store comp_1_2_geq2017

* Comparar AAI con AAI + PPCC

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 3), by(ejecucion_PNIS)
estimates store comp_1_3_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 3), by(ejecucion_PNIS)
estimates store comp_1_3_geq2017

* Comparar AAI con AAI + SA + PPCC

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_1_4_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 1 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_1_4_geq2017


* Comparar AAI + SA con AAI + SA + PPCC

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 2 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_2_4_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 2 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_2_4_geq2017

* Comparar AAI + PPCC con AAI + SA + PPCC

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 3 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_3_4_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 3 | ejecucion_PNIS == 4), by(ejecucion_PNIS)
estimates store comp_3_4_geq2017

*Comparar AAI + SA + PPCC con AAI + SA + PPCC + PPCL

estpost ttest d_IPM_2 if year < 2017 & (ejecucion_PNIS == 4 | ejecucion_PNIS == 5), by(ejecucion_PNIS)
estimates store comp_4_5_lt2017
estpost ttest d_IPM_2 if year >= 2017 & (ejecucion_PNIS == 4 | ejecucion_PNIS == 5), by(ejecucion_PNIS)
estimates store comp_4_5_geq2017

* Exportar todos los estimates
est dir 

esttab comp_* using "~/Downloads/ipm2_ttests.csv", replace noobs compress nonum  ///
	cells("b(star fmt(2))" "se(par fmt(2))") ///
	 mtitles ///
	 note("Error estándar en paréntesis." "*** p<0.01, ** p<0.05 * p<0.1")


// IPM 1 --------------------------------------------------------

* Definir matriz para exportar tabla
matrix define A=J(28,4,.)
matrix colnames A = "Media 1" "Media 2" "Dif. medias (p-valor)" "DiD (p-valor)" 
matrix rownames A = "Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" ""
					
**# Looped ttest for IPM 1
cls
local f=1
local c=1
return clear
forvalues row=1/7{
	local g1=N[`row', 1]
	local g2= N[`row', 2]
	di "Groups: " N[`row', 1], N[`row', 2] "********************************"
	
	* PRE 2017
	di "Para <2017 tengo que (f,c)=(`f',`c')"
	qui ttest d_IPM_1 ///
	if (year < 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS) 
// 	qui return list
	di "mu1=`r(mu_1)', mu2=`r(mu_2)' " "diff:" `r(mu_1)'-`r(mu_2)' ", p=`r(p)'"
	
	* Data on <2017 is on odd numbered rows: 1, 5, 9, 11, 15, 19, 
	matrix A[`f',`c']=r(mu_1)
	matrix A[`f',`c'+1]=r(mu_2)
	matrix A[`f',`c'+2]=r(mu_1)-r(mu_2)
	matrix A[`f'+1,`c'+2]=(r(p))
	
// 	return clear
	
	* ≥ 2017
	local f=`f'+2	
	di "Para ≥2017 tengo que (f,c)=(`f',`c')"
	qui ttest d_IPM_1 ///
	if (year >= 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS)
// 	qui return list
	di "mu1= `r(mu_1)', mu2= `r(mu_2)' " "diff:" `r(mu_1)'-`r(mu_2)' ", p=`r(p)'"
	matrix A[`f',`c']=r(mu_1)
	matrix A[`f',`c'+1]=r(mu_2)
	matrix A[`f',`c'+2]=r(mu_1)-r(mu_2)
	matrix A[`f'+1,`c'+2]=(r(p))
// 	return clear
	di "end (f,c)=(`f',`c')"
	local f=`f'+2	
}
matlist A

putexcel set "/Users/upar/Dropbox/02-MONEY/CESED/Producto_3/Insumos/ipm_ttest_final.xlsx", sheet("import") modify
putexcel A1=matrix(A), names 


// IPM 2 --------------------------------------------------------
* Definir matriz para exportar tabla
matrix define B=J(28,4,.)
matrix colnames B = "Media 1" "Media 2" "Dif. medias (p-valor)" "DiD (p-valor)" 
matrix rownames B = "Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" "" ///
					"Pre 2017" "" "Post 2017" ""
					
**# Looped ttest for IPM 2
local f=1
local c=1
return clear
forvalues row=1/7{
	local g1=N[`row', 1]
	local g2= N[`row', 2]
	di "Groups: " N[`row', 1], N[`row', 2] "********************************"
	
	* PRE 2017
	di "Para <2017 tengo que (f,c)=(`f',`c')"
	qui ttest d_IPM_2 ///
	if (year < 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS) 
// 	qui return list
	di "mu1=`r(mu_1)', mu2=`r(mu_2)' " "diff:" `r(mu_1)'-`r(mu_2)' ", p=`r(p)'"
	
	* Data on <2017 is on odd numbered rows: 1, 5, 9, 11, 15, 19, 
	matrix B[`f',`c']=r(mu_1)
	matrix B[`f',`c'+1]=r(mu_2)
	matrix B[`f',`c'+2]=r(mu_1)-r(mu_2)
	matrix B[`f'+1,`c'+2]=(r(p))
	
// 	return clear
	
	* ≥ 2017
	local f=`f'+2	
	di "Para ≥2017 tengo que (f,c)=(`f',`c')"
	qui ttest d_IPM_2 ///
	if (year >= 2017) & (ejecucion_PNIS == `g1' | ejecucion_PNIS == `g2'), ///
	by(ejecucion_PNIS)
// 	qui return list
	di "mu1= `r(mu_1)', mu2= `r(mu_2)' " "diff:" `r(mu_1)'-`r(mu_2)' ", p=`r(p)'"
	matrix B[`f',`c']=r(mu_1)
	matrix B[`f',`c'+1]=r(mu_2)
	matrix B[`f',`c'+2]=r(mu_1)-r(mu_2)
	matrix B[`f'+1,`c'+2]=(r(p))
// 	return clear
	di "end (f,c)=(`f',`c')"
	local f=`f'+2	
}
// putexcel set "/Users/upar/Dropbox/02-MONEY/CESED/Producto_3/Insumos/ipm_ttest_final.xlsx", sheet("IPM") replace
putexcel F1=matrix(B), names 	 

* End
