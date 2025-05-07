*===============================================================================
* Peru Vulnerability Maps: Clean 2017 Household survey data.
* Author: Julian Arteaga
* Date: 08/14/2022
*===============================================================================

cap log close
log using "$projdir_git/output/log/02_clean_hhsurvey_2017.log", replace

clear all
cd "$projdir_box"

* enaho01-2017-100.dta: CARACTERÍSTICAS DE LA VIVIENDA Y DEL HOGAR (MÓDULO 100)
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-100.dta", clear
numlabel, add

* Housing Characteristics (Vivienda):
keep if inlist(result, 1, 2) // drop households that refused to be surveyed
							 // sample is 34,584 households

rename a*o year // year == 2017

rename ubigeo dist_code

* ----- Rural / Urban -------

/*
tab estrato
estrato geogr�fico |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
        1.  de 500 000 a m�s habitantes |      5,362       15.50       15.50
    2.  de 100 000 a 499 999 habitantes |      6,417       18.55       34.06
      3.  de 50 000 a 99 999 habitantes |      2,708        7.83       41.89
      4.  de 20 000 a 49 999 habitantes |      2,321        6.71       48.60
        5. de 2 000 a 19 999 habitantes |      4,862       14.06       62.66
          6.  de 500 a 1 999 habitantes |      1,788        5.17       67.83
7.  �rea de empadronamiento rural (aer) |      8,615       24.91       92.74
8.  �rea de empadronamiento rural (aer) |      2,511        7.26      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,584      100.00
*/

gen rural = inlist(estrato, 6, 7 ,8)
label var rural "Rural household"

* ----- Type of housing -----

rename p101 tipo_viv

/*
tab tipo_viv
                       tipo de vivienda |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                  1. casa independiente |     30,524       89.33       89.33
            2. departamento en edificio |      1,423        4.16       93.49
                  3. vivienda en quinta |        353        1.03       94.52
4. vivienda en casa de vecindad (callej |      1,181        3.46       97.98
                      5. choza o caba�a |        668        1.95       99.94
                6. vivienda improvisada |         18        0.05       99.99
7. local no destinado para habitaci�n h |          3        0.01      100.00
                                8. otro |          1        0.00      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,171      100.00
*/

gen byte viv_casa = inlist(tipo_viv, 1)
gen byte viv_departamento = inlist(tipo_viv, 2)
gen byte viv_quinta = inlist(tipo_viv, 3)
gen byte viv_vecindad = inlist(tipo_viv, 4)
gen byte viv_choza = inlist(tipo_viv, 5)
gen byte viv_improv = inlist(tipo_viv, 6)
gen byte viv_otra = inlist(tipo_viv, 7)

drop tipo_viv

label var viv_casa "Housing type: house"
label var viv_departamento "Housing type: apartment"
label var viv_quinta "Housing type: farm"
label var viv_vecindad "Housing type: condo"
label var viv_choza "Housing type: cabin"
label var viv_improv "Housing type: improvised"
label var viv_otra "Housing type: other"

* ----- Walls material -----

rename p102 mat_pared

/*
tab mat_pared

     el material predominante en las |
              paredes exteriores es: |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
     1. ladrillo o bloque de cemento |     15,359       44.95       44.95
2. piedra o sillar con cal o cemento |        190        0.56       45.50
                            3. adobe |      9,250       27.07       72.57
                            4. tapia |      3,062        8.96       81.53
         5. quincha (ca�a con barro) |        604        1.77       83.30
                 6. piedra con barro |        343        1.00       84.31
                           7. madera |      3,930       11.50       95.81
                           8. estera |        173        0.51       96.31
                    9. otro material |      1,260        3.69      100.00
-------------------------------------+-----------------------------------
                               Total |     34,171      100.00

*/

gen byte pared_ladrillo = inlist(mat_pared, 1)
gen byte pared_piedra = inlist(mat_pared, 2)
gen byte pared_adobe = inlist(mat_pared, 3)
gen byte pared_tapia = inlist(mat_pared, 4)
gen byte pared_quincha = inlist(mat_pared, 5)
gen byte pared_barro = inlist(mat_pared, 6)
gen byte pared_madera = inlist(mat_pared, 7)
gen byte pared_triplay = inlist(mat_pared, 8)
gen byte pared_otro = inlist(mat_pared, 9)

drop mat_pared

label var pared_ladrillo "Wall material: brick"
label var pared_piedra "Wall material: stone"
label var pared_adobe "Wall material: adobe"
label var pared_tapia "Wall material: tapia"
label var pared_quincha "Wall material: quincha"
label var pared_barro "Wall material: mud"
label var pared_madera "Wall material: wood"
label var pared_triplay "Wall material: triplay"
label var pared_otro "Wall material: other"

* ----- Roof material -----

rename p103a mat_techo

/*
tab mat_techo

 el material predominante en los techos |
                                    es: |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     1. concreto armado |     10,704       31.32       31.32
                              2. madera |        549        1.61       32.93
                               3. tejas |      3,122        9.14       42.07
4. planchas de calamina, fibra de cemen |     16,892       49.43       91.50
    5. ca�a o estera con torta de barro |      1,303        3.81       95.31
                              6. estera |        260        0.76       96.08
              7. paja, hojas de palmera |      1,141        3.34       99.41
                       8. otro material |        200        0.59      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,171      100.00
*/

