//preliminares//
clear all
cls

///////importamos base detalle avance///////

import excel "/Users/lucasrodriguez/PISDA/3. INICIATIVAS PDET- PAI COMUNITARIO PNIS.xlsx", sheet("Detalle Avance") cellrange(A2:AA2413) firstrow

rename CodigoIniciativa codigo
rename CodigoDane codigo_dane
rename DescripciónIniciativa despripcion_iniciativa
rename NúmeroProducto numero_producto
rename TïtuloIniciativa titulo_iniciativa
rename Subregión subregion
rename Clasificación clasificacion
rename Inversión_Proyecto Inversion_proyecto
rename Fuentedelosrecursosinvertido Fuente_de_Recursos
rename EntidadesFinanciadoras Entidades_Financiadoras
gen pilar = substr(Pilar, 4, .)
drop Pilar

drop Programadeguarderíasinfantile Construcciónydotacióndecomed Mecanismosdeinformaciónparaf Programascontraelhambrepara Programasdesuperacióndelapo Brigadasdeatenciónbásicaens RutadeImplementacióna3006

replace Inversion_proyecto = "0" if Inversion_proyecto =="NULL"
destring Inversion_proyecto, replace
destring codigo, replace

save "PDET_Avance.dta", replace

///////importamos base General///////
clear all
cls

import excel "/Users/lucasrodriguez/PISDA/3. INICIATIVAS PDET- PAI COMUNITARIO PNIS.xlsx", sheet("General") cellrange(A3:AL1301) firstrow

rename CódigoIniciativa codigo
rename CodigoDane codigo_dane
rename TituloIniciativa titulo_iniciativa
rename DescripcionIniciativa descripcion_iniciativa
rename NumeroProducto numero_producto
rename Subregion subregion
gen pilar = substr(Pilar, 4, .)
drop Pilar

destring codigo, replace
destring codigo_dane, replace

save "PDET_General.dta", replace

merge m:m codigo using "PDET_Avance.dta", force //combinamos base de datos
drop _merge codigo_dane numero_producto

//convertimos componentes PAI a numerico//
replace Programadeguarderíasinfantile = "1" if Programadeguarderíasinfantile=="X"
replace Construcciónydotacióndecomed = "1" if Construcciónydotacióndecomed=="X"
replace Mecanismosdeinformaciónparaf = "1" if Mecanismosdeinformaciónparaf=="X"
replace Programascontraelhambrepara = "1" if Programascontraelhambrepara=="X"
replace Programasdesuperacióndelapo = "1" if Programasdesuperacióndelapo=="X"
replace Brigadasdeatenciónbásicaens = "1" if Brigadasdeatenciónbásicaens=="X"
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26=="X"

destring Programadeguarderíasinfantile, replace
destring Construcciónydotacióndecomed, replace
destring Mecanismosdeinformaciónparaf, replace
destring Programascontraelhambrepara, replace
destring Programasdesuperacióndelapo, replace
destring Brigadasdeatenciónbásicaens, replace
destring GestionadaNogestionadaa26, replace

save "PDET_Base.dta", replace







/////Tabla municipio/////
cls
clear all
use "PDET_Base.dta"

order Municipio

drop subregion Departamento titulo_iniciativa codigo descripcion_iniciativa despripcion_iniciativa IDProyectoGestión ProductoART CategoriaART EstrategiaART Nombre_Proyecto Tipo_Proyecto //borramos variables que no nos interesan

egen contador= count(Municipio), by (Municipio) //creamos variable que cuenta las veces que un municipio aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(Municipio) if Estado_Proyecto=="TERMINADO", by (Municipio) 
egen x = mean(proyectos_terminados), by (Municipio)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (Municipio) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

drop if missing(Municipio) //borramos observaciones que no tienen municipio

//creamos variable de valor total y valor promedio de proyecto para cada municipio//
egen valor_total = total(Inversion_proyecto), by (Municipio)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (Municipio)
egen x = mean(valor_total_Terminado), by (Municipio)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (Municipio)
egen x = mean(valor_promedio_Terminado), by (Municipio)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (Municipio)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (Municipio)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (Municipio)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (Municipio)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (Municipio)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (Municipio)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (Municipio)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (Municipio)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (Municipio)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (Municipio)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (Municipio)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (Municipio)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (Municipio)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (Municipio)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (Municipio)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (Municipio)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(clasificacion=="Proyecto"), by (Municipio)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(clasificacion=="Gestión"), by (Municipio)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(clasificacion=="contrato"), by (Municipio)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop clasificacion

//creamos variables de componentes PAI//
egen x= total(Programadeguarderíasinfantile), by (Municipio)
gen Guarderia_Infantil_Rural=x/contador
format Guarderia_Infantil_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programadeguarderíasinfantile==1
egen z = total(y), by (Municipio)
gen Infantil_Rural_Terminado= z/x
replace Infantil_Rural_Terminado=0 if Infantil_Rural_Terminado==.
drop x y z Programadeguarderíasinfantile

egen x= total(Construcciónydotacióndecomed), by (Municipio)
gen Comedores_Escolares_Suministros=x/contador
format Comedores_Escolares_Suministros %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Construcciónydotacióndecomed==1
egen z = total(y), by (Municipio)
gen Escolares_Suministros_Terminado= z/x
replace Escolares_Suministros_Terminado=0 if Escolares_Suministros_Terminado==.
drop x y z Construcciónydotacióndecomed

egen x= total(Mecanismosdeinformaciónparaf), by (Municipio)
gen Informacion_Acceso_Laboral=x/contador
format Informacion_Acceso_Laboral %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Mecanismosdeinformaciónparaf==1
egen z = total(y), by (Municipio)
gen Informacion_Laboral_Terminado= z/x
replace Informacion_Laboral_Terminado=0 if Informacion_Laboral_Terminado==.
drop x y z Mecanismosdeinformaciónparaf

egen x= total(Programascontraelhambrepara), by (Municipio)
gen Hambre_Tercera_Edad=x/contador
format Hambre_Tercera_Edad %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programascontraelhambrepara==1
egen z = total(y), by (Municipio)
gen Hambre_Terminado= z/x
replace Hambre_Terminado=0 if Hambre_Terminado==.
drop x y z Programascontraelhambrepara

egen x= total(Programasdesuperacióndelapo), by (Municipio)
gen Superacion_Pobreza=x/contador
format Superacion_Pobreza %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programasdesuperacióndelapo==1
egen z = total(y), by (Municipio)
gen Superacion_Pobreza_Terminado= z/x
replace Superacion_Pobreza_Terminado=0 if Superacion_Pobreza_Terminado==.
drop x y z Programasdesuperacióndelapo

egen x= total(Brigadasdeatenciónbásicaens), by (Municipio)
gen Atencion_Basica_Salud=x/contador
format Atencion_Basica_Salud %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Brigadasdeatenciónbásicaens==1
egen z = total(y), by (Municipio)
gen Atencion_Salud_Salud= z/x
replace Atencion_Salud_Salud=0 if Atencion_Salud_Salud==.
drop x y z Brigadasdeatenciónbásicaens

//creamos variables de estado del proyecto//
rename Estado_Proyecto estado_proyecto
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (Municipio)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (Municipio)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (Municipio)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (Municipio)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (Municipio)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (Municipio)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de ruta de implementacion//
replace Rutadeimplementacióna2202 = "1" if Rutadeimplementacióna2202 == "Con ruta de implementación "
replace Rutadeimplementacióna2202 = "0" if Rutadeimplementacióna2202 == "Sin ruta de implementación "
destring Rutadeimplementacióna2202, replace

replace Rutadeimplementacióna0903 = "1" if Rutadeimplementacióna0903 == "Con ruta de implementación "
replace Rutadeimplementacióna0903 = "0" if Rutadeimplementacióna0903 == "Sin ruta de implementación "
destring Rutadeimplementacióna0903, replace

replace Rutadeimplementacióna0704 = "1" if Rutadeimplementacióna0704 == "Con ruta de implementación "
replace Rutadeimplementacióna0704 = "0" if Rutadeimplementacióna0704 == "Sin ruta de implementación "
destring Rutadeimplementacióna0704, replace

replace Rutadeimplementacióna0505 = "1" if Rutadeimplementacióna0505 == "Con ruta de implementación "
replace Rutadeimplementacióna0505 = "0" if Rutadeimplementacióna0505 == "Sin ruta de implementación "
destring Rutadeimplementacióna0505, replace

replace Rutadeimplementacióna0706 = "1" if Rutadeimplementacióna0706 == "Con ruta de implementación "
replace Rutadeimplementacióna0706 = "0" if Rutadeimplementacióna0706 == "Sin ruta de implementación"
destring Rutadeimplementacióna0706, replace

