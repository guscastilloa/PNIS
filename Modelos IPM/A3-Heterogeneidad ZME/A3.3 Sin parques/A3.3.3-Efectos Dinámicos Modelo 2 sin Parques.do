/*
AUTOR:
	Gustavo A. Castillo
	
DESCRIPCIÓN:
	En este script se producen los gráficos de los efectos dinámicos del 
	modelos 2 (especificaciones 4 y 5) para la revisión de los efectos 
	heterogéneos por ZME una vez se elimina de la muestra los beneficiarios
	en La Macarena, Meta.

*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones/_heterogeneidad zme"
global output_path "${projectfolder}/Output/Estimación_modelos/graficos/ZME/A3.3 Sin parques"
// cd "${output}/Estimación_modelos/graficos/ZME"
set scheme s1mono

global Z0: label lzme 0
global Z1: label lzme 1


*------------------------------------------------------------------------------
**# Con outliers para no-ZME (ZME==0)
*------------------------------------------------------------------------------
local nZ=0 //Fijar ZME==0
forvalues M=2/2{ // Iterar sobre modelos - - - - - - - - - - - - - - - - - - - -
	
	forvalues E=4/5{ // Iterar sobre Esp. 4 y 5- - - - - - - - - - - - - - - - -
		
		forvalues I=1/2{ // Iterar sobre IPM - - - - - - - - - - - - - - - - - -
			estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-con_outliers-Z`nZ'-sin_parques.ster" 
			estat simple, estore(E`E'M`M'I`I')
			estat event, window(-6 6)
			csdid_plot, title("IPM `I'") aspect(.6) nodraw name(I`I', replace)
		}
		grc1leg I1 I2, ycommon col(1) name(G`E', replace) ///
			title("Especificación `E'")
		
	}
	grc1leg G4 G5, ycommon col(2) name(M`M', replace) ///
		title("${Z0}") subtitle("Excluyendo beneficiarios en PNN") ///
		note("Variable IPM continua con outliers para beneficiarios no ZME.")
		graph export "${output_path}/ED-modelo`M'-con_outliers-Z`nZ'-sin_parques.jpg", replace
}
*------------------------------------------------------------------------------
**# Con outliers para En ZME (ZME==1)
*------------------------------------------------------------------------------
local nZ=1 //Fijar ZME==0
forvalues M=2/2{ // Iterar sobre modelos - - - - - - - - - - - - - - - - - - - -
	
	forvalues E=4/5{ // Iterar sobre Esp. 4 y 5- - - - - - - - - - - - - - - - -
		
		forvalues I=1/2{ // Iterar sobre IPM - - - - - - - - - - - - - - - - - -
			estimates use "${dir_estimaciones}/esp`E'-model`M'-IPM `I'-con_outliers-Z`nZ'-sin_parques.ster" 
			estat simple, estore(E`E'M`M'I`I')
			estat event, window(-6 6)
			csdid_plot, title("IPM `I'") aspect(.6) nodraw name(I`I', replace)
		}
		grc1leg I1 I2, ycommon col(1) name(G`E', replace) ///
			title("Especificación `E'")
		
	}
	grc1leg G4 G5, ycommon col(2) name(M`M', replace) ///
		title("${Z1}") subtitle("Excluyendo beneficiarios en PNN") ///
		note("Variable IPM continua con outliers para beneficiarios en ZME.")
		graph export "${output_path}/ED-modelo`M'-con_outliers-Z`nZ'-sin_parques.jpg", replace
}
