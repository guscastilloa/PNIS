/*
DESCRIPCIÓN:
	En este script se prepara la base con la que se realizaron las estimaciones
	de los modelos de IPM para evaluar la heterogeneidad de los efectos al 
	segregar por género de los beneficiarios. 

*/

* Preámbulo luego de correr _main.do
tab sexo_titular, miss
*------------------------------------------------------------------------------
**# Preparar base y variables para la estimación de los modelos 
*------------------------------------------------------------------------------
* Llenar el sexo para el 2015
sort cub year
tab year sexo_titular, miss
bysort cub: ereplace sexo_titular=mean(sexo_titular)
tab year sexo_titular, miss

global switch_estimation_on 1 // Fijar a 1 para estimar modelos.

*------------------------------------------------------------------------------
**# Estimar modelos 1 a 7 especificación 4
*------------------------------------------------------------------------------
if ${switch_estimation_on}==1{
	do "${projectfolder}/Do/A4-Especificacion4.do"
}
*------------------------------------------------------------------------------
**# Estimar modelos 1 a 7 especificación 5
*------------------------------------------------------------------------------
if ${switch_estimation_on}==1{
	do "${projectfolder}/Do/A4-Especificacion5.do"
}

* End
