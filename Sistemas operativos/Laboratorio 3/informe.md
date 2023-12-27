# INFORME: Multi-Level Feedback Queue (MLFQ)

Entrar a este [link](https://docs.google.com/spreadsheets/d/1pEw_8e0mO8ZSU8SgQDTV4f6N5n7r8bIPVn3bLvkw9Ko/edit?exids=71471483%2C71471477#gid=0) Para ver El cuadro con el resumen de las comparaciones entre el quantum original y el que esta reducido 10 veces

## **MEDICIONES: Quantum original (1000000)**                   vs              **Quantum reducido en 10 (1000000)**

### CASO 1: $ iobench
<table>
<tr>
<th> Quantum Original </th>
<th> Quantum reducido en 10</th>
</tr>
<tr>
<td>

```shell
$ iobench
					3: 6144 OPW100T, 6144 OPR100T
					3: 6272 OPW100T, 6272 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6272 OPW100T, 6272 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6272 OPW100T, 6272 OPR100T
					3: 6272 OPW100T, 6272 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
					3: 6336 OPW100T, 6336 OPR100T
Termino iobench 3: total ops 239872u -->	
Promedio de OPW: 6312
Promedio de OPR: 6312

pid: 3 prio: 2 cantselect: 394480 lastexec: 2158
```
</td>
<td>

```shell
4: 10048 OPW100T, 10048 OPR100T
					4: 9984 OPW100T, 9984 OPR100T
					4: 9984 OPW100T, 9984 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 9856 OPW100T, 9856 OPR100T
					4: 9856 OPW100T, 9856 OPR100T
					4: 9920 OPW100T, 9920 OPR100T
					4: 9728 OPW100T, 9728 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10112 OPW100T, 10112 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10048 OPW100T, 10048 OPR100T
					4: 10112 OPW100T, 10112 OPR100T
					4: 10112 OPW100T, 10112 OPR100T
Termino iobench 4: total ops 380288u -->	
Promedio de OPW: 10007
Promedio de OPR: 10007

pid: 4 prio: 1 cantselect: 638451 lastexec: 67814
```
</td>
</tr>
</table>

#### COMPARACION

Ir a al "Caso 1" en la parte inferior del excel para poder ver los cuadros de este caso. Notamos que se selecciona mas veces el proceso iobench en el caso en que se reduce 10 veces el quantum, atribuimos este hecho a que al haber tiempos mas cortos de ejecucion de procesos pasa mas veveces por uno especifico. El promedio de OPW y OPR tambien da un salto pensamos que de igual manera esto se debe a que el scheduler lo selecciona mas veces, pensamos que la cantidad de OPR y OPW es proporcional a la cantidad de veces que se selecciona el proceso.

### CASO 2: $ cpubench
<table>
<tr>
<th> Quantum Original </th>
<th> Quantum reducido en 10</th>
</tr>
<tr>
<td>

```shell
$ cpubench
4: 867 MFLOP100T
4: 875 MFLOP100T
4: 867 MFLOP100T
4: 867 MFLOP100T
4: 875 MFLOP100T
4: 875 MFLOP100T
4: 867 MFLOP100T
4: 875 MFLOP100T
4: 867 MFLOP100T
4: 867 MFLOP100T
4: 875 MFLOP100T
4: 867 MFLOP100T
4: 875 MFLOP100T
4: 867 MFLOP100T
4: 867 MFLOP100T
4: 867 MFLOP100T
4: 875 MFLOP100T
Termino cpubench 4: total ops 4227858432u --> 
Promedio de measurments: 870

pid: 4 prio: 0 cantselect: 2115 lastexec: 5067
```
</td>
<td>

```shell
3: 1098 MFLOP100T
3: 1108 MFLOP100T
3: 1098 MFLOP100T
3: 1108 MFLOP100T
3: 1098 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1098 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1098 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1108 MFLOP100T
3: 1098 MFLOP100T
Termino cpubench 3: total ops 268435456u --> 
Promedio de measurments: 1104

pid: 3 prio: 0 cantselect: 21018 lastexec: 23013
```
</td>
</tr>
</table>

#### COMPARACION 

Ir a al "Caso 2" en la parte inferior del excel para poder ver los cuadros de este caso. Aqui notamos que el promedio de  MFLOP100T es un poco menor en el quantum normal, no es mucha diferencia, son solo 270, donde si se nota un cambio abrupto es en la cantidad de seleccion, que en el quantum normal es mucho mas chica que en el otro quantum, de vuelta, pensamos que esto se debe a que el scheduler selecciona este proceso mas veces.

### CASO 3: $ iobench &; cpubench
<table>
<tr>
<th> Quantum Original </th>
<th> Quantum reducido en 10</th>
</tr>
<tr>
<td>

```shell
$ iobench &; cpubench
5: 867 MFLOP100T
5: 867 MFLOP100T
5: 867 MFLOP100T
					7: 62 OPW100T, 62 OPR100T
5: 867 MFLOP100T
5: 867 MFLOP100T
					7: 34 OPW100T, 34 OPR100T
5: 860 MFLOP100T
					7: 33 OPW100T, 33 OPR100T
5: 867 MFLOP100T
					7: 38 OPW100T, 38 OPR100T
5: 860 MFLOP100T
5: 867 MFLOP100T
					7: 36 OPW100T, 36 OPR100T
5: 867 MFLOP100T
					7: 37 OPW100T, 37 OPR100T
5: 867 MFLOP100T
5: 867 MFLOP100T
					7: 34 OPW100T, 34 OPR100T
5: 860 MFLOP100T
5: 867 MFLOP100T
					7: 34 OPW100T, 34 OPR100T
5: 867 MFLOP100T
					7: 35 OPW100T, 35 OPR100T
5: 867 MFLOP100T
5: 867 MFLOP100T
					7: 33 OPW100T, 33 OPR100T
Termino iobench 7: total ops 1408u -->	
Promedio de OPW: 37
Promedio de OPR: 37

pid: 7 prio: 2 cantselect: 2224 lastexec: 8007
Termino cpubench 5: total ops 4227858432u --> 
Promedio de measurments: 865

pid: 5 prio: 0 cantselect: 2123 lastexec: 8014
```                                           
</td>
<td>

```shell
$ iobench &; cpubench
17: 2300 MFLOP100T
					19: 382 OPW100T, 382 OPR100T
17: 2257 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2279 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2279 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2279 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2279 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2257 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2279 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2236 MFLOP100T
					19: 559 OPW100T, 559 OPR100T
17: 2236 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2279 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2300 MFLOP100T
17: 2279 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2279 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2257 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2279 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
17: 2257 MFLOP100T
					19: 336 OPW100T, 336 OPR100T
17: 2257 MFLOP100T
					19: 333 OPW100T, 333 OPR100T
Termino cpubench 17: total ops 536870912u --> 
Promedio de measurments: 2270

pid: 17 prio: 0 cantselect: 20999 lastexec: 126265
$ Termino iobench 19: total ops 13568u -->	
Promedio de OPW: 350
Promedio de OPR: 350

pid: 19 prio: 1 cantselect: 21843 lastexec: 126268

```
</td>
</tr>
</table>

#### COMPARACION

Ir a al "Caso 3" en la parte inferior del excel para poder ver los cuadros de este caso. Tenemos que MFLOP100T es mucho mayor en el quantum mas chico, puede ser por la cantidad de veces que se repite, que como se puede apreciar es mucho mayor en el segundo caso. El promedio de OPW y OPR es tambien mucho mayor, otra ves por lo explicado anteriormente.

### CASO 4: $ cpubench &; cpubench
<table>
<tr>
<th> Quantum Original </th>
<th> Quantum reducido en 10</th>
</tr>
<tr>
<td>

```shell
$ cpubench &; cpubench
13: 444 MFLOP100T
15: 434 MFLOP100T
13: 447 MFLOP100T
15: 434 MFLOP100T
13: 875 MFLOP100T
15: 883 MFLOP100T
13: 1068 MFLOP100T
15: 1068 MFLOP100T
13: 1078 MFLOP100T
15: 1068 MFLOP100T
13: 1088 MFLOP100T
15: 1050 MFLOP100T
13: 1059 MFLOP100T
15: 1059 MFLOP100T
13: 1078 MFLOP100T
15: 1050 MFLOP100T
13: 1088 MFLOP100T
15: 1059 MFLOP100T
13: 1068 MFLOP100T
15: 1068 MFLOP100T
13: 1078 MFLOP100T
15: 1059 MFLOP100T
13: 1059 MFLOP100T
15: 1088 MFLOP100T
13: 1068 MFLOP100T
15: 1041 MFLOP100T
13: 1059 MFLOP100T
15: 1088 MFLOP100T
13: 1068 MFLOP100T
15: 1059 MFLOP100T
13: 1068 MFLOP100T
15: 1068 MFLOP100T
13: 1078 MFLOP100T
15: 1059 MFLOP100T
Termino cpubench 15: total ops 1946157056u --> 
Promedio de measurments: 978

pid: 15 prio: 0 cantselect: 1050 lastexec: 16571
Termino cpubench 13: total ops 1946157056u --> 
Promedio de measurments: 986

pid: 13 prio: 0 cantselect: 1051 lastexec: 16571




```
</td>
<td>

```shell
$ cpubench &; cpubench
9: 1006 MFLOP100T
11: 986 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1150 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1150 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1172 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
9: 1184 MFLOP100T
11: 1161 MFLOP100T
9: 1172 MFLOP100T
11: 1150 MFLOP100T
9: 1172 MFLOP100T
11: 1161 MFLOP100T
Termino cpubench 11: total ops 1275068416u --> 
Promedio de measurments: 1150

pid: 11 prio: 0 cantselect: 10550 lastexec: 24969
Termino cpubench 9: total ops 1275068416u --> 
Promedio de measurments: 1168

pid: 9 prio: 0 cantselect: 10570 lastexec: 24989

```
</td>
</tr>
</table>

#### COMPARACION

Ir a al "Caso 4" en la parte inferior del excel para poder ver los cuadros de este caso. No hay casi diferencia entre promedios de MFLOP100T pero si la hay en la cantidad de veces que se selecciona, podria deberse a que el quantum sea mas chico, reitero, se cambia mas veces de procesos.

### CASO 5: $ cpubench &; cpubench &; iobench
<table>
<tr>
<th> Quantum Original </th>
<th> Quantum reducido en 10</th>
</tr>
<tr>
<td>

```shell
$ cpubench &; cpubench &; iobench
25: 1088 MFLOP100T
23: 1041 MFLOP100T
25: 1059 MFLOP100T
23: 1068 MFLOP100T
25: 1088 MFLOP100T
23: 1059 MFLOP100T
					21: 60 OPW100T, 60 OPR100T
25: 1078 MFLOP100T
23: 1050 MFLOP100T
25: 1088 MFLOP100T
23: 1050 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
25: 1068 MFLOP100T
23: 1050 MFLOP100T
25: 1078 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
23: 1068 MFLOP100T
25: 1088 MFLOP100T
23: 1050 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
25: 1088 MFLOP100T
23: 1041 MFLOP100T
25: 1098 MFLOP100T
23: 1050 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
25: 1088 MFLOP100T
23: 1041 MFLOP100T
25: 1078 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
23: 1059 MFLOP100T
25: 1078 MFLOP100T
23: 1059 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
25: 1078 MFLOP100T
23: 1068 MFLOP100T
25: 1078 MFLOP100T
23: 1068 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
25: 1059 MFLOP100T
23: 1050 MFLOP100T
25: 1068 MFLOP100T
					21: 33 OPW100T, 33 OPR100T
23: 1059 MFLOP100T
Termino cpubench 23: total ops 3355443200u --> 
Promedio de measurments: 1054

pid: 23 prio: 0 cantselect: 1051 lastexec: 24007
Termino cpubench 25: total ops 3355443200u --> 
Promedio de measurments: 1079

pid: 25 prio: 0 cantselect: 1057 lastexec: 24013
					21: 33 OPW100T, 33 OPR100T
Termino iobench 21: total ops 1408u -->	
Promedio de OPW: 35
Promedio de OPR: 35

pid: 21 prio: 2 cantselect: 2226 lastexec: 24014




```
</td>
<td>

```shell
$ cpubench &; cpubench &; iobench
14: 1150 MFLOP100T
16: 1128 MFLOP100T
					12: 389 OPW100T, 389 OPR100T
14: 1139 MFLOP100T
16: 1139 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1150 MFLOP100T
16: 1128 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1128 MFLOP100T
16: 1118 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1150 MFLOP100T
16: 1139 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1128 MFLOP100T
16: 1108 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1128 MFLOP100T
16: 1128 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
14: 1150 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
16: 1128 MFLOP100T
14: 1150 MFLOP100T
16: 1128 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1139 MFLOP100T
16: 1128 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1139 MFLOP100T
16: 1139 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
14: 1150 MFLOP100T
16: 1118 MFLOP100T
					12: 333 OPW100T, 333 OPR100T
14: 1128 MFLOP100T
16: 1128 MFLOP100T
					12: 336 OPW100T, 336 OPR100T
Termino iobench 12: total ops 13184u -->	
Promedio de OPW: 337
Promedio de OPR: 337

pid: 12 prio: 2 cantselect: 21018 lastexec: 80225
$ Termino cpubench 14: total ops 268435456u --> 
Promedio de measurments: 1140

pid: 14 prio: 0 cantselect: 10550 lastexec: 80307
Termino cpubench 16: total ops 268435456u --> 
Promedio de measurments: 1127

pid: 16 prio: 0 cantselect: 10571 lastexec: 80328

```
</td>
</tr>
</table>

#### COMPARACION

Ir a al "Caso 5" en la parte inferior del excel para poder ver los cuadros de este caso. Se puede apreciar que la cantidad de seleccion del proceso del quantum mas chico es mucho mayor, otra vez debido a que se esta cambiando de proceso mucho mas seguido. Igualmente OPW y OPR tambien aumentan, probablemente por lo mismo.