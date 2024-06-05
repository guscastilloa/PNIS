* Preámbulo luego de correr _main.do
* Preámbulo
clear 
cls
set more off
set rmsg off
set scheme s1mono
* Fijar globals necesarios para fijar working directory y output directory
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"
global table_output "${output}/Modelos IPM/tablas"

* GUIA ITERACIÓN:
 * Fijo un modelo
 * Fijo un IPM
 * Itero las 5 especificaciones para obtener ATT
 
 * Model names: esp4-model3-IPM 2.ster
 
global banderita 0
if ${banderita}==1{
//   _____  _    _ __  __ __  ____     __
//  |  __ \| |  | |  \/  |  \/  \ \   / /
//  | |  | | |  | | \  / | \  / |\ \_/ / 
//  | |  | | |  | | |\/| | |\/| | \   /  
//  | |__| | |__| | |  | | |  | |  | |   
//  |_____/ \____/|_|  |_|_|  |_|  |_|   
**# IPM Dummy                       

//------------------------------------------------------------------------------
// 	 	IPM 1	    
//------------------------------------------------------------------------------
* Cargar estimaciones

* Iterar especificaciones
global num_especificacion 1
forvalues x=1/5{
	estimates use "${dir_estimaciones}/esp`x'-${modelo}-IPM ${num_ipm}.ster"
	estat simple, estore(eesp`x')
	eststo
} 
**# Bookmark #1
esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/${modelo}-ipm`I'.csv", ///
	replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("EFT EF Tiempo" "EFU EF Unidad" "CLMUN Cluster Mun." "CLDEPT Cluster Depto" "TRUNC Truncado") ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

cls
**# Loop para exportar tablas en TeX

forvalues M=1/7{
	di "**************************************""
	di ">>> MODELO `M' **************************************"
	forvalues I=1/2{
		di ">> IPM `I'"
		forvalues E=1/5{
			di "> Estimacion `E'"
			qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'.ster"
			qui estat simple, estore(eesp`E')
			scalar N_OBS_`E'= e(N)
			
			qui eststo con_eststo`E'
		}
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
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5 using "${table_output}/_modelo`M'-ipm`I'.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
	}
	//est clear
}
}

* Correr do file que produce matriz con los promedios de control 
* para cada uno de los modelos.
qui do "${projectfolder}/Do/Modelos IPM/12-Media de control.do"


//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# Modelos 1 a 2 IPM Continua

cls

*esp1-model1-IPM 1-continua.ster

* Iterar sobre los modelos 1 a 2
forvalues M=1/2{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	
	* Iterar sobrelas IPMs: IPM 1 e IPM 2
	forvalues I=1/2{
		di ">> IPM `I'"
		
		* Cargar Estimación de Especificación 4
		local E=4
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		* Cargar Estimación de Especificación 5
		local E=5
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		*-- Scalars Especificación 4
		est restore eesp4_`I'
		di "antes "
		local controlmean=C[`M',`I']
		di "desp"
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Especificación 5 truncado
		est restore eesp5_`I'
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "\checkmark"
		
	}	
		esttab eesp4_1 eesp5_1 eesp4_2 eesp5_2 using "${table_output}/_modelo`M'-continua.tex", ///
			mtitles("Esp. 4" "Esp. 5" "Esp. 4" "Esp. 5") ///
			mgroups("IPM 1" "IPM 2", pattern(1 0 1 0) ///
				prefix(\multicolumn{@span}{c}{) suffix(})   ///
				span erepeat(\cmidrule(lr){@span})) ///
			nonum ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
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
**# Modelos 1 a 6 IPM continua sin outliers
cls

*esp1-model1-IPM 2-continua-no_outliers.ster
forvalues M=1/6{
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
		// Cargar estimación de modelo 7 truncando 2017,2018 ("-t.ster")
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers-t.ster"
		qui estat simple, estore(eesp`E'_t)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t
		
		// Cargar estimación de modelo 7 truncando 2017-2020 ("-t2.ster")
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers-t2.ster"
		qui estat simple, estore(eesp`E'_t2)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t2
		
		qui est dir
		*-- Scalars Estimación 1
		est restore eesp1
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_1, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND " "
		qui estadd local CLMUN " "
		qui estadd local CLDEPT " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 2
		est restore eesp2
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_2, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 3
		est restore eesp3
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_3, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT "\checkmark"
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 4
		est restore eesp4
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Estimación 5 truncando 2017, 2018
		est restore eesp5_t
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2017-2018"
		
		*-- Scalars Estimación 5 truncando 2017-2020
		est restore eesp5_t2
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2017-2020"
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5_t eesp5_2 using "${table_output}/_modelo`M'-ipm`I'-continua-no_outliers-28ago.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
	}
	//est clear
}



//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 

* EN adelante se realiza el mismo procedimiento que arriba pero únicamente para 
* el modelo 7 truncado, que la especificación 5 consta de truncar las cohortes
* 2017-2020, que fue la última actualización discutida la semana del
* 24 de agosto.


//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# Modelo 7 IPM Continua 

cls

*esp1-model1-IPM 1-continua-t.ster

* Fijar modelo 7
forvalues M=7/7{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	
	* Iterar sobrelas IPMs: IPM 1 e IPM 2
	forvalues I=1/2{
		di ">> IPM `I'"
		
		* Iterar sobre las 4 especificaciones que no tienen truncamiento
		forvalues E=1/4{
			di "> Estimacion `E'"
			qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua.ster"
			qui estat simple, estore(eesp`E')
			scalar N_OBS_`E'= e(N)
			
			qui eststo con_eststo`E'
		}
		di "off loop"
		
// 		// Cargar estimación de modelo 7 truncando 2017,2018
// 		local E 5
// 		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-t.ster"
// 		qui estat simple, estore(eesp`E'_t)
// 		scalar N_OBS_`E'= e(N)	
// 		qui eststo con_eststo`E'_t
		
		// Cargar estimación de modelo 7 truncando 2017-2020
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-t2.ster"
		qui estat simple, estore(eesp`E'_t2)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t2
		
		qui est dir
		*-- Scalars Estimación 1
		est restore eesp1
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_1, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND " "
		qui estadd local CLMUN " "
		qui estadd local CLDEPT " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 2
		est restore eesp2
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_2, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 3
		est restore eesp3
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_3, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT "\checkmark"
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 4
		est restore eesp4
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Estimación 5 truncando 2017, 2018
// 		est restore eesp5_t
// 		local controlmean=C[`M',`I']
// 		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 		estadd scalar OBS=N_OBS_5, replace
// 		qui estadd local EFT "\checkmark"
// 		qui estadd local EFU "\checkmark"
// 		qui estadd local TREND "\checkmark"
// 		qui estadd local CLDEPT " "
// 		qui estadd local CLMUN "\checkmark"
// 		qui estadd local TRUNC "2017-2018"
		
		*-- Scalars Estimación 5 truncando 2017-2020
		est restore eesp5_t2
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2017-2020"
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5_t2 using "${table_output}/_modelo`M'-ipm`I'-continua.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
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
**# Modelo 7 IPM continua sin outliers
cls

* Fijando el modeo 7
forvalues M=7/7{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	
	* Iterando sobre las IPMs
	forvalues I=1/2{
		di ">> IPM `I'"
		
		* Iterando sobre las 4 especificaciones sin truncamiento
		forvalues E=1/4{
			di "> Estimacion `E'"
			qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers.ster"
			qui estat simple, estore(eesp`E')
			scalar N_OBS_`E'= e(N)
			
			qui eststo con_eststo`E'
		}
		di "off loop"
// 		// Cargar estimación de modelo 7 truncando 2017,2018 ("-t.ster")
// 		local E 5
// 		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers-t.ster"
// 		qui estat simple, estore(eesp`E'_t)
// 		scalar N_OBS_`E'= e(N)	
// 		qui eststo con_eststo`E'_t
		
		// Cargar estimación de modelo 7 truncando 2017-2020 ("-t2.ster")
		local E 5
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-continua-no_outliers-t2.ster"
		qui estat simple, estore(eesp`E'_t2)
		scalar N_OBS_`E'= e(N)	
		qui eststo con_eststo`E'_t2
		
		qui est dir
		*-- Scalars Estimación 1
		est restore eesp1
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_1, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND " "
		qui estadd local CLMUN " "
		qui estadd local CLDEPT " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 2
		est restore eesp2
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_2, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 3
		est restore eesp3
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_3, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT "\checkmark"
		qui estadd local CLMUN " "
		qui estadd local TRUNC " "
		*-- Scalars Estimación 4
		est restore eesp4
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Estimación 5 truncando 2017, 2018
// 		est restore eesp5_t
// 		local controlmean=C[`M',`I']
// 		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
// 		estadd scalar OBS=N_OBS_5, replace
// 		qui estadd local EFT "\checkmark"
// 		qui estadd local EFU "\checkmark"
// 		qui estadd local TREND "\checkmark"
// 		qui estadd local CLDEPT " "
// 		qui estadd local CLMUN "\checkmark"
// 		qui estadd local TRUNC "2017-2018"
		
		*-- Scalars Estimación 5 truncando 2017-2020
		est restore eesp5_t2
		local controlmean=S[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2017-2020"
		
		qui esttab eesp1 eesp2 eesp3 eesp4 eesp5_t2 using "${table_output}/_modelo`M'-ipm`I'-continua-no_outliers.tex", ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
	}
	//est clear
}

