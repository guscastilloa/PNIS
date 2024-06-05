/*
AUTOR:
	Gustavo Castillo

FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las tablas de resultados de la 
	estimación del anuncio del PNIS de los modelos de deforestación.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Deforestacion/estimaciones"
global output_path "${projectfolder}/Output/Deforestacion/graficos/efectos dinamicos"

*-------------------------------------------------------------------------------
* Anuncio PNIS
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Grillas PNIS" "vs Control Puro") name(g1, replace)
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 5. Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Vecina" "vs Control Puro") ///
		name(g4, replace)
		
// 	graph export "${output_path}/ED-PNIS-Vecina-defo.jpg", replace
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 6. Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_PNIS_CP.ster"
	estat event, window(-3 2)
	csdid_plot, title("Vecinas de Vecinas" "vs Control Puro") ///
		name(g5, replace)
	
// 	graph export "${output_path}/ED-PNIS-VecinaVecina-defo.jpg", replace	

	grc1leg g1 g4 g5, note("PNIS", color(gs15)) col(3)
	graph export "${output_path}/ED-PNIS-defo.jpg", replace
		
* End
