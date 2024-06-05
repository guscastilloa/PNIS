//preliminares//
clear all
cls

///////importamos base de datos de Avance implementación///////

import excel "/Users/lucasrodriguez/Downloads/1. PISDA - PDET.xlsx", sheet("2. Avance implementación") cellrange(A6:P1226) firstrow clear

rename Subregióniniciativa subregion_iniciativa //cambiamos nombre de variable
rename Departamentoiniciativa departamento_iniciativa
rename Municipioiniciativa municipio_iniciativa
rename Códigoiniciativa codigo
rename Títuloiniciativa titulo_inciativa
rename IDProyecto ID
rename NombreProyecto nombre_proyecto
rename TipoProyecto financiamiento
rename EstadoProyecto estado_proyecto
rename SUBREGIONES_PROYECTO subregion_proyecto
rename DEPARTAMENTOS_PROYECTOS departamento_proyecto
rename MUNICIPIO_PROYECTOS municipio_proyecto
rename EstadoValidadoActual estado_valido_actual 
gen pilar = substr(Pilar, 4, .)
drop Pilar

drop subregion_proyecto departamento_proyecto municipio_proyecto //todos son missing value

destring codigo, replace

save "PNIS_Avance.dta", replace

///////importamos base de datos de Iniciativas///////

import excel "/Users/lucasrodriguez/Downloads/1. PISDA - PDET.xlsx", sheet("1. Iniciativas") cellrange(A6:K818) firstrow clear

//cambiamos nombres de variables//
rename Códigoiniciativa codigo 
rename TítuloIniciativa titulo_inciativa
rename DescripciónIniciativa descripcion_inciativa
rename ProyectoGestión proyecto_gestion
rename Conrutadeimplementaciónactiv ruta_implementación
rename Clasificación etnia
rename Subregión subregion
gen pilar = substr(Pilar, 4, .)
drop Pilar

destring codigo, replace //convertimos a valor numerico

save "PNIS_Inciativa.dta", replace

merge 1:m codigo using "PNIS_Avance.dta" //combinamos base de datos

drop _merge subregion_iniciativa

destring Valor, replace

save "PNIS_Base.dta", replace //salvamos base
export excel using "/Users/lucasrodriguez/Downloads/PNIS_Base.xlsx", nolabel replace firstrow(variables) //exportamos base a excel







///////Tabla municipio///////
cls
clear all
use "PNIS_Base.dta"

drop descripcion_inciativa titulo_inciativa nombre_proyecto departamento_iniciativa subregion codigo ID Categoría Estrategia Producto proyecto financiamiento //quitamos variables que no nos interesan

order municipio_iniciativa //ponemos de primero a municipio

egen contador= count(municipio_iniciativa), by (municipio_iniciativa) //creamos variable que cuenta las veces que un municipio aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(municipio_iniciativa) if estado_proyecto=="TERMINADO", by (municipio_iniciativa) 
egen x = mean(proyectos_terminados), by (municipio_iniciativa)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x


gen contador2=1 if Valor != 0
egen contador_recursos=total (contador2), by (municipio_iniciativa) //creamos variable que cuente el numero de proyectos financiados por municipio
drop contador2

drop if missing(municipio_iniciativa) //borramos observaciones que no tienen municipio

//creamos variable de valor total y valor promedio de proyecto para cada municipio//
egen valor_total = total(Valor), by (municipio_iniciativa)  //creamos variable de valor total y valor promedio de proyecto para cada municipio//
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Valor) if estado_proyecto=="TERMINADO", by (municipio_iniciativa)
egen x = mean(valor_total_Terminado), by (municipio_iniciativa)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Valor) if estado_proyecto=="TERMINADO" & Valor!=0, by (municipio_iniciativa)
egen x = mean(valor_promedio_Terminado), by (municipio_iniciativa)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (municipio_iniciativa)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (municipio_iniciativa)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (municipio_iniciativa)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (municipio_iniciativa)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (municipio_iniciativa)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (municipio_iniciativa)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (municipio_iniciativa)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (municipio_iniciativa)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (municipio_iniciativa)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (municipio_iniciativa)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (municipio_iniciativa)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (municipio_iniciativa)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (municipio_iniciativa)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (municipio_iniciativa)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (municipio_iniciativa)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (municipio_iniciativa)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(CLASIFICACIÓN=="Proyecto"), by (municipio_iniciativa)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(CLASIFICACIÓN=="Gestión"), by (municipio_iniciativa)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(CLASIFICACIÓN=="contrato"), by (municipio_iniciativa)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop CLASIFICACIÓN

