/*
AUTOR:
	Lucas Marin Llanes
	Gustavo Castillo

DESCRIPCIÓN:
	En este script se estiman los modelos 3 y 4 de coca agrupando los
	proyectos productivos en uno solo como prueba de robustez. Así los grupos de
	ejecución quedarían:
	0. No recibió nada
	1. AAI
	2. SA
	3. PP (PPCC o PPCL)
	4. PP (CC o CL) & SA


	
*/

* Preámbulo luego de ejecutar _master.do
cd "${projectfolder}/Output/Modelos Coca/estimaciones/robustez PP"


use "${datafolder}/db_pnis_panel_grid_simci_coca.dta", replace 
global switch_estimation_on 0
if ${switch_estimation_on}==9{
	capture log close
	log using "${projectfolder}/Log/dinamicos_coca_robustez_PP", replace
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

* Crear variable dummy de tratamiento PP para producir las cohortes
gen d_pp = 1 if d_ppcc == 1 | d_ppcl == 1
replace d_pp = 0 if d_pp == .

* Crear grupos de ejecución primados (PP agrupado)
gen ejecución_PNIS = 0 if total_cub == 0 | ti_aai == 0
replace ejecución_PNIS = 1 if ti_aai == 1 & ti_sa == 0 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 2 if ti_sa == 1 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 3 if (ti_ppcc == 1 | ti_ppcl==1 ) & (ti_sa == 0) 
replace ejecución_PNIS = 4 if (ti_ppcc == 1 | ti_ppcl==1 ) & (ti_sa == 1)

global def_tratamiento d n p 


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
****************************
**	 	 PP vs AAI   	  **
****************************

* Crear año (cohorte) de tratamiento: esta debe tomar el año 
sort grilla year
gen year_t_PP_AAI = .
bysort grilla: replace year_t_PP_AAI = year if d_pp == 1 & d_pp[_n-1] == 0
bys grilla: ereplace year_t_PP_AAI = mean(year_t_PP_AAI)
replace year_t_PP_AAI = 0 if year_t_PP_AAI == . 

if ${switch_estimation_on}==9{
csdid ln_coca if ejecución_PNIS == 1 | ejecución_PNIS == 3, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PP_AAI)
estimates save "modeloPP-lncoca.ster", replace

csdid areacoca if ejecución_PNIS == 1 | ejecución_PNIS == 3, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PP_AAI)
estimates save "modeloPP-areacoca.ster", replace
}

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
****************************
**	 PP + SA vs AAI  	  **
**************************** 

* Definir variable de cohortes de tratamiento
gen d_pp_sa = d_pp*d_sa 
sort grilla year
gen year_t_PPSA_AAI = .
bysort grilla: replace year_t_PPSA_AAI = year if d_pp_sa == 1 & d_pp_sa[_n-1] == 0
bys grilla: ereplace year_t_PPSA_AAI = mean(year_t_PPSA_AAI)
replace year_t_PPSA_AAI = 0 if year_t_PPSA_AAI == . 

* Ejercicio a: Estimando con grupos de ejecución PNIS 1 versus 4
if ${switch_estimation_on}==9{

csdid ln_coca if ejecución_PNIS == 1 | ejecución_PNIS == 4, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-1v4.ster", replace

csdid areacoca if ejecución_PNIS == 1 | ejecución_PNIS == 4, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-1v4.ster", replace

}

* Ejercicio b: Estimando con grupos de ejecución PNIS 1 a 4: 1-4 vs 4
if ${switch_estimation_on}==9{
preserve 

keep if ejecución_PNIS==1 | ejecución_PNIS == 2 | ejecución_PNIS==3 | ejecución_PNIS==4
tab year_t_PPSA_AAI	
csdid ln_coca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-1a4.ster", replace

csdid areacoca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-1a4.ster", replace

restore 
}

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _______    | || |      _       | |
// | |  |  _____|   | || |     | |      | |
// | |  | |____     | || |     \_|      | |
// | |  '_.____''.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs SA   	  **
**************************** 
* La variable de cohorte de tratamiento para quiénes recibieron PP+SA (y AAI) 
* fue creada en el modelo anterior comparando PP+SA vs AAI, por lo que se seguirá
* usando esta variable que identifica las cohortes de tratamiento.

* Ejercicio a: Estimando con grupos de ejecución PNIS 2 versus 4'
if ${switch_estimation_on}==9{

csdid ln_coca if ejecución_PNIS == 2 | ejecución_PNIS == 4, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-2v4.ster", replace

csdid areacoca if ejecución_PNIS == 2 | ejecución_PNIS == 4, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-2v4.ster", replace

}
 
* Ejercicio b: Estimando con grupos de ejecución PNIS 2 a 4: 2-4 vs 4
if ${switch_estimation_on}==9{
preserve 

keep if ejecución_PNIS == 2 | ejecución_PNIS==3 | ejecución_PNIS==4
tab year_t_PPSA_AAI
csdid ln_coca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-2a4.ster", replace

csdid areacoca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-2a4.ster", replace

restore 
}



//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |  .' ____ \   | || |     | |      | |
// | |  | |____\_|  | || |     \_|      | |
// | |  | '____`'.  | || |              | |
// | |  | (____) |  | || |              | |
// | |  '.______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
************************
**	 SA + PP vs PP 	  **
************************

* Ejercicio a: Estimando con grupos de ejecución PNIS 3' vs 4'
if ${switch_estimation_on}==9{
preserve

tab year_t_PPSA_AAI

csdid ln_coca if ejecución_PNIS == 3 | ejecución_PNIS == 4, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-3v4.ster", replace

csdid areacoca if ejecución_PNIS == 3 | ejecución_PNIS == 4, ///
	cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-3v4.ster", replace
	
}
* Ejercicio b: Estimando con grupos de ejecición PNIS 3' a 4': 3',4' vs 4'
if ${switch_estimation_on}==9{
preserve
keep if ejecución_PNIS==3 | ejecución_PNIS==4
tab year_t_PPSA_AAI 

csdid ln_coca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-lncoca-3a4.ster", replace

csdid areacoca, cluster(cod_mpio) ivar(grilla) time(year) gvar(year_t_PPSA_AAI)
estimates save "modeloPP&SA-areacoca-3a4.ster", replace

}


log close
* End