gen byte techo_concreto = inlist(mat_techo, 1)
gen byte techo_madera = inlist(mat_techo, 2)
gen byte techo_tejas = inlist(mat_techo, 3)
gen byte techo_calamina = inlist(mat_techo, 4)
gen byte techo_estera = inlist(mat_techo, 5)
gen byte techo_triplay = inlist(mat_techo, 6)
gen byte techo_paja = inlist(mat_techo, 7)
gen byte techo_otro = inlist(mat_techo, 8)

drop mat_techo

label var techo_concreto "Roof material: concrete"
label var techo_madera "Roof material: wood"
label var techo_tejas "Roof material: tiles"
label var techo_calamina "Roof material: calamine"
label var techo_estera "Roof material: mat"
label var techo_triplay "Roof material: triplay"
label var techo_paja "Roof material: hay"
label var techo_otro "Roof material: other"

* ----- Floor material -----

rename p103 mat_piso

/*
tab mat_piso

  el material predominante en los pisos |
                                    es: |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
             1. parquet o madera pulida |        918        2.69        2.69
2. l�minas asf�lticas, vin�licos o simi |      1,517        4.44        7.13
       3. losetas, terrazos o similares |      3,184        9.32       16.44
                 4. madera (entablados) |      2,857        8.36       24.80
                             5. cemento |     14,342       41.97       66.78
                              6. tierra |     11,137       32.59       99.37
                       7. otro material |        216        0.63      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,171      100.00

*/

gen byte piso_parquet = inlist(mat_piso, 1)
gen byte piso_lamina = inlist(mat_piso, 2)
gen byte piso_loseta = inlist(mat_piso, 3)
gen byte piso_madera = inlist(mat_piso, 4)
gen byte piso_cemento = inlist(mat_piso, 5)
gen byte piso_tierra = inlist(mat_piso, 6)
gen byte piso_otro = inlist(mat_piso, 7)

drop mat_piso

label var piso_parquet "Floor material: Parquet"
label var piso_lamina "Floor material: sheet"
label var piso_loseta "Floor material: tile"
label var piso_madera "Floor material: wood"
label var piso_cemento "Floor material: cement"
label var piso_tierra "Floor material: dirt"
label var piso_otro "Floor material: other"

* ----- Property rights -----

rename p105a prop_right

/*
tab prop_right

    la vivienda que ocupa su hogar es: |      Freq.     Percent        Cum.
---------------------------------------+-----------------------------------
                          1. alquilada |      2,613        7.56        7.56
          2. propia, totalmente pagada |     25,029       72.37       79.93
               3. propia, por invasi�n |      1,440        4.16       84.09
       4. propia, compr�ndola a plazos |        170        0.49       84.58
    5. cedida por el centro de trabajo |        215        0.62       85.20
6. cedida por otro hogar o instituci�n |      5,087       14.71       99.91
                         7. otra forma |         30        0.09      100.00
---------------------------------------+-----------------------------------
                                 Total |     34,584      100.00
*/

gen byte prop_alquilada = inlist(prop_right, 1)
gen byte prop_contitulo = inlist(prop_right, 2, 4)
gen byte prop_sintitulo = inlist(prop_right, 3)
gen byte prop_cedida = inlist(prop_right, 5, 6)
gen byte prop_otra = inlist(prop_right, 7)

drop prop_right

label var prop_alquilada "Property: rented"
label var prop_contitulo "Property: own with title"
label var prop_sintitulo "Property: own without title"
label var prop_cedida "Property: transfer"
label var prop_otra "Property: other"

* ----- Water service -----

rename p110 water_prov

/*
tab water_prov

  el abastecimiento de agua en su hogar |
                           procede de : |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
  1. red p�blica, dentro de la vivienda |     27,267       78.84       78.84
2. red p�blica, fuera de la vivienda pe |      1,305        3.77       82.62
                3. pil�n de uso p�blico |        601        1.74       84.35
    4. cami�n - cisterna u otro similar |        470        1.36       85.71
                                5. pozo |        809        2.34       88.05
   6. r�o, acequia, manantial o similar |      2,696        7.80       95.85
                                7. otra |      1,436        4.15      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,584      100.00
*/

gen byte agua_dentro = inlist(water_prov, 1)
gen byte agua_fuera = inlist(water_prov, 2)
gen byte agua_fuente = inlist(water_prov, 3)
gen byte agua_cisterna = inlist(water_prov, 4)
gen byte agua_pozo = inlist(water_prov, 5)
gen byte agua_manantial = inlist(water_prov, 6)
gen byte agua_otro = inlist(water_prov, 7)
gen byte agua_rio = inlist(water_prov, 8)

drop water_prov

label var agua_dentro "Drinking water: indoor plumbing"
label var agua_fuera "Drinking water: outdoor plumbing"
label var agua_fuente "Drinking water: public fountain"
label var agua_cisterna "Drinking water: truck"
label var agua_pozo "Drinking water: well"
label var agua_manantial "Drinking water: spring"
label var agua_otro "Drinking water: other"
label var agua_rio "Drinking water: river; lake; etc"

* ----- Water every day -----

rename p110c water_everyday

