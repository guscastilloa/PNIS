/*
DESCRIPCION:
	Exportar gráficas de efectos dinámicos de modelos de coca y exportar las
	tablas de ATT para cada modelo.
*/

* Preambulo
global dir_estimaciones "${projectfolder}/Output/Modelos Coca/estimaciones"
global table_output "${output}/Modelos Coca/tablas"

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
global modelnum 1
estimates use "${dir_estimaciones}/modeloAAI-areacoca.ster"
estat event, window(-5 5)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloAAI-lncoca.ster"
estat event, window(-5 5)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo AAI") name(M1, replace)
graph export "${output}/Modelos Coca/graficos/ED_modeloAAI.jpg", replace 

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
global modelnum 2
estimates use "${dir_estimaciones}/modeloSA-areacoca.ster"
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloSA-lncoca.ster"
estat event, window(-4 4)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo SA") name(M2, replace) 
graph export "${output}/Modelos Coca/graficos/ED_modeloSA.jpg", replace 

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
global modelnum 3
estimates use "${dir_estimaciones}/modeloPPCC-areacoca.ster"
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloPPCC-lncoca.ster"
estat event, window(-4 4)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo PPCC") name(M3, replace) 
graph export "${output}/Modelos Coca/graficos/ED_modeloPPCC.jpg", replace 

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

* 1a4 - - - - - - - - - - - - - - - - - - - - -
global modelnum 4
estimates use "${dir_estimaciones}/modeloPPCC&SA-areacoca-1a4.ster"
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloPPCC&SA-lncoca-1a4.ster"
estat event, window(-4 4)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo PPCC & SA") name(M4a, replace) ///
	note("Incluye a beneficiarios que recibieron AAI, SA, PPCC y SA+PPCC")
graph export "${output}/Modelos Coca/graficos/ED_modeloPPCC&SA-1a4.jpg", replace 
	
* 1v4 - - - - - - - - - - - - - - - - - - - - - 
estimates use "${dir_estimaciones}/modeloPPCC&SA-areacoca-1v4.ster"
estat event, window(-4 4)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloPPCC&SA-lncoca-1v4.ster"
estat event, window(-4 4)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo PPCC & SA") name(M4b, replace) ///
	note("Incluye solo a beneficiarios que recibieron AAI y SA+PPCC")
graph export "${output}/Modelos Coca/graficos/ED_modeloPPCC&SA-1v4.jpg", replace 

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
global modelnum 5
estimates use "${dir_estimaciones}/modeloPPCL-areacoca.ster"
estat event, window(-5 5)
csdid_plot, title("Area Coca") name(area, replace) nodraw aspect(1)

estimates use "${dir_estimaciones}/modeloPPCL-lncoca.ster"
estat event, window(-5 5)
csdid_plot, title("Ln. Coca") name(ln, replace) nodraw aspect(1)

grc1leg area ln, ycommon title("Modelo PPCL") name(M5, replace) 
graph export "${output}/Modelos Coca/graficos/ED_modeloPPCL.jpg", replace 

*-------------------------------------------------------------------------
* Exportar tablas ATT modelos coca para AAI, SA, PPCC, PPCL
*-------------------------------------------------------------------------

global modelos "AAI SA PPCC PPCL"
global indep "areacoca lncoca"
foreach M of global modelos{
	di "`M'"
	foreach Y of global indep{
		estimates use "${dir_estimaciones}/modelo`M'-`Y'"			
		qui estat simple, estore(E`Y')
		scalar N_OBS_`Y'= e(N)
	}
	
	*-- Scalars areacoca
	est restore Eareacoca
	estadd scalar OBS=N_OBS_areacoca, replace
	qui estadd local EFT "\checkmark"
	qui estadd local EFG "\checkmark"
	qui estadd local TREND "\checkmark"
	qui estadd local CLMUN "\checkmark"
	
	*-- Scalarslncoca
	est restore Elncoca
	estadd scalar OBS=N_OBS_lncoca, replace
	qui estadd local EFT "\checkmark"
	qui estadd local EFG "\checkmark"
	qui estadd local TREND "\checkmark"
	qui estadd local CLMUN "\checkmark"
	
	esttab Eareacoca Elncoca using "${table_output}/modelo`M'-coca", replace ///
		main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress ///
		gap nonotes noobs ///
		scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun.") note("Error estándar en paréntesis." ///
		"* p$<0.10$, ** p$<0.05$, *** p$<0.01$")  ///
		mlabels("Area Coca" "Ln Coca") nonum booktabs
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

* 1a4 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
estimates use "${dir_estimaciones}/modeloPPCC&SA-areacoca-1a4.ster"
estat simple, estore(Eareacoca)
scalar N_OBS_areacoca= e(N)

estimates use "${dir_estimaciones}/modeloPPCC&SA-lncoca-1a4.ster"
estat simple, estore(Elncoca)
scalar N_OBS_lncoca= e(N)

*-- Scalars areacoca
est restore Eareacoca
estadd scalar OBS=N_OBS_areacoca, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND "\checkmark"
qui estadd local CLMUN "\checkmark"

*-- Scalarslncoca
est restore Elncoca
estadd scalar OBS=N_OBS_lncoca, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND "\checkmark"
qui estadd local CLMUN "\checkmark"

esttab Eareacoca Elncoca using "${table_output}/modeloPPCC&SA-coca-1a4", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun.") ///
	note("Error estándar en paréntesis." ///
	"* p$<0.10$, ** p$<0.05$, *** p$<0.01$")  ///
	mlabels("Area Coca" "Ln Coca") nonum booktabs //title("1a4")

* 1v4 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
estimates use "${dir_estimaciones}/modeloPPCC&SA-areacoca-1v4.ster"
estat simple, estore(Eareacoca)
scalar N_OBS_areacoca= e(N)

estimates use "${dir_estimaciones}/modeloPPCC&SA-lncoca-1v4.ster"
estat simple, estore(Elncoca)
scalar N_OBS_lncoca= e(N)

*-- Scalars areacoca
est restore Eareacoca
estadd scalar OBS=N_OBS_areacoca, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND "\checkmark"
qui estadd local CLMUN "\checkmark"

*-- Scalarslncoca
est restore Elncoca
estadd scalar OBS=N_OBS_lncoca, replace
qui estadd local EFT "\checkmark"
qui estadd local EFG "\checkmark"
qui estadd local TREND "\checkmark"
qui estadd local CLMUN "\checkmark"

esttab Eareacoca Elncoca using "${table_output}/modeloPPCC&SA-coca-1v4", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" "CLMUN Cluster Mun.") ///
	note("Error estándar en paréntesis." ///
	"* p$<0.10$, ** p$<0.05$, *** p$<0.01$")  ///
	mlabels("Area Coca" "Ln Coca") nonum booktabs title("1v4")
