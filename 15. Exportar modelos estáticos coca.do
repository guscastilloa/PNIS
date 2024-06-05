/*
DESCRIPCION:
	Exportar gráficas de modelos estáticos de modelos de coca. Recordar que
	las 5 especificaciones se caracterizan por:	
	* Esp 1: FE grilla y año
	* Esp 2: FE grilla y año, interacción (tendencia)
	* Esp 3: FE grilla y año, interacción (tendencia), cluster municipio
	* Esp 4: FE grilla y año, interacción (tendencia), cluster vereda
	* Esp 5: FE grilla y año, interacción (tendencia), cluster grilla
		
*/

* Preambulo
global dir_estimaciones "${projectfolder}/Output/Modelos Coca/estimaciones"
global table_output "${output}/Estimación_modelos/tablas/coca/estaticos"
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
local modelnum 1
local tratamiento "aai"

*----------------------------------------
* AREA COCA: areacoca
local Y "areacoca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	di "`t'_aai "
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		
// 		di "> Estimacion `E'"
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
// 		scalar N_OBS_`E'= e(N)
		}
{
	// 	*-- Scalars Estimación de Especificación 1
// 	est restore eesp1
// // 	local controlmean=C[`M',`I']
// 	qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 	estadd scalar OBS=N_OBS_1, replace
// 	qui estadd local EFG "\checkmark" // EF GRILLA
// 	qui estadd local EFA "\checkmark" // EF AÑO
// 	qui estadd local TREND " "	// Tendencia
// 	qui estadd local CLMUN " " // Cluster Mun
// 	qui estadd local CLVER " "// Cluster Vereda
// 	qui estadd local CLGR " " // Cluster Grilla
//	
// 	*-- Scalars Estimación de Especificación 2
// 	est restore eesp2
// 	local controlmean=C[`M',`I']
// 	qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 	estadd scalar OBS=N_OBS_2, replace
// 	qui estadd local EFG "\checkmark"	// EF GRILLA
// 	qui estadd local EFA "\checkmark"	// EF AÑO
// 	qui estadd local TREND "\checkmark"	// Tendencia
// 	qui estadd local CLMUN " " 			// Cluster Mun
// 	qui estadd local CLVER " "			// Cluster Vereda
// 	qui estadd local CLGR " " 			// Cluster Grilla
//	
// 	*-- Scalars Estimación de Especificación 3
// 	est restore eesp3
// 	local controlmean=C[`M',`I']
// 	qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 	estadd scalar OBS=N_OBS_3, replace
// 	qui estadd local EFG "\checkmark"	// EF GRILLA
// 	qui estadd local EFA "\checkmark"	// EF AÑO
// 	qui estadd local TREND "\checkmark"	// Tendencia
// 	qui estadd local CLMUN "\checkmark"	// Cluster Mun
// 	qui estadd local CLVER " "			// Cluster Vereda
// 	qui estadd local CLGR " " 			// Cluster Grilla
// 	*-- Scalars Estimación de Especificación 4
// 	est restore eesp4
// 	local controlmean=C[`M',`I']
// 	qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 	estadd scalar OBS=N_OBS_4, replace
// 	qui estadd local EFG "\checkmark"	// EF GRILLA
// 	qui estadd local EFA "\checkmark"	// EF AÑO
// 	qui estadd local TREND "\checkmark"	// Tendencia
// 	qui estadd local CLMUN " "			// Cluster Mun
// 	qui estadd local CLVER "\checkmark"	// Cluster Vereda
// 	qui estadd local CLGR " " 			// Cluster Grilla
// 	*-- Scalars Estimación de Especificación 5 truncando 2017, 2018
// 	est restore eesp5_t
// 	local controlmean=C[`M',`I']
// 	qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 	estadd scalar OBS=N_OBS_5, replace
// 	qui estadd local EFG "\checkmark"	// EF GRILLA
// 	qui estadd local EFA "\checkmark"	// EF AÑO
// 	qui estadd local TREND "\checkmark"	// Tendencia
// 	qui estadd local CLMUN " "			// Cluster Mun
// 	qui estadd local CLVER " "			// Cluster Vereda
// 	qui estadd local CLGR "\checkmark"	// Cluster Grilla
}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("A. Coca") nomtitle

}

*----------------------------------------
* LOGARITMO COCA
local Y "ln_coca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	di "`t'_aai "
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		
// 		di "> Estimacion `E'"
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("Ln. Coca") nomtitle

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
local modelnum 2
local tratamiento "sa"

*----------------------------------------
* AREA COCA: areacoca
local Y "areacoca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("A. Coca") nomtitle

}

*----------------------------------------
* LOGARITMO COCA
local Y "ln_coca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("Ln. Coca") nomtitle 

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
local modelnum 3
local tratamiento "ppcc"

*----------------------------------------
* AREA COCA: areacoca
local Y "areacoca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("A. Coca") nomtitle

}

*----------------------------------------
* LOGARITMO COCA
local Y "ln_coca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("Ln. Coca") nomtitle

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
local modelnum 4
local tratamiento "ppcc_sa"
local t "d"

*----------------------------------------
* AREA COCA: areacoca
local Y "areacoca"

* Iterar sobre tipo tratamiento: d, n, p
forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
	keep(`t'_* 1.d_ppcc#1.d_sa) main(b %6.3f) aux(se %6.3f) nonotes /// 
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
	"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	booktabs replace collabels("A. Coca") nomtitle
	
*----------------------------------------
* LOGARITMO COCA: ln_coca
local Y "ln_coca"

* Iterar sobre 5 especificaciones
forvalues E=1/5{ // - - - - - - - - - - - - - - - 
	qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
	qui eststo eesp`E'
	}

esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
	keep(`t'_* 1.d_ppcc#1.d_sa) main(b %6.3f) aux(se %6.3f) nonotes /// 
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
	"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	booktabs replace collabels("Ln. Coca") nomtitle

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
local modelnum 5
local tratamiento "ppcl"

*----------------------------------------
* AREA COCA areacoca ln_coca
local Y "areacoca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("A. Coca") nomtitle

}

*----------------------------------------
* LOGARITMO COCA
local Y "ln_coca"

* Iterar sobre tipo tratamiento: d, n, p
foreach t of global def_tratamiento { // - - - - - - - - - - - - - - - 
	
	* Iterar sobre 5 especificaciones
	forvalues E=1/5{ // - - - - - - - - - - - - - - - 
		qui estimates use "${dir_estimaciones}/fixed effects/FE-M`modelnum'-E`E'-`t'_`tratamiento'_`Y'.ster"
		qui eststo eesp`E'
		}

	esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/M`modelnum'-`Y'_`t'_`tratamiento'", ///
		keep(`t'_*) main(b %6.3f) aux(se %6.3f) nonotes /// 
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		scalars("EFG EF Grilla" "EFA EF Año" "TREND Tendencia" ///
		"CLMUN Cluster Mun." "CLVER Cluster Vereda" "CLGR Cluster Grilla") ///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
		booktabs replace collabels("Ln. Coca") nomtitle

}
