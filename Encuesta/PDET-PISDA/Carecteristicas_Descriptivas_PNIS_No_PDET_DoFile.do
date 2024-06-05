//preliminares//
clear all
cls

///////importamos base de datos de Avance implementación///////
import excel "/Users/lucasrodriguez/PISDA/PNIS NO PDET.xlsx", sheet("2. Avance Implementación") cellrange(A7:N335) firstrow

rename CODIGOINICIATIVA codigo
rename Fuente financiamiento
rename IDPROYECTO ID
rename DEPTO departamento_iniciativa
rename Estado estado_proyecto

destring codigo, replace
destring ID, replace

save "PNIS_No_PDET_Avance.dta", replace

drop TITULO DESCRIPCION codigo ID TIPO NOMBREDELPROYECTO CODIGOBPIN MUNICIPIO J financiamiento

//creamos contadores//
egen contador= count(departamento_iniciativa), by (departamento_iniciativa) 
egen proyectos_terminados= count(departamento_iniciativa) if estado_proyecto=="TERMINADO", by (departamento_iniciativa) 
egen x = mean(proyectos_terminados), by (departamento_iniciativa)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

//creamos variables de estado del proyecto//
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (departamento_iniciativa)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (departamento_iniciativa)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (departamento_iniciativa)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (departamento_iniciativa)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="FOCALIZADO O FINANCIADO"), by (departamento_iniciativa)
gen Focalizado_o_Financiado=x/contador
drop x
format Focalizado_o_Financiado %9.2f

egen x= total(estado_proyecto=="ENTREGADO"), by (departamento_iniciativa)
gen Entregado=x/contador
drop x
format Entregado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (departamento_iniciativa)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de estado valido//
egen x= total(EstadoValidadoActual=="En Edición"), by (departamento_iniciativa)
gen En_Edicion=x/contador
drop x
format En_Edicion %9.2f

egen x= total(EstadoValidadoActual=="En proceso "), by (departamento_iniciativa)
gen En_Proceso=x/contador
drop x
format En_Proceso %9.2f

egen x= total(EstadoValidadoActual=="Rechazado"), by (departamento_iniciativa)
gen Rechazado=x/contador
drop x
format Rechazado %9.2f

drop EstadoValidadoActual

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Valor !=.
egen y = total(x), by (departamento_iniciativa)
gen Missing_Financiamiento = 1- y/contador
format Missing_Financiamiento %9.3f
drop x y Valor

//creamos variable de cantidad de proyectos por departamento//
drop if missing(departamento_iniciativa)
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (departamento_iniciativa)

//ordenamos base//
order contador, after (departamento_iniciativa)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos
rename departamento_iniciativa departamento

save "/Users/lucasrodriguez/PISDA/PNIS_No_PDET_Departamentos.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_No_PDET_Tabla_Departamentos.xlsx", nolabel replace firstrow(variables)


//tabla financiamiento//
clear all
use "PNIS_No_PDET_Avance.dta"

drop codigo TITULO DESCRIPCION ID TIPO NOMBREDELPROYECTO CODIGOBPIN MUNICIPIO J EstadoValidadoActual

order financiamiento

egen contador= count(financiamiento), by (financiamiento) //creamos variable que cuenta las veces que un tipo de financiamiento sale aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(financiamiento) if estado_proyecto=="TERMINADO", by (financiamiento) 
egen x = mean(proyectos_terminados), by (financiamiento)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Valor != .
egen contador_recursos=total (contador2), by (financiamiento) //creamos variable que cuente el numero de proyectos financiados por tipo de financiamiento
drop contador2

//creamos variables de estado del proyecto//
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (financiamiento)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (financiamiento)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (financiamiento)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (financiamiento)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="FOCALIZADO O FINANCIADO"), by (financiamiento)
gen Focalizado_o_Financiado=x/contador
drop x
format Focalizado_o_Financiado %9.2f

egen x= total(estado_proyecto=="ENTREGADO"), by (financiamiento)
gen Entregado=x/contador
drop x
format Entregado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (financiamiento)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de departamento//
egen x= total(departamento_iniciativa=="CAUCA"), by (financiamiento)
gen Cauca=x/contador
drop x
format Cauca %9.2f

egen x= total(departamento_iniciativa=="GUAINÍA"), by (financiamiento)
gen Guainia=x/contador
drop x
format Guainia %9.2f

egen x= total(departamento_iniciativa=="NARIÑO"), by (financiamiento)
gen Nariño=x/contador
drop x
format Nariño %9.2f

egen x= total(departamento_iniciativa=="VALLE DEL CAUCA"), by (financiamiento)
gen Valle_del_Cauca=x/contador
drop x
format Valle_del_Cauca %9.2f

egen x= total(departamento_iniciativa=="VICHADA"), by (financiamiento)
gen Vichada=x/contador
drop x
format Vichada %9.2f

drop departamento_iniciativa

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Valor !=.
egen y = total(x), by (financiamiento)
gen Missing_Financiamiento = 1- y/contador
format Missing_Financiamiento %9.3f
drop x y Valor

//creamos variable de cantidad de proyectos por fuente//
drop if missing(financiamiento)
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (financiamiento)

order contador, after (financiamiento)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PNIS_No_PDET_Financiamiento.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_No_PDET_Tabla_Financiamiento.xlsx", nolabel replace firstrow(variables)


