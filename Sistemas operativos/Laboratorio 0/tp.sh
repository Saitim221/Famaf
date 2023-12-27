#!/bin/bash

#ejercicio 1
cat /proc/cpuinfo | grep "model name"

#ejercicio 2
cat /proc/cpuinfo | grep "model name" | wc -l

#ejercicio 3
curl https://www.gutenberg.org/files/11/11-0.txt | sed 's/Alice/Santino/g' > santino_in_wonderlands.txt
#utilizo curl para imprimir el texto de la pagina y luego sed sin tener que indicarle fichero pues utilizara lo que se va a imprimir en pantalla, con esto me ahorro tener que descargar el archivo y luego borrarlo

#ejercicio 4
#omito el cd hacia donde esta ubicado el archivo.
#Dos procesos, para maximo:
sort -k 4 weather_cordoba.in | head -n 1 | awk '{print $1, $2, $3}'
#para minimo:
sort -k 4 weather_cordoba.in | tail -n 1 | awk '{print $1, $2, $3}'
#se ordena el archivo y luego se utiliza el head que dropea todos los elementos que siguen de la linea 1, y el mismo caso con el minimo solo que se usara tail en ese caso

#ejercicio 5
sort -k 3 -n atpplayers.in

#ejercicio 6
awk  '{print $1, $2, $3, $4, $5, $6, $7, $8, ($7 - $8)}' superliga.in | sort -k2nr -k9nr 

#ejercicio 7
ip address | grep -i link/ether

#ejercicio 8
#Dado que la consigna no se explica del todo bien he decidido usar 3 comandos distintos, 1 para crear el directorio, otro para los archivos y el ultimo para cambiar el nombre
mkdir serie
cd serie
#crea el nuevo directorio
touch aña_SO1E{1..10}_es.srt
#crea los 10 archivos
for f in **_es**;do mv $f ${f%_es.srt}.srt; done
#cambia el nombre

