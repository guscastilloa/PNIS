* Preámbulo luego de correr _main.do

global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"

set scheme s1mono

* Exportar gráficos de efectos dinámicos


//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# IPM Continua

*esp1-model2-IPM 1-continua.ster
forvalues x=1/5{
	di ">>>`x':"
	forvalues M=1/7{
		di ">>MODELO `M'"
		if (`M'==1) | (`M'==7){
			forvalues i=1/2{
				di "> IPM `i'"
				estimates use "${dir_estimaciones}/esp`x'-model`M'-IPM `i'-continua.ster"
				estat simple, estore(esp`x'_modelo`M'_ipm`i')
				estat event, window(-6 6)
				csdid_plot, title("Especificacion `x'-Modelo `M'" "IPM `i'") name(I`i', replace) nodraw
			}
		graph combine I1 I2, ycommon name(S`x'M`M'common, replace) ///
			note("Variable IPM continua con outliers")
		graph export "${output}/Estimación_modelos/graficos/esp`x'-modelo`M'-continua.jpg", replace
		}
		
		else {
			forvalues i=1/2{
				di "> IPM `i'"
				estimates use "${dir_estimaciones}/esp`x'-model`M'-IPM `i'-continua.ster"
				estat simple, estore(esp`x'_modelo`M'_ipm`i')
				estat event, window(-5 5)
				csdid_plot, title("Especificacion `x'-Modelo `M'" "IPM `i'") name(I`i', replace) nodraw
			}
		graph combine I1 I2, ycommon name(S`x'M`M'common, replace) ///
			note("Variable IPM continua con outliers")
		graph export "${output}/Estimación_modelos/graficos/esp`x'-modelo`M'-continua.jpg", replace		
		}
		
	}
}

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\
//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
**# IPM continua sin outliers

*esp1-model2-IPM 2-continua-no_outliers.ster
forvalues x=1/5{
	di ">>>`x':"
	forvalues M=1/7{
		di ">>MODELO `M'"
		if (`M'==1) | (`M'==7){
			forvalues i=1/2{
				di "> IPM `i'"
				estimates use "${dir_estimaciones}/esp`x'-model`M'-IPM `i'-continua-no_outliers.ster"
				estat simple, estore(esp`x'_modelo`M'_ipm`i')
				estat event, window(-6 6)
				csdid_plot, title("Especificacion `x'-Modelo `M'" "IPM `i'") name(I`i', replace) nodraw
			}
		graph combine I1 I2, ycommon name(S`x'M`M'common, replace) ///
			note("Variable IPM continua sin outliers")
		graph export "${output}/Estimación_modelos/graficos/esp`x'-modelo`M'-continua-no_outliers.jpg", replace
		}
		
		else {
			forvalues i=1/2{
				di "> IPM `i'"
				estimates use "${dir_estimaciones}/esp`x'-model`M'-IPM `i'-continua-no_outliers.ster"
				estat simple, estore(esp`x'_modelo`M'_ipm`i')
				estat event, window(-5 5)
				csdid_plot, title("Especificacion `x'-Modelo `M'" "IPM `i'") name(I`i', replace) nodraw
			}
		graph combine I1 I2, ycommon name(S`x'M`M'common, replace) ///
			note("Variable IPM continua sin outliers")
		graph export "${output}/Estimación_modelos/graficos/esp`x'-modelo`M'-continua-no_outliers.jpg", replace		
		}
		
	}
}



//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# IPM Continua con outliers


*---------------------
* Especificacion 4
*---------------------
local M 7
local ESP 4
* Iterar entre IPM 1 y 2
forvalues I = 1/2{
	estimates use "${dir_estimaciones}/esp`ESP'-model`M'-IPM `I'-continua.ster"
	estat simple, estore(esp`ESP'_modelo`M'_ipm`I')
	estat event, window(-6 6)
	csdid_plot, title("Especificacion `ESP'-Modelo `M'" "IPM `I'") name(I`I', replace) nodraw
}

* Exportar gráfico
graph combine I1 I2, ycommon name(S`ESP'M`M'common, replace) ///
		note("Variable IPM continua con outliers")
graph export "${output}/Estimación_modelos/graficos/esp`ESP'-modelo`M'-continua.jpg", replace		



*---------------------
* Especificación 5
*---------------------
local M 7
local ESP 5
* Iterar entre IPM 1 y 2
forvalues I = 1/2{
	estimates use "${dir_estimaciones}/esp`ESP'-model`M'-IPM `I'-continua-t2.ster"
	estat simple, estore(esp`ESP'_modelo`M'_ipm`I')
	estat event, window(-6 6)
	csdid_plot, title("Especificacion `ESP'-Modelo `M'" "IPM `I'") name(I`I', replace) nodraw
}
graph combine I1 I2, ycommon name(S`ESP'M`M'common, replace) ///
		note("Variable IPM continua con outliers")
graph export "${output}/Estimación_modelos/graficos/esp`ESP'-modelo`M'-continua-t2.jpg", replace		

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\
//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
**# IPM continua sin outliers

*---------------------
* Especificacion 4
*---------------------
local M 7
local ESP 4
* Iterar entre IPM 1 y 2
forvalues I = 1/2{
	estimates use "${dir_estimaciones}/esp`ESP'-model`M'-IPM `I'-continua-no_outliers.ster"
	estat simple, estore(esp`ESP'_modelo`M'_ipm`I')
	estat event, window(-6 6)
	csdid_plot, title("Especificacion `ESP'-Modelo `M'" "IPM `I'") name(I`I', replace) nodraw
}

* Exportar gráfico
graph combine I1 I2, ycommon name(S`ESP'M`M'common, replace) ///
		note("Variable IPM continua sin outliers")
graph export "${output}/Estimación_modelos/graficos/esp`ESP'-modelo`M'-continua-no_outliers.jpg", replace	

*---------------------
* Especificación 5
*---------------------
local M 7
local ESP 5
* Iterar entre IPM 1 y 2
forvalues I = 1/2{
	estimates use "${dir_estimaciones}/esp`ESP'-model`M'-IPM `I'-continua-no_outliers-t2.ster"
	estat simple, estore(esp`ESP'_modelo`M'_ipm`I')
	estat event, window(-6 6)
	csdid_plot, title("Especificacion `ESP'-Modelo `M'" "IPM `I'") name(I`I', replace) nodraw
}
graph combine I1 I2, ycommon name(S`ESP'M`M'common, replace) ///
		note("Variable IPM continua sin outliers")
graph export "${output}/Estimación_modelos/graficos/esp`ESP'-modelo`M'-continua-no_outliers-t2.jpg", replace		


