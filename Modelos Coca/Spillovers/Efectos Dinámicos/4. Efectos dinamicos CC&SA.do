/*
AUTOR:
	Gustavo Castillo

FECHA:
	29/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las gráficas de efectos dinámicos
	de resultados de CC&SA.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global output_path "${projectfolder}/Output/Modelos Coca Spillovers/graficos/efectos dinamicos"

*-------------------------------------------------------------------------------
* CC&SA
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. E4Gp vs E0G0: Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/d_CCSA_CP.ster"
	estat event, window(-4 4)
	csdid_plot, title("Control Puro") name(g1, replace)
	
	* 2: E4Gp vs E1Gp: Grilla PNIS vs Grillas solo AAI
	estimates use "${dir_estimaciones}/d_CCSA_AAI.ster"
	estat event, window(-4 4)
	csdid_plot, title("solo AAI") name(g2, replace)
	
	* 3. E4Gp vs E2Gv: Grilla PNIS vs Vecina
	estimates use "${dir_estimaciones}/d_CCSA_v.ster"
	estat event, window(-4 4)
	csdid_plot, title("Vecina") name(g3, replace)	
		
	* 4. E4Gp vs E2Gvv: Grilla PNIS vs Vecina de Vecina
	estimates use "${dir_estimaciones}/d_CCSA_vv.ster"
	estat event, window(-4 4)
	csdid_plot, title("Vecina de Vecina") name(g4, replace)		
	
	* 5. Grilla PNIS vs Grilla PNIS pre CC&SA
	estimates use "${dir_estimaciones}/d_CCSA_ROLL.ster"
	estat event, window(-4 4)
	csdid_plot, title("CC&SA en 2022") name(g5, replace)			
	
	* Unir gráficos en uno combinado para exportar
	grc1leg g1 g2 g3 g4 g5, ycommon name(P, replace) ///
		title("Grillas PNIS") note("CC&SA", color(gs15))
	graph export "${output_path}/ED-CCSA-grillasPNIS-spillovers.jpg", replace
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 6. E4Gv vs E0G0: Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_CCSA_CP.ster"
	estat event, window(-4 4)
	csdid_plot, title("Control Puro") name(g6, replace)			
	
	* 7. E4Gv vs E1Gp: Grilla Vecina vs solo AAI
	estimates use "${dir_estimaciones}/v_CCSA_AAI.ster"
	estat event, window(-4 4)
	csdid_plot, title("solo AAI") name(g7, replace)
	
	* 8. Grilla Vecina vs pre CC&SA (CC&SA en 2022)
	estimates use "${dir_estimaciones}/v_CCSA_ROLL.ster"
	estat event, window(-4 4)
	csdid_plot, title("CC&SA en 2022") name(g8, replace)		

	* Unir gráficos en uno combinado para exportar
	grc1leg g6 g7 g8, ycommon name(V, replace) ///
		title("Grillas Vecinas") col(3) note("CC&SA", color(gs15))
	graph export "${output_path}/ED-CCSA-Vecina-spillovers.jpg", replace
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 9. E4Gvv vs E0G0: Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_CCSA_CP.ster"
	estat event, window(-4 4)
	csdid_plot, title("Control Puro") name(g9, replace)			
	
	* 10. E4Gvv vs E1Gp
	estimates use "${dir_estimaciones}/vv_CCSA_AAI.ster"
	estat event, window(-4 4)
	csdid_plot, title("solo AAI") name(g10, replace)
	
	* 11. Grilla Vecina de Vecina vs Grilla PNIS pre CC&SA
	estimates use "${dir_estimaciones}/vv_CCSA_ROLL.ster"
	estat event, window(-4 4)
	csdid_plot, title("CC&SA en 2022") name(g11, replace)		
	
	* Unir gráficos en uno combinado para exportar
	grc1leg g9 g10 g11, ycommon name(VV, replace) ///
		title("Grillas Vecinas de las Vecinas") col(3) note("CC&SA", color(gs15))
	graph export "${output_path}/ED-CCSA-VecinaVecina-spillovers.jpg", replace
