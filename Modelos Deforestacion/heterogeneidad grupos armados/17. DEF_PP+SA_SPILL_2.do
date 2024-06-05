global output_path "${projectfolder}/Output/Deforestacion/_heterogeneidad grupos armados/estimaciones"

use "${projectfolder}/Datos/base_estimaciones_deforestacion_grupos_armados.dta", replace
*-------------------------------------------------------------------------------
**# 2. Estimar modelo para beneficiarios en municipios grupos_armados==0
*-------------------------------------------------------------------------------
	global n_grupoarmado 2
	keep if grupos_armados==${n_grupoarmado}
	
	/// Grillas PNIS y vecinas vs grillas controles puros

	preserve 

	// cd "C:\Users\l.marinl\OneDrive - Universidad de los andes\Evaluación PNIS\Resultados deforestación" 

	keep if ejecución_PNIS == 4 | ejecución_PNIS == 0

	// 1. Grillas PNIS vs CP 

	csdid p_loss trend if grupo_clean == 1 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_CP_2.ster", replace

	/// 2. Grillas vecinas PNIS vs CP

	csdid p_loss trend if grupo_clean == 2 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
	estimates save "${output_path}/v_PPSA_CP_2.ster", replace

	/// 3. Grillas vecinas de vecinas PNIS vs CP

	csdid p_loss trend if grupo_clean == 3 | grupo_clean == 0, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
	estimates save "${output_path}/vv_PPSA_CP_2.ster", replace

	/// Grillas PNIS vs vecinas/vecinas2 PNIS 

	keep if ejecución_PNIS == 4

	/// 4. Grillas PNIS vs vecinas PNIS

	csdid p_loss trend if grupo_clean == 1 | grupo_clean == 2, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_v_2.ster", replace

	/// 5. Grillas PNIS vs vecinas de vecinas PNIS

	csdid p_loss trend if grupo_clean == 1 | grupo_clean == 3, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_vv_2.ster", replace

	restore 

	// cd "C:\Users\l.marinl\OneDrive - Universidad de los andes\Evaluación PNIS\Resultados deforestación" 

	/// Grillas PNIS y vecinas vs grillas solo AAI 

	keep if ejecución_PNIS == 4 | ejecución_PNIS == 1 // Quedarnos solo con CC+SA y AAI

	drop if grupo_clean != 1 & ejecución_PNIS == 1 // Quedarnos de las de AAI, solo con las que son PNIS

	// 6. Grillas PNIS vs solo AAI 

	csdid p_loss trend if grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_AAI_2.ster", replace

	drop if ejecución_PNIS == 4 & grupo_clean == 1 // Quitar a las grillas PNIS para mirar efectos de CC+SA en vecinas 

	/// 7. Grillas vecinas PNIS vs solo AAI 

	csdid p_loss trend if grupo_clean == 2 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
	estimates save "${output_path}/v_PPSA_AAI_2.ster", replace

	/// 8. Grillas vecinas de vecinas PNIS vs solo AAI 

	csdid p_loss trend if grupo_clean == 3 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
	estimates save "${output_path}/vv_PPSA_AAI_2.ster", replace










