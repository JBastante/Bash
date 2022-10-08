#!/bin/bash

################################################################################
##  Ejercicio nro 2 del APL 1 - 2c 2022 - Entrega nro 1
##  Script: Ejercicio02.sh
##
##  Integrantes del grupo
##  Rodriguez,Cesar Daniel, 39166725
##  Bastante, Javier, 38621360
##  Garcia Velez, Kevin, 38619312
##  Morales ,Maximiliano, 38176604
##  Baranda Leonardo, 36875068
################################################################################

ayuda(){
	echo "------------------------------------------------------------------------"
	echo "Ayuda - Uso del Script Papelera"
    echo "Luego del nombre del Script debe colocar una de las siguientes opciones:"
	echo "--listar"
	echo "--recuperar nombreArchivo"
	echo "--vaciar"
	echo "--eliminar nombreArchivo"
	echo "--destruir nombreArchivo"
	echo "------------------------------------------------------------------------"
}

listar(){
	( [ $# -ne 0 ] ) && errorParametros

	if [ -f ~/papelera.zip ] #-f verifica que el archivo exista
	then
		CANTNR=$(zipinfo ~/papelera.zip |grep ^-|wc -l) #guardo en la variable la cantidad de elementos que hay en el zip
		if [ $CANTNR -gt 0 ] 
		then 
			IFS=$'\n'
			for archivo in $(zip -sf ~/papelera | awk "NR>1{print $1 $2}" | awk "NR<=$CANTNR{print $1 $2}" ) #no muestro la 1er y ult linea
			do
				rutaArchivo=$(dirname "$archivo")
				nombreArchivo=$(basename "$archivo")
				echo "$nombreArchivo $rutaArchivo"
			done
			exit 0
		else
			echo "Error, nada que listar, la papelera está vacía"
			exit 1
		fi
	else
		echo "Error, no existe la papelera"
		exit 1
	fi
}

recuperar(){
	( [ $# -ne 1 ] ) && errorParametros

	if [ ! -f ~/papelera.zip ] 	
	then
		echo "Error, no existe la papelera"
		exit 1
	fi

	Recuperar="$1"
	CANTNR=$(zipinfo ~/papelera.zip |grep ^-|wc -l) #guardo la cantidad de elementos que hay en el zip
	contadorArchivosIguales=0
	archivosIguales=""
	declare -a arrayArchivos
	archivo_a_recuperar=""

	IFS=$'\n'
	for archivo in $(zip -sf ~/papelera | awk '{print substr($0,3)}' )
	do
		rutaArchivo=$(dirname "$archivo")
		nombreArchivo=$(basename "$archivo")
		if [ "$nombreArchivo" == "$Recuperar" ]
		then
			((contadorArchivosIguales++))
			archivosIguales="$archivosIguales$contadorArchivosIguales - $nombreArchivo $rutaArchivo;"
			arrayArchivos[$contadorArchivosIguales]="$rutaArchivo/$nombreArchivo"
			archivo_a_recuperar="$rutaArchivo/$nombreArchivo"
		fi
	done

	if [ "$contadorArchivosIguales" -eq 0 ]
	then
		echo "No existe el archivo en la papelera"
		exit 1
	else
		if [ "$contadorArchivosIguales" -eq 1 ]
		then
			unzip -q ~/papelera.zip "$archivo_a_recuperar" -d /
			zip -q -d ~/papelera.zip "$rutaArchivo/$archivo_a_recuperar"
		else
			echo "$archivosIguales" | awk 'BEGIN{FS=";"} {for(i=1; i < NF; i++) print $i}'
			echo "¿Qué archivo desea recuperar?"
			read opcion
			
			if [ $opcion -gt 0 -a $opcion -le "${#arrayArchivos[@]}" ]
			then
				seleccion="${arrayArchivos[$opcion]}"
			else
				echo ""
				echo "Error, selección inválida"
				echo ""
				exit 1
			fi

			elementoNumero=0
			indice=0
			IFS=$'\n'
			#realizo una indexacion del elemento elegido con los elementos del zip
			for archivo in $(zip -sf ~/papelera |  awk '{print substr($0,3)}')
			do
				((indice++))
				if [ "$seleccion" == "$archivo" ]
				then
					elementoNumero=$indice
				fi
			done
			indice=0
			IFS=$'\n'
			#busco de forma incremental hasta encontrar en indice anterior y elimino el archivo en el zip 
			for archivo in $(zip -sf ~/papelera  |  awk '{print substr($0,3)}' )
			do
				#echo "$archivo"
				((indice++))
				if [ "$indice" == "$elementoNumero" ]
				then
					unzip -q ~/papelera.zip "$archivo" -d /			
					zip -q -d ~/papelera.zip "$archivo"
				fi
			done
		fi
	fi
	echo "Archivo recuperado"
}

vaciar(){
	if [ -f ~/papelera.zip ] #-f verifica que el archivo exista
	then
		if [ $(zipinfo ~/papelera.zip |grep ^-|wc -l) -gt 0 ] 
		then
			zip -qd ~/papelera.zip "*"
			echo "La papelera fue vaciada"
			exit 0
		else	
			echo "Error, la papelera está vacía"
			exit 1
		fi
	else
		echo "Error, no existe la papelera"
		exit 1
	fi
}

eliminar(){
	( [ $# -ne 1 ] ) && errorParametros
	
	if ( [ -f "$1" ] || [ -d "$1" ] ) #si existe el archivo o directorio
	then
		var=$(realpath "$1")
		if ( zip -q -m ~/papelera.zip "$var" ) #-m borra el archivo en el sistema y lo mete al zip
		then
			echo "Se elimina archivo $(basename "$var")"
			exit 0
		else
			echo "No se logra eliminar el archivo $1"
			exit 1
		fi
	else
		echo "Error, no existe el archivo o carpeta que intenta eliminar"
		exit 1
	fi
}

destruir(){
	( [ $# -ne 1 ] ) && errorParametros

	if [ -f ~/papelera.zip ] #-f verifica que el archivo exista
	then
		if [ $(zipinfo ~/papelera.zip |grep ^-|wc -l) -gt 0 ] 
		then 
			var=$(realpath $1)
			nombreArchivoADestruir=$(basename "$var")
			IFS=$'\n'
			for archivo in $(zip -sf ~/papelera | awk '{print substr($0,3)}' )
			do
				nombreArchivo=$(basename "$archivo")
				if [ "$nombreArchivo" == "$nombreArchivoADestruir" ]
				then
					zip -q -d ~/papelera.zip "$archivo"
					echo "Se destruyó el archivo de la papelera"
					exit 0
				fi
			done
			echo "Error, no existe el archivo a eliminar"
		else
			echo "Error, la papelera está vacía"
			exit 1
		fi
	else
		echo "Error, no existe la papelera"
		exit 1
	fi
}

errorParametros(){
	echo "###################################################"
	echo "Error revisar parametros igresados"
	echo ""
	echo "Se recomienda usar la ayuda -> ./papelera.sh -h"
	echo "                             ó ./papelera.sh -?"
	echo "                             ó ./papelera.sh --help"	
	echo "###################################################"
	exit 1
}

#Verifico que los parametros ingresados sean mayor a 1 y menor a 2
( [ $# -lt 1 ] ) && errorParametros #if corto

case $1 in
	"-h"|"-?"|"--help")
		ayuda;;
	
	"--listar")
		listar;;
	
	"--vaciar")
		vaciar;;
		
	"--recuperar")
		recuperar $2;;

	"--eliminar")
		eliminar "$2";;
		
	"--destruir")
		destruir $2;;

	*) 
		errorParametros
		exit;;
esac
