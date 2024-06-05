global output_path "${projectfolder}/Output/Deforestacion/_heterogeneidad grupos armados/estimaciones/ROLL"

tempfile master grupos_armados
use "${projectfolder}/Datos/db_pnis_panel_grid_simci_coca_spill.dta", clear 

merge 1:1 grilla year using "${projectfolder}/Datos/db_deforestacion.dta", gen(u1)

keep if u1 == 3 /// hay grillas (2203) que no tiene cobertura forestal en el año 2000 (denominador para calcular el área perdida), entonces no las tenemos en cuenta

// Guardar base para pegue con grupos armados
	save `master'

	use "${projectfolder}/Datos/armed_presence.dta", clear
		rename cod_dane_mpio cod_mpio
		rename d grupos_armados
		label variable grupos_armados "Presencia de grupos armados"
		label define larmed 0 "Sin presencia" 1 "Un grupo armado" 2 "En disputa", replace
		label values grupos_armados larmed 
		save `grupos_armados'

	use `master'

	merge m:1 cod_mpio using `grupos_armados'

/// El percentil 99 de porcentaje de deforestación es 10.4, hay valores atípicos por encima de 100%. Identificamos esos valores y borramos las grillas (123) que tienen esos valores 

gen out = 1 if p_loss > 100
bysort grilla: ereplace out = mean(out)
drop if out== 1

/// Empieza el arreglo normal para los tratamientos del PNIS

global componentes aai sa ppcc ppcl

egen trend= group(cod_dpto  year)

/// Definir una variable de tratamiento si la grilla recibió alguno de los proyectos productivos

replace d_ppcc = d_ppcl if d_ppcc == 0 & d_ppcl == 1 // Por notación del script mantenemos CC para que el número de cambios sean menores - PNIS. Cambian 77 obs
replace vd_ppcc = vd_ppcl if vd_ppcc == 0 & vd_ppcl == 1 // Por notación del script mantenemos CC para que el número de cambios sean menores - Vecina PNIS. Cambian 85 obs
replace vvd_ppcc = vvd_ppcl if vvd_ppcc == 0 & vvd_ppcl == 1 // Por notación del script mantenemos CC para que el número de cambios sean menores - Vecina de vecina PNIS. Cambian 9 obs

/// Crear una variable que integre la información de grilla PNIS, vecina PNIS y vecina de vecina PNIS 

foreach x of global componentes { 
	
	gen D_`x' = d_`x' + vd_`x' + vvd_`x'
	
}

/// Crear un indicador que no cambie en el tiempo para seleccionar las muestras de grillas en cada modelo

foreach x of global componentes  {
	
	bysort grilla: egen ti_`x' = mean(D_`x')
	replace ti_`x' = 1 if ti_`x' > 0
	tab ti_`x' year
	
}

tab ti_aai ti_sa
tab ti_aai ti_ppcc
tab ti_sa ti_ppcc

gen ejecución_PNIS = 0
replace ejecución_PNIS = 1 if ti_aai == 1 & ti_sa == 0 & ti_ppcc == 0 
replace ejecución_PNIS = 2 if ti_sa == 1 & ti_ppcc == 0
replace ejecución_PNIS = 3 if ti_ppcc == 1 & ti_sa == 0
replace ejecución_PNIS = 4 if ti_ppcc == 1 & ti_sa == 1

/// Pegar con grillas tratadas por componente desde el 2022 

merge m:1 grilla using "${projectfolder}/Datos/grillas_t_2022.dta", gen(u2)

foreach x of varlist T22_* { 
	
	replace `x' = 0 if `x' == . 
	
}

/// Crear una variable conjunta para grillas que empiezan a ser tratadas por al PP en el 2022

replace T22_PPCC = T22_PPCL if T22_PPCC == 0 & T22_PPCL == 1 // Por notación del script mantenemos CC para que el número de cambios sean menores - PNIS. Cambian 312 obs

/// Crear variable de tratamiento para recibir PPCC + SA

gen d_ppcc_sa = d_ppcc * d_sa 
gen vd_ppcc_sa = vd_ppcc * vd_sa 
gen vvd_ppcc_sa = vvd_ppcc * vvd_sa 

/// Regresiones

// Crear indicador de grillas que reciben SA y CC en el 2022 pero no antes

gen T22_CC_SA = T22_PPCC*T22_SA

/// Solo necesitamos a las tratadas con CC+SA y las que solo han recibido AAI hasta el 2021 pero que en 2022 reciben CC+SA (mejor control posible)

keep if ejecución_PNIS == 4 | T22_CC_SA == 1
keep if ejecución_PNIS == 4 | ejecución_PNIS == 1

// cd "C:\Users\l.marinl\OneDrive - Universidad de los andes\Evaluación PNIS\Resultados deforestación" 

// Modelos C&S 

// PP + SA

/// A. Definir el tratamiento solo para las grillas PNIS que empiezan a ser tratadas con PP+SA

sort grilla year
gen year_t_CCSA = .
bysort grilla: replace year_t_CCSA = year if d_ppcc_sa == 1 & d_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA = mean(year_t_CCSA)
replace year_t_CCSA = 0 if year_t_CCSA == . 

/// B. Definir el tratamiento solo para las grillas vecinas de PNIS que empiezan a ser tratadas con PP+SA

sort grilla year
gen year_t_CCSA_v = .
bysort grilla: replace year_t_CCSA_v = year if vd_ppcc_sa == 1 & vd_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA_v = mean(year_t_CCSA_v)
replace year_t_CCSA_v = 0 if year_t_CCSA_v == .  

/// C. Definir el tratamiento solo para las grillas vecinas de vecinas de PNIS que empiezan a ser tratadas con PP+SA

sort grilla year
gen year_t_CCSA_vv = .
bysort grilla: replace year_t_CCSA_vv = year if vvd_ppcc_sa == 1 & vvd_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA_vv = mean(year_t_CCSA_vv)
replace year_t_CCSA_vv = 0 if year_t_CCSA_vv == .  

save "${projectfolder}/Datos/base_estimaciones_deforestacion_grupos_armados_roll.dta", replace

use "${projectfolder}/Datos/base_estimaciones_deforestacion_grupos_armados_roll.dta", replace

*-------------------------------------------------------------------------------
**# 2. Estimar modelo para beneficiarios en municipios grupos_armados==0
*-------------------------------------------------------------------------------
	global n_grupoarmado 0
	keep if grupos_armados==${n_grupoarmado}
	/// Grillas PNIS y vecinas vs grillas potenciales tratadas de CC+SA

	// 1. Grillas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_ROLL_0.ster", replace

	drop if ejecución_PNIS == 4 & grupo_clean == 1

	/// 2. Grillas vecinas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 2 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
	estimates save "${output_path}/v_PPSA_ROLL_0.ster", replace

	/// 3. Grillas vecinas de vecinas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 3 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
	estimates save "${output_path}/vv_PPSA_ROLL_0.ster", replace
