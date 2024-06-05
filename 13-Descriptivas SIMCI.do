/*
AUTOR:
	Gustavo Castillo
	
DESCRIPCIÓN:
	En este script hago el análisis inicial de la variabilidad de la ejecución 
	de los componentes del PNIS a nivel grilla año


*/

* Preambulo
use "${projectfolder}/Datos/db_sisben_pnis_panel_VF.dta", clear

drop if year < 2016

* Pegar con base SIMCI
merge m:1 cub using "${datafolder}/db_join_simci_&_pnis.dta", gen(u2)

keep if u2==3 // quitar a quienes no tienen georreferenciación 

gen rec_noactivo=1 if actividad=="Recolector" | activo==0 // quedarnos solo con activos que sean cultivadores o no cultivadores 

*------------------------------------------------------------------------------
**# Crear variables de tratamiento en el tiempo
*------------------------------------------------------------------------------

{
****************************
** AAI **
****************************

global var_umbral "c_aai_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=2000000		// Global de umbral para crear var trat dummy
global treatment_variable "t_AAI"		// Global para var de componente

// 1. Crear tratamiento dummy

gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
	${treatment_variable} == . 
replace ${treatment_variable} = 0 if ${treatment_variable} == . & rec_noactivo != 1

// 3. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} ${var_umbral} 


****************************
**	 	 SA   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

* A continuación prepararemos los globals que se usarán para la definición de
* las variables de tratamiento, de año de tratamiento, grupos de control y 
* tratamiento, y demás. Esto recude la probabilidad de error humano en la 
* creación de las variables y facilita encontrar errores.

global treatment_variable "t_SA"		// Global para var de componente
global var_umbral "c_sa_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=1620000			// Global de umbral para crear var trat dummy

// 1. Crear tratamiento dummy

gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
	${treatment_variable} == . 
replace ${treatment_variable} = 0 if ${treatment_variable} == . & rec_noactivo != 1

// 3. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} ${var_umbral} 


****************************
**	 	 PPCC   	  **
**************************** 
global treatment_variable "t_PPCC"		// Global para var de componente
global var_umbral "c_pp_total_cc"				// Global para crear componente dummy
global umbral_monto_tratado=8100000			// Global de umbral para crear var trat dummy

// 1. Crear componente dummy

gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
	${treatment_variable} == . 
replace ${treatment_variable} = 0 if ${treatment_variable} == . & rec_noactivo != 1

// 3. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} ${var_umbral}

****************************
**	 PPCL  	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global treatment_variable "t_PPCL"		// Global para var de componente
global var_umbral "c_pp_total_cl"		// Global para crear componente dummy
global umbral_monto_tratado=9000000		// Global de umbral para crear var trat dummy

// 1. Crear tratamiento dummy

gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
	${treatment_variable} == . 
replace ${treatment_variable} = 0 if ${treatment_variable} == . & rec_noactivo != 1

// 2. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} ${var_umbral}
}

save "${projectfolder}/Datos/base_panel_simci.dta", replace
*------------------------------------------------------------------------------
**# Colapsar grilla-año
*------------------------------------------------------------------------------
use "${projectfolder}/Datos/base_panel_simci.dta", clear

drop if actividad == "Recolector" | activo == 0

gen d_aai_2 = 1 if aai_total >= 2000000 & aai_total != . 
replace d_aai_2 = 0 if aai_total < 2000000

foreach X of varlist d_aai d_sa d_ppcc d_ppcl{
	bysort cub: ereplace `X'=mean(`X')
	replace `X'=1 if `X'>0 & `X'!=.
}
tab year d_aai

collapse (count) count_aai=d_aai count_sa=d_sa count_pocc=d_ppcc count_ppcl=d_ppcl ///
		(sd) sd_t_AAI=t_AAI sd_t_SA=t_SA sd_t_PPCC=t_PPCC ///
				sd_t_PPCL=t_PPCL ///
				sd_aai = d_aai sd_sa=d_sa sd_ppcc = d_ppcc sd_ppcl = d_ppcl ///
		(mean) mean_t_AAI=t_AAI mean_t_SA=t_SA mean_t_PPCC=t_PPCC ///
				mean_t_PPCL=t_PPCL, by(grilla year)
save "${datafolder}/collapse_sdgrilla.dta", replace

sum mean_t_AAI if mean_t_AAI>0
sum mean_t_SA if mean_t_SA>0
sum mean_t_PPCC if mean_t_PPCC>0
sum mean_t_PPCL if mean_t_PPCL>0

sum mean_t_* , d

*------------------------------------------------------------------------------
**# Promedio anual de desviaciones estándar
*------------------------------------------------------------------------------ 

global componentes "AAI SA PPCC PPCL"
global componentes_l "aai sa ppcc ppcl"
foreach C of global componentes_l{
	di "`C'"
	matrix define `C'=J(7,4,.)
	matrix colnames `C' = "Promedio" "std" "N CUB" "std CUB"
	matrix rownames `C' = "2016" "2017" "2018" "2019" "2020" "2021" ///
						"2022" 
}
matlist aai


foreach C of global componentes_l{
	local row = 1
	di "mean_t_`C'"
	forvalues Y=2016/2022{
		qui sum sd_t_`C' if year==`Y'
		qui return list
		matrix `C'[`row',1]=round(r(mean),0.0001)
		matrix `C'[`row',2]=round(r(sd),0.0001)
		
		qui sum count_cub if year==`Y'
		matrix `C'[`row',3]=round(r(mean),0.01)
		matrix `C'[`row',4]=round(r(sd),0.01)
		local row=`row'+1
		
		
	}	
}
matlist AAI
matlist SA
matlist PPCC
matlist PPCL

// use "${projectfolder}/Datos/base_panel_simci.dta", clear
// collapse (count) cub, by(grilla)
// sum cub

