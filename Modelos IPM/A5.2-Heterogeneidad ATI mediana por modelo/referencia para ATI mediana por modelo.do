* Modelo 4
// keep if ejecucion_PNIS ==1 | ejecucion_PNIS ==4
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4), d
	scalar med = r(p50)
	di med
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
// 	tab d_ati

tab year_t_PPCCySA d_ati if year==2017 & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4)

log using "${projectfolder}/Log/Estimar heter ATI Mediana por modelo", replace

di _newline(5)

* ATI==0
preserve
keep if d_ati==0
tab year_t_PPCCySA d_ati if year==2017 & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4)
csdid IPM_1 trend if ///
			ejecucion_PNIS == 1 | ///
			ejecucion_PNIS == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPCC_AAI)
restore
di _newline(9)

* ATI==1
preserve
keep if d_ati==1
tab year_t_PPCCySA d_ati if year==2017 & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4)
csdid IPM_1 trend if ///
			ejecucion_PNIS == 1 | ///
			ejecucion_PNIS == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPCC_AAI)

estat all
restore
di _newline(9)

* ATI==2
preserve
keep if d_ati==2
tab year_t_PPCCySA d_ati if year==2017 & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4)
csdid IPM_1 trend if ///
			ejecucion_PNIS == 1 | ///
			ejecucion_PNIS == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPCC_AAI)
estat all
restore
capture log close
