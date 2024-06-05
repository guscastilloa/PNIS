

/*
DESCRIPCIÓN:
	En este script se crean dos variables que ayudan a identificar si un cub
	es outlier (valor extremo o valor atípico) según el criterio de las cercas
	de Tukey (Tukey's fences) que es convencional en la producción de box plots.
	
	Si una observación está fuera del 
*/


* Preamble after running _master.do
clear all
cls
use "${datafolder}/base_estimaciones_gus.dta", clear
set scheme s1mono


* Subset data for easy graph production
// gen borrar=rbinomial(1,.9)
// tab borrar	
// drop if borrar==1
// duplicates report cub year

* Guardar outliers en matriz
matrix define O=J(10,2,.)
matrix colnames O="IPM 1" "IPM 2"
matrix rownames O= "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" ///
				   "2021" "2022"
matlist O

* Generar histogramas para cada año
* IPM 1
capture drop es_outlier_IPM_1
gen es_outlier_IPM_1 = .
local row=1
forvalues x=2013(1)2022{
	* Calculate Outliers to report
	quiet sum IPM_1 if year==`x', d
	qui return list
	// 	di r(p25) // Q1
	// 	di r(p75) //Q3
	// 	di r(p75)-r(p25) //IQR
	scalar IQR=r(p75)-r(p25)
	* Calculating Lower Inner Fence:
	scalar LIF=r(p25)-1.5*IQR
	scalar UIF=r(p75)+1.5*IQR
	qui sum IPM_1 if year==`x' & IPM_1<LIF
	qui return list
	scalar lower_outliers=r(N)
	
	replace es_outlier_IPM_1 = 1 if year==`x' & IPM_2<LIF
	
	qui sum IPM_1 if year==`x' & IPM_1>UIF
	qui return list
	scalar upper_outliers=r(N)
	
	replace es_outlier_IPM_1=1 if year==`x' & IPM_1>UIF
	replace es_outlier_IPM_1=0 if es_outlier_IPM_1==.

	local outliers=lower_outliers+upper_outliers
	matrix O[`row',1]=`outliers'
	local LIF=round(LIF,0.001)
	local UIF=round(UIF,0.001)
	* Create Graph
	di "*************`x'***************"
// 	hist IPM_1 if year==`x', kden name("IPM1_`x'", replace) ///
// 		title("Histograma para IPM 1" "`x'") aspect(1) xtitle("IPM 1") ///
// 		ytitle("Densidad") ///
// 		note("Valores fuera de rango de Tukey [`LIF',`UIF']=`outliers' (outliers)") nodraw
// 	graph export "${output}/Graficos/hist_IPM1_`x'.png", as(png) replace
	scalar drop _all
	local row=`row'+1	
}

* IPM 2
capture drop es_outlier_IPM_2
gen es_outlier_IPM_2 = .
local row=1
forvalues x=2013(1)2022{
	* Calculate Outliers to report
	quiet sum IPM_2 if year==`x', d
	qui return list
	// 	di r(p25) // Q1
	// 	di r(p75) //Q3
	// 	di r(p75)-r(p25) //IQR
	scalar IQR=r(p75)-r(p25)
	* Calculating Lower Inner Fence:
	scalar LIF=r(p25)-1.5*IQR
	scalar UIF=r(p75)+1.5*IQR
	qui sum IPM_2 if year==`x' & IPM_2<LIF
	qui return list
	scalar lower_outliers=r(N)
	
	replace es_outlier_IPM_2 = 1 if year==`x' & IPM_2<LIF
	
	qui sum IPM_2 if year==`x' & IPM_2>UIF
	qui return list
	scalar upper_outliers=r(N)
	
	replace es_outlier_IPM_2=1 if year==`x' & IPM_2>UIF
	replace es_outlier_IPM_2=0 if es_outlier_IPM_2==.
	
	local outliers=lower_outliers+upper_outliers
	matrix O[`row',2]=`outliers'
	local LIF=round(LIF,0.001)
	local UIF=round(UIF,0.001)
	* Create Graph
	di "*************`x'***************"
// 	hist IPM_2 if year==`x', kden name("IPM2_`x'", replace) ///
// 		title("Histograma para IPM 2" "`x'") aspect(1) xtitle("IPM 2") ///
// 		ytitle("Densidad") ///
// 		note("Valores fuera de rango de Tukey [`LIF',`UIF']=`outliers' (outliers)") nodraw
// 	graph export "${output}/Graficos/hist_IPM2_`x'.png", as(png) replace
	scalar drop _all
	local row=`row'+1	
}
matlist O

* Modificar variables que identifican outliers para que sean 1 en todos los años
* para el mismo CUB. Hasta aquí la variable de outlier toma el valor de 1 
* solamente si el valor del IPM es outlier *dado* un año, por lo que puede pasar
* que un mismo CUB sea outlier en algunos años y en otros no. Ejemplo: 

// cub	  | year      | IPM_1|	es_outlier_IPM_1
*-------------------------------------------------
// 719182	2013 (0)	.52	    0
// 719182	2014 (0)	.52 	0
// 719182	2015 (1)	.934	1
// 719182	2016 (1)	.934	1
// 719182	2017 (6)	.934	1
// 719182	2018 (8)	.934	1
// 719182	2019 (43)	.934	1
// 719182	2020 (51)	.934	1
// 719182	2021 (130)	.934	1
// 719182	2022 (182)	.48 	0

capture drop aux_mean_outlier_IPM1
capture drop aux_mean_outlier_IPM2

bysort cub: egen aux_mean_outlier_IPM1=mean(es_outlier_IPM_1)
bysort cub: replace es_outlier_IPM_1=1 if aux_mean_outlier_IPM1>0
	capture drop aux_mean_outlier_IPM1
	bysort cub: egen aux_mean_outlier_IPM1=mean(es_outlier_IPM_1)
tab aux_mean_outlier_IPM1

bysort cub: egen aux_mean_outlier_IPM2=mean(es_outlier_IPM_2)
bysort cub: replace es_outlier_IPM_2=1 if aux_mean_outlier_IPM2>0
	capture drop aux_mean_outlier_IPM2
	bysort cub: egen aux_mean_outlier_IPM2=mean(es_outlier_IPM_2)
tab aux_mean_outlier_IPM2

* Producir value labels para cada valor de "year" para cada IPM
* IPM 1
local row=1
forvalues j=2013/2022{
	local label : label (year) `j'
	local outlier=O[`row',1]
	local label  "`label' (`outlier')"
	lab define year_label_IPM1 `j' "`label'", modify
	local row=`row'+1
}

* IPM 2
local row=1
forvalues j=2013/2022{
	local label : label (year) `j'
	local outlier=O[`row',2]
	local label  "`label' (`outlier')"
	lab define year_label_IPM2 `j' "`label'", modify
	local row=`row'+1
}

* Gráficos para IPM 1
label values year year_label_IPM1	
tab year	
vioplot IPM_1, over(year) horizontal ///
	title("Distribución de IPM 1 por año") ytitle("IPM 1") xtitle("Año") ///
	 line(lcolor(blue) lpattern(dash)) ylab(,angle(horiz)) ///
	l1title("`: var label year'") note("Número de {it:outliers} en paréntesis")
graph export "${output}/Graficos/hviolin_plot-ipm1.png", as(png) replace

graph hbox IPM_1, over(year) ///
	title("Distribución de IPM 1 por año") ytitle("IPM 1") ///
	l1title("`: var label year'") note("Número de {it:outliers} en paréntesis")
graph export "${output}/Graficos/hbox_plot-ipm1.png", as(png) replace
label values year

* Gráficos para IPM 2
label values year year_label_IPM2	
tab year
vioplot IPM_2, over(year) horizontal ///
	title("Distribución de IPM 2 por año") xtitle("IPM 2") ytitle("Año") ///
	line(lcolor(blue) lpattern(dash)) ylab(,angle(horiz)) ///
	note("Número de {it:outliers} en paréntesis") ///
	barwidth(100)
graph export "${output}/Graficos/hviolin_plot-ipm2.png", as(png) replace	
	
graph hbox IPM_2, over(year) ///
	title("Distribución de IPM 2 por año") ytitle("IPM 2") ///
	l1title("`: var label year'") note("Número de {it:outliers} en paréntesis")
graph export "${output}/Graficos/hbox_plot-ipm2.png", as(png) replace
label values year

save "${datafolder}/base_estimaciones_gus.dta", replace
