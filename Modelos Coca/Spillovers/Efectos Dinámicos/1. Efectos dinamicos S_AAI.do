/*
AUTOR:
	Gustavo Castillo

FECHA:
	29/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las gráficas de efectos dinámicos
	de resultados de S_AAI (que recibieron únicamente AAI).
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global output_path "${projectfolder}/Output/Modelos Coca Spillovers/graficos/efectos dinamicos"

*-------------------------------------------------------------------------------
* SA
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/S_AAI_CP.ster"
	estat event, window(-5 5)	
	csdid_plot, title("Grillas PNIS" "vs Control Puro") ///
	name(g1, replace)
	
	* Unir gráficos en uno combinado para exportar
	grc1leg g1, ycommon name(P, replace) ///
		title("Grillas PNIS") note("S_AAI", color(gs15))

* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 6. E4Gv vs E0G0: Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_S_AAI_CP.ster"
	estat event, window(-5 5) 
	csdid_plot, title("Vecinas" "vs Control Puro") name(g4, replace)
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 9. E4Gvv vs E0G0: Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_S_AAI_CP.ster"
	estat event, window(-5 5)		
	csdid_plot, title("Vecinas de Vecinas" "vs Control Puro") ///
		name(g5, replace)

* Exportar gráfico
	grc1leg g1 g4 g5, note("S_AAI", color(gs15)) col(3)
	graph export "${output_path}/ED-S_AAI-spillovers.jpg", replace

	
* End