//creamos variables de estado del proyecto//
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (municipio_iniciativa)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (municipio_iniciativa)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (municipio_iniciativa)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (municipio_iniciativa)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (municipio_iniciativa)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de estado valido del proyecto//
egen x= total(estado_valido_actual=="APROBADO" | estado_valido_actual== "APROBADO                     "), by (municipio_iniciativa)
gen Aprobado=x/contador
drop x
format Aprobado %9.2f

egen x= total(estado_valido_actual=="RECHAZADO" | estado_valido_actual== "RECHAZADO                     "), by (municipio_iniciativa)
gen Rechazado=x/contador
drop x
format Rechazado %9.2f

egen x= total(estado_valido_actual=="EN EDICIÓN" | estado_valido_actual== "EN EDICIÓN                    "), by (municipio_iniciativa)
gen En_Edicion=x/contador
drop x
format En_Edicion %9.2f

egen x= total(estado_valido_actual=="POR VALIDAR                   "), by (municipio_iniciativa)
gen Por_Validar=x/contador
drop x
format Por_Validar %9.2f

drop estado_valido_actual

//creamos variables de etnia//
egen x= total(etnia=="Común étnica"), by (municipio_iniciativa)
gen Comunidad_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="No étnica"), by (municipio_iniciativa)
gen No_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="Propia étnica"), by (municipio_iniciativa)
gen Propia_Etnica=x/contador
drop x
format Por_Validar %9.2f

drop etnia

//creamos variable de ruta de implementación//
egen x= total(ruta_implementación=="Si"), by (municipio_iniciativa)
gen Si=x/contador
drop x
format Por_Validar %9.2f

drop ruta_implementación

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Valor !=.
egen y = total(x), by (municipio_iniciativa)
gen Missing_Financiamiento = 1- y/contador
format Missing_Financiamiento %9.3f
drop x y Valor

//creamos variable de cantidad de proyectos por municipio//
drop if missing(municipio_iniciativa)
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Distribucion_de_Proyectos= contador/x
drop x
format Distribucion_de_Proyectos %9.3f
order Distribucion_de_Proyectos, after (municipio_iniciativa)

gen Dis_de_Proyectos_Terminado = Distribucion_de_Proyectos*Terminado
order Dis_de_Proyectos_Terminado, after (Distribucion_de_Proyectos)

//creamos variable de porcentaje de dinero destinado a municipio//
egen x = total(valor_total)
gen Distribucion_de_Recursos= valor_total/x
drop x
format Distribucion_de_Recursos %9.3f
order Distribucion_de_Recursos, after (Distribucion_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (municipio_iniciativa)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos
rename municipio_iniciativa Municipio

save "/Users/lucasrodriguez/PISDA/PNIS_Municipios.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_Tabla_Municipios.xlsx", nolabel replace firstrow(variables)







///////Tabla Departamento///////
cls
clear all
use "PNIS_Base.dta"

drop descripcion_inciativa titulo_inciativa nombre_proyecto municipio_iniciativa subregion codigo ID Categoría Estrategia Producto proyecto financiamiento //quitamos variables que no nos interesan

order departamento_iniciativa //ponemos de primero a departamento

egen contador= count(departamento_iniciativa), by (departamento_iniciativa) //creamos variable que cuenta las veces que un departamento aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(departamento_iniciativa) if estado_proyecto=="TERMINADO", by (departamento_iniciativa) 
egen x = mean(proyectos_terminados), by (departamento_iniciativa)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x


gen contador2=1 if Valor != 0
egen contador_recursos=total (contador2), by (departamento_iniciativa) //creamos variable que cuente el numero de proyectos financiados por departamento
drop contador2

drop if missing(departamento_iniciativa) //borramos observaciones que no tienen departamento

//creamos variable de valor total y valor promedio de proyecto para cada municipio//
egen valor_total = total(Valor), by (departamento_iniciativa)  //creamos variable de valor total y valor promedio de proyecto para cada departamento//
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Valor) if estado_proyecto=="TERMINADO", by (departamento_iniciativa)
egen x = mean(valor_total_Terminado), by (departamento_iniciativa)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Valor) if estado_proyecto=="TERMINADO" & Valor!=0, by (departamento_iniciativa)
egen x = mean(valor_promedio_Terminado), by (departamento_iniciativa)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (departamento_iniciativa)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (departamento_iniciativa)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (departamento_iniciativa)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (departamento_iniciativa)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (departamento_iniciativa)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (departamento_iniciativa)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (departamento_iniciativa)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (departamento_iniciativa)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (departamento_iniciativa)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (departamento_iniciativa)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (departamento_iniciativa)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (departamento_iniciativa)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (departamento_iniciativa)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (departamento_iniciativa)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (departamento_iniciativa)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (departamento_iniciativa)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(CLASIFICACIÓN=="Proyecto"), by (departamento_iniciativa)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(CLASIFICACIÓN=="Gestión"), by (departamento_iniciativa)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(CLASIFICACIÓN=="contrato"), by (departamento_iniciativa)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop CLASIFICACIÓN

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

