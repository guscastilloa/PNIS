/*
AUTOR:
	Gustavo Castillo

FECHA:
	30/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las gráficas de efectos dinámicos
	de resultados de CL.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global output_path "${projectfolder}/Output/Modelos Coca Spillovers/graficos/efectos dinamicos"

*-------------------------------------------------------------------------------
* CL
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. Grilla PNIS vs CCSA
	estimates use "${dir_estimaciones}/d_CL_CCSA.ster"
	estat event, window(-4 4)
	csdid_plot, title("con CC&SA") name(g1, replace)
	
	* 3. Grilla PNIS vs Vecina
	estimates use "${dir_estimaciones}/d_CL_v.ster"
	estat event, window(-4 4)
	csdid_plot, title("Vecina") name(g2, replace)	
		
	* 4. Grilla PNIS vs Vecina de Vecina
	estimates use "${dir_estimaciones}/d_CL_vv.ster"
	estat event, window(-4 4)
	csdid_plot, title("Vecina de Vecina") name(g3, replace)		
		
	* Unir gráficos en uno combinado para exportar
	grc1leg g1 g2 g3, ycommon name(P, replace) ///
		title("Grillas PNIS") note("CL", color(gs15)) col(3)
	graph export "${output_path}/ED-CL-grillasPNIS-spillovers.jpg", replace
	
	
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 6. E4Gv vs E0G0: Grilla Vecina vs PNIS con CC&SA
	estimates use "${dir_estimaciones}/v_CL_CCSA.ster"
	estat event, window(-5 5)
	csdid_plot, title("Vecina vs PNIS con CC&SA") name(g4, replace)	note("CL", color(gs15))		
	
	graph export "${output_path}/ED-CL-Vecina-spillovers.jpg", replace
	
	
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 9. E4Gvv vs E0G0: Grilla vecina de vecina vs PNIS con CC&SA
	estimates use "${dir_estimaciones}/vv_CL_CCSA.ster"
	estat event, window(-4 4)		
	csdid_plot, title("Vecinas de Vecinas vs PNIS con CC&SA") ///
		name(g5, replace)	note("CL", color(gs15))		
		
	graph export "${output_path}/ED-CL-VecinaVecina-spillovers.jpg", replace	

* End
