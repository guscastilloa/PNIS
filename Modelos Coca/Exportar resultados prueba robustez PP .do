/*
AUTOR:
	Gustavo Castillo
	
DESCRIPCIÓN:
	En este script se producen los reultados de las estimaciones de los modelos
	dinámicos de coca para la prueba de robustez de PP agrupado.
	
NOTA:
	Para que este script pueda ejecutarse se requiere primero haber
	creado las variables de cohortes de tratamiento que se crean en el script
	"18. Modelos coca_grillas PP agrupado robustez". Se procuró no incluir una
	línea que lo ejecutara dado el riesgo de que tenga el "switch" de estimación
	activado (un global) y vuelva a estimar los modelos, una actividad que toma
	mucho tiempo.
*/

* Preámbulo luego de ejecutar _master.do
cd "${projectfolder}/Output/Modelos Coca/tablas"
global dir_estimaciones "${projectfolder}/Output/Modelos Coca/estimaciones/robustez PP"
global output "${projectfolder}/Output/Modelos Coca/tablas"

use "${datafolder}/db_pnis_panel_grid_simci_coca.dta", replace 
global switch_estimation_on 0
if ${switch_estimation_on}==9{
	capture log close
	log using "${projectfolder}/Log/dinamicos_coca_robustez_PP", replace
}
gen ln_coca = log(areacoca+1)

global componentes aai sa ppcc ppcl

egen trend= group(cod_dpto  year)

