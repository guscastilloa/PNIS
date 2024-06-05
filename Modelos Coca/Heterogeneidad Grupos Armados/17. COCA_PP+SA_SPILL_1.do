//    _____ _____ _____ _      _      
//   / ____|  __ \_   _| |    | |     
//  | (___ | |__) || | | |    | |     
//   \___ \|  ___/ | | | |    | |     
//   ____) | |    _| |_| |____| |____ 
//  |_____/|_|   |_____|______|______|

global output_path "${projectfolder}/Output/Modelos Coca Spillovers/_heterogeneidad grupos armados/estimaciones/SPILL"

tempfile master grupos_armados
use "${projectfolder}/Datos/db_pnis_panel_grid_simci_coca_spill.dta", clear 
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

/// Borrar grillas que no han recibido ningún componente pero tienen beneficiarios (16 grillas y sus vecinas): en total 116 grillas de 283431 

drop if ejecución_PNIS == 0 & grupo_clean != 0 

/// Crear variable de tratamiento para recibir PPCC + SA

gen d_ppcc_sa = d_ppcc * d_sa 
gen vd_ppcc_sa = vd_ppcc * vd_sa 
gen vvd_ppcc_sa = vvd_ppcc * vvd_sa 

/// Regresiones


// Modelos C&S 

// CC + SA

/// A. Definir el tratamiento solo para las grillas PNIS que empiezan a ser tratadas con CC+SA

sort grilla year
gen year_t_CCSA = .
bysort grilla: replace year_t_CCSA = year if d_ppcc_sa == 1 & d_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA = mean(year_t_CCSA)
replace year_t_CCSA = 0 if year_t_CCSA == . 

/// B. Definir el tratamiento solo para las grillas vecinas de PNIS que empiezan a ser tratadas con CC+SA

sort grilla year
gen year_t_CCSA_v = .
bysort grilla: replace year_t_CCSA_v = year if vd_ppcc_sa == 1 & vd_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA_v = mean(year_t_CCSA_v)
replace year_t_CCSA_v = 0 if year_t_CCSA_v == .  

/// C. Definir el tratamiento solo para las grillas vecinas de vecinas de PNIS que empiezan a ser tratadas con CC+SA

sort grilla year
gen year_t_CCSA_vv = .
bysort grilla: replace year_t_CCSA_vv = year if vvd_ppcc_sa == 1 & vvd_ppcc_sa[_n-1] == 0
bys grilla: ereplace year_t_CCSA_vv = mean(year_t_CCSA_vv)
replace year_t_CCSA_vv = 0 if year_t_CCSA_vv == .  

/// Grillas PNIS y vecinas vs grillas controles puros
*-------------------------------------------------------------------------------
**# 2. Estimar modelo para beneficiarios en municipios grupos_armados==0
*-------------------------------------------------------------------------------
	global n_grupoarmado 1
	keep if grupos_armados==${n_grupoarmado}
	
// 	preserve 
//	
// 	keep if ejecución_PNIS == 4 | ejecución_PNIS == 0
//
// 	// 1. Grillas PNIS vs CP 
//
// 	csdid areacoca trend if grupo_clean == 1 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
// 	estimates save "${output_path}/d_PPSA_CP_1.ster", replace
//
// 	/// 2. Grillas vecinas PNIS vs CP
//
// 	csdid areacoca trend if grupo_clean == 2 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
// 	estimates save "${output_path}/v_PPSA_CP_1.ster", replace
//
// 	/// 3. Grillas vecinas de vecinas PNIS vs CP
//
// 	csdid areacoca trend if grupo_clean == 3 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
// 	estimates save "${output_path}/vv_PPSA_CP_1.ster", replace
//
// 	/// Grillas PNIS vs vecinas/vecinas2 PNIS 
//
// 	keep if ejecución_PNIS == 4
//
// 	/// 4. Grillas PNIS vs vecinas PNIS
//
// 	csdid areacoca trend if grupo_clean == 1 | grupo_clean == 2, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
// 	estimates save "${output_path}/d_PPSA_v_1.ster", replace
//
// 	/// 5. Grillas PNIS vs vecinas de vecinas PNIS
//
// 	csdid areacoca trend if grupo_clean == 1 | grupo_clean == 3, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
// 	estimates save "${output_path}/d_PPSA_vv_1.ster", replace
//
// 	restore 


	/// Grillas PNIS y vecinas vs grillas solo AAI 

	keep if ejecución_PNIS == 4 | ejecución_PNIS == 1 // Quedarnos solo con CC+SA y AAI

	drop if grupo_clean != 1 & ejecución_PNIS == 1 // Quedarnos de las de AAI, solo con las que son PNIS

	// 6. Grillas PNIS vs solo AAI 
	
	csdid areacoca trend if grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_AAI_1.ster", replace

	//drop if ejecución_PNIS == 4 & grupo_clean == 1 // Quitar a las grillas PNIS para mirar efectos de CC+SA en vecinas 

	/// 7. Grillas vecinas PNIS vs solo AAI 
	
	csdid areacoca trend if grupo_clean == 2 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
	estimates save "${output_path}/v_PPSA_AAI_1.ster", replace

	/// 8. Grillas vecinas de vecinas PNIS vs solo AAI 
	
	csdid areacoca trend if grupo_clean == 3 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
	estimates save "${output_path}/vv_PPSA_AAI_1.ster", replace










