/*
AUTOR:
	Gustavo Castillo

FECHA:
	29/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las gráficas de efectos dinámicos
	de resultados de PP de los modelos de deforestación.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Deforestacion/estimaciones"
global output_path "${projectfolder}/Output/Deforestacion/graficos/efectos dinamicos"

*-------------------------------------------------------------------------------
* PP
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/d_PP_CP.ster"
	estat event, window(-3 3)
	csdid_plot, title("Control Puro") name(g1, replace)
	
	* 2. Grilla PNIS vs Grillas solo AAI
	estimates use "${dir_estimaciones}/d_PP_AAI.ster"
	estat event, window(-3 3)
	csdid_plot, title("solo AAI") name(g2, replace)		
	
	* 5. Grilla PNIS vs Grilla PNIS pre PP
	estimates use "${dir_estimaciones}/d_PP_ROLL.ster"
	estat event, window(-3 3)
	csdid_plot, title("PP en 2022") name(g5, replace)			
	
	* Unir gráficos en uno combinado para exportar
	grc1leg g1 g2 g5, ycommon name(P, replace) ///
		title("Grillas PNIS") note("PP", color(gs15)) col(3)
	graph export "${output_path}/ED-PP-grillasPNIS-defo.jpg", replace
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 6. E4Gv vs E0G0: Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_PP_CP.ster"
	estat event, window(-3 3)
	csdid_plot, title("Control Puro") name(g6, replace)			
	
	* 7. E4Gv vs E1Gp: Grilla Vecina vs solo AAI
	estimates use "${dir_estimaciones}/v_PP_AAI.ster"
	estat event, window(-3 3)
	csdid_plot, title("solo AAI") name(g7, replace)
	
	* 8. Grilla Vecina vs pre PP (PP en 2022)
	estimates use "${dir_estimaciones}/v_PP_ROLL.ster"
	estat event, window(-3 3)
	csdid_plot, title("PP en 2022") name(g8, replace)		

	* Unir gráficos en uno combinado para exportar
	grc1leg g6 g7 g8, ycommon name(V, replace) ///
		title("Grillas Vecinas") col(3) note("PP", color(gs15))
	graph export "${output_path}/ED-PP-Vecina-defo.jpg", replace

* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 9. E4Gvv vs E0G0: Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_PP_CP.ster"
	estat event, window(-4 4)		
	csdid_plot, title("Control Puro") name(g9, replace)			
	
	* 10. E4Gvv vs E1Gp
	estimates use "${dir_estimaciones}/vv_PP_AAI.ster"
	estat event, window(-4 4)		
	csdid_plot, title("solo AAI") name(g10, replace)
	
	* 11. Grilla Vecina de Vecina vs pre PP (PP en 2022)
	estimates use "${dir_estimaciones}/vv_PP_ROLL.ster"
	estat event, window(-4 4)		
	csdid_plot, title("PP en 2022") name(g11, replace)		
	
	* Unir gráficos en uno combinado para exportar
	grc1leg g9 g10 g11, ycommon name(VV, replace) ///
		title("Grillas Vecinas de las Vecinas") col(3) note("PP", color(gs15))
	graph export "${output_path}/ED-PP-VecinaVecina-defo.jpg", replace
