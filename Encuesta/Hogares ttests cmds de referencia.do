/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	1/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final.

*/

* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas"
use "${projectfolder}/Datos/db_encuesta_hogar.dta", clear

*-------------------------------------------------------------------------------
**# 1. Crear grupos de ejecución
*-------------------------------------------------------------------------------
foreach x of varlist c09_08 c09_10 c09_12 c09_13 { 
	
	replace `x' = 1 if `x' == 2
	label define eti_`x' 0 "No" 1 "Sí"
	label values `x' eti_`x'

	}

gen d=1

tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0  // 53 nada
tab d [aw = factor_exp] if c09_08 == 1 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 //234 solo aai
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 1 & c09_12 == 0 & c09_13 == 0 // 12 solo sa
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 1 & c09_13 == 0  // 10 solo ppcc
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 1  // 0 solo ppcl

tab d [aw = factor_exp] if c09_10 == 1 & c09_12 == 0 & c09_13 == 0 // 436  sa sin ppcc
tab d [aw = factor_exp] if c09_10 == 0 & c09_12 == 1 & c09_13 == 0  // 75  ppcc sin sa
tab d [aw = factor_exp] if c09_10 == 1 & c09_12 == 1 & c09_13 == 0  // 315 solo ppcl
tab d [aw = factor_exp] if c09_13 == 1  // 72 solo ppcl

gen ejecución_PNIS = .
replace ejecución_PNIS = 0 if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 
replace ejecución_PNIS = 1 if c09_08 == 1 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 
replace ejecución_PNIS = 2 if c09_10 == 1 & c09_12 == 0 & c09_13 == 0
replace ejecución_PNIS = 3 if c09_10 == 0 & c09_12 == 1 & c09_13 == 0
replace ejecución_PNIS = 4 if c09_10 == 1 & c09_12 == 1 & c09_13 == 0
replace ejecución_PNIS = 5 if c09_13 == 1 & actividad != 3

label define grupos 0 "Nada" 1 "Asistencia Alimentaria Inmediata" 2 "Seguridad Alimentaria" 3 "Ciclo corto" 4 "SA + CC" 5 "Ciclo largo"
label values ejecución_PNIS grupos

tab ejecución_PNIS [aw=factor_exp]
tab ejecución_PNIS actividad

* Crear variables agrupadoras por cada componente

* No haber recibido nada
gen l_Nada = 1 if ejecución_PNIS==0
replace l_Nada =0 if linea=="base"
label define lnada 1 "Nada" 0 "Línea Base", replace
label values l_Nada lnada
label variable l_Nada "Nada vs LB"
tab l_Nada

* AAI
tab linea
gen l_AAI = 1 if ejecución_PNIS==1
replace l_AAI=0 if linea=="base"
label define laai 1 "AAI" 0 "Línea Base", replace
label values l_AAI laai
label variable l_AAI "AAI vs LB"
tab l_AAI

* SA
gen l_SA = 1 if ejecución_PNIS==2
replace l_SA=0 if linea=="base"
label define lsa 1 "SA" 0 "Línea Base", replace
label values l_SA lsa
label variable l_SA "SA vs LB"
tab l_SA

* CC
gen l_CC = 1 if ejecución_PNIS==3
replace l_CC=0 if linea=="base"
label define lcc 1 "CC" 0 "Línea Base", replace
label values l_CC lcc
label var l_CC "CC vs LB"
tab l_CC

* CCSA
gen l_CCSA = 1 if ejecución_PNIS==4
replace l_CCSA=0 if linea=="base"
label define lccsa 1 "CC&SA" 0 "Línea Base", replace
label values l_CCSA lccsa
label variable l_CCSA "CC&SA vs LB"
tab l_CCSA

* CL
gen l_CL = 1 if ejecución_PNIS==5
replace l_CL=0 if linea=="base"
label define lcl 1 "CL" 0 "Línea Base", replace
label values l_CL lcl
label variable l_CL "CL vs LB"
tab l_CL

// Revisar que hayan quedado bien construidas las variables 
tab ejecución_PNIS
tab l_Nada
tab l_AAI
tab l_SA
tab l_CC
tab l_CCSA
tab l_CL

*-------------------------------------------------------------------------------
**# 2. Preparar variables
*-------------------------------------------------------------------------------


 
*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------


* Pregunta 1:
	* Nada
	global c2p1 c02_01_d1 c02_01_d2 c02_01_d3 c02_01_d4 c02_01_d5 c02_01_d6
	estpost ttest ${c2p1}, by(l_Nada)
	eststo p10

	* AAI
	global c2p1 c02_01_d1 c02_01_d2 c02_01_d3 c02_01_d4 c02_01_d5 c02_01_d6
	estpost ttest ${c2p1}, by(l_AAI)
	eststo p11
	
	esttab p10 p11, wide

ttest c02_01_d1, by(l_Nada)
return list
di r(mu_1)
	
foreach x of global c2p1{
	ttest "`x'", by(l_Nada)
	
	
}	
	
	
	
global c2p2 c02_02a_d1 c02_02a_d2 c02_02a_d3 c02_02a_d4 c02_02a_d5
estpost ttest ${c2p2}, by(l_Nada)
eststo p2


esttab p1 p2, wide


cls
foreach v in c04_02_02_1 c04_02_02_2 c04_02_02_3 c04_02_02_4 c04_02_02_90{
	di "`v'"
// 	sum `v'
	ttest `v', by(linea)
	di _newline(5)
}
ttest c04_02_02_1, by(linea)

global vars c04_02_02_1 c04_02_02_2 c04_02_02_3 c04_02_02_4 c04_02_02_90
estpost ttest ${vars}, by(linea)
esttab using "${output_table}/individuos_cap3.tex", ///
	cells("mu_1(fmt(3)) mu_2 b(star fmt(2)) N_1(fmt(0)) N_2(fmt(0))") ///
	wide star(* 0.10 ** 0.05 *** 0.01) label nonum compress ///
	collabels("L. Base" "L. Final" "Diff (Base-Final)" "Obs L. Base" "Obs L. Final") booktabs
	
	
	