/// Revisión panel de datos del SISBÉN III y IV ///

set more off
set scheme s1mono

use "${datafolder}/SISBEN/db_sisben-pnis_panel.dta", clear 

// Verificar que todos los cubs tengan al menos 2 observaciones //
bys cub: gen N = _N
tab N

// Verificar que no haya duplicados a nivel de cub-año //
duplicates tag cub year, gen(d)
tab d

// Verificar el número de cub únicos en el panel: 77839 - 78.5% //
preserve
collapse documento_titular, by(cub)
restore 

// Construir la distribución temporal de la primera observación para cada cub //
preserve
sort cub year
bysort cub: keep if _n == 1
tab year 
hist year, frac ///
	xtitle("Años") ytitle("Proporción de primeras actualizaciones por año", size(med)) ///
	subtitle("Distribución temporal de primeras actualizaciones en el Sisbén") ///
	note("Nota: La distribución acumulada al 2015 es del 91.5% y hasta el 2013 del 84.3%", size(vsmall)) 
graph export "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Cuanti-PNIS/Gráficos/dist_temporal_1srobs.png", as(png) replace
restore 


// Construir el panel balanceado desde el primer año para el cual se tiene información //


xtset cub year

tsfill, full

// Quitar todas las variables del PNIS, esas después se agregan cuando esté el panel SISBÉN listo // 

drop c_* pp_* treated_* aai_total ati_total meses_ati

/// Remplazar por el valor anterior para cada una de las variables numéricas y alfanuméricas 

foreach x of varlist N activi activo acueduc agua alcanta asiste auto1 basura bieraices buscando carnet cocina cocinan computador comuna cuandi cuanhoras cub d depmuni_int depto documento_titular edad elimbasura embaraza energia estcivil fecham fechanto ficha gas grado i_agua i_bajo_educativo i_desempleo_largo i_excretas i_hacimiento i_inasistencia_escolar i_paredes i_pisos i_rezago_escolar i_salud i_trabajo_infantil ind_conyuge_vive_hogar ind_discap_bañarse ind_discap_entender ind_discap_hablar ind_discap_moverse ind_discap_ninguna ind_discap_oir ind_discap_salir ind_discap_ver ingreso ingresos ipm_indice jefeug lavadora llega moto nevera nivel orden pared parentes percibe piso preparan retirado sanitar sexo sis suminis suspendido tcuartos tcuartosvi tdormir telecontac telefono teneviv thogar tipodoc tpersona tractor usosani usanitar vivienda zona {
	
	bysort cub: replace `x' = `x'[_n-1] if `x' == . 

}

foreach x of varlist actividad ape1 ape2 nom1 nom2 id_ficha id_hogar nombarrio nomvereda unigasto direcc puntaje_sisben_3_trunc grupo_sis_3 {
	
	bysort cub: replace `x' = `x'[_n-1] if `x' == "" 
	
}

***************************
***						***
***   CONSTRUCCIÓN IPM 	***
***						***
***************************

// Creación del IPM con dos opciones: manteniendo pesos de las dimensiones y manteniendo pesos de las privaciones

// Dimensiones 

gen IPM_1 = (i_bajo_educativo + i_desempleo_largo + i_salud) * 0.2 + ///
	(i_inasistencia_escolar + i_rezago_escolar + i_trabajo_infantil) * 0.067 + ///
	(i_agua + i_excretas + i_paredes + i_pisos + i_hacimiento) * 0.04

gen d_IPM_1 = 1 if IPM_1 > 0.33 & IPM_1 != .
replace d_IPM_1 = 0 if IPM_1 <= 0.33

// Privaciones 

gen IPM_2 = (i_bajo_educativo + i_desempleo_largo + i_salud) * 0.1538 + ///
	(i_inasistencia_escolar + i_rezago_escolar + i_trabajo_infantil) * 0.0769 + ///
	(i_agua + i_excretas + i_paredes + i_pisos + i_hacimiento) * 0.0615

gen d_IPM_2 = 1 if IPM_2 > 0.33 & IPM_2 != .
replace d_IPM_2 = 0 if IPM_2 <= 0.33

save "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Cuanti-PNIS/Datos/SISBEN/db_sisben_panel_VF.dta", replace 
* End
