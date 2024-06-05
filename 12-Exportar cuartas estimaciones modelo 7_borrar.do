* Preámbulo luego de correr _main.do
* Preámbulo
clear 
cls
set more off
set rmsg off
set scheme s1mono
* Fijar globals necesarios para fijar working directory y output directory
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"
global table_output "${output}/Estimación_modelos/tablas"

* GUIA ITERACIÓN:
 * Fijo un modelo
 * Fijo un IPM
 * Itero las 5 especificaciones para obtener ATT
 
 * Model names: esp4-model3-IPM 2.ster
 
global banderita 0

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# IPM Continua
qui do "${projectfolder}/Do/12-Media de control.do"


* Iterar sobre todos los 7 modelos
forvalues M=7/7{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	* Iterar sobre las IPM's, IPM 1 e IPM 2
	forvalues I=1/2{
		di ">> IPM `I'"
		
		* Iterar sobre las 5 especificaciones
		forvalues E=1/5{
			di "> Estimacion `E'"
			qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua.ster"
			qui estat simple, estore(eesp`E')
			scalar N_OBS_`E'= e(N)
			
			qui eststo con_eststo`E'
		}
		di "off loop"
		// Cargar estimación de modelo 7 truncado
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-t.ster"
		qui estat simple, estore(eesp`E'_t)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t
		
		*-- Scalars Estimación 5 para modelo 7 truncando
		est restore eesp5_t
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "\checkmark"
		
		
		qui est dir
		*-- Scalars Estimación 1
		est restore eesp1
		estadd scalar OBS=N_OBS_1, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND " "
		qui estadd local CLMUN " "
		qui estadd local CLDEPT " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 2
		est restore eesp2
		estadd scalar OBS=N_OBS_2, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 3
		est restore eesp3
		estadd scalar OBS=N_OBS_3, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT "\checkmark"
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 4
		est restore eesp4
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Estimación 5
		est restore eesp5
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "\checkmark"
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5_t using "${table_output}/_modelo`M'-ipm`I'-continua-24ago.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
	}
	//est clear
}



//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\
//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
**# IPM continua sin outliers
cls

*esp1-model1-IPM 2-continua-no_outliers.ster
forvalues M=7/7{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	forvalues I=1/2{
		di ">> IPM `I'"
		forvalues E=1/5{
			di "> Estimacion `E'"
			qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers.ster"
			qui estat simple, estore(eesp`E')
			scalar N_OBS_`E'= e(N)
			
			qui eststo con_eststo`E'
		}
		di "off loop"
		// Cargar estimación de modelo 7 truncado
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers-t.ster"
		qui estat simple, estore(eesp`E'_t)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t
		
		*-- Scalars Estimación 5 (sin outliers) para modelo 7 truncando 
		est restore eesp5_t
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "\checkmark"
		
		
		qui est dir
		*-- Scalars Estimación 1
		est restore eesp1
		estadd scalar OBS=N_OBS_1, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND " "
		qui estadd local CLMUN " "
		qui estadd local CLDEPT " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 2
		est restore eesp2
		estadd scalar OBS=N_OBS_2, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 3
		est restore eesp3
		estadd scalar OBS=N_OBS_3, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT "\checkmark"
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 4
		est restore eesp4
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Estimación 5
		est restore eesp5
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "\checkmark"
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5_t using "${table_output}/_modelo`M'-ipm`I'-continua-no_outliers-24ago.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
	}
	//est clear
}