replace Rutadeimplementacióna0807 = "1" if Rutadeimplementacióna0807 == "Con ruta de implementación "
replace Rutadeimplementacióna0807 = "0" if Rutadeimplementacióna0807 == "Sin ruta de implementación"
destring Rutadeimplementacióna0807, replace

replace Rutadeimplementacióna3107 = "1" if Rutadeimplementacióna3107 == "Con ruta de implementación "
replace Rutadeimplementacióna3107 = "0" if Rutadeimplementacióna3107 == "Sin ruta de implementación"
destring Rutadeimplementacióna3107, replace

replace Rutadeimplementacióna3108 = "1" if Rutadeimplementacióna3108 == "Con ruta de implementación"
replace Rutadeimplementacióna3108 = "0" if Rutadeimplementacióna3108 == "Sin ruta de implementación"
destring Rutadeimplementacióna3108, replace

replace Rutadeimplementacióna3009 = "1" if Rutadeimplementacióna3009 == "Con ruta de implementación"
replace Rutadeimplementacióna3009 = "0" if Rutadeimplementacióna3009 == "Sin ruta de implementación"
destring Rutadeimplementacióna3009, replace

replace Rutadeimplementacióna3110 = "1" if Rutadeimplementacióna3110 == "Con ruta de implementación"
replace Rutadeimplementacióna3110 = "0" if Rutadeimplementacióna3110 == "Sin ruta de implementación"
destring Rutadeimplementacióna3110, replace

replace Rutadeimplementacióna3011 = "1" if Rutadeimplementacióna3011 == "Con ruta de implementación "
replace Rutadeimplementacióna3011 = "0" if Rutadeimplementacióna3011 == "Sin ruta de implementación"
destring Rutadeimplementacióna3011, replace

replace Rutadeimplementacióna2212 = "1" if Rutadeimplementacióna2212 == "Con ruta de implementación "
replace Rutadeimplementacióna2212 = "0" if Rutadeimplementacióna2212 == "Sin ruta de implementación"
destring Rutadeimplementacióna2212, replace

replace Rutadeimplementacióna3112 = "1" if Rutadeimplementacióna3112 == "Con ruta de implementación "
replace Rutadeimplementacióna3112 = "0" if Rutadeimplementacióna3112 == "Sin ruta de implementación"
destring Rutadeimplementacióna3112, replace

replace Rutadeimplementacióna3101 = "1" if Rutadeimplementacióna3101 == "Con ruta de implementación "
replace Rutadeimplementacióna3101 = "0" if Rutadeimplementacióna3101 == "Sin ruta de implementación"
destring Rutadeimplementacióna3101, replace

replace Rutadeimplementacióna2802 = "1" if Rutadeimplementacióna2802 == "Con ruta de implementación "
replace Rutadeimplementacióna2802 = "0" if Rutadeimplementacióna2802 == "Sin ruta de implementación"
destring Rutadeimplementacióna2802, replace

replace Rutadeimplementacióna3103 = "1" if Rutadeimplementacióna3103 == "Con ruta de implementación "
replace Rutadeimplementacióna3103 = "0" if Rutadeimplementacióna3103 == "Sin ruta de implementación"
destring Rutadeimplementacióna3103, replace

replace Rutadeimplementacióna3004 = "1" if Rutadeimplementacióna3004 == "Con ruta de implementación "
replace Rutadeimplementacióna3004 = "0" if Rutadeimplementacióna3004 == "Sin ruta de implementación"
destring Rutadeimplementacióna3004, replace

replace Rutadeimplementacióna3105 = "1" if Rutadeimplementacióna3105 == "Con ruta de implementación "
replace Rutadeimplementacióna3105 = "0" if Rutadeimplementacióna3105 == "Sin ruta de implementación"
destring Rutadeimplementacióna3105, replace

replace Rutadeimplementacióna3006 = "1" if Rutadeimplementacióna3006 == "Con ruta de implementación "
replace Rutadeimplementacióna3006 = "0" if Rutadeimplementacióna3006 == "Sin ruta de implementación"
destring Rutadeimplementacióna3006, replace

egen x=total(Rutadeimplementacióna2202), by (Municipio)
gen ruta_implementacion_22_02_2022= x/contador
drop x Rutadeimplementacióna2202

egen x=total(Rutadeimplementacióna0903), by (Municipio)
gen ruta_implementacion_09_03_2022= x/contador
drop x Rutadeimplementacióna0903

egen x=total(Rutadeimplementacióna0704), by (Municipio)
gen ruta_implementacion_07_04_2022= x/contador
drop x Rutadeimplementacióna0704

egen x=total(Rutadeimplementacióna0505), by (Municipio)
gen ruta_implementacion_05_05_2022= x/contador
drop x Rutadeimplementacióna0505

egen x=total(Rutadeimplementacióna0706), by (Municipio)
gen ruta_implementacion_07_06_2022= x/contador
drop x Rutadeimplementacióna0706

egen x=total(Rutadeimplementacióna0807), by (Municipio)
gen ruta_implementacion_08_07_2022= x/contador
drop x Rutadeimplementacióna0807

egen x=total(Rutadeimplementacióna3107), by (Municipio)
gen ruta_implementacion_31_07_2022= x/contador
drop x Rutadeimplementacióna3107

egen x=total(Rutadeimplementacióna3108), by (Municipio)
gen ruta_implementacion_31_08_2022= x/contador
drop x Rutadeimplementacióna3108

egen x=total(Rutadeimplementacióna3009), by (Municipio)
gen ruta_implementacion_30_09_2022= x/contador
drop x Rutadeimplementacióna3009

egen x=total(Rutadeimplementacióna3110), by (Municipio)
gen ruta_implementacion_31_10_2022= x/contador
drop x Rutadeimplementacióna3110

egen x=total(Rutadeimplementacióna3011), by (Municipio)
gen ruta_implementacion_30_11_2022= x/contador
drop x Rutadeimplementacióna3011

egen x=total(Rutadeimplementacióna2212), by (Municipio)
gen ruta_implementacion_22_12_2022= x/contador
drop x Rutadeimplementacióna2212

egen x=total(Rutadeimplementacióna3112), by (Municipio)
gen ruta_implementacion_31_12_2022= x/contador
drop x Rutadeimplementacióna3112

egen x=total(Rutadeimplementacióna3101), by (Municipio)
gen ruta_implementacion_31_01_2023= x/contador
drop x Rutadeimplementacióna3101

egen x=total(Rutadeimplementacióna2802), by (Municipio)
gen ruta_implementacion_28_02_2023= x/contador
drop x Rutadeimplementacióna2802

egen x=total(Rutadeimplementacióna3103), by (Municipio)
gen ruta_implementacion_31_03_2023= x/contador
drop x Rutadeimplementacióna3103

egen x=total(Rutadeimplementacióna3004), by (Municipio)
gen ruta_implementacion_30_04_2023= x/contador
drop x Rutadeimplementacióna3004

egen x=total(Rutadeimplementacióna3105), by (Municipio)
gen ruta_implementacion_31_05_2023= x/contador
drop x Rutadeimplementacióna3105

egen x=total(Rutadeimplementacióna3006), by (Municipio)
gen ruta_implementacion_30_06_2023= x/contador
drop x Rutadeimplementacióna3006

//creamos variables que cuenten proyectos sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (Municipio)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (Municipio)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (Municipio)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto Entidades_Financiadoras Fuente_de_Recursos

//creamos variable de cantidad de proyectos por municipio//
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Distribucion_de_Proyectos= contador/x
drop x
format Distribucion_de_Proyectos %9.3f
order Distribucion_de_Proyectos, after (Municipio)