egen x= total(estado_proyecto=="TERMINADO"), by (departamento_iniciativa)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de estado valido del proyecto//
egen x= total(estado_valido_actual=="APROBADO" | estado_valido_actual== "APROBADO                     "), by (departamento_iniciativa)
gen Aprobado=x/contador
drop x
format Aprobado %9.2f

egen x= total(estado_valido_actual=="RECHAZADO" | estado_valido_actual== "RECHAZADO                     "), by (departamento_iniciativa)
gen Rechazado=x/contador
drop x
format Rechazado %9.2f

egen x= total(estado_valido_actual=="EN EDICIÓN" | estado_valido_actual== "EN EDICIÓN                    "), by (departamento_iniciativa)
gen En_Edicion=x/contador
drop x
format En_Edicion %9.2f

egen x= total(estado_valido_actual=="POR VALIDAR                   "), by (departamento_iniciativa)
gen Por_Validar=x/contador
drop x
format Por_Validar %9.2f

drop estado_valido_actual

//creamos variables de etnia//
egen x= total(etnia=="Común étnica"), by (departamento_iniciativa)
gen Comunidad_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="No étnica"), by (departamento_iniciativa)
gen No_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="Propia étnica"), by (departamento_iniciativa)
gen Propia_Etnica=x/contador
drop x
format Por_Validar %9.2f

drop etnia

//creamos variable de ruta de implementación//
egen x= total(ruta_implementación=="Si"), by (departamento_iniciativa)
gen Si=x/contador
drop x
format Por_Validar %9.2f

drop ruta_implementación

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

//creamos variable de porcentaje de dinero destinado a departamento//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (departamento_iniciativa)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos
rename departamento_iniciativa departamento

save "/Users/lucasrodriguez/PISDA/PNIS_Departamentos.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_Tabla_Departamentos.xlsx", nolabel replace firstrow(variables)







///////Tabla Subregión///////
cls
clear all
use "PNIS_Base.dta"

drop descripcion_inciativa titulo_inciativa nombre_proyecto municipio_iniciativa departamento_iniciativa codigo ID Categoría Estrategia Producto proyecto financiamiento //quitamos variables que no nos interesan

order subregion //ponemos de primero a subregion

egen contador= count(subregion), by (subregion) //creamos variable que cuenta las veces que un subregion aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(subregion) if estado_proyecto=="TERMINADO", by (subregion) 
egen x = mean(proyectos_terminados), by (subregion)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Valor !=.
egen contador_recursos=total (contador2), by (subregion) //creamos variable que cuente el numero de proyectos financiados por subregion
drop contador2

//creamos variable de valor total y valor promedio de proyecto para cada subregion//
egen valor_total = total(Valor), by (subregion)  //creamos variable de valor total y valor promedio de proyecto para cada subregion//
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Valor) if estado_proyecto=="TERMINADO", by (subregion)
egen x = mean(valor_total_Terminado), by (subregion)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Valor) if estado_proyecto=="TERMINADO" & Valor!=0, by (subregion)
egen x = mean(valor_promedio_Terminado), by (subregion)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (subregion)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (subregion)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (subregion)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (subregion)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (subregion)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (subregion)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (subregion)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (subregion)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (subregion)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (subregion)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (subregion)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (subregion)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (subregion)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (subregion)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (subregion)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (subregion)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(CLASIFICACIÓN=="Proyecto"), by (subregion)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(CLASIFICACIÓN=="Gestión"), by (subregion)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(CLASIFICACIÓN=="contrato"), by (subregion)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop CLASIFICACIÓN

//creamos variables de estado del proyecto//
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (subregion)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (subregion)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (subregion)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (subregion)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (subregion)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de estado valido del proyecto//
egen x= total(estado_valido_actual=="APROBADO" | estado_valido_actual== "APROBADO                     "), by (subregion)
gen Aprobado=x/contador
drop x
format Aprobado %9.2f

