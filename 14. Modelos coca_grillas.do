/*
AUTOR:
	Lucas Marin Llanes
	Gustavo Castillo
	
DESCRIPCIÓN:
	En este script se crea la variable de ejecución y las variables de tratamiento
	para la estimación de los modelos estáticos con efectos fijos.
*/


* Preámbulo luego de ejecutar _master.do
use "${datafolder}/db_pnis_panel_grid_simci_coca.dta", replace 

gen ln_coca = log(areacoca+1)

global componentes aai sa ppcc ppcl

egen trend= group(cod_dpto  year)

foreach x of global componentes  {
	
	bysort grilla: egen ti_`x' = mean(d_`x')
	replace ti_`x' = 1 if ti_`x' > 0
	tab ti_`x' year
	
}

tab ti_aai ti_sa
tab ti_aai ti_ppcc
tab ti_aai ti_ppcl
tab ti_sa ti_ppcc
tab ti_sa ti_ppcl
tab ti_ppcc ti_ppcl

gen ejecución_PNIS = 0 if total_cub == 0
replace ejecución_PNIS = 1 if ti_aai == 1 & ti_sa == 0 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 2 if ti_sa == 1 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 3 if ti_ppcc == 1 & ti_sa == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 4 if ti_ppcc == 1 & ti_sa == 1 & ti_ppcl == 0 
replace ejecución_PNIS = 5 if ti_ppcl == 1
replace ejecución_PNIS = 0 if ti_aai == 0

/// Regresiones

cd "${output}/Modelos Coca/estimaciones/fixed effects"

global def_tratamiento d n p 

//  .----------------. 
// | .--------------. |
// | |     __       | |
// | |    /  |      | |
// | |    `| |      | |
// | |     | |      | |
// | |    _| |_     | |
// | |   |_____|    | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
** AAI vs No recibió nada **
****************************
/// AAI 

foreach y of varlist areacoca ln_coca { 
	
	foreach t of global def_tratamiento { 
		* Esp 1: FE grilla y año
		reghdfe `y' `t'_aai if ejecución_PNIS == 0 | ejecución_PNIS == 1, ///
			a(grilla year)
		estimates save "FE-M1-E1-`t'_aai_`y'.ster", replace
// 		outreg2 using "`t'_aai_`y'", tex replace dec(3)

		* Esp 2: FE grilla y año, interacción
		reghdfe `y' `t'_aai c.year##i.cod_dpto if ejecución_PNIS == 0 | ejecución_PNIS == 1, ///
			a(grilla year)
		estimates save "FE-M1-E2-`t'_aai_`y'.ster", replace	
// 		outreg2 using "`t'_aai_`y'", tex append dec(3)
		
		* Esp 3: FE grilla y año, interacción, cluster municipio
		reghdfe `y' `t'_aai c.year##i.cod_dpto if ejecución_PNIS == 0 | ejecución_PNIS == 1, ///
			a(grilla year) cluster(cod_mpio)
		estimates save "FE-M1-E3-`t'_aai_`y'.ster", replace	
// 		outreg2 using "`t'_aai_`y'", tex append dec(3)
		
		* Esp 4: FE grilla y año, interacción, cluster vereda
		reghdfe `y' `t'_aai c.year##i.cod_dpto if ejecución_PNIS == 0 | ejecución_PNIS == 1, ///
			a(grilla year) cluster(cod_ver)
		estimates save "FE-M1-E4-`t'_aai_`y'.ster", replace	
// 		outreg2 using "`t'_aai_`y'", append dec(3)
		
		* Esp 5: FE grilla y año, interacción, cluster grilla
		reghdfe `y' `t'_aai c.year##i.cod_dpto if ejecución_PNIS == 0 | ejecución_PNIS == 1, ///
			a(grilla year) cluster(grilla)	
		estimates save "FE-M1-E5-`t'_aai_`y'.ster", replace	
// 		outreg2 using "`t'_aai_`y'", append dec(3)
	}
	
}
//  .----------------. 
// | .--------------. |
// | |    _____     | |
// | |   / ___ `.   | |
// | |  |_/___) |   | |
// | |   .'____.'   | |
// | |  / /____     | |
// | |  |_______|   | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 	 SA vs AAI   	  **
**************************** 
/// SA 

foreach y of varlist areacoca ln_coca { 
	
	foreach t of global def_tratamiento { 
		* Esp 1: FE grilla y año
		reghdfe `y' `t'_sa if ejecución_PNIS == 1 | ejecución_PNIS == 2, a(grilla year)
		estimates save "FE-M2-E1-`t'_sa_`y'.ster", replace	
		
		* Esp 2: FE grilla y año, interacción
		reghdfe `y' `t'_sa c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 2, ///
			a(grilla year)
		estimates save "FE-M2-E2-`t'_sa_`y'.ster", replace	
		
		* Esp 3: FE grilla y año, interacción, cluster municipio
		reghdfe `y' `t'_sa c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 2, ///
			a(grilla year) cluster(cod_mpio)
		estimates save "FE-M2-E3-`t'_sa_`y'.ster", replace	
		
		* Esp 4: FE grilla y año, interacción, cluster vereda
		reghdfe `y' `t'_sa c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 2, ///
			a(grilla year) cluster(cod_ver)
		estimates save "FE-M2-E4-`t'_sa_`y'.ster", replace	
		
		* Esp 5: FE grilla y año, interacción, cluster grilla
		reghdfe `y' `t'_sa c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 2, ///
			a(grilla year) cluster(grilla)
		estimates save "FE-M2-E5-`t'_sa_`y'.ster", replace	

	}
	
}
//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |   / ____ `.  | |
// | |   `'  __) |  | |
// | |   _  |__ '.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 	 PPCC vs AAI   	  **
****************************
/// PPCC 

foreach y of varlist areacoca ln_coca { 
	
	foreach t of global def_tratamiento { 
		* Esp 1: FE grilla y año
		reghdfe `y' `t'_ppcc if ejecución_PNIS == 1 | ejecución_PNIS == 3, a(grilla year)
		estimates save "FE-M3-E1-`t'_ppcc_`y'.ster", replace	
		
		* Esp 2: FE grilla y año, interacción
		reghdfe `y' `t'_ppcc c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 3, a(grilla year)
		estimates save "FE-M3-E2-`t'_ppcc_`y'.ster", replace	
		
		* Esp 3: FE grilla y año, interacción, cluster municipio
		reghdfe `y' `t'_ppcc c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 3, a(grilla year) cluster(cod_mpio)
		estimates save "FE-M3-E3-`t'_ppcc_`y'.ster", replace	
		
		* Esp 4: FE grilla y año, interacción, cluster vereda
		reghdfe `y' `t'_ppcc c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 3, a(grilla year) cluster(cod_ver)
		estimates save "FE-M3-E4-`t'_ppcc_`y'.ster", replace	
		
		* Esp 5: FE grilla y año, interacción, cluster grilla
		reghdfe `y' `t'_ppcc c.year##i.cod_dpto if ejecución_PNIS == 1 | ejecución_PNIS == 3, a(grilla year) cluster(grilla)
		estimates save "FE-M3-E5-`t'_ppcc_`y'.ster", replace	
	}
	
}

//  .----------------. 
// | .--------------. |
// | |   _    _     | |
// | |  | |  | |    | |
// | |  | |__| |_   | |
// | |  |____   _|  | |
// | |      _| |_   | |
// | |     |_____|  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 PPCC + SA vs AAI  	  **
**************************** 
/// SA+PPCC 

preserve 

drop if ejecución_PNIS == 0 | ejecución_PNIS == 5

foreach y of varlist areacoca ln_coca { 
	* Esp 1: FE grilla y año	
	reghdfe `y' d_ppcc d_sa i.d_ppcc##i.d_sa, a(grilla year)
	estimates save "FE-M4-E1-d_ppcc_sa_`y'.ster", replace
	
	* Esp 2: FE grilla y año, interacción
	reghdfe `y' d_ppcc d_sa i.d_ppcc##i.d_sa c.year##i.cod_dpto, a(grilla year)
	estimates save "FE-M4-E2-d_ppcc_sa_`y'.ster", replace
	
	* Esp 3: FE grilla y año, interacción, cluster municipio
	reghdfe `y' d_ppcc d_sa i.d_ppcc##i.d_sa c.year##i.cod_dpto, a(grilla year) cluster(cod_mpio)
	estimates save "FE-M4-E3-d_ppcc_sa_`y'.ster", replace
	
	* Esp 4: FE grilla y año, interacción, cluster vereda
	reghdfe `y' d_ppcc d_sa i.d_ppcc##i.d_sa c.year##i.cod_dpto, a(grilla year) cluster(cod_ver)
	estimates save "FE-M4-E4-d_ppcc_sa_`y'.ster", replace
	
	* Esp 5: FE grilla y año, interacción, cluster grilla
	reghdfe `y' d_ppcc d_sa i.d_ppcc##i.d_sa c.year##i.cod_dpto, a(grilla year) cluster(grilla)
	estimates save "FE-M4-E5-d_ppcc_sa_`y'.ster", replace
	
}

restore
//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  _____|   | |
// | |  | |____     | |
// | |  '_.____''.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 PPCL + SA vs SA   	  **
**************************** 
/// PPCL 

foreach y of varlist areacoca ln_coca { 
	
	foreach t of global def_tratamiento { 
		* Esp 1: FE grilla y año
		reghdfe `y' `t'_ppcl if ejecución_PNIS == 4 | ejecución_PNIS == 5, ///
			a(grilla year)
		estimates save "FE-M5-E1-`t'_ppcl_`y'.ster", replace
		
		* Esp 2: FE grilla y año, interacción
		reghdfe `y' `t'_ppcl c.year##i.cod_dpto if ejecución_PNIS == 4 | ejecución_PNIS == 5, ///
			a(grilla year)
		estimates save "FE-M5-E2-`t'_ppcl_`y'.ster", replace
		
		* Esp 3: FE grilla y año, interacción, cluster municipio
		reghdfe `y' `t'_ppcl c.year##i.cod_dpto if ejecución_PNIS == 4 | ejecución_PNIS == 5, ///
			a(grilla year) cluster(cod_mpio)
		estimates save "FE-M5-E3-`t'_ppcl_`y'.ster", replace
		
		* Esp 4: FE grilla y año, interacción, cluster vereda
		reghdfe `y' `t'_ppcl c.year##i.cod_dpto if ejecución_PNIS == 4 | ejecución_PNIS == 5, ///
			a(grilla year) cluster(cod_ver)
		estimates save "FE-M5-E4-`t'_ppcl_`y'.ster", replace
		
		* Esp 5: FE grilla y año, interacción, cluster grilla
		reghdfe `y' `t'_ppcl c.year##i.cod_dpto if ejecución_PNIS == 4 | ejecución_PNIS == 5, ///
			a(grilla year) cluster(grilla)
		estimates save "FE-M5-E5-`t'_ppcl_`y'.ster", replace
	}
	
}




