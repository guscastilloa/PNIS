/*
AUTOR:
	Gustavo A. Castillo
	
DESCRIPCIÓN:
	En este script se producen los gráficos de los efectos dinámicos de los 
	modelos 1-4 (especificaciones 4 y 5) para la revisión de los efectos 
	heterogéneos por género (sexo). 

*/

* Preámbulo luego de ejecutar _master.do
use "${datafolder}/base_estimaciones_gus.dta", clear
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"
cd "${output}/Estimación_modelos/graficos/SEXO/"
set scheme stcolor

global G0: label sexo 0
global G1: label sexo 1


*------------------------------------------------------------------------------
**# Con outliers para hombres (sexo_titular==0)
*------------------------------------------------------------------------------
local nS=0 //Fijar SEXO==0
forvalues M=1/4{ // Iterar sobre modelos - - - - - - - - - - - - - - - - - - - -
	
	forvalues E=4/5{ // Iterar sobre Esp. 4 y 5- - - - - - - - - - - - - - - - -
		
		forvalues I=1/2{ // Iterar sobre IPM - - - - - - - - - - - - - - - - - -
			estimates use "${dir_estimaciones}/_heterogeneidad sexo/esp`E'-model`M'-IPM `I'-continua-S`nS'.ster" 
			estat simple, estore(E`E'M`M'I`I')
			estat event, window(-6 6)
			csdid_plot, title("IPM `I'") aspect(.3) nodraw name(I`I', replace)
		}
		grc1leg I1 I2, ycommon col(1) name(G`E', replace) ///
			title("Especificación `E'")
		
	}
	grc1leg G4 G5, ycommon col(2) name(M`M', replace) ///
		title("${G0}") ///
		note("Variable IPM continua con outliers para beneficiarios hombres.")
		graph export "modelo`M'-continua-S`nS'.jpg", replace
}
*------------------------------------------------------------------------------
**# Con outliers para mujeres (sexo_titular==1)
*------------------------------------------------------------------------------
local nS=1 //Fijar SEXO==1
forvalues M=1/4{ // Iterar sobre modelos - - - - - - - - - - - - - - - - - - - -
	
	forvalues E=4/5{ // Iterar sobre Esp. 4 y 5- - - - - - - - - - - - - - - - -
		
		forvalues I=1/2{ // Iterar sobre IPM - - - - - - - - - - - - - - - - - -
			estimates use "${dir_estimaciones}/_heterogeneidad sexo/esp`E'-model`M'-IPM `I'-continua-S`nS'.ster" 
			estat simple, estore(E`E'M`M'I`I')
			estat event, window(-6 6)
			csdid_plot, title("IPM `I'") aspect(.3) nodraw name(I`I', replace)
		}
		grc1leg I1 I2, ycommon col(1) name(G`E', replace) ///
			title("Especificación `E'")
		
	}
	grc1leg G4 G5, ycommon col(2) name(M`M', replace) ///
		title("${G1}") ///
		note("Variable IPM continua con outliers para beneficiarias mujeres.")
		graph export "modelo`M'-continua-S`nS'.jpg", replace
}