egen x= total(estado_valido_actual=="RECHAZADO" | estado_valido_actual== "RECHAZADO                     "), by (subregion)
gen Rechazado=x/contador
drop x
format Rechazado %9.2f

egen x= total(estado_valido_actual=="EN EDICIÓN" | estado_valido_actual== "EN EDICIÓN                    "), by (subregion)
gen En_Edicion=x/contador
drop x
format En_Edicion %9.2f

egen x= total(estado_valido_actual=="POR VALIDAR                   "), by (subregion)
gen Por_Validar=x/contador
drop x
format Por_Validar %9.2f

drop estado_valido_actual

//creamos variables de etnia//
egen x= total(etnia=="Común étnica"), by (subregion)
gen Comunidad_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="No étnica"), by (subregion)
gen No_Etnica=x/contador
drop x
format Por_Validar %9.2f

egen x= total(etnia=="Propia étnica"), by (subregion)
gen Propia_Etnica=x/contador
drop x
format Por_Validar %9.2f

drop etnia

//creamos variable de ruta de implementación//
egen x= total(ruta_implementación=="Si"), by (subregion)
gen Si=x/contador
drop x
format Por_Validar %9.2f

drop ruta_implementación

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Valor !=.
egen y = total(x), by (subregion)
gen Missing_Financiamiento = 1- y/contador
format Missing_Financiamiento %9.3f
drop x y Valor

//creamos variable de cantidad de proyectos por subregion//
drop if missing(subregion)
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (subregion)

//creamos variable de porcentaje de dinero destinado a subregion//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (subregion)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PNIS_Subregion.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_Tabla_Subregion.xlsx", nolabel replace firstrow(variables)







///////Tabla Pilar///////
cls
clear all
use "PNIS_Base.dta"

drop codigo titulo_inciativa descripcion_inciativa Categoría Estrategia Producto etnia ruta_implementación municipio_iniciativa ID nombre_proyecto financiamiento  CLASIFICACIÓN estado_valido_actual proyecto_gestion departamento_iniciativa //eliminamos variables que no nos interesan

order pilar //ponemos de primero a los pilares

egen contador= count(pilar), by (pilar) //creamos variable que cuenta las veces que un pilar aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(pilar) if estado_proyecto=="TERMINADO", by (pilar) 
egen x = mean(proyectos_terminados), by (pilar)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Valor !=.
egen contador_recursos=total (contador2), by (pilar) //creamos variable que cuente el numero de proyectos financiados por pilar
drop contador2

//creamos variable de valor total y valor promedio de proyecto para cada pilar//
egen valor_total = total(Valor), by (pilar)  //creamos variable de valor total y valor promedio de proyecto para cada pilar//
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Valor) if estado_proyecto=="TERMINADO", by (pilar)
egen x = mean(valor_total_Terminado), by (pilar)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Valor) if estado_proyecto=="TERMINADO" & Valor!=0, by (pilar)
egen x = mean(valor_promedio_Terminado), by (pilar)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de estado del proyecto//
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (pilar)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (pilar)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (pilar)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (pilar)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (pilar)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de subregion//
egen x= total(subregion=="ALTO PATÍA Y NORTE DEL CAUCA"), by (pilar)
gen Alto_Patia_Norte_Cauca=x/contador
drop x
format Alto_Patia_Norte_Cauca %9.2f

egen x= total(subregion=="ARAUCA"), by (pilar)
gen Arauca=x/contador
drop x
format Arauca %9.2f

egen x= total(subregion=="CATATUMBO"), by (pilar)
gen Catatumbo=x/contador
drop x
format Catatumbo %9.2f

egen x= total(subregion=="BAJO CAUCA Y NORDESTE ANTIOQUEÑO"), by (pilar)
gen Bajo_Cauca=x/contador
drop x
format Bajo_Cauca %9.2f

egen x= total(subregion=="CUENCA DEL CAGUÁN Y PIEDEMONTE CAQUETEÑO"), by (pilar)
gen Caguan=x/contador
drop x
format Caguan %9.2f

egen x= total(subregion=="MACARENA - GUAVIARE"), by (pilar)
gen Macarena=x/contador
drop x
format Macarena %9.2f

egen x= total(subregion=="PACÍFICO Y FRONTERA NARIÑENSE"), by (pilar)
gen Pacifico=x/contador
drop x
format Pacifico %9.2f