/*
tab water_everyday

   el hogar |
      tiene |
  acceso al |
servicio de |
 agua todos |
los d�as de |
  la semana |      Freq.     Percent        Cum.
------------+-----------------------------------
      1. si |     26,053       89.50       89.50
      2. no |      3,058       10.50      100.00
------------+-----------------------------------
      Total |     29,111      100.00
*/

recode water_everyday (2 = 0)
label var water_everyday "House has access to water everyday"

* ----- Sanitation -----

rename p111a sanitation

/*
tab sanitation

el ba�o o servicio higi�nico que tiene |
             su hogar esta conectado a: |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
1. red p�blica de desag�e dentro de la  |     19,979       57.77       57.77
2. red p�blica de desag�e fuera de la v |      1,160        3.35       61.12
                             3. letrina |      2,595        7.50       68.63
                        4. pozo s�ptico |      3,580       10.35       78.98
                  5. pozo ciego o negro |      3,013        8.71       87.69
                6. r�o, acequia o canal |        459        1.33       89.02
                                7. otra |        376        1.09       90.11
                            8. no tiene |      3,422        9.89      100.00
----------------------------------------+-----------------------------------
                                  Total |     34,584      100.00
*/

gen byte desague_dentro = inlist(sanitation, 1)
gen byte desague_fuera = inlist(sanitation, 2)
gen byte desague_letrina = inlist(sanitation, 3)
gen byte desague_septico = inlist(sanitation, 4)
gen byte desague_pozo = inlist(sanitation, 5)
gen byte desague_rio = inlist(sanitation, 6)
gen byte desague_otro = inlist(sanitation, 7)
gen byte desague_abierto = inlist(sanitation, 8)

drop sanitation

label var desague_dentro "Sanitation: indoor plumbing"
label var desague_fuera "Sanitation: outdoor plumbing"
label var desague_septico "Sanitation: septic tank"
label var desague_letrina "Sanitation: latrine"
label var desague_pozo "Sanitation: cesspool"
label var desague_rio "Sanitation: river"
label var desague_abierto "Sanitation: open field"
label var desague_otro "Sanitation: other"

* ----- Has Electricity -----

rename p1121 has_electricity

/*
tab has_electricity

        tipo de |
  alumbrado del |
         hogar: |
   electricidad |      Freq.     Percent        Cum.
----------------+-----------------------------------
        0. pase |      2,952        8.54        8.54
1. electricidad |     31,632       91.46      100.00
----------------+-----------------------------------
          Total |     34,584      100.00
*/

label var has_electricity "House connected to electric grid"

* -------------------------------------------------------------------

* Household Characteristics (Hogar):

tab p1131
/*
combustible que |
     usan en el |
     hogar para |
    cocinar sus |
     alimentos: |
   electricidad |      Freq.     Percent        Cum.
----------------+-----------------------------------
        0. pase |     32,052       92.68       92.68
1. electricidad |      2,532        7.32      100.00
----------------+-----------------------------------
          Total |     34,584      100.00
*/

gen byte cookfuel_electricity = p1131 == 1
drop p1131

tab p1132
/*
 combustible |
 que usan en |
    el hogar |
para cocinar |
         sus |
  alimentos: |
   gas (glp) |      Freq.     Percent        Cum.
-------------+-----------------------------------
     0. pase |      8,002       23.14       23.14
1. gas (glp) |     26,582       76.86      100.00
-------------+-----------------------------------
       Total |     34,584      100.00
*/

gen byte cookfuel_gascylinder = p1132 == 1
drop p1132

tab p1133
/*
   combustible |
que usan en el |
    hogar para |
   cocinar sus |
alimentos: gas |
       natural |      Freq.     Percent        Cum.
---------------+-----------------------------------
       0. pase |     33,796       97.72       97.72
1. gas natural |        788        2.28      100.00
---------------+-----------------------------------
         Total |     34,584      100.00
*/

gen byte cookfuel_naturalgas = p1133 == 1
drop p1133

tab p1135
/*
combustible |
que usan en |
   el hogar |
       para |
cocinar sus |
 alimentos: |
     carb�n |      Freq.     Percent        Cum.
------------+-----------------------------------
    0. pase |     32,758       94.72       94.72
  1. carb�n |      1,826        5.28      100.00
------------+-----------------------------------
      Total |     34,584      100.00
*/

gen byte cookfuel_coal = p1135 == 1
drop p1135

tab p1136
/*
combustible |
que usan en |
   el hogar |
       para |
cocinar sus |
 alimentos: |
       le�a |      Freq.     Percent        Cum.
------------+-----------------------------------
    0. pase |     22,371       64.69       64.69
    1. le�a |     12,213       35.31      100.00
------------+-----------------------------------
      Total |     34,584      100.00
*/

gen byte cookfuel_wood = p1136 == 1
drop p1136

tab p1137
/*
combustible |
que usan en |
   el hogar |
       para |
cocinar sus |
 alimentos: |
       otro |      Freq.     Percent        Cum.
------------+-----------------------------------
    0. pase |     24,933       72.09       72.09
    1. otro |      9,651       27.91      100.00
------------+-----------------------------------
      Total |     34,584      100.00
*/

gen byte cookfuel_other = p1137 == 1
drop p1137

// tab p1138: cookfuel_manure not in this survey

