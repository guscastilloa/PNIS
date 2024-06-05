/*
AUTOR:
	Gustavo Castillo

FECHA:
	30/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las tablas de resultados de la 
	estimación del anuncio del PNIS.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global table_output "${projectfolder}/Output/Modelos Coca Spillovers/tablas"

*-------------------------------------------------------------------------------
* Anuncio PNIS
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Grillas PNIS" "vs Control Puro") name(g1, replace)
	
// 	* 3. Grilla PNIS vs Vecina
// 	estimates use "${dir_estimaciones}/PNIS_v.ster"
// 	estat event, window(-3 2)
// 	csdid_plot, title("Vecina") name(g2, replace)	
//
// 	* 4. Grilla PNIS vs Vecina de Vecina
// 	estimates use "${dir_estimaciones}/PNIS_vv.ster"
// 	estat event, window(-3 2)
// 	csdid_plot, title("Vecina de Vecina") name(g3, replace)
//	
// 	* Unir gráficos en uno combinado para exportar
// 	grc1leg g1, ycommon name(P, replace) ///
// 		title("Grillas PNIS") note("PNIS", color(gs15))
// 	graph export "${output_path}/ED-PNIS-grillasPNIS-spillovers.jpg", replace
	
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 5. Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Vecina" "vs Control Puro") ///
		name(g4, replace)
		
// 	graph export "${output_path}/ED-PNIS-Vecina-spillovers.jpg", replace
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 6. Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Vecinas de Vecinas" "vs Control Puro") ///
		name(g5, replace)
	
// 	graph export "${output_path}/ED-PNIS-VecinaVecina-spillovers.jpg", replace	

	grc1leg g1 g4 g5, note("PNIS", color(gs15)) col(3)
	graph export "${output_path}/ED-PNIS-spillovers.jpg", replace
		
* End