egen x= total(subregion=="PUTUMAYO"), by (pilar)
gen Putumayo=x/contador
drop x
format Putumayo %9.2f

egen x= total(subregion=="SUR DE BOLÍVAR"), by (pilar)
gen Sur_Bolivar=x/contador
drop x
format Sur_Bolivar %9.2f

egen x= total(subregion=="SUR DE CÓRDOBA"), by (pilar)
gen Sur_Cordoba=x/contador
drop x
format Sur_Cordoba %9.2f

drop subregion

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Valor !=.
egen y = total(x), by (pilar)
gen Missing_Financiamiento = 1- y/contador
format Missing_Financiamiento %9.3f
drop x y Valor

//creamos variable de cantidad de proyectos por pilar//
drop if missing(pilar)
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (pilar)

//creamos variable de porcentaje de dinero destinado a pilar//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (pilar)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PNIS_Pilar.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_Tabla_Pilar.xlsx", nolabel replace firstrow(variables)







///////Financiamiento///////
cls
clear all
use "PNIS_Base.dta"

drop codigo titulo_inciativa descripcion_inciativa Categoría Estrategia Producto proyecto_gestion etnia ruta_implementación municipio_iniciativa ID nombre_proyecto CLASIFICACIÓN estado_valido_actual departamento_iniciativa 

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


//creamos variable de valor total y valor promedio de proyecto para cada subregion//
egen valor_total = total(Valor), by (financiamiento)  //creamos variable de valor total y valor promedio de proyecto para cada subregion//
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Valor) if estado_proyecto=="TERMINADO", by (financiamiento)
egen x = mean(valor_total_Terminado), by (financiamiento)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Valor) if estado_proyecto=="TERMINADO" & Valor!=0, by (financiamiento)
egen x = mean(valor_promedio_Terminado), by (financiamiento)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

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

egen x= total(estado_proyecto=="TERMINADO"), by (financiamiento)
gen Terminado=x/contador
drop x
format Terminado %9.2f

//creamos variables de subregion//

egen x= total(subregion=="ALTO PATÍA Y NORTE DEL CAUCA"), by (financiamiento)
gen Alto_Patia_Norte_Cauca=x/contador
drop x
format Alto_Patia_Norte_Cauca %9.2f

egen x= total(subregion=="ARAUCA"), by (financiamiento)
gen Arauca=x/contador
drop x
format Arauca %9.2f

egen x= total(subregion=="CATATUMBO"), by (financiamiento)
gen Catatumbo=x/contador
drop x
format Catatumbo %9.2f

egen x= total(subregion=="BAJO CAUCA Y NORDESTE ANTIOQUEÑO"), by (financiamiento)
gen Bajo_Cauca=x/contador
drop x
format Bajo_Cauca %9.2f

egen x= total(subregion=="CUENCA DEL CAGUÁN Y PIEDEMONTE CAQUETEÑO"), by (financiamiento)
gen Caguan=x/contador
drop x
format Caguan %9.2f

egen x= total(subregion=="MACARENA - GUAVIARE"), by (financiamiento)
gen Macarena=x/contador
drop x
format Macarena %9.2f

egen x= total(subregion=="PACÍFICO Y FRONTERA NARIÑENSE"), by (financiamiento)
gen Pacifico=x/contador
drop x
format Pacifico %9.2f

egen x= total(subregion=="PUTUMAYO"), by (financiamiento)
gen Putumayo=x/contador
drop x
format Putumayo %9.2f

egen x= total(subregion=="SUR DE BOLÍVAR"), by (financiamiento)
gen Sur_Bolivar=x/contador
drop x
format Sur_Bolivar %9.2f

egen x= total(subregion=="SUR DE CÓRDOBA"), by (financiamiento)
gen Sur_Cordoba=x/contador
drop x
format Sur_Cordoba %9.2f

drop subregion

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (financiamiento)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (financiamiento)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (financiamiento)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (financiamiento)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (financiamiento)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (financiamiento)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (financiamiento)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (financiamiento)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (financiamiento)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (financiamiento)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (financiamiento)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (financiamiento)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (financiamiento)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (financiamiento)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (financiamiento)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if estado_proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (financiamiento)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar estado_proyecto

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

//creamos variable de porcentaje de dinero aportado por fuente//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
//drop contador_recursos
order contador, after (financiamiento)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PNIS_Financiamiento.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PNIS_Tabla_Financiamiento.xlsx", nolabel replace firstrow(variables)


///levelsof categoria, local(unique_vals)///
