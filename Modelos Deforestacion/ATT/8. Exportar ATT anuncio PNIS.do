/*
AUTOR:
	Gustavo Castillo

FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las tablas de resultados de la 
	estimación del anuncio del PNIS en deforestación.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Deforestacion/estimaciones"
global table_output "${projectfolder}/Output/Deforestacion/tablas"
*-------------------------------------------------------------------------------
* Anuncio PNIS
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/PNIS_CP.ster"
	estat simple, estore(modelo1) // Guardar ATT en estimación
	scalar N_OBS_1= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo1
		estadd scalar OBS=N_OBS_1, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control puro
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 5. Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_PNIS_CP.ster"
	estat simple, estore(modelo4) // Guardar ATT en estimación
	scalar N_OBS_4= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo4
		estadd scalar OBS=N_OBS_4, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control puro

	
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 6. Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_PNIS_CP.ster"
	estat simple, estore(modelo5) // Guardar ATT en estimación
	scalar N_OBS_5= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo5
		estadd scalar OBS=N_OBS_5, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control Puro
	
esttab modelo1 modelo4 modelo5 ///
	using "${table_output}/defo_spillover_att_anuncioPNIS.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" ///
	"CLVER Cluster Vereda" "CONTROL Control")  ///
	mgroups("Grilla PNIS" "Grilla Vecina" "Grilla V. de Vecina", ///
	pattern(1 1 1 ) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	alignment(D{.}{.}{-1}) /// 
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

	
* End
