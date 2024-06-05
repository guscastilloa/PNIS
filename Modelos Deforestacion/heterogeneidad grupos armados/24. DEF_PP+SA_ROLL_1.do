global output_path "${projectfolder}/Output/Deforestacion/_heterogeneidad grupos armados/estimaciones/ROLL"
use "${projectfolder}/Datos/base_estimaciones_deforestacion_grupos_armados_roll.dta", replace

*-------------------------------------------------------------------------------
**# 2. Estimar modelo para beneficiarios en municipios grupos_armados==1
*-------------------------------------------------------------------------------
	global n_grupoarmado 1
	keep if grupos_armados==${n_grupoarmado}
	/// Grillas PNIS y vecinas vs grillas potenciales tratadas de CC+SA

	// 1. Grillas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA)
	estimates save "${output_path}/d_PPSA_ROLL_1.ster", replace

	drop if ejecución_PNIS == 4 & grupo_clean == 1

	/// 2. Grillas vecinas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 2 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_v)
	estimates save "${output_path}/v_PPSA_ROLL_1.ster", replace

	/// 3. Grillas vecinas de vecinas PNIS vs grillas potenciales tratadas de CC+SA

	csdid p_loss trend if grupo_clean == 3 | grupo_clean == 1, cluster(cod_ver) ivar(grilla) time(year) gvar(year_t_CCSA_vv)
	estimates save "${output_path}/vv_PPSA_ROLL_1.ster", replace
