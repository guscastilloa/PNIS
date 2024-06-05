***** Arreglo de cédulas del SISPNIS para cruzar con miembros del hogar SISBEN *****

*** Objetivo: crear una base en csv con las cédulas de los titulares y de los beneficiarios del PNIS para solicitar el cruce con los otros miembros del hogar a através de la información del SISBEN

/// Importar base de vinculados del PNIS en CSV y dejar solo la información para beneficiarios ///
import delimited "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Datos/SISPNIS/Corte_PNIS.csv", clear

keep if documento_beneficiario != "" // Dejar unicamente a los beneficiarios

keep documento_beneficiario cub tipodoc_beneficiario primer_apellido_beneficiario primer_nombre_beneficiario segundo_apellido_beneficiario segundo_nombre_beneficiario
gen tipo_vinculado = 2 // Crear esta variable para identificar a los beneficiarios y para crear un id único para cada persona de la base 

rename (documento_beneficiario tipodoc_beneficiario primer_apellido_beneficiario primer_nombre_beneficiario segundo_apellido_beneficiario segundo_nombre_beneficiario) (documento tipodoc primer_apellido primer_nombre segundo_apellido segundo_nombre)
save "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Datos/SISPNIS/cub_beneficiarios.dta", replace 

/// Importar base general para hacer el pegue de las cédulas de los titulares y beneficiarios 

import delimited "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Datos/SISPNIS/Corte_PNIS.csv", clear

keep documento_titular cub tipodoc_titular primer_apellido_titular primer_nombre_titular segundo_apellido_titular segundo_nombre_titular fecha_nacimiento_titular

rename (documento_titular tipodoc_titular primer_apellido_titular primer_nombre_titular segundo_apellido_titular segundo_nombre_titular fecha_nacimiento_titular) (documento tipodoc primer_apellido primer_nombre segundo_apellido segundo_nombre fecha_nacimiento)
gen tipo_vinculado = 1

append using "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Datos/SISPNIS/cub_beneficiarios.dta" 

egen id = group(cub tipo_vinculado) // Generar un id único para cada individuo

duplicates tag id, gen(d) // Verificar que no hay duplicados en el id 
sum d
drop d 

export delimited using "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2023/Evaluación PNIS-DNP/Datos/SISPNIS/cbu_cedula_PNIS", replace

*** La base nueva tiene la cédula/contraseña para todas las personas en la base de vinculados del PNIS (titular o beneficario), el cub del hogar, una variable que muestra si es titular o beneficiario, y un id único para cada persona
