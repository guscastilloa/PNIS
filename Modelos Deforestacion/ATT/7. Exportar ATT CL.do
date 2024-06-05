/*
AUTOR:
	Gustavo Castillo

FECHA:
	30/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las tablas de resultados de CL.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global table_output "${projectfolder}/Output/Modelos Coca Spillovers/tablas"

*-------------------------------------------------------------------------------
* PP
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs CCSA
	estimates use "${dir_estimaciones}/d_CL_CCSA.ster"
	estat simple, estore(modelo1) // Guardar ATT en estimación
	scalar N_OBS_1= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo1
		estadd scalar OBS=N_OBS_1, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize PNIS con CC\&SA}" // CCSA
	
	* 3. Grilla PNIS vs Vecina
	estimates use "${dir_estimaciones}/d_CL_v.ster"
	estat simple, estore(modelo2) // Guardar ATT en estimación
	scalar N_OBS_2= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo2
		estadd scalar OBS=N_OBS_2, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize Vecinas}" // Vecinas

	* 4. Grilla PNIS vs Vecina de Vecina
	estimates use "${dir_estimaciones}/d_CL_vv.ster"
	estat simple, estore(modelo3) // Guardar ATT en estimación
	scalar N_OBS_3= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo3
		estadd scalar OBS=N_OBS_3, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize V. de Vecinas}" // Vecina de vecina
	
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 5. E4Gv vs E0G0: Grilla Vecina vs PNIS con CC&SA
	estimates use "${dir_estimaciones}/v_CL_CCSA.ster"
	estat simple, estore(modelo4) // Guardar ATT en estimación
	scalar N_OBS_4= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo4
		estadd scalar OBS=N_OBS_4, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize PNIS con CC\&SA}" // CCSA

	
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 6. E4Gvv vs E0G0: Grilla vecina de vecina vs PNIS con CC&SA
	estimates use "${dir_estimaciones}/vv_CL_CCSA.ster"
	estat simple, estore(modelo5) // Guardar ATT en estimación
	scalar N_OBS_5= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo5
		estadd scalar OBS=N_OBS_5, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize PNIS con CC\&SA}" // CCSA
	
esttab modelo1 modelo2 modelo3 modelo4 modelo5 ///
	using "${table_output}/coca_spillover_att_CL.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" ///
	"CLVER Cluster Vereda" "CONTROL Control")  ///
	mgroups("Grilla PNIS" "Grilla Vecina" "Grilla V. de Vecina", ///
	pattern(1 0 0 1 1 ) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	alignment(D{.}{.}{-1}) /// 
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

	
* End