/*
tab p1138

 no cocinan |      Freq.     Percent        Cum.
--------------+-----------------------------------
      0. pase |     33,729       97.53       97.53
1. no cocinan |        855        2.47      100.00
--------------+-----------------------------------
        Total |     34,584      100.00
*/

gen byte cookfuel_none = p1138 == 1
drop p1138

label var cookfuel_electricity "Cooking fuel: electricity"
label var cookfuel_gascylinder "Cooking fuel: gas cylinder"
label var cookfuel_naturalgas "Cooking fuel: natural gas"
label var cookfuel_coal "Cooking fuel: coal"
label var cookfuel_wood "Cooking fuel: wood"
// label var cookfuel_manure "Cooking fuel: manure"
label var cookfuel_other "Cooking fuel: other"
label var cookfuel_none "Cooking fuel: no cooking done"

* ----- Durable goods -----

* Phones are in module 100, rest in module 112:

gen telefono = p1141 == 1
gen celular = p1142 == 1
gen tvcable = p1143 == 1
gen internet = p1144 == 1

label var celular "Durables: cellphone"
label var telefono "Durables: telephone"
label var tvcable "Durables: cable tv"
label var internet "Durables: internet"

rename factor07 hhweight

keep dist_code conglome vivienda hogar viv_* pared_* techo_* piso_* agua_*  ///
	 desague_* prop_* has_electricity water_everyday cookfuel_*				///
	 telefono celular tvcable internet hhweight rural

saveold "$projdir_box/dta/cln/hhsurv_vivienda.dta", replace

* -------------------------------------------------------------------

* enaho01-2017-612.dta : EQUIPAMIENTO DEL HOGAR ( MÓDULO 612 )
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-612.dta", clear
numlabel, add

rename ubigeo dist_code

tab p612n

/*
       equipamiento del hogar |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
                     1. radio |     34,584        3.85        3.85
                2. tv a color |     34,584        3.85        7.69
         3. tv blanco y negro |     34,584        3.85       11.54
          4. equipo de sonido |     34,584        3.85       15.38
                       5. dvd |     34,584        3.85       19.23
           6. video grabadora |     34,584        3.85       23.08
               7. computadora |     34,584        3.85       26.92
                   8. plancha |     34,584        3.85       30.77
                 9. licuadora |     34,584        3.85       34.62
             10. cocina a gas |     34,584        3.85       38.46
        11. cocina a kerosene |     34,584        3.85       42.31
12. refrigeradora/congeladora |     34,584        3.85       46.15
                 13. lavadora |     34,584        3.85       50.00
         14. horno microondas |     34,584        3.85       53.85
         15. m�quina de coser |     34,584        3.85       57.69
                16. bicicleta |     34,584        3.85       61.54
          17. auto, camioneta |     34,584        3.85       65.38
              18. motocicleta |     34,584        3.85       69.23
                 19. triciclo |     34,584        3.85       73.08
                 20. mototaxi |     34,584        3.85       76.92
                   21. cami�n |     34,584        3.85       80.77
                     22. otro |     34,584        3.85       84.62
                     23. otro |     34,584        3.85       88.46
                     24. otro |     34,584        3.85       92.31
                     25. otro |     34,584        3.85       96.15
                     26. otro |     34,584        3.85      100.00
------------------------------+-----------------------------------
                        Total |    899,184      100.00
*/

gen equipsonido = p612n == 4 & p612 == 1 // p612: yes/no
gen tv = (p612n == 2 & p612 == 1) | (p612n == 3 & p612 == 1)
gen cocinagas = p612n == 10 & p612 == 1
gen refri = p612n == 12 & p612 == 1
gen lavadora = p612n == 13 & p612 == 1
gen microondas = p612n == 14 & p612 == 1
gen licuadora = p612n == 9 & p612 == 1
gen plancha = p612n == 8 & p612 == 1
gen computadora = p612n == 7 & p612 == 1
gen automovil = (p612n == 17 & p612 == 1) | (p612n == 21 & p612 == 1)
gen moto = (p612n == 18 & p612 == 1) | (p612n == 20 & p612 == 1)

foreach var in equipsonido tv cocinagas refri 								///
	 		   lavadora microondas licuadora plancha 						///
			   computadora automovil moto {

    bys dist_code conglome vivienda hogar: egen `var'_aux = max(`var')
    drop `var'
	rename `var'_aux `var'
}

label var equipsonido "Durables: stereo"
label var tv "Durables: tv"
label var cocinagas "Durables: gas stove"
label var refri "Durables: fridge"
label var lavadora "Durables: washing"
label var microondas "Durables: microwave"
label var licuadora "Durables: blender"
label var plancha "Durables: clothes iron"
label var computadora "Durables: computer"
label var automovil "Durables: automobile"
label var moto "Durables: motorbike"

bys dist_code conglome vivienda hogar: keep if _n == 1

keep dist_code conglome vivienda hogar equipsonido tv cocinagas refri 		///
	 lavadora microondas licuadora plancha computadora automovil moto

saveold "$projdir_box/dta/cln/hhsurv_assets.dta", replace

* -------------------------------------------------------------------

* Individual Characteristics:

* enaho01-2017-200.dta : CARACTERÍSTICAS DE LOS MIEMBROS DEL HOGAR:
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-200.dta", clear
numlabel, add