//creamos variable de porcentaje de dinero destinado a municipio//
egen x = total(valor_total)
gen Distribucion_de_Recursos= valor_total/x
drop x
format Distribucion_de_Recursos %9.3f
order Distribucion_de_Recursos, after (Distribucion_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (Municipio)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PDET_Municipios.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_Municipios.xlsx", nolabel replace firstrow(variables)







///////Tabla Departamento///////
cls
clear all
use "PDET_Base.dta"

order Departamento

drop subregion Municipio titulo_iniciativa codigo descripcion_iniciativa despripcion_iniciativa IDProyectoGestión ProductoART CategoriaART EstrategiaART Nombre_Proyecto Tipo_Proyecto //borramos variables que no nos interesan

egen contador= count(Departamento), by (Departamento) //creamos variable que cuenta las veces que un Departamento aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(Departamento) if Estado_Proyecto=="TERMINADO", by (Departamento) 
egen x = mean(proyectos_terminados), by (Departamento)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (Departamento) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

drop if missing(Departamento) //borramos observaciones que no tienen Departamento

//creamos variable de valor total y valor promedio de proyecto para cada Departamento//
egen valor_total = total(Inversion_proyecto), by (Departamento)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (Departamento)
egen x = mean(valor_total_Terminado), by (Departamento)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (Departamento)
egen x = mean(valor_promedio_Terminado), by (Departamento)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (Departamento)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (Departamento)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (Departamento)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (Departamento)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (Departamento)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (Departamento)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (Departamento)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (Departamento)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (Departamento)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (Departamento)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (Departamento)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (Departamento)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (Departamento)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (Departamento)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (Departamento)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (Departamento)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(clasificacion=="Proyecto"), by (Departamento)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(clasificacion=="Gestión"), by (Departamento)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(clasificacion=="contrato"), by (Departamento)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop clasificacion

//creamos variables de componentes PAI//
egen x= total(Programadeguarderíasinfantile), by (Departamento)
gen Guarderia_Infantil_Rural=x/contador
format Guarderia_Infantil_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programadeguarderíasinfantile==1
egen z = total(y), by (Departamento)
gen Infantil_Rural_Terminado= z/x
replace Infantil_Rural_Terminado=0 if Infantil_Rural_Terminado==.
drop x y z Programadeguarderíasinfantile

egen x= total(Construcciónydotacióndecomed), by (Departamento)
gen Comedores_Escolares_Suministros=x/contador
format Comedores_Escolares_Suministros %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Construcciónydotacióndecomed==1
egen z = total(y), by (Departamento)
gen Escolares_Suministros_Terminado= z/x
replace Escolares_Suministros_Terminado=0 if Escolares_Suministros_Terminado==.
drop x y z Construcciónydotacióndecomed

egen x= total(Mecanismosdeinformaciónparaf), by (Departamento)
gen Informacion_Acceso_Laboral=x/contador
format Informacion_Acceso_Laboral %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Mecanismosdeinformaciónparaf==1
egen z = total(y), by (Departamento)
gen Informacion_Laboral_Terminado= z/x
replace Informacion_Laboral_Terminado=0 if Informacion_Laboral_Terminado==.
drop x y z Mecanismosdeinformaciónparaf

egen x= total(Programascontraelhambrepara), by (Departamento)
gen Hambre_Tercera_Edad=x/contador
format Hambre_Tercera_Edad %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programascontraelhambrepara==1
egen z = total(y), by (Departamento)
gen Hambre_Terminado= z/x
replace Hambre_Terminado=0 if Hambre_Terminado==.
drop x y z Programascontraelhambrepara

egen x= total(Programasdesuperacióndelapo), by (Departamento)
gen Superacion_Pobreza=x/contador
format Superacion_Pobreza %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programasdesuperacióndelapo==1
egen z = total(y), by (Departamento)
gen Superacion_Pobreza_Terminado= z/x
replace Superacion_Pobreza_Terminado=0 if Superacion_Pobreza_Terminado==.
drop x y z Programasdesuperacióndelapo

egen x= total(Brigadasdeatenciónbásicaens), by (Departamento)
gen Atencion_Basica_Salud=x/contador
format Atencion_Basica_Salud %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Brigadasdeatenciónbásicaens==1
egen z = total(y), by (Departamento)
gen Atencion_Salud_Salud= z/x
replace Atencion_Salud_Salud=0 if Atencion_Salud_Salud==.
drop x y z Brigadasdeatenciónbásicaens

//creamos variables de estado del proyecto//
rename Estado_Proyecto estado_proyecto
egen x= total(estado_proyecto=="EN EJECUCIÓN"), by (Departamento)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(estado_proyecto=="EN ESTRUCTURACIÓN"), by (Departamento)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO"), by (Departamento)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(estado_proyecto=="ESTRUCTURADO Y FINANCIADO"), by (Departamento)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(estado_proyecto=="TERMINADO"), by (Departamento)
gen Terminado=x/contador
drop x
format Terminado %9.2f

drop estado_proyecto

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (Departamento)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de ruta de implementacion//
replace Rutadeimplementacióna2202 = "1" if Rutadeimplementacióna2202 == "Con ruta de implementación "
replace Rutadeimplementacióna2202 = "0" if Rutadeimplementacióna2202 == "Sin ruta de implementación "
destring Rutadeimplementacióna2202, replace

replace Rutadeimplementacióna0903 = "1" if Rutadeimplementacióna0903 == "Con ruta de implementación "
replace Rutadeimplementacióna0903 = "0" if Rutadeimplementacióna0903 == "Sin ruta de implementación "
destring Rutadeimplementacióna0903, replace

replace Rutadeimplementacióna0704 = "1" if Rutadeimplementacióna0704 == "Con ruta de implementación "
replace Rutadeimplementacióna0704 = "0" if Rutadeimplementacióna0704 == "Sin ruta de implementación "
destring Rutadeimplementacióna0704, replace

replace Rutadeimplementacióna0505 = "1" if Rutadeimplementacióna0505 == "Con ruta de implementación "
replace Rutadeimplementacióna0505 = "0" if Rutadeimplementacióna0505 == "Sin ruta de implementación "
destring Rutadeimplementacióna0505, replace

replace Rutadeimplementacióna0706 = "1" if Rutadeimplementacióna0706 == "Con ruta de implementación "
replace Rutadeimplementacióna0706 = "0" if Rutadeimplementacióna0706 == "Sin ruta de implementación"
destring Rutadeimplementacióna0706, replace

replace Rutadeimplementacióna0807 = "1" if Rutadeimplementacióna0807 == "Con ruta de implementación "
replace Rutadeimplementacióna0807 = "0" if Rutadeimplementacióna0807 == "Sin ruta de implementación"
destring Rutadeimplementacióna0807, replace

replace Rutadeimplementacióna3107 = "1" if Rutadeimplementacióna3107 == "Con ruta de implementación "
replace Rutadeimplementacióna3107 = "0" if Rutadeimplementacióna3107 == "Sin ruta de implementación"
destring Rutadeimplementacióna3107, replace

replace Rutadeimplementacióna3108 = "1" if Rutadeimplementacióna3108 == "Con ruta de implementación"
replace Rutadeimplementacióna3108 = "0" if Rutadeimplementacióna3108 == "Sin ruta de implementación"
destring Rutadeimplementacióna3108, replace

replace Rutadeimplementacióna3009 = "1" if Rutadeimplementacióna3009 == "Con ruta de implementación"
replace Rutadeimplementacióna3009 = "0" if Rutadeimplementacióna3009 == "Sin ruta de implementación"
destring Rutadeimplementacióna3009, replace

replace Rutadeimplementacióna3110 = "1" if Rutadeimplementacióna3110 == "Con ruta de implementación"
replace Rutadeimplementacióna3110 = "0" if Rutadeimplementacióna3110 == "Sin ruta de implementación"
destring Rutadeimplementacióna3110, replace

replace Rutadeimplementacióna3011 = "1" if Rutadeimplementacióna3011 == "Con ruta de implementación "
replace Rutadeimplementacióna3011 = "0" if Rutadeimplementacióna3011 == "Sin ruta de implementación"
destring Rutadeimplementacióna3011, replace

replace Rutadeimplementacióna2212 = "1" if Rutadeimplementacióna2212 == "Con ruta de implementación "
replace Rutadeimplementacióna2212 = "0" if Rutadeimplementacióna2212 == "Sin ruta de implementación"
destring Rutadeimplementacióna2212, replace

replace Rutadeimplementacióna3112 = "1" if Rutadeimplementacióna3112 == "Con ruta de implementación "
replace Rutadeimplementacióna3112 = "0" if Rutadeimplementacióna3112 == "Sin ruta de implementación"
destring Rutadeimplementacióna3112, replace

replace Rutadeimplementacióna3101 = "1" if Rutadeimplementacióna3101 == "Con ruta de implementación "
replace Rutadeimplementacióna3101 = "0" if Rutadeimplementacióna3101 == "Sin ruta de implementación"
destring Rutadeimplementacióna3101, replace

replace Rutadeimplementacióna2802 = "1" if Rutadeimplementacióna2802 == "Con ruta de implementación "
replace Rutadeimplementacióna2802 = "0" if Rutadeimplementacióna2802 == "Sin ruta de implementación"
destring Rutadeimplementacióna2802, replace

replace Rutadeimplementacióna3103 = "1" if Rutadeimplementacióna3103 == "Con ruta de implementación "
replace Rutadeimplementacióna3103 = "0" if Rutadeimplementacióna3103 == "Sin ruta de implementación"
destring Rutadeimplementacióna3103, replace

replace Rutadeimplementacióna3004 = "1" if Rutadeimplementacióna3004 == "Con ruta de implementación "
replace Rutadeimplementacióna3004 = "0" if Rutadeimplementacióna3004 == "Sin ruta de implementación"
destring Rutadeimplementacióna3004, replace

replace Rutadeimplementacióna3105 = "1" if Rutadeimplementacióna3105 == "Con ruta de implementación "
replace Rutadeimplementacióna3105 = "0" if Rutadeimplementacióna3105 == "Sin ruta de implementación"
destring Rutadeimplementacióna3105, replace

replace Rutadeimplementacióna3006 = "1" if Rutadeimplementacióna3006 == "Con ruta de implementación "
replace Rutadeimplementacióna3006 = "0" if Rutadeimplementacióna3006 == "Sin ruta de implementación"
destring Rutadeimplementacióna3006, replace

egen x=total(Rutadeimplementacióna2202), by (Departamento)
gen ruta_implementacion_22_02_2022= x/contador
drop x Rutadeimplementacióna2202

egen x=total(Rutadeimplementacióna0903), by (Departamento)
gen ruta_implementacion_09_03_2022= x/contador
drop x Rutadeimplementacióna0903

egen x=total(Rutadeimplementacióna0704), by (Departamento)
gen ruta_implementacion_07_04_2022= x/contador
drop x Rutadeimplementacióna0704

egen x=total(Rutadeimplementacióna0505), by (Departamento)
gen ruta_implementacion_05_05_2022= x/contador
drop x Rutadeimplementacióna0505

egen x=total(Rutadeimplementacióna0706), by (Departamento)
gen ruta_implementacion_07_06_2022= x/contador
drop x Rutadeimplementacióna0706

egen x=total(Rutadeimplementacióna0807), by (Departamento)
gen ruta_implementacion_08_07_2022= x/contador
drop x Rutadeimplementacióna0807

egen x=total(Rutadeimplementacióna3107), by (Departamento)
gen ruta_implementacion_31_07_2022= x/contador
drop x Rutadeimplementacióna3107

egen x=total(Rutadeimplementacióna3108), by (Departamento)
gen ruta_implementacion_31_08_2022= x/contador
drop x Rutadeimplementacióna3108

egen x=total(Rutadeimplementacióna3009), by (Departamento)
gen ruta_implementacion_30_09_2022= x/contador
drop x Rutadeimplementacióna3009

egen x=total(Rutadeimplementacióna3110), by (Departamento)
gen ruta_implementacion_31_10_2022= x/contador
drop x Rutadeimplementacióna3110

egen x=total(Rutadeimplementacióna3011), by (Departamento)
gen ruta_implementacion_30_11_2022= x/contador
drop x Rutadeimplementacióna3011

egen x=total(Rutadeimplementacióna2212), by (Departamento)
gen ruta_implementacion_22_12_2022= x/contador
drop x Rutadeimplementacióna2212

egen x=total(Rutadeimplementacióna3112), by (Departamento)
gen ruta_implementacion_31_12_2022= x/contador
drop x Rutadeimplementacióna3112

egen x=total(Rutadeimplementacióna3101), by (Departamento)
gen ruta_implementacion_31_01_2023= x/contador
drop x Rutadeimplementacióna3101

egen x=total(Rutadeimplementacióna2802), by (Departamento)
gen ruta_implementacion_28_02_2023= x/contador
drop x Rutadeimplementacióna2802

egen x=total(Rutadeimplementacióna3103), by (Departamento)
gen ruta_implementacion_31_03_2023= x/contador
drop x Rutadeimplementacióna3103

egen x=total(Rutadeimplementacióna3004), by (Departamento)
gen ruta_implementacion_30_04_2023= x/contador
drop x Rutadeimplementacióna3004

egen x=total(Rutadeimplementacióna3105), by (Departamento)
gen ruta_implementacion_31_05_2023= x/contador
drop x Rutadeimplementacióna3105

egen x=total(Rutadeimplementacióna3006), by (Departamento)
gen ruta_implementacion_30_06_2023= x/contador
drop x Rutadeimplementacióna3006

//creamos variables que cuenten proyectos sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (Departamento)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (Departamento)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (Departamento)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto Entidades_Financiadoras Fuente_de_Recursos

//creamos variable de cantidad de proyectos por Departamento//
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Distribucion_de_Proyectos= contador/x
drop x
format Distribucion_de_Proyectos %9.3f
order Distribucion_de_Proyectos, after (Departamento)

//creamos variable de porcentaje de dinero destinado a departmaneto//
egen x = total(valor_total)
gen Distribucion_de_Recursos= valor_total/x
drop x
format Distribucion_de_Recursos %9.3f
order Distribucion_de_Recursos, after (Distribucion_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (Departamento)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PDET_Departamentos.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_Departamentos.xlsx", nolabel replace firstrow(variables)







///////Tabla Subregion///////
cls
clear all
use "PDET_Base.dta"

order subregion

drop Departamento Municipio titulo_iniciativa codigo descripcion_iniciativa despripcion_iniciativa IDProyectoGestión ProductoART CategoriaART EstrategiaART Nombre_Proyecto Tipo_Proyecto //borramos variables que no nos interesan

egen contador= count(subregion), by (subregion) //creamos variable que cuenta las veces que un subregion aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(subregion) if Estado_Proyecto=="TERMINADO", by (subregion) 
egen x = mean(proyectos_terminados), by (subregion)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (subregion) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

drop if missing(subregion) //borramos observaciones que no tienen subregion

//creamos variable de valor total y valor promedio de proyecto para cada Departamento//
egen valor_total = total(Inversion_proyecto), by (subregion)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (subregion)
egen x = mean(valor_total_Terminado), by (subregion)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (subregion)
egen x = mean(valor_promedio_Terminado), by (subregion)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (subregion)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (subregion)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (subregion)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (subregion)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (subregion)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (subregion)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (subregion)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (subregion)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (subregion)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (subregion)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (subregion)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (subregion)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (subregion)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (subregion)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (subregion)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (subregion)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar

//creamos variables de clasificacion (gestion/proyecto/contrato)//
egen x= total(clasificacion=="Proyecto"), by (subregion)
gen Proyecto=x/contador
drop x
format Proyecto %9.2f

egen x= total(clasificacion=="Gestión"), by (subregion)
gen Gestion=x/contador
drop x
format Gestion %9.2f

egen x= total(clasificacion=="contrato"), by (subregion)
gen Contrato=x/contador
drop x
format Contrato %9.2f

drop clasificacion

//creamos variables de componentes PAI//
egen x= total(Programadeguarderíasinfantile), by (subregion)
gen Guarderia_Infantil_Rural=x/contador
format Guarderia_Infantil_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programadeguarderíasinfantile==1
egen z = total(y), by (subregion)
gen Infantil_Rural_Terminado= z/x
replace Infantil_Rural_Terminado=0 if Infantil_Rural_Terminado==.
drop x y z Programadeguarderíasinfantile

egen x= total(Construcciónydotacióndecomed), by (subregion)
gen Comedores_Escolares_Suministros=x/contador
format Comedores_Escolares_Suministros %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Construcciónydotacióndecomed==1
egen z = total(y), by (subregion)
gen Escolares_Suministros_Terminado= z/x
replace Escolares_Suministros_Terminado=0 if Escolares_Suministros_Terminado==.
drop x y z Construcciónydotacióndecomed

egen x= total(Mecanismosdeinformaciónparaf), by (subregion)
gen Informacion_Acceso_Laboral=x/contador
format Informacion_Acceso_Laboral %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Mecanismosdeinformaciónparaf==1
egen z = total(y), by (subregion)
gen Informacion_Laboral_Terminado= z/x
replace Informacion_Laboral_Terminado=0 if Informacion_Laboral_Terminado==.
drop x y z Mecanismosdeinformaciónparaf

egen x= total(Programascontraelhambrepara), by (subregion)
gen Hambre_Tercera_Edad=x/contador
format Hambre_Tercera_Edad %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programascontraelhambrepara==1
egen z = total(y), by (subregion)
gen Hambre_Terminado= z/x
replace Hambre_Terminado=0 if Hambre_Terminado==.
drop x y z Programascontraelhambrepara

egen x= total(Programasdesuperacióndelapo), by (subregion)
gen Superacion_Pobreza=x/contador
format Superacion_Pobreza %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programasdesuperacióndelapo==1
egen z = total(y), by (subregion)
gen Superacion_Pobreza_Terminado= z/x
replace Superacion_Pobreza_Terminado=0 if Superacion_Pobreza_Terminado==.
drop x y z Programasdesuperacióndelapo

egen x= total(Brigadasdeatenciónbásicaens), by (subregion)
gen Atencion_Basica_Salud=x/contador
format Atencion_Basica_Salud %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Brigadasdeatenciónbásicaens==1
egen z = total(y), by (subregion)
gen Atencion_Salud_Salud= z/x
replace Atencion_Salud_Salud=0 if Atencion_Salud_Salud==.
drop x y z Brigadasdeatenciónbásicaens

//creamos variables de estado del proyecto//
rename Estado_Proyecto estado_proyecto
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

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (subregion)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de ruta de implementacion//
replace Rutadeimplementacióna2202 = "1" if Rutadeimplementacióna2202 == "Con ruta de implementación "
replace Rutadeimplementacióna2202 = "0" if Rutadeimplementacióna2202 == "Sin ruta de implementación "
destring Rutadeimplementacióna2202, replace

replace Rutadeimplementacióna0903 = "1" if Rutadeimplementacióna0903 == "Con ruta de implementación "
replace Rutadeimplementacióna0903 = "0" if Rutadeimplementacióna0903 == "Sin ruta de implementación "
destring Rutadeimplementacióna0903, replace

replace Rutadeimplementacióna0704 = "1" if Rutadeimplementacióna0704 == "Con ruta de implementación "
replace Rutadeimplementacióna0704 = "0" if Rutadeimplementacióna0704 == "Sin ruta de implementación "
destring Rutadeimplementacióna0704, replace

replace Rutadeimplementacióna0505 = "1" if Rutadeimplementacióna0505 == "Con ruta de implementación "
replace Rutadeimplementacióna0505 = "0" if Rutadeimplementacióna0505 == "Sin ruta de implementación "
destring Rutadeimplementacióna0505, replace

replace Rutadeimplementacióna0706 = "1" if Rutadeimplementacióna0706 == "Con ruta de implementación "
replace Rutadeimplementacióna0706 = "0" if Rutadeimplementacióna0706 == "Sin ruta de implementación"
destring Rutadeimplementacióna0706, replace

replace Rutadeimplementacióna0807 = "1" if Rutadeimplementacióna0807 == "Con ruta de implementación "
replace Rutadeimplementacióna0807 = "0" if Rutadeimplementacióna0807 == "Sin ruta de implementación"
destring Rutadeimplementacióna0807, replace

replace Rutadeimplementacióna3107 = "1" if Rutadeimplementacióna3107 == "Con ruta de implementación "
replace Rutadeimplementacióna3107 = "0" if Rutadeimplementacióna3107 == "Sin ruta de implementación"
destring Rutadeimplementacióna3107, replace

replace Rutadeimplementacióna3108 = "1" if Rutadeimplementacióna3108 == "Con ruta de implementación"
replace Rutadeimplementacióna3108 = "0" if Rutadeimplementacióna3108 == "Sin ruta de implementación"
destring Rutadeimplementacióna3108, replace

replace Rutadeimplementacióna3009 = "1" if Rutadeimplementacióna3009 == "Con ruta de implementación"
replace Rutadeimplementacióna3009 = "0" if Rutadeimplementacióna3009 == "Sin ruta de implementación"
destring Rutadeimplementacióna3009, replace

replace Rutadeimplementacióna3110 = "1" if Rutadeimplementacióna3110 == "Con ruta de implementación"
replace Rutadeimplementacióna3110 = "0" if Rutadeimplementacióna3110 == "Sin ruta de implementación"
destring Rutadeimplementacióna3110, replace

replace Rutadeimplementacióna3011 = "1" if Rutadeimplementacióna3011 == "Con ruta de implementación "
replace Rutadeimplementacióna3011 = "0" if Rutadeimplementacióna3011 == "Sin ruta de implementación"
destring Rutadeimplementacióna3011, replace

replace Rutadeimplementacióna2212 = "1" if Rutadeimplementacióna2212 == "Con ruta de implementación "
replace Rutadeimplementacióna2212 = "0" if Rutadeimplementacióna2212 == "Sin ruta de implementación"
destring Rutadeimplementacióna2212, replace

replace Rutadeimplementacióna3112 = "1" if Rutadeimplementacióna3112 == "Con ruta de implementación "
replace Rutadeimplementacióna3112 = "0" if Rutadeimplementacióna3112 == "Sin ruta de implementación"
destring Rutadeimplementacióna3112, replace

replace Rutadeimplementacióna3101 = "1" if Rutadeimplementacióna3101 == "Con ruta de implementación "
replace Rutadeimplementacióna3101 = "0" if Rutadeimplementacióna3101 == "Sin ruta de implementación"
destring Rutadeimplementacióna3101, replace

replace Rutadeimplementacióna2802 = "1" if Rutadeimplementacióna2802 == "Con ruta de implementación "
replace Rutadeimplementacióna2802 = "0" if Rutadeimplementacióna2802 == "Sin ruta de implementación"
destring Rutadeimplementacióna2802, replace

replace Rutadeimplementacióna3103 = "1" if Rutadeimplementacióna3103 == "Con ruta de implementación "
replace Rutadeimplementacióna3103 = "0" if Rutadeimplementacióna3103 == "Sin ruta de implementación"
destring Rutadeimplementacióna3103, replace

replace Rutadeimplementacióna3004 = "1" if Rutadeimplementacióna3004 == "Con ruta de implementación "
replace Rutadeimplementacióna3004 = "0" if Rutadeimplementacióna3004 == "Sin ruta de implementación"
destring Rutadeimplementacióna3004, replace

replace Rutadeimplementacióna3105 = "1" if Rutadeimplementacióna3105 == "Con ruta de implementación "
replace Rutadeimplementacióna3105 = "0" if Rutadeimplementacióna3105 == "Sin ruta de implementación"
destring Rutadeimplementacióna3105, replace

replace Rutadeimplementacióna3006 = "1" if Rutadeimplementacióna3006 == "Con ruta de implementación "
replace Rutadeimplementacióna3006 = "0" if Rutadeimplementacióna3006 == "Sin ruta de implementación"
destring Rutadeimplementacióna3006, replace

egen x=total(Rutadeimplementacióna2202), by (subregion)
gen ruta_implementacion_22_02_2022= x/contador
drop x Rutadeimplementacióna2202

egen x=total(Rutadeimplementacióna0903), by (subregion)
gen ruta_implementacion_09_03_2022= x/contador
drop x Rutadeimplementacióna0903

egen x=total(Rutadeimplementacióna0704), by (subregion)
gen ruta_implementacion_07_04_2022= x/contador
drop x Rutadeimplementacióna0704

egen x=total(Rutadeimplementacióna0505), by (subregion)
gen ruta_implementacion_05_05_2022= x/contador
drop x Rutadeimplementacióna0505

egen x=total(Rutadeimplementacióna0706), by (subregion)
gen ruta_implementacion_07_06_2022= x/contador
drop x Rutadeimplementacióna0706

egen x=total(Rutadeimplementacióna0807), by (subregion)
gen ruta_implementacion_08_07_2022= x/contador
drop x Rutadeimplementacióna0807

egen x=total(Rutadeimplementacióna3107), by (subregion)
gen ruta_implementacion_31_07_2022= x/contador
drop x Rutadeimplementacióna3107

egen x=total(Rutadeimplementacióna3108), by (subregion)
gen ruta_implementacion_31_08_2022= x/contador
drop x Rutadeimplementacióna3108

egen x=total(Rutadeimplementacióna3009), by (subregion)
gen ruta_implementacion_30_09_2022= x/contador
drop x Rutadeimplementacióna3009

egen x=total(Rutadeimplementacióna3110), by (subregion)
gen ruta_implementacion_31_10_2022= x/contador
drop x Rutadeimplementacióna3110

egen x=total(Rutadeimplementacióna3011), by (subregion)
gen ruta_implementacion_30_11_2022= x/contador
drop x Rutadeimplementacióna3011

egen x=total(Rutadeimplementacióna2212), by (subregion)
gen ruta_implementacion_22_12_2022= x/contador
drop x Rutadeimplementacióna2212

egen x=total(Rutadeimplementacióna3112), by (subregion)
gen ruta_implementacion_31_12_2022= x/contador
drop x Rutadeimplementacióna3112

egen x=total(Rutadeimplementacióna3101), by (subregion)
gen ruta_implementacion_31_01_2023= x/contador
drop x Rutadeimplementacióna3101

egen x=total(Rutadeimplementacióna2802), by (subregion)
gen ruta_implementacion_28_02_2023= x/contador
drop x Rutadeimplementacióna2802

egen x=total(Rutadeimplementacióna3103), by (subregion)
gen ruta_implementacion_31_03_2023= x/contador
drop x Rutadeimplementacióna3103

egen x=total(Rutadeimplementacióna3004), by (subregion)
gen ruta_implementacion_30_04_2023= x/contador
drop x Rutadeimplementacióna3004

egen x=total(Rutadeimplementacióna3105), by (subregion)
gen ruta_implementacion_31_05_2023= x/contador
drop x Rutadeimplementacióna3105

egen x=total(Rutadeimplementacióna3006), by (subregion)
gen ruta_implementacion_30_06_2023= x/contador
drop x Rutadeimplementacióna3006

//creamos variables que cuenten proyectos sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (subregion)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (subregion)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (subregion)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto Entidades_Financiadoras Fuente_de_Recursos

//creamos variable de cantidad de proyectos por subregion//
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Distribucion_de_Proyectos= contador/x
drop x
format Distribucion_de_Proyectos %9.3f
order Distribucion_de_Proyectos, after (subregion)

//creamos variable de porcentaje de dinero destinado a subregion//
egen x = total(valor_total)
gen Distribucion_de_Recursos= valor_total/x
drop x
format Distribucion_de_Recursos %9.3f
order Distribucion_de_Recursos, after (Distribucion_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (subregion)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PDET_Subregion.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_Subregion.xlsx", nolabel replace firstrow(variables)







///////Tabla Pilar///////
clear all
cls

use "PDET_Base.dta"

drop Departamento Municipio codigo titulo_iniciativa descripcion_iniciativa ProductoART CategoriaART EstrategiaART Rutadeimplementacióna2202 Rutadeimplementacióna0903 Rutadeimplementacióna0704 Rutadeimplementacióna0505 Rutadeimplementacióna0706 Rutadeimplementacióna0807 Rutadeimplementacióna3107 Rutadeimplementacióna3108 Rutadeimplementacióna3009 Rutadeimplementacióna3110 Rutadeimplementacióna3011 Rutadeimplementacióna2212 Rutadeimplementacióna3112 Rutadeimplementacióna3101 Rutadeimplementacióna2802 Rutadeimplementacióna3103 Rutadeimplementacióna3004 Rutadeimplementacióna3105 Rutadeimplementacióna3006 despripcion_iniciativa IDProyectoGestión Nombre_Proyecto Tipo_Proyecto clasificacion //quitamos variables que no nos interesan

order pilar //ponemos de primero a los pilares

egen contador= count(pilar), by (pilar) //creamos variable que cuenta las veces que un pilar aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(pilar) if Estado_Proyecto=="TERMINADO", by (pilar) 
egen x = mean(proyectos_terminados), by (pilar)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (pilar) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

//creamos variable de valor total y valor promedio de proyecto para cada pilar//
egen valor_total = total(Inversion_proyecto), by (pilar)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (pilar)
egen x = mean(valor_total_Terminado), by (pilar)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (pilar)
egen x = mean(valor_promedio_Terminado), by (pilar)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de estado del proyecto//
egen x= total(Estado_Proyecto=="EN EJECUCIÓN"), by (pilar)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(Estado_Proyecto=="EN ESTRUCTURACIÓN"), by (pilar)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO"), by (pilar)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO Y FINANCIADO"), by (pilar)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(Estado_Proyecto=="TERMINADO"), by (pilar)
gen Terminado=x/contador
drop x
format Terminado %9.2f

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (pilar)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de componentes PAI//
egen x= total(Programadeguarderíasinfantile), by (pilar)
gen Guarderia_Infantil_Rural=x/contador
format Guarderia_Infantil_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programadeguarderíasinfantile==1
egen z = total(y), by (pilar)
gen Infantil_Rural_Terminado= z/x
replace Infantil_Rural_Terminado=0 if Infantil_Rural_Terminado==.
drop x y z Programadeguarderíasinfantile

egen x= total(Construcciónydotacióndecomed), by (pilar)
gen Comedores_Escolares_Suministros=x/contador
format Comedores_Escolares_Suministros %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Construcciónydotacióndecomed==1
egen z = total(y), by (pilar)
gen Escolares_Suministros_Terminado= z/x
replace Escolares_Suministros_Terminado=0 if Escolares_Suministros_Terminado==.
drop x y z Construcciónydotacióndecomed

egen x= total(Mecanismosdeinformaciónparaf), by (pilar)
gen Informacion_Acceso_Laboral=x/contador
format Informacion_Acceso_Laboral %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Mecanismosdeinformaciónparaf==1
egen z = total(y), by (pilar)
gen Informacion_Laboral_Terminado= z/x
replace Informacion_Laboral_Terminado=0 if Informacion_Laboral_Terminado==.
drop x y z Mecanismosdeinformaciónparaf

egen x= total(Programascontraelhambrepara), by (pilar)
gen Hambre_Tercera_Edad=x/contador
format Hambre_Tercera_Edad %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programascontraelhambrepara==1
egen z = total(y), by (pilar)
gen Hambre_Terminado= z/x
replace Hambre_Terminado=0 if Hambre_Terminado==.
drop x y z Programascontraelhambrepara

egen x= total(Programasdesuperacióndelapo), by (pilar)
gen Superacion_Pobreza=x/contador
format Superacion_Pobreza %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programasdesuperacióndelapo==1
egen z = total(y), by (pilar)
gen Superacion_Pobreza_Terminado= z/x
replace Superacion_Pobreza_Terminado=0 if Superacion_Pobreza_Terminado==.
drop x y z Programasdesuperacióndelapo

egen x= total(Brigadasdeatenciónbásicaens), by (pilar)
gen Atencion_Basica_Salud=x/contador
format Atencion_Basica_Salud %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Brigadasdeatenciónbásicaens==1
egen z = total(y), by (pilar)
gen Atencion_Salud_Salud= z/x
replace Atencion_Salud_Salud=0 if Atencion_Salud_Salud==.
drop x y z Brigadasdeatenciónbásicaens Estado_Proyecto


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

//creamos variables que cuenten proyectos sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (pilar)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (pilar)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (pilar)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto Entidades_Financiadoras Fuente_de_Recursos

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

save "/Users/lucasrodriguez/PISDA/PDET_Pilar.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_Pilar.xlsx", nolabel replace firstrow(variables)






///////Financiamiento///////
cls
clear all

use "PDET_Base.dta"

drop Departamento Municipio codigo titulo_iniciativa descripcion_iniciativa ProductoART CategoriaART EstrategiaART Rutadeimplementacióna2202 Rutadeimplementacióna0903 Rutadeimplementacióna0704 Rutadeimplementacióna0505 Rutadeimplementacióna0706 Rutadeimplementacióna0807 Rutadeimplementacióna3107 Rutadeimplementacióna3108 Rutadeimplementacióna3009 Rutadeimplementacióna3110 Rutadeimplementacióna3011 Rutadeimplementacióna2212 Rutadeimplementacióna3112 Rutadeimplementacióna3101 Rutadeimplementacióna2802 Rutadeimplementacióna3103 Rutadeimplementacióna3004 Rutadeimplementacióna3105 Rutadeimplementacióna3006 despripcion_iniciativa IDProyectoGestión Nombre_Proyecto clasificacion  

order Tipo_Proyecto //ponemos de primero a los pilares

egen contador= count(Tipo_Proyecto), by (Tipo_Proyecto) //creamos variable que cuenta las veces que un tipo de proyecto aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(Tipo_Proyecto) if Estado_Proyecto=="TERMINADO", by (Tipo_Proyecto) 
egen x = mean(proyectos_terminados), by (Tipo_Proyecto)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (Tipo_Proyecto) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

//creamos variable de valor total y valor promedio de proyecto para cada tipo de proyecto//
egen valor_total = total(Inversion_proyecto), by (Tipo_Proyecto)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (Tipo_Proyecto)
egen x = mean(valor_total_Terminado), by (Tipo_Proyecto)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (Tipo_Proyecto)
egen x = mean(valor_promedio_Terminado), by (Tipo_Proyecto)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de estado del proyecto//
egen x= total(Estado_Proyecto=="EN EJECUCIÓN"), by (Tipo_Proyecto)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(Estado_Proyecto=="EN ESTRUCTURACIÓN"), by (Tipo_Proyecto)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO"), by (Tipo_Proyecto)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO Y FINANCIADO"), by (Tipo_Proyecto)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(Estado_Proyecto=="TERMINADO"), by (Tipo_Proyecto)
gen Terminado=x/contador
drop x
format Terminado %9.2f

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (Tipo_Proyecto)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de componentes PAI//
egen x= total(Programadeguarderíasinfantile), by (Tipo_Proyecto)
gen Guarderia_Infantil_Rural=x/contador
format Guarderia_Infantil_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programadeguarderíasinfantile==1
egen z = total(y), by (Tipo_Proyecto)
gen Infantil_Rural_Terminado= z/x
replace Infantil_Rural_Terminado=0 if Infantil_Rural_Terminado==.
drop x y z Programadeguarderíasinfantile

egen x= total(Construcciónydotacióndecomed), by (Tipo_Proyecto)
gen Comedores_Escolares_Suministros=x/contador
format Comedores_Escolares_Suministros %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Construcciónydotacióndecomed==1
egen z = total(y), by (Tipo_Proyecto)
gen Escolares_Suministros_Terminado= z/x
replace Escolares_Suministros_Terminado=0 if Escolares_Suministros_Terminado==.
drop x y z Construcciónydotacióndecomed

egen x= total(Mecanismosdeinformaciónparaf), by (Tipo_Proyecto)
gen Informacion_Acceso_Laboral=x/contador
format Informacion_Acceso_Laboral %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Mecanismosdeinformaciónparaf==1
egen z = total(y), by (Tipo_Proyecto)
gen Informacion_Laboral_Terminado= z/x
replace Informacion_Laboral_Terminado=0 if Informacion_Laboral_Terminado==.
drop x y z Mecanismosdeinformaciónparaf

egen x= total(Programascontraelhambrepara), by (Tipo_Proyecto)
gen Hambre_Tercera_Edad=x/contador
format Hambre_Tercera_Edad %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programascontraelhambrepara==1
egen z = total(y), by (Tipo_Proyecto)
gen Hambre_Terminado= z/x
replace Hambre_Terminado=0 if Hambre_Terminado==.
drop x y z Programascontraelhambrepara

egen x= total(Programasdesuperacióndelapo), by (Tipo_Proyecto)
gen Superacion_Pobreza=x/contador
format Superacion_Pobreza %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Programasdesuperacióndelapo==1
egen z = total(y), by (Tipo_Proyecto)
gen Superacion_Pobreza_Terminado= z/x
replace Superacion_Pobreza_Terminado=0 if Superacion_Pobreza_Terminado==.
drop x y z Programasdesuperacióndelapo

egen x= total(Brigadasdeatenciónbásicaens), by (Tipo_Proyecto)
gen Atencion_Basica_Salud=x/contador
format Atencion_Basica_Salud %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & Brigadasdeatenciónbásicaens==1
egen z = total(y), by (Tipo_Proyecto)
gen Atencion_Salud_Salud= z/x
replace Atencion_Salud_Salud=0 if Atencion_Salud_Salud==.
drop x y z Brigadasdeatenciónbásicaens


//creamos variables de subregion//
egen x= total(subregion=="ALTO PATÍA Y NORTE DEL CAUCA"), by (Tipo_Proyecto)
gen Alto_Patia_Norte_Cauca=x/contador
drop x
format Alto_Patia_Norte_Cauca %9.2f

egen x= total(subregion=="ARAUCA"), by (Tipo_Proyecto)
gen Arauca=x/contador
drop x
format Arauca %9.2f

egen x= total(subregion=="CATATUMBO"), by (Tipo_Proyecto)
gen Catatumbo=x/contador
drop x
format Catatumbo %9.2f

egen x= total(subregion=="BAJO CAUCA Y NORDESTE ANTIOQUEÑO"), by (Tipo_Proyecto)
gen Bajo_Cauca=x/contador
drop x
format Bajo_Cauca %9.2f

egen x= total(subregion=="CUENCA DEL CAGUÁN Y PIEDEMONTE CAQUETEÑO"), by (Tipo_Proyecto)
gen Caguan=x/contador
drop x
format Caguan %9.2f

egen x= total(subregion=="MACARENA - GUAVIARE"), by (Tipo_Proyecto)
gen Macarena=x/contador
drop x
format Macarena %9.2f

egen x= total(subregion=="PACÍFICO Y FRONTERA NARIÑENSE"), by (Tipo_Proyecto)
gen Pacifico=x/contador
drop x
format Pacifico %9.2f

egen x= total(subregion=="PUTUMAYO"), by (Tipo_Proyecto)
gen Putumayo=x/contador
drop x
format Putumayo %9.2f

egen x= total(subregion=="SUR DE BOLÍVAR"), by (Tipo_Proyecto)
gen Sur_Bolivar=x/contador
drop x
format Sur_Bolivar %9.2f

egen x= total(subregion=="SUR DE CÓRDOBA"), by (Tipo_Proyecto)
gen Sur_Cordoba=x/contador
drop x
format Sur_Cordoba %9.2f

drop subregion

//creamos variables de pilar//
egen x= total(pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"), by (Tipo_Proyecto)
gen Construccion_de_Paz=x/contador
format Construccion_de_Paz %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="RECONCILIACIÓN, CONVIVENCIA Y CONSTRUCCIÓN DE PAZ"
egen z = total(y), by (Tipo_Proyecto)
gen Construccion_de_Paz_Terminado= z/x
replace Construccion_de_Paz_Terminado=0 if Construccion_de_Paz_Terminado==.
drop x y z

egen x= total(pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"), by (Tipo_Proyecto)
gen Educacion_Rural=x/contador
format Educacion_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="EDUCACIÓN RURAL Y PRIMERA INFANCIA RURAL"
egen z = total(y), by (Tipo_Proyecto)
gen Educacion_Rural_Terminado= z/x
replace Educacion_Rural_Terminado=0 if Educacion_Rural_Terminado==.
drop x y z

egen x= total(pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"), by (Tipo_Proyecto)
gen Infraestructura=x/contador
format Infraestructura %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="INFRAESTRUCTURA Y ADECUACIÓN DE TIERRAS"
egen z = total(y), by (Tipo_Proyecto)
gen Infraestructura_Terminado= z/x
replace Infraestructura_Terminado=0 if Infraestructura_Terminado==.
drop x y z

egen x= total(pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"), by (Tipo_Proyecto)
gen Ordenamiento_de_Propiedad_Rural=x/contador
format Ordenamiento_de_Propiedad_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="ORDENAMIENTO SOCIAL DE LA PROPIEDAD RURAL Y USO DEL SUELO"
egen z = total(y), by (Tipo_Proyecto)
gen Propiedad_Rural_Terminado= z/x
replace Propiedad_Rural_Terminado=0 if Propiedad_Rural_Terminado==.
drop x y z

egen x= total(pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"), by (Tipo_Proyecto)
gen Produccion_Agropecuaria=x/contador
format Produccion_Agropecuaria %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="REACTIVACIÓN ECONÓMICA Y PRODUCCIÓN AGROPECUARIA"
egen z = total(y), by (Tipo_Proyecto)
gen Agropecuaria_Terminado= z/x
replace Agropecuaria_Terminado=0 if Agropecuaria_Terminado==.
drop x y z

egen x= total(pilar=="SALUD RURAL"), by (Tipo_Proyecto)
gen Salud_Rural=x/contador
format Salud_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SALUD RURAL"
egen z = total(y), by (Tipo_Proyecto)
gen Salud_Rural_Terminado= z/x
replace Salud_Rural_Terminado=0 if Salud_Rural_Terminado==.
drop x y z

egen x= total(pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"), by (Tipo_Proyecto)
gen Alimentacion=x/contador
format Alimentacion %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="SISTEMA PARA LA GARANTÍA PROGRESIVA DEL DERECHO A LA ALIMENTACIÓN"
egen z = total(y), by (Tipo_Proyecto)
gen Alimentacion_Terminado= z/x
replace Alimentacion_Terminado=0 if Alimentacion_Terminado==.
drop x y z

egen x= total(pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"), by (Tipo_Proyecto)
gen Vivienda_Rural=x/contador
format Vivienda_Rural %9.2f

gen y = 1 if Estado_Proyecto=="TERMINADO" & pilar=="VIVIENDA RURAL, AGUA POTABLE Y SANEAMIENTO BÁSICO RURAL"
egen z = total(y), by (Tipo_Proyecto)
gen Vivienda_Rural_Terminado= z/x
replace Vivienda_Rural_Terminado=0 if Vivienda_Rural_Terminado==.
drop x y z

drop pilar Estado_Proyecto

//creamos variables que cuenten tipos de proyecto sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (Tipo_Proyecto)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (Tipo_Proyecto)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (Tipo_Proyecto)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto

//creamos variable de cantidad de proyectos por fuente//
drop if missing(Tipo_Proyecto)
drop Fuente_de_Recursos Entidades_Financiadoras
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (Tipo_Proyecto)

//creamos variable de porcentaje de dinero aportado por fuente//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
drop contador_recursos
order contador, after (Tipo_Proyecto)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PDET_Financiamiento.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_Financiamiento.xlsx", nolabel replace firstrow(variables)


///////Tabla Componente PAI///////
clear all
cls

use "PDET_Base.dta"

drop Departamento Municipio codigo titulo_iniciativa descripcion_iniciativa ProductoART CategoriaART EstrategiaART Rutadeimplementacióna2202 Rutadeimplementacióna0903 Rutadeimplementacióna0704 Rutadeimplementacióna0505 Rutadeimplementacióna0706 Rutadeimplementacióna0807 Rutadeimplementacióna3107 Rutadeimplementacióna3108 Rutadeimplementacióna3009 Rutadeimplementacióna3110 Rutadeimplementacióna3011 Rutadeimplementacióna2212 Rutadeimplementacióna3112 Rutadeimplementacióna3101 Rutadeimplementacióna2802 Rutadeimplementacióna3103 Rutadeimplementacióna3004 Rutadeimplementacióna3105 Rutadeimplementacióna3006 despripcion_iniciativa IDProyectoGestión Nombre_Proyecto Tipo_Proyecto clasificacion //quitamos variables que no nos interesan

gen x=.
tostring x, generate(Componente_PAI)
replace Componente_PAI= "Guarderia_Infantil_Rural" if Programadeguarderíasinfantile==1
replace Componente_PAI= "Comedores_Escolares_Suministros" if Construcciónydotacióndecomed==1
replace Componente_PAI= "Informacion_Acceso_Laboral" if Mecanismosdeinformaciónparaf==1
replace Componente_PAI= "Hambre_Tercera_Edad" if Programascontraelhambrepara==1
replace Componente_PAI= "Superacion_Pobreza" if Programasdesuperacióndelapo==1
replace Componente_PAI= "Atencion_Basica_Salud" if Brigadasdeatenciónbásicaens==1

drop x Programadeguarderíasinfantile Construcciónydotacióndecomed Programascontraelhambrepara Programasdesuperacióndelapo Brigadasdeatenciónbásicaens Mecanismosdeinformaciónparaf

order Componente_PAI //ponemos de primero a los pilares

egen contador= count(Componente_PAI), by (Componente_PAI) //creamos variable que cuenta las veces que un pilar aparece

//creamos variable de proyectos terminados//
egen proyectos_terminados= count(Componente_PAI) if Estado_Proyecto=="TERMINADO", by (Componente_PAI) 
egen x = mean(proyectos_terminados), by (Componente_PAI)
replace proyectos_terminados = x if missing(proyectos_terminados)
replace proyectos_terminados = 0 if missing(proyectos_terminados)
drop x

gen contador2=1 if Inversion_proyecto > 0
egen contador_recursos=total (contador2), by (pilar) //creamos variable que cuente el numero de proyectos financiados por tipo de proyecto
drop contador2

//creamos variable de valor total y valor promedio de proyecto para cada pilar//
egen valor_total = total(Inversion_proyecto), by (Componente_PAI)
label var valor_total "Valor Total"

egen valor_total_Terminado = total(Inversion_proyecto) if Estado_Proyecto=="TERMINADO", by (Componente_PAI)
egen x = mean(valor_total_Terminado), by (Componente_PAI)
replace valor_total_Terminado = x if missing(valor_total_Terminado)
replace valor_total_Terminado = 0 if missing(valor_total_Terminado)
drop x

gen valor_promedio= valor_total/contador_recursos
label var valor_promedio "Valor Promedio"

egen valor_promedio_Terminado = mean(Inversion_proyecto) if Estado_Proyecto=="TERMINADO" & (Inversion_proyecto!=0 | Inversion_proyecto!=.), by (Componente_PAI)
egen x = mean(valor_promedio_Terminado), by (Componente_PAI)
replace valor_promedio_Terminado = x if missing(valor_promedio_Terminado)
replace valor_promedio_Terminado = 0 if missing(valor_promedio_Terminado)
drop x

//creamos variables de estado del proyecto//
egen x= total(Estado_Proyecto=="EN EJECUCIÓN"), by (Componente_PAI)
gen En_Ejecucion=x/contador
drop x
format En_Ejecucion %9.2f

egen x= total(Estado_Proyecto=="EN ESTRUCTURACIÓN"), by (Componente_PAI)
gen En_Estructuracion=x/contador
drop x
format En_Estructuracion %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO"), by (Componente_PAI)
gen Estructurado=x/contador
drop x
format Estructurado %9.2f

egen x= total(Estado_Proyecto=="ESTRUCTURADO Y FINANCIADO"), by (Componente_PAI)
gen Estructurado_y_Financiado=x/contador
drop x
format Estructurado_y_Financiado %9.2f

egen x= total(Estado_Proyecto=="TERMINADO"), by (Componente_PAI)
gen Terminado=x/contador
drop x
format Terminado %9.2f

//creamos variables de gestion a fecha de 26/06/2020 (gestionada/nogestionada)//
replace GestionadaNogestionadaa26 = "1" if GestionadaNogestionadaa26 == "GESTIONADA"
replace GestionadaNogestionadaa26 = "0" if GestionadaNogestionadaa26 == "NO GESTIONADA"
destring GestionadaNogestionadaa26, replace

egen x=total(GestionadaNogestionadaa26), by (Componente_PAI)
gen Gestionado= x/contador
drop x GestionadaNogestionadaa26

//creamos variables de subregion//
egen x= total(subregion=="ALTO PATÍA Y NORTE DEL CAUCA"), by (Componente_PAI)
gen Alto_Patia_Norte_Cauca=x/contador
drop x
format Alto_Patia_Norte_Cauca %9.2f

egen x= total(subregion=="ARAUCA"), by (Componente_PAI)
gen Arauca=x/contador
drop x
format Arauca %9.2f

egen x= total(subregion=="CATATUMBO"), by (Componente_PAI)
gen Catatumbo=x/contador
drop x
format Catatumbo %9.2f

egen x= total(subregion=="BAJO CAUCA Y NORDESTE ANTIOQUEÑO"), by (Componente_PAI)
gen Bajo_Cauca=x/contador
drop x
format Bajo_Cauca %9.2f

egen x= total(subregion=="CUENCA DEL CAGUÁN Y PIEDEMONTE CAQUETEÑO"), by (Componente_PAI)
gen Caguan=x/contador
drop x
format Caguan %9.2f

egen x= total(subregion=="MACARENA - GUAVIARE"), by (Componente_PAI)
gen Macarena=x/contador
drop x
format Macarena %9.2f

egen x= total(subregion=="PACÍFICO Y FRONTERA NARIÑENSE"), by (Componente_PAI)
gen Pacifico=x/contador
drop x
format Pacifico %9.2f

egen x= total(subregion=="PUTUMAYO"), by (Componente_PAI)
gen Putumayo=x/contador
drop x
format Putumayo %9.2f

egen x= total(subregion=="SUR DE BOLÍVAR"), by (Componente_PAI)
gen Sur_Bolivar=x/contador
drop x
format Sur_Bolivar %9.2f

egen x= total(subregion=="SUR DE CÓRDOBA"), by (Componente_PAI)
gen Sur_Cordoba=x/contador
drop x
format Sur_Cordoba %9.2f

drop subregion

//creamos variables que cuenten proyectos sin financiamiento//
gen x = 1 if Inversion_proyecto > 0 & Inversion_proyecto != .
egen y = total (x), by (Componente_PAI)
gen Proyectos_Financiados = y/contador
format Proyectos_Financiados %9.3f
drop x y 

gen x = 1 if Inversion_proyecto == 0
egen y = total(x), by (Componente_PAI)
gen Sin_Financiamiento = y/contador
format Sin_Financiamiento %9.3f
drop x y

gen x = 1 if Inversion_proyecto ==.
egen y = total(x), by (Componente_PAI)
gen Missing_Financiamiento = y/contador
format Missing_Financiamiento %9.3f
drop x y Inversion_proyecto Entidades_Financiadoras Fuente_de_Recursos

//creamos variable de cantidad de proyectos por pilar//
drop if missing(Componente_PAI)
drop if Componente_PAI=="."
duplicates report, list varlist
duplicates drop

egen x = total(contador)
gen Cantidad_de_Proyectos= contador/x
drop x
format Cantidad_de_Proyectos %9.3f
order Cantidad_de_Proyectos, after (Componente_PAI)

//creamos variable de porcentaje de dinero destinado a pilar//
egen x = total(valor_total)
gen Dinero_Destinado= valor_total/x
drop x
format Dinero_Destinado %9.3f
order Dinero_Destinado, after (Cantidad_de_Proyectos)

//ordenamos la base//
drop contador_recursos pilar Estado_Proyecto
order contador, after (Componente_PAI)
order proyectos_terminados, after (contador)
rename contador Numero_de_Proyectos

save "/Users/lucasrodriguez/PISDA/PDET_PAI.dta", replace
export excel using "/Users/lucasrodriguez/PISDA/PDET_Tabla_PAI.xlsx", nolabel replace firstrow(variables)