foreach x of global componentes  {
	
	bysort grilla: egen ti_`x' = mean(d_`x')
	replace ti_`x' = 1 if ti_`x' > 0
	tab ti_`x' year
	
}

tab ti_aai ti_sa
tab ti_aai ti_ppcc
tab ti_aai ti_ppcl
tab ti_sa ti_ppcc
tab ti_sa ti_ppcl
tab ti_ppcc ti_ppcl

* Crear variable dummy de tratamiento PP para producir las cohortes
gen d_pp = 1 if d_ppcc == 1 | d_ppcl == 1
replace d_pp = 0 if d_pp == .

* Crear grupos de ejecución primados (PP agrupado)
gen ejecución_PNIS = 0 if total_cub == 0 | ti_aai == 0
replace ejecución_PNIS = 1 if ti_aai == 1 & ti_sa == 0 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 2 if ti_sa == 1 & ti_ppcc == 0 & ti_ppcl == 0 
replace ejecución_PNIS = 3 if (ti_ppcc == 1 | ti_ppcl==1 ) & (ti_sa == 0) 
replace ejecución_PNIS = 4 if (ti_ppcc == 1 | ti_ppcl==1 ) & (ti_sa == 1)

label define ejecucion_prima 0 "No recibió nada" 1 "Recibió solo AAI" ///
							 2 "Recibió SA" 3 "Recibió PP" ///
							 4 "Recibió SA+PP"

label values ejecución_PNIS ejecucion_prima

* 			En este punto se debe referir a la nota
*			en el encabezado para asegurar que se cuente
*			con las variables de cohortes de tratamiento
*			necesarias.

*-------------------------------------------------------------------------
**# Cohortes de tratamiento:

* Nota: Para la construcción de las tablas de cohortes de tratamiento 
* se debe revisar el número de grillas en 1 año para sacasr el porcentaje
* de cada celda. Se puede revisar ejecutando:
*	tab ejecución_PNIS if year==2017
* y luego revisando el r(N) resultante, que para este caso es 283.431.

*-------------------------------------------------------------------------
tab ejecución_PNIS if year==2017
scalar denom = r(N)
scalar di denom
//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |   / ____ `.  | || |     | |      | |
// | |   `'  __) |  | || |     \_|      | |
// | |   _  |__ '.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 	 PP vs AAI   	  **
**************************** 

qui estpost tab year_t_PP_AAI ejecución_PNIS ///
	if (ejecución_PNIS==1 | ejecución_PNIS==3) & year==2017
	
global control: label ejecucion_prima 1
global tratamiento: label ejecucion_prima 3

qui esttab using "cohortes-robustezPP-PPvAAI.tex", replace ///
	wide unstack compress eqlabels("$control" "$tratamiento") nonum ///
	nonote noobs booktabs
	
	
* >> Producir matrices con porcentajes para porcentajes en overleaf
	tab year_t_PP_AAI ejecución_PNIS ///
		if (ejecución_PNIS==1 | ejecución_PNIS==3) & year==2017, matcell(X)
	scalar tot=r(N)
	qui matlist X
	mat Z=(X/denom)*100
	matlist Z
	di "Total: " round((tot/denom)*100,0.01)

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _    _     | || |      _       | |
// | |  | |  | |    | || |     | |      | |
// | |  | |__| |_   | || |     \_|      | |
// | |  |____   _|  | || |              | |
// | |      _| |_   | || |              | |
// | |     |_____|  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs AAI  	  **
**************************** 

	* 1v4
	qui estpost tab year_t_PPSA_AAI ejecución_PNIS if ///
		(ejecución_PNIS==1 | ejecución_PNIS==4) & year==2017
	global control: label ejecucion_prima 1
	global tratamiento: label ejecucion_prima 4

	qui esttab using "cohortes-robustezPP-PPSAvAAI-1v4.tex", replace ///
		wide unstack compress eqlabels("$control" "$tratamiento") nonum ///
		nonote noobs booktabs
		
		* >> Producir matrices con porcentajes para porcentajes en overleaf
		tab year_t_PPSA_AAI ejecución_PNIS if ///
			(ejecución_PNIS==1 | ejecución_PNIS==4) & year==2017, matcell(X)
		scalar tot=r(N)
		qui matlist X
		mat Z=(X/denom)*100
		matlist Z
		di "Total: " round((tot/denom)*100,0.01)
		
	
	* 1a4
	qui estpost tab year_t_PPSA_AAI ejecución_PNIS if ///
		(ejecución_PNIS==1 | ejecución_PNIS==2 | ///
		ejecución_PNIS==3 | ejecución_PNIS==4) & year==2017
		
	qui esttab using "cohortes-robustezPP-PPSAvAAI-1a4.tex", replace ///
		wide unstack compress eqlabels("$control" "$tratamiento") nonum ///
		nonote noobs
		
		* >> Producir matrices con porcentajes para porcentajes en overleaf
		tab year_t_PPSA_AAI ejecución_PNIS if ///
			(ejecución_PNIS==1 | ejecución_PNIS==2 | ///
			ejecución_PNIS==3 | ejecución_PNIS==4) & year==2017, matcell(X)
		scalar tot=r(N)
		qui matlist X
		mat Z=(X/denom)*100
		matlist Z
		di "Total: " round((tot/denom)*100,0.01)		
		
//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _______    | || |      _       | |
// | |  |  _____|   | || |     | |      | |
// | |  | |____     | || |     \_|      | |
// | |  '_.____''.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs SA   	  **
**************************** 
qui estpost tab year_t_PPSA_AAI ejecución_PNIS if ///
	(ejecución_PNIS==2 | ejecución_PNIS==4) & year==2017

global control: label ejecucion_prima 2
global tratamiento: label ejecucion_prima 4

qui esttab using "cohortes-robustezPP-PPSAvSA.tex", replace ///
	wide unstack compress eqlabels("$control" "$tratamiento") nonum ///
	nonote noobs booktabs
	
* >> Producir matrices con porcentajes para porcentajes en overleaf
	tab year_t_PPSA_AAI ejecución_PNIS if ///
		(ejecución_PNIS==2 | ejecución_PNIS==4) & year==2017, matcell(X)
	scalar tot=r(N)
	qui matlist X
	mat Z=(X/denom)*100
	matlist Z
	di "Total: " round((tot/denom)*100,0.01)	

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |  .' ____ \   | || |     | |      | |
// | |  | |____\_|  | || |     \_|      | |
// | |  | '____`'.  | || |              | |
// | |  | (____) |  | || |              | |
// | |  '.______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
************************
**	 SA + PP vs PP 	  **
************************
qui estpost tab year_t_PPSA_AAI ejecución_PNIS if ///
	(ejecución_PNIS==3 | ejecución_PNIS==4) & year==2017

global control: label ejecucion_prima 3
global tratamiento: label ejecucion_prima 4

qui esttab using "cohortes-robustezPP-PPSAvPP.tex", replace ///
	wide unstack compress eqlabels("$control" "$tratamiento") nonum ///
	nonote noobs booktabs

* >> Producir matrices con porcentajes para porcentajes en overleaf
	tab year_t_PPSA_AAI ejecución_PNIS if ///
		(ejecución_PNIS==3 | ejecución_PNIS==4) & year==2017, matcell(X)
	scalar tot=r(N)
	qui matlist X
	mat Z=(X/denom)*100
	matlist Z
	di "Total: " round((tot/denom)*100,0.01)

*-------------------------------------------------------------------------------
**# Exportar tablas con ATTs variable (con outliers)
*-------------------------------------------------------------------------------
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
matlist N

matrix define C=J(7,2,.)
matrix colnames C = "Area Coca" "Ln Coca"
matrix rownames C = "Modelo 1" "Modelo 2" "Modelo 3'" "Modelo 4'" "Modelo 5'" ///
				"Modelo 6'" "Modelo 7"				

forvalues M=3/6{
	local grupo_control=N[`M',1]
	di "Control: `grupo_control'"
	qui mean areacoca ln_coca if ejecución_PNIS ==`grupo_control' & year==2015
	matrix C[`M',1]=round(r(table)[1,1], 0.0001)
	matrix C[`M',2]=round(r(table)[1,2], 0.0001)
// 	di "Media paraa modelo `M' y el grupo de control es `grupo_control'"
}

matlist C


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |   / ____ `.  | || |     | |      | |
// | |   `'  __) |  | || |     \_|      | |
// | |   _  |__ '.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 	 PP vs AAI   	  **
****************************

//> Cargar resultados 
* Cargar resultados areacoca
estimates use "${dir_estimaciones}/modeloPP-areacoca.ster"
estat simple, estore(area3)
scalar N_OBS_A=e(N)

* Cargar resultados de lncoca
estimates use "${dir_estimaciones}/modeloPP-lncoca.ster"
estat simple, estore(lncoca3)
scalar N_OBS_L=e(N)

//> Cargar esalares
* Scalars Area coca
est restore area3
local controlmean=C[3,1]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_A, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

* Scalars Ln Coca
est restore lncoca3
local controlmean=C[3,2]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_L, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

esttab area3 lncoca3 using "${output}/modeloPP-ATT-robustezPP.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	mtitles("Area Coca" "Ln Coca") ///
	nonum gap nonotes star(* 0.10 ** 0.05 *** 0.01) compress ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun." "TRUNC Truncado") noobs booktabs

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _    _     | || |      _       | |
// | |  | |  | |    | || |     | |      | |
// | |  | |__| |_   | || |     \_|      | |
// | |  |____   _|  | || |              | |
// | |      _| |_   | || |              | |
// | |     |_____|  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs AAI  	  **
**************************** 
//> Cargar resultados 1v4
* Cargar resultados areacoca
estimates use "${dir_estimaciones}/modeloPP&SA-areacoca-1v4.ster"
estat simple, estore(area1v4)
scalar N_OBS_area1v4=e(N)

* Cargar resultados de lncoca
estimates use "${dir_estimaciones}/modeloPP&SA-lncoca-1v4.ster"
estat simple, estore(lncoca1v4)
scalar N_OBS_lncoca1v4=e(N)

estimates use "${dir_estimaciones}/modeloPP&SA-areacoca-1a4.ster"
estat simple, estore(area1a4)
scalar N_OBS_area1a4=e(N)

* Cargar resultados de lncoca
estimates use "${dir_estimaciones}/modeloPP&SA-lncoca-1a4.ster"
estat simple, estore(lncoca1a4)
scalar N_OBS_lncoca1a4=e(N)

//> Cargar esalares 1v4
* Scalars Area coca
est restore area1v4
local controlmean=C[4,1]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_area1v4, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"
qui estadd local NOTA "{\scriptsize AAI, PP\&SA}"

* Scalars Ln Coca
est restore lncoca1v4
local controlmean=C[4,2]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_lncoca1v4, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"
qui estadd local NOTA "{\scriptsize AAI, PP\&SA}"

//> Cargar esalares 1a4
* Scalars Area coca
est restore area1a4
local controlmean=C[4,1]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_area1a4, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"
qui estadd local NOTA "{\scriptsize AAI,SA,PP,PP\&SA}"

* Scalars Ln Coca
est restore lncoca1a4
local controlmean=C[4,2]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_lncoca1a4, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"
qui estadd local NOTA "{\scriptsize AAI,SA,PP,PP\&SA}"

esttab area1v4 area1a4 lncoca1v4 lncoca1a4  using "${output}/modeloPP&SA-ATT-robustezPP-4.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	mtitles("Area Coca" "Area Coca" "Ln Coca" "Ln Coca") ///
	nonum gap nonotes star(* 0.10 ** 0.05 *** 0.01) compress ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun." "TRUNC Truncado" "NOTA Grupos") noobs booktabs

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _______    | || |      _       | |
// | |  |  _____|   | || |     | |      | |
// | |  | |____     | || |     \_|      | |
// | |  '_.____''.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs SA   	  **
**************************** 	
//> Cargar resultados 
* Cargar resultados areacoca
estimates use "${dir_estimaciones}/modeloPP&SA-areacoca-2v4.ster"
estat simple, estore(area3)
scalar N_OBS_A=e(N)

* Cargar resultados de lncoca
estimates use "${dir_estimaciones}/modeloPP&SA-lncoca-2v4.ster"
estat simple, estore(lncoca3)
scalar N_OBS_L=e(N)

//> Cargar esalares
* Scalars Area coca
est restore area3
local controlmean=C[5,1]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_A, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

* Scalars Ln Coca
est restore lncoca3
local controlmean=C[5,2]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_L, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

esttab area3 lncoca3 using "${output}/modeloPP&SA-ATT-robustezPP-5.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	mtitles("Area Coca" "Ln Coca") ///
	nonum gap nonotes star(* 0.10 ** 0.05 *** 0.01) compress ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun." "TRUNC Truncado") noobs booktabs
	
	
//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |  .' ____ \   | || |     | |      | |
// | |  | |____\_|  | || |     \_|      | |
// | |  | '____`'.  | || |              | |
// | |  | (____) |  | || |              | |
// | |  '.______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
************************
**	 SA + PP vs PP 	  **
************************	
//> Cargar resultados 
* Cargar resultados areacoca
estimates use "${dir_estimaciones}/modeloPP&SA-areacoca-3v4.ster"
estat simple, estore(area3)
scalar N_OBS_A=e(N)

* Cargar resultados de lncoca
estimates use "${dir_estimaciones}/modeloPP&SA-lncoca-3v4.ster"
estat simple, estore(lncoca3)
scalar N_OBS_L=e(N)

//> Cargar esalares
* Scalars Area coca
est restore area3
local controlmean=C[6,1]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_A, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

* Scalars Ln Coca
est restore lncoca3
local controlmean=C[6,2]
di "mu= `controlmean'"
qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
estadd scalar OBS=N_OBS_L, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND " "
qui estadd local CLMUN "\checkmark"

esttab area3 lncoca3 using "${output}/modeloPP&SA-ATT-robustezPP-6.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	mtitles("Area Coca" "Ln Coca") ///
	nonum gap nonotes star(* 0.10 ** 0.05 *** 0.01) compress ///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$") ///
	scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun." "TRUNC Truncado") noobs booktabs

*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para todos los modelos 
*-------------------------------------------------------------------------------
global output "${projectfolder}/Output/Modelos Coca/graficos"

*****************************
* 3': Modelo PP vs AAI
*****************************
estimates use "modeloPP-areacoca.ster"
estat simple, estore (area)
estat event, window(-5 5)
csdid_plot, title("Area Coca") name(A, replace)

estimates use "modeloPP-lncoca.ster"
estat simple, estore (lncoca)
estat event, window(-5 5)
csdid_plot, title("Ln Coca") name(L, replace)

grc1leg A L, ycommon name(tresprima, replace) ///
	note("Prueba robustez con PP agrupado")
graph export "${output}/ED-modeloPPvAAI-robustezPP-3prima.jpg", replace

*****************************
* 4': Modelo PP + SA vs AAI
*****************************
estimates use "modeloPP&SA-areacoca-1v4.ster"
estat simple, estore (arae)
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area1v4, replace) aspect(1.4) ///
	note("Incluye solo a beneficiarios que recibieron AAI y PP+SA")

estimates use "modeloPP&SA-areacoca-1a4.ster"
estat simple, estore (arae)
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area1a4, replace) aspect(1.4) ///
	note("Incluye a beneficiarios que recibieron AAI, SA, PP y PP+SA")


estimates use "modeloPP&SA-lncoca-1v4.ster"
estat simple, estore (lncoca)
estat event, window(-4 4)
csdid_plot, title("Ln Coca") name(lncoca1v4, replace) aspect(1.4) ///
	note("Incluye solo a beneficiarios que recibieron AAI y PP+SA")

estimates use "modeloPP&SA-lncoca-1a4.ster"
estat simple, estore (lncoca)
estat event, window(-4 4)
csdid_plot, title("Ln Coca") name(lncoca1a4, replace) aspect(1.4) ///
	note("Incluye a beneficiarios que recibieron AAI, SA, PP y PP+SA")

grc1leg area1v4 area1a4, rows(1) ycommon name(Areacuatroprima, replace)
graph export "${output}/ED-modeloPP&SAvAAI-robustezPP-4primaArea.jpg", replace

grc1leg lncoca1v4 lncoca1a4, rows(1) ycommon name(lncocacuatroprima, replace)
graph export "${output}/ED-modeloPP&SAvAAI-robustezPP-4primaLn.jpg", replace

*****************************
* 5': Modelo PP + SA vs SA
*****************************
estimates use "modeloPP&SA-areacoca-2v4.ster"
estat simple, estore (area)
estat event, window(-5 5)
csdid_plot, title("Area Coca") name(A, replace)

estimates use "modeloPP&SA-lncoca-2v4.ster"
estat simple, estore (lncoca)
estat event, window(-5 5)
csdid_plot, title("Ln Coca") name(L, replace)

grc1leg A L, ycommon name(cincoprima, replace) ///
	note("Prueba robustez con PP agrupado")
graph export "${output}/ED-modeloPP&SAvSA-robustezPP-5prima.jpg", replace
	
*****************************
* Modelo PP + SA vs PP
*****************************
estimates use "modeloPP&SA-areacoca-3v4.ster"
estat simple, estore (area)
estat event, window(-5 5)
csdid_plot, title("Area Coca") name(A, replace)

estimates use "modeloPP&SA-lncoca-3v4.ster"
estat simple, estore (lncoca)
estat event, window(-5 5)
csdid_plot, title("Ln Coca") name(L, replace)

grc1leg A L, ycommon name(seisprima, replace) ///
	note("Prueba robustez con PP agrupado")
graph export "${output}/ED-modeloPP&SAvPP-robustezPP-6prima.jpg", replace