rename ubigeo dist_code

rename p203 relationship

gen female = p207 == 2

rename p208a age

* Head male
gen head_male_aux = (relationship == 1 & female == 0)
bys dist_code conglome vivienda hogar: egen head_male = max(head_male_aux)
label var head_male "Head is male"

* Head age
gen hage_aux = age if relationship == 1
bys dist_code conglome vivienda hogar: egen hage = max(hage_aux)
label var hage "Head age"

drop *_aux

* Household composition
gen fm_u15_aux   = inrange(age, 0, 14)
gen f_15to64_aux = inrange(age, 15, 64)
gen fm_o65_aux   = inrange(age, 64, 120)

bys dist_code conglome vivienda hogar: egen fm_u15   = total(fm_u15_aux)
bys dist_code conglome vivienda hogar: egen f_15to64 = total(f_15to64_aux)
bys dist_code conglome vivienda hogar: egen fm_o65   = total(fm_o65_aux)

label var fm_u15   "# of hh members aged under 15"
label var f_15to64 "# of hh members aged 15-64"
label var fm_o65   "# of hh members aged 65 and over"

* Dependency ratio
bys dist_code conglome vivienda hogar: gen hhsize = _N
label var hhsize "Household size"

gen depend_ratio = (fm_u15 + fm_o65) / hhsize
label var depend_ratio "(fm_u15 + fm_o65) / hhsize"

* Household size
gen ln_hhsize = ln(hhsize)
label var ln_hhsize "log hh size"

bys dist_code conglome vivienda hogar: keep if _n == 1

keep dist_code conglome vivienda hogar depend_ratio 						///
	 hhsize ln_hhsize hage head_male

saveold "$projdir_box/dta/cln/hhsurv_individual.dta", replace

* ----- Employment -----

* enaho01-2017-500.dta: EMPLEO E INGRESO:
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-500.dta", clear
numlabel, add

rename ubigeo dist_code
rename p203 relationship

gen worked_last_week = p501 == 1

gen worked_onehour_lastweek = 0

foreach var of varlist p5041-p50411 {

	replace worked_onehour_lastweek = 1 if `var' == 1
}

gen occup_aux = (worked_last_week==1 | /*worked_onehour_lastweek == 1 |*/	///
 			p502 == 1 | p503 == 1) & relationship == 1

bys dist_code conglome vivienda hogar: egen hoccup = max(occup_aux)

gen unemp_aux = hoccup == 0 & p545 == 1 & relationship == 1
bys dist_code conglome vivienda hogar: egen hunemp = max(unemp_aux)

gen not_labforce_aux = hoccup == 0 & unemp == 0 & relationship == 1
bys dist_code conglome vivienda hogar: egen hretired = max(not_labforce_aux)

drop *_aux

bys dist_code conglome vivienda hogar: keep if _n == 1

label var hoccup "Household occupied"
label var hunemp "Household head unemployed"
label var hretired "Household head not in labor force"

keep dist_code conglome vivienda hogar hoccup hunemp hretired

/*
sum hoccup hunemp hretired

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
      hoccup |     34,584    .8465186    .3604561          0          1
      hunemp |     34,584    .0078938    .0884971          0          1
    hretired |     34,584    .1455876    .3526973          0          1
*/

saveold "$projdir_box/dta/cln/hhsurv_employment.dta", replace

* ----- Education -----

* enaho01-2017-300.dta: EDUCACIÓN:
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-300.dta", clear
numlabel, add

rename ubigeo dist_code

rename p203 relationship

/*
p301a

 �cu�l es el �ltimo a�o o grado de |
   estudios y nivel que aprob�? - nivel |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           1. sin nivel |      8,979        7.54        7.54
                   2. educaci�n inicial |      6,228        5.23       12.76
                 3. primaria incompleta |     25,465       21.37       34.14
                   4. primaria completa |     13,674       11.48       45.61
               5. secundaria incompleta |     18,432       15.47       61.08
                 6. secundaria completa |     21,758       18.26       79.35
7. superior no universitaria incompleta |      3,685        3.09       82.44
  8. superior no universitaria completa |      6,997        5.87       88.31
   9. superior universitaria incompleta |      6,035        5.07       93.38
    10. superior universitaria completa |      6,450        5.41       98.79
            11. postgrado universitario |      1,314        1.10       99.89
                    12. b�sica especial |        127        0.11      100.00
----------------------------------------+-----------------------------------
                                  Total |    119,144      100.00
*/

rename p301a heduc

gen byte head_noeduc = inlist(heduc, 1, 2, 3) & relation == 1
gen byte head_prim   = inlist(heduc, 4, 5)  & relation == 1
gen byte head_sec1   = inlist(heduc, 12) & relation == 1
gen byte head_sec2   = inlist(heduc, 6, 7, 9) & relation == 1
gen byte head_ter    = inlist(heduc, 8, 10, 11) & relation == 1

foreach var of varlist head_* {

	bys dist_code conglome vivienda hogar: egen `var'_aux = max(`var')
	drop `var'
	rename `var'_aux `var'
}

bys dist_code conglome vivienda hogar: keep if _n == 1

label var head_noeduc "No education"
label var head_prim   "Primary education"
label var head_sec1   "Basic secondary education"
label var head_sec2   "Secondary education"
label var head_ter    "Tertiary education"

