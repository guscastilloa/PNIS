/*
AUTOR:
	Lucas Marin Llanes
	Gustavo Castillo

DESCRIPCIÓN:
	En este script se estima solo una especificación para cada uno de los siguientes
	modelos de coca:
	1. AAI
	2. SA
	3. PPCC
	4. PPCC & SA
	5. PPCL

*/

* Preámbulo luego de ejecutar _master.do
use "${datafolder}/db_pnis_panel_grid_simci_coca.dta", replace 
global switch_estimation_on 9
if ${switch_estimation_on}==9{
	capture log close
	log using "${projectfolder}/dinamicos_coca_notrend", replace
}
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

gen ejecución_PNIS = 0 if total_cub == 0 | ti_aai == 0
replace ejecución_PNIS = 1 if ti_aai == 1 & ti_sa == 0 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 2 if ti_sa == 1 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 3 if ti_ppcc == 1 & ti_sa == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 4 if ti_ppcc == 1 & ti_sa == 1 & ti_ppcl == 0 
replace ejecución_PNIS = 5 if ti_ppcl == 1

/// Regresiones
cd "${output}/Modelos Coca"

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
**********************************************
**# Tratamiento para C&S - Event Study - AAI 
**********************************************

sort grilla year
gen year_t_AAI_Nada = .
bysort grilla: replace year_t_AAI_Nada = year if d_aai == 1 & d_aai[_n-1] == 0
bys grilla: ereplace year_t_AAI_Nada = mean(year_t_AAI_Nada)
replace year_t_AAI_Nada = 0 if year_t_AAI_Nada == . 
if ${switch_estimation_on}==9{
	
csdid ln_coca if ejecución_PNIS == 0 | ejecución_PNIS == 1, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_AAI_Nada)
estimates save "estimaciones/modeloAAI-lncoca.ster", replace
// estat all
// estat event, window(-6 6)
// csdid_plot
// graph export "d_aai_ln_coca.png", as(png) replace

csdid areacoca if ejecución_PNIS == 0 | ejecución_PNIS == 1, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_AAI_Nada)
estimates save "estimaciones/modeloAAI-areacoca.ster", replace
// estat all
// estat event, window(-6 6)
// csdid_plot
// graph export "d_aai_areacoca.png", as(png) replace
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
**********************************************
**# Tratamiento para C&S - Event Study - SA 
**********************************************
* Crear cohortes de tratamiento
sort grilla year
gen year_t_SA_AAI = .
bysort grilla: replace year_t_SA_AAI = year if d_sa == 1 & d_sa[_n-1] == 0
bys grilla: ereplace year_t_SA_AAI = mean(year_t_SA_AAI)
replace year_t_SA_AAI = 0 if year_t_SA_AAI == . 

if ${switch_estimation_on}==9{
csdid ln_coca if ejecución_PNIS == 1 | ejecución_PNIS == 2, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_SA_AAI)
estimates save "estimaciones/modeloSA-lncoca.ster", replace

csdid areacoca if ejecución_PNIS == 1 | ejecución_PNIS == 2, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_SA_AAI)
estimates save "estimaciones/modeloSA-areacoca.ster", replace
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
*********************************************
**# Tratamiento para C&S - Event Study - PPCC 
*********************************************

sort grilla year
gen year_t_PPCC_AAI = .
bysort grilla: replace year_t_PPCC_AAI = year if d_ppcc == 1 & d_ppcc[_n-1] == 0
bys grilla: ereplace year_t_PPCC_AAI = mean(year_t_PPCC_AAI)
replace year_t_PPCC_AAI = 0 if year_t_PPCC_AAI == . 

if ${switch_estimation_on}==9{
csdid ln_coca if ejecución_PNIS == 1 | ejecución_PNIS == 3, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCC_AAI)
estimates save "estimaciones/modeloPPCC-lncoca.ster", replace

csdid areacoca if ejecución_PNIS == 1 | ejecución_PNIS == 3, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCC_AAI)
estimates save "estimaciones/modeloPPCC-areacoca.ster", replace
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
*********************************************
**# Tratamiento para C&S - Event Study - PPCC & SA 
*********************************************
gen d_ppcc_sa = d_ppcc*d_sa 
sort grilla year
gen year_t_PPCCSA_AAI = .
bysort grilla: replace year_t_PPCCSA_AAI = year if d_ppcc_sa == 1 & d_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_PPCCSA_AAI = mean(year_t_PPCCSA_AAI)
replace year_t_PPCCSA_AAI = 0 if year_t_PPCCSA_AAI == . 

* Estimando con grupos de ejecución PNIS 1 versus 4
if ${switch_estimation_on}==9{

csdid ln_coca if ejecución_PNIS == 1 | ejecución_PNIS == 4, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCCSA_AAI)
estimates save "estimaciones/modeloPPCC&SA-lncoca-1v4.ster", replace

csdid areacoca if ejecución_PNIS == 1 | ejecución_PNIS == 4, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCCSA_AAI)
estimates save "estimaciones/modeloPPCC&SA-areacoca-1v4.ster", replace

}


* Estimando con grupos de ejecución PNIS 1 a 4
if ${switch_estimation_on}==9{
preserve 

drop if ejecución_PNIS == 0 | ejecución_PNIS == 5 

csdid ln_coca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCCSA_AAI)
estimates save "estimaciones/modeloPPCC&SA-lncoca-1a4.ster", replace

csdid areacoca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCCSA_AAI)
estimates save "estimaciones/modeloPPCC&SA-areacoca-1a4.ster", replace

restore 
}


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
**********************************************
**# Tratamiento para C&S - Event Study - PPCL
**********************************************

sort grilla year
gen year_t_PPCL = .
bysort grilla: replace year_t_PPCL = year if d_ppcl == 1 & d_ppcl[_n-1] == 0
bys grilla: ereplace year_t_PPCL = mean(year_t_PPCL)
replace year_t_PPCL = 0 if year_t_PPCL == . 

if ${switch_estimation_on}==9{
preserve
keep if ejecución_PNIS == 4 | ejecución_PNIS == 5 

csdid ln_coca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCL)
estimates save "estimaciones/modeloPPCL-lncoca.ster", replace

csdid areacoca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPCL)
estimates save "estimaciones/modeloPPCL-areacoca.ster", replace
restore
}

log close
* End
