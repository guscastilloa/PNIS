* Preámbulo después después de correr _master.do

use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear

*----------------------------------------
* Continua CON OUTLIERS

matrix define N=J(7,2,.)
matrix colnames N = "Control"  "Tratamiento"
matrix N[1,1] = 0
matrix N[2,1] = 1
matrix N[3,1] = 1
matrix N[4,1] = 1
matrix N[5,1] = 2
matrix N[6,1] = 3
matrix N[7,1] = 4
matrix N[1,2] = 1
matrix N[2,2] = 2
matrix N[3,2] = 3
matrix N[4,2] = 4
matrix N[5,2] = 4
matrix N[6,2] = 4
matrix N[7,2] = 5
// matlist N


matrix define C=J(7,2,.)
matrix colnames C = "IPM 1" "IPM 2"
matrix rownames C = "Modelo 1" "Modelo 2" "Modelo 3" "Modelo 4" "Modelo 5" ///
					"Modelo 6" "Modelo 7"
// matlist C

forvalues M=1/7{
	local grupo_control=N[`M',1]
	qui mean IPM_1 IPM_2 if ejecucion_PNIS==`grupo_control' & year==2015
	matrix C[`M',1]=round(r(table)[1,1], 0.0001)
	matrix C[`M',2]=round(r(table)[1,2], 0.0001)
// 	di "Media paraa modelo `M' y el grupo de control es `grupo_control'"
}

matlist C

*----------------------------------------
* Continua SIN OUTLIERS

matrix define S=J(7,2,.)
matrix colnames S = "IPM 1" "IPM 2"
matrix rownames S = "Modelo 1" "Modelo 2" "Modelo 3" "Modelo 4" "Modelo 5" ///
					"Modelo 6" "Modelo 7"
matlist S

* IPM 1
preserve 
	drop if es_outlier_IPM_1==1
	forvalues M=7/7{
		local grupo_control=N[`M',1]
		qui mean IPM_1 if ejecucion_PNIS==`grupo_control' & year==2015
		matrix S[`M',1]=round(r(table)[1,1], 0.0001)
// 		di "modelo `M', g. control es `grupo_control'"
	}
restore

* IPM 2
preserve
	drop if es_outlier_IPM_2==1
	forvalues M=1/7{
		local grupo_control=N[`M',1]
		qui mean IPM_2 if ejecucion_PNIS==`grupo_control' & year==2015
		matrix S[`M',2]=round(r(table)[1,1], 0.0001)
// 		di "modelo `M', g. control es `grupo_control'"
}
restore

*----------------------------------------
* Revisar matrices listas
	* Con Outliers
	matlist C 
	
	* Sin Outliers:
	matlist S

*----------------------------------------
* Revisar matrices listas	
**# Modelo 7 truncando 2017-2020
tempfile mod0 truncado
save `mod0'
use `mod0'
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
		(year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020)
save `truncado'
* IPM 1 con outliers
mean IPM_1 if ejecucion_PNIS==4 & year==2015
di "IPM 1 con outliers: " round(r(table)[1,1], 0.0001)

* IPM 1 sin outliers

mean IPM_1 if ejecucion_PNIS==4 & year==2015 & es_outlier_IPM_1==0
di "IPM 1 sin outliers: " round(r(table)[1,1], 0.0001)

* IPM 2 con outliers
mean IPM_2 if ejecucion_PNIS==4 & year==2015
di "IPM 2 con outliers: " round(r(table)[1,1], 0.0001)

* IPM 2 sin outliers
mean IPM_2 if ejecucion_PNIS==4 & year==2015 & es_outlier_IPM_2==0
di "IPM 1 sin outliers: " round(r(table)[1,1], 0.0001)