bys dist_code conglome vivienda hogar: keep if _n == 1

keep dist_code conglome vivienda hogar head_noeduc head_prim				///
	 head_sec1 head_sec2 head_ter

saveold "$projdir_box/dta/cln/hhsurv_education.dta", replace

* ----- Handicap -----

* enaho01-2017-400.dta: SALUD:
use "$projdir_box/dta/src/enaho/2017/enaho01-2017-400.dta", clear
numlabel, add

rename ubigeo dist_code

rename p203 relationship


/*
desc p401h*

Variable      Storage   Display    Value
    name         type    format    label      Variable label
--------------------------------------------------------------------------------
p401h1          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para: moverse o
                                                caminar, para usar
p401h2          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para: ver, aun
                                                usando anteojos?
p401h3          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para: hablar o
                                                comunicarse, a�n usa
p401h4          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para: o�r, a�n
                                                usando aud�fonos ?
p401h5          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para: entender o
                                                aprender (concentr
p401h6          byte    %8.0g      LABB       �tiene ud. limitaciones de forma
												permanente, para:
												relacionarse con los dem�s, p
*/

gen handicap_motor = p401h1 == 1 & relationship == 1
gen handicap_sordo  = (p401h3 == 1 | p401h4 == 1) & relationship == 1
gen handicap_visual = p401h2 == 1 & relationship == 1
gen handicap_mental = p401h5 == 1 & relationship == 1
gen handicap_otro  = p401h6 == 1 & relationship == 1

foreach var of varlist handicap_* {

	bys dist_code conglome vivienda hogar: egen `var'_aux = max(`var')
	drop `var'
	rename `var'_aux `var'
}

label var handicap_motor "Handicap: motor"
label var handicap_sordo  "Handicap: deaf; mute"
label var handicap_visual "Handicap: visual"
label var handicap_mental "Handicap: mental"
label var handicap_otro  "Handicap: otro"

bys dist_code conglome vivienda hogar: keep if _n == 1

keep dist_code conglome vivienda hogar handicap_motor						///
	 handicap_sordo	handicap_visual handicap_mental handicap_otro

saveold "$projdir_box/dta/cln/hhsurv_handicaps.dta", replace

* ----- Income, expenditure and poverty lines -----

* Yearly Inflation :
use "$projdir_box/dta/src/sedlac/ipc_sedlac_wb_PER.dta", clear
numlabel, add

rename ano year

keep year ipc_sedlac
keep if year == 2017

sum ipc_sedlac

local deflactor = r(mean)

* sumaria-2021.dta
use "$projdir_box/dta/src/enaho/2017/sumaria-2017.dta", clear
numlabel, add

* Build (area + region + dominio) poverty lines to impute to census:
gen area=estrato
recode area (1/5=1)(6/8=2)
lab define labarea 1"Urban" 2"Rural"
lab val area labarea

gen arealima=.
replace arealima=2         if real(ubigeo)>=150100 & real(ubigeo)<160000
replace arealima=1         if real(ubigeo)>=150100 & real(ubigeo)<=150143

gen region= real(substr(ubigeo,1,2))

gen provincia = substr(ubigeo,1,4)

// Lima* is Lima Metropolitana and Callao
replace region=15 if region==7
replace region=26 if arealima==2
label define region 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa"           ///
                    5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica"       ///
                    10"Huanuco" 11"Ica" 12"Junin" 13"La Libertad"           ///
                    14"Lambayeque" 15"Lima*" 16"Loreto" 17"Madre de Dios"   ///
                    18"Moquegua" 19"Pasco" 20"Piura" 21"Puno"               ///
                    22"San Martin" 23"Tacna" 24"Tumbes" 25"Ucayali"         ///
                    26"Lima provincias"

label values region region

decode region, gen(region_name)

preserve

keep region area dominio linea linpe
distinct linea // 82
bys region area dominio: keep if _n == 1 // 82. ok.
numlabel, remove
decode dominio, gen(dominio_s)

saveold 																	///
	"$projdir_box/dta/cln/enaho/dominio_area_region_povline_list_2017.dta", ///
	replace

restore

rename ubigeo dist_code

gen percexp = gashog2d / (mieperho*12)
label var percexp "Gross household percapita monthly expenditure"

rename gashog2d total_hhexp
label var total_hhexp "Gross household expenditure"

label var linea "Total poverty line"
label var linpe "Extreme poverty line"
// label var lineav "Vulnerability poverty line" // not available

/*
tab pobreza
             pobreza |      Freq.     Percent        Cum.
--------------------+-----------------------------------
   1. pobre extremo |      1,212        3.50        3.50
2. pobre no extremo |      5,246       15.17       18.67
        3. no pobre |     28,126       81.33      100.00
--------------------+-----------------------------------
              Total |     34,584      100.00
*/

gen pobre_extremo = pobreza == 1
gen pobre_no_extremo = pobreza == 2
gen no_pobre = pobreza == 3

gen popweight = factor07*mieperho
/*
sum pobre_extremo pobre_no_extremo no_pobre [aw=factor07*mieperho]

 Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
pobre_extr~o |  34,584  32106270.1    .0378628   .1908672          0          1
pobre_no_e~o |  34,584  32106270.1    .1791371   .3834726          0          1
no_pobre 	 |  34,584  32106270.1    .7830001   .4122085          0          1
*/

keep dist_code conglome vivienda hogar linea linpe /*lineav*/ 				///
	 total_hhexp pobreza percexp mieperho region region_name area dominio

saveold "$projdir_box/dta/cln/hhsurv_income_exp.dta", replace

* ----- Merge all:

use "$projdir_box/dta/cln/hhsurv_vivienda.dta", clear

merge 1:1 dist_code conglome vivienda hogar using 							///
 		  "$projdir_box/dta/cln/hhsurv_assets.dta"
drop _merge // all _merge == 3

merge 1:1 dist_code conglome vivienda hogar using 							///
 		  "$projdir_box/dta/cln/hhsurv_income_exp.dta"
drop _merge // all _merge == 3

merge 1:1 dist_code conglome vivienda hogar using 							///
 		  "$projdir_box/dta/cln/hhsurv_individual.dta"
drop _merge // all _merge == 3

merge 1:1 dist_code conglome vivienda hogar using 							///
 		  "$projdir_box/dta/cln/hhsurv_employment.dta"
drop _merge

merge 1:1 dist_code conglome vivienda hogar using 							///
		  "$projdir_box/dta/cln/hhsurv_education.dta"
drop _merge

merge 1:1 dist_code conglome vivienda hogar using 							///
		  "$projdir_box/dta/cln/hhsurv_handicaps.dta"
drop _merge

***

gen poor = (percexp < linea)
label var poor "(pctotal_hhexpexp < linea)"

gen extreme_poor = (percexp < linpe)
label var extreme_poor "(pctotal_hhexpexp < linpe)"

gen popweight = mieperho*hhweight
label var popweight "mieperho*hhweight"

/*
sum poor extreme_poor [aw=popweight]

    Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
        poor |  34,584  32106270.1    .2169999   .4122085          0          1
extreme_poor |  34,584  32106270.1    .0378628   .1908672          0          1
*/

drop poor extreme_poor
***

merge m:1 dist_code using "$projdir_box/dta/cln/dist_code_list.dta"

drop if _merge == 2 // 611 districts not in hhsurvey
drop _merge

destring dpto_code, replace
destring prov_code, replace
destring dist_code, replace

order _all, alpha
order dpto_code prov_code dist_code dpto_name prov_name dist_name 			///
 	  conglome vivienda hogar
compress

saveold "$projdir_box/dta/cln/enaho/hhsurv_2017_cln.dta", replace

erase "$projdir_box/dta/cln/hhsurv_handicaps.dta"
erase "$projdir_box/dta/cln/hhsurv_education.dta"
erase "$projdir_box/dta/cln/hhsurv_employment.dta"
erase "$projdir_box/dta/cln/hhsurv_individual.dta"
erase "$projdir_box/dta/cln/hhsurv_income_exp.dta"
erase "$projdir_box/dta/cln/hhsurv_assets.dta"
erase "$projdir_box/dta/cln/hhsurv_vivienda.dta"

***

* Poverty rates by region:

preserve
gen poor = (percexp < linea)
label var poor "(pctotal_hhexpexp < linea)"

collapse poor [aw = popweight], by(region)

saveold "$projdir_box/dta/cln/enaho/povrates_by_region_2017.dta", replace
restore

***

/*
desc

 Observations:        35,195
    Variables:           112                  14 Aug 2022 23:02
--------------------------------------------------------------------------------
Variable      Storage   Display    Value
    name         type    format    label      Variable label
--------------------------------------------------------------------------------
dpto_code       byte    %10.0g
prov_code       int     %10.0g
dist_code       long    %10.0g                ubicaci�n geogr�fica
dpto_name       str13   %13s                  DEPARTAMEN
prov_name       str25   %25s                  PROVINCIA
dist_name       str36   %36s                  DISTRITO
conglome        str6    %6s                   n�mero de conglomerado
vivienda        str3    %3s                   n�mero de selecci�n de vivienda
hogar           str2    %2s                   n�mero secuencial del hogar
agua_cisterna   byte    %8.0g                 Drinking water: truck
agua_dentro     byte    %8.0g                 Drinking water: indoor plumbing
agua_fuente     byte    %8.0g                 Drinking water: public fountain
agua_fuera      byte    %8.0g                 Drinking water: outdoor plumbing
agua_manantial  byte    %8.0g                 Drinking water: spring
agua_otro       byte    %8.0g                 Drinking water: other
agua_pozo       byte    %8.0g                 Drinking water: well
agua_rio        byte    %8.0g                 Drinking water: river; lake; etc
automovil       byte    %9.0g                 Durables: automobile
celular         byte    %9.0g                 Durables: cellphone
cocinagas       byte    %9.0g                 Durables: gas stove
computadora     byte    %9.0g                 Durables: computer
cookfuel_coal   byte    %8.0g                 Cooking fuel: coal
cookfuel_elec~y byte    %8.0g                 Cooking fuel: electricity
cookfuel_gasc~r byte    %8.0g                 Cooking fuel: gas cylinder
cookfuel_natu~s byte    %8.0g                 Cooking fuel: natural gas
cookfuel_none   byte    %8.0g                 Cooking fuel: no cooking done
cookfuel_other  byte    %8.0g                 Cooking fuel: other
cookfuel_wood   byte    %8.0g                 Cooking fuel: wood
depend_ratio    float   %9.0g                 (fm_u15 + fm_o65) / hhsize
desague_abierto byte    %8.0g                 Sanitation: open field
desague_dentro  byte    %8.0g                 Sanitation: indoor plumbing
desague_fuera   byte    %8.0g                 Sanitation: outdoor plumbing
desague_letrina byte    %8.0g                 Sanitation: latrine
desague_otro    byte    %8.0g                 Sanitation: other
desague_pozo    byte    %8.0g                 Sanitation: cesspool
desague_rio     byte    %8.0g                 Sanitation: river
desague_septico byte    %8.0g                 Sanitation: septic tank
equipsonido     byte    %9.0g                 Durables: stereo
hage            byte    %9.0g                 Head age
handicap_mental byte    %9.0g                 Handicap: mental
handicap_motor  byte    %9.0g                 Handicap: motor
handicap_otro   byte    %9.0g                 Handicap: otro
handicap_sordo  byte    %9.0g                 Handicap: deaf; mute
handicap_visual byte    %9.0g                 Handicap: visual
has_electricity byte    %15.0g     p1121      House connected to electric grid
head_male       byte    %9.0g                 Head is male
head_noeduc     byte    %9.0g                 No education
head_prim       byte    %9.0g                 Primary education
head_sec1       byte    %9.0g                 Basic secondary education
head_sec2       byte    %9.0g                 Secondary education
head_ter        byte    %9.0g                 Tertiary education
hhsize          byte    %9.0g                 Household size
hhweight        float   %9.0g                 factor de expansi�n anual proyecci
hoccup          byte    %9.0g                 Household occupied
hretired        byte    %9.0g                 Household head not in labor force
hunemp          byte    %9.0g                 Household head unemployed
internet        byte    %9.0g                 Durables: internet
lavadora        byte    %9.0g                 Durables: washing
licuadora       byte    %9.0g                 Durables: blender
linea           float   %9.0g                 Total poverty line
linpe           float   %9.0g                 Extreme poverty line
ln_hhsize       float   %9.0g                 log hh size
microondas      byte    %9.0g                 Durables: microwave
mieperho        byte    %8.0g                 total de miembros del hogar
moto            byte    %9.0g                 Durables: motorbike
pared_adobe     byte    %8.0g                 Wall material: adobe
pared_barro     byte    %8.0g                 Wall material: mud
pared_ladrillo  byte    %8.0g                 Wall material: brick
pared_madera    byte    %8.0g                 Wall material: wood
pared_otro      byte    %8.0g                 Wall material: other
pared_piedra    byte    %8.0g                 Wall material: stone
pared_quincha   byte    %8.0g                 Wall material: quincha
pared_tapia     byte    %8.0g                 Wall material: tapia
pared_triplay   byte    %8.0g                 Wall material: triplay
percexp         float   %9.0g                 Gross household percapita monthly
piso_cemento    byte    %8.0g                 Floor material: cement
piso_lamina     byte    %8.0g                 Floor material: sheet
piso_loseta     byte    %8.0g                 Floor material: tile
piso_madera     byte    %8.0g                 Floor material: wood
piso_otro       byte    %8.0g                 Floor material: other
piso_parquet    byte    %8.0g                 Floor material: Parquet
piso_tierra     byte    %8.0g                 Floor material: dirt
plancha         byte    %9.0g                 Durables: clothes iron
pobreza         byte    %19.0g     pobreza    pobreza
popweight       float   %9.0g                 mieperho*hhweight
prop_alquilada  byte    %8.0g                 Property: rented
prop_cedida     byte    %8.0g                 Property: transfer
prop_contitulo  byte    %8.0g                 Property: own with title
prop_otra       byte    %8.0g                 Property: other
prop_sintitulo  byte    %8.0g                 Property: own without title
refri           byte    %9.0g                 Durables: fridge
rural           byte    %9.0g                 Rural household
techo_calamina  byte    %8.0g                 Roof material: calamine
techo_concreto  byte    %8.0g                 Roof material: concrete
techo_estera    byte    %8.0g                 Roof material: mat
techo_madera    byte    %8.0g                 Roof material: wood
techo_otro      byte    %8.0g                 Roof material: other
techo_paja      byte    %8.0g                 Roof material: hay
techo_tejas     byte    %8.0g                 Roof material: tiles
techo_triplay   byte    %8.0g                 Roof material: triplay
telefono        byte    %9.0g                 Durables: telephone
total_hhexp     double  %10.0g                Gross household expenditure
tv              byte    %9.0g                 Durables: tv
tvcable         byte    %9.0g                 Durables: cable tv
viv_casa        byte    %8.0g                 Housing type: house
viv_choza       byte    %8.0g                 Housing type: cabin
viv_departame~o byte    %8.0g                 Housing type: apartment
viv_improv      byte    %8.0g                 Housing type: improvised
viv_otra        byte    %8.0g                 Housing type: other
viv_quinta      byte    %8.0g                 Housing type: farm
viv_vecindad    byte    %8.0g                 Housing type: condo
water_everyday  byte    %8.0g      p110c      House has access to water everyday
--------------------------------------------------------------------------------
Sorted by:

.
