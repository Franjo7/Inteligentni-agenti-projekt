breed [tehnicari tehnicar]
breed [uredjaji uredjaj]
breed [stolovi stol]

globals [
  cijena-po-satu
  cijena-popravka-osnovni
  cijena-popravka-slozeni
  cijena-popravka-hitni
  radno-vrijeme-pocetak
  radno-vrijeme-kraj
  zarada
  ukupni-troskovi
  popravke
  neuspjele-popravke
]

turtles-own [
  placa  ;; Plaća tehničara
  status  ;; Status tehničara (slobodan ili zauzet)
  radno-vrijeme  ;; Radno vrijeme tehničara
]

uredjaji-own [
  vrijeme-popravka ;; Vrijeme potrebno za popravak uređaja
  vrsta-kvara  ;; Vrsta kvara uređaja (osnovni, složeni, hitni)
  vrijeme-dolaska  ;; Vrijeme dolaska uređaja u servis
]

tehnicari-own [
  vrsta-kvara  ;; Vrsta kvara koju tehničar može popraviti
]

to setup
  clear-all

  set cijena-po-satu 120
  set cijena-popravka-osnovni 80
  set cijena-popravka-slozeni 120
  set cijena-popravka-hitni 150
  set zarada 0
  set ukupni-troskovi 0
  set popravke 0
  set neuspjele-popravke 0

  ;; Postavljanje radnog vremena servisa                         ;; 8h * 60min = 480min
  set radno-vrijeme-pocetak 0                                    ;; 09:00h
  set radno-vrijeme-kraj 480                                     ;; 17:00h

  let positions [[-35 -15] [-35 15] [0 0] [35 15] [35 -15]]      ;; Fiksne pozicije stolova i tehničara
  let counter 0

  ;; Postavljanje početnih stanja tehničara i stolova
  create-tehnicari broj-aktivnih-tehnicara [
    set color blue
    set shape "person"
    set size 3
    set placa cijena-po-satu
    set status "slobodan"
    set radno-vrijeme 0
    ;; Postavljanje pozicije za svakog tehničara
    let position-item item counter positions
    setxy (first position-item) (last position-item)

    ;; Stvaranje stola pored svakog tehničara
    ifelse (first position-item) < 0 [
      ask patch (first position-item + 2) (last position-item) [
        sprout 1 [
          set breed stolovi
          set shape "square"
          set color brown
          set size 3
        ]
      ]
    ]
    [
      ask patch (first position-item - 2) (last position-item) [
        sprout 1 [
          set breed stolovi
          set shape "square"
          set color brown
          set size 3
        ]
      ]
    ]

    set counter counter + 1
  ]

  reset-ticks

end

to go
  ;; Provjera je li trenutni tick unutar radnog vremena servisa
  if ticks > radno-vrijeme-pocetak and ticks <= radno-vrijeme-kraj [
    if ticks <= 180 [                                             ;; 09:00h - 12:00h
      if ticks mod 7 = 0 [                                        ;; 25 uređaja
        create-new-device
      ]
    ]

    if ticks > 180 and ticks <= 360 [                            ;; 12:00h - 15:00h
      if ticks mod 12 = 0 [                                      ;; 15 uređaja
        create-new-device
      ]
    ]

    if ticks > 360 and ticks <= 480 [                            ;; 15:00h - 17:00h
      if ticks mod 12 = 0 [                                      ;; 10 uređaja
        create-new-device
      ]
    ]
  ]

  ;; Provjera statusa svakog tehničara i obrada uređaja
  ask tehnicari [
    if status = "slobodan" [
      let available-technicians turtles with [breed = tehnicari and status = "slobodan"]
      ifelse any? available-technicians [
        let nearest-uredjaj min-one-of uredjaji [distance myself] ;; Pronalazi najbliži uređaj tehničaru
        if nearest-uredjaj != nobody [
          ;; tehnicar repairs uredjaj
          let nearest-tehnicar min-one-of available-technicians [distance myself] ;; Pronalazi najbližeg tehničara uređaju
          face nearest-tehnicar
          move-to nearest-tehnicar
          ;; Rad tehničara na odabranom uredjaju
          ask nearest-tehnicar [
            set status "zauzet"
            set radno-vrijeme (radno-vrijeme + [vrijeme-popravka] of nearest-uredjaj)
            let cijena-popravka 0
            if [vrsta-kvara] of nearest-uredjaj = "osnovni" [
              set cijena-popravka cijena-popravka-osnovni
            ] if [vrsta-kvara] of nearest-uredjaj = "slozeni" [
              set cijena-popravka cijena-popravka-slozeni
            ] if [vrsta-kvara] of nearest-uredjaj = "hitni" [
              set cijena-popravka cijena-popravka-hitni
            ]
            show (word "Tehničar " who " popravlja uređaj " [who] of nearest-uredjaj ", vrsta kvara: " [vrsta-kvara] of nearest-uredjaj)
            ifelse ticks - [vrijeme-dolaska] of nearest-uredjaj <= 30 [
              show (word "Uređaj " [who] of nearest-uredjaj " popravljen.")
              set zarada zarada + cijena-popravka
              set popravke popravke + 1
              ask nearest-uredjaj [die]
              set status "slobodan"
            ] [
              show (word "Uređaj " [who] of nearest-uredjaj " nije popravljen unutar 30 minuta i umire.")
              set neuspjele-popravke neuspjele-popravke + 1
              ask nearest-uredjaj [die]
              set status "slobodan"
            ]
          ]
        ]
      ] [
        ;; Handle case where no technicians are available
        show (word "Nema dostupnih tehničara za popravak uređaja.")
      ]
    ]
  ]

  tick

  if ticks = radno-vrijeme-kraj [
    finish-day
    stop
  ]
end

to create-new-device
  create-uredjaji 1 [
    setxy random-xcor random-ycor
    set color red
    set shape "computer"
    set size 2
    set vrijeme-dolaska ticks
    set vrsta-kvara one-of ["osnovni" "slozeni" "hitni"]
    set vrijeme-popravka 30  ;; Prosjecno vrijeme za popravak svakog novog uređaja
    show (word "Novi uređaj stigao na popravak.")

    let nearest-tehnicar min-one-of tehnicari [distance myself]  ;; Pronalazi najbližeg tehničara uređaju

    ;; Provjeri je li najbliži tehničar pronađen
    ifelse nearest-tehnicar != nobody [
      ;; Pomakni se prema tehničaru korak po korak
      while [distance nearest-tehnicar > 1] [
        let step-distance min (list 1 (distance nearest-tehnicar))
        let delta-x ([xcor] of nearest-tehnicar - [xcor] of self) / distance nearest-tehnicar * step-distance
        let delta-y ([ycor] of nearest-tehnicar - [ycor] of self) / distance nearest-tehnicar * step-distance
        setxy ([xcor] of self + delta-x) ([ycor] of self + delta-y)
        wait 0.1  ;; Pričekaj 0.1 ticka
      ]

      face nearest-tehnicar  ;; Okreni se prema tehničaru
    ] [
      show "Nema dostupnih tehničara za popravak uređaja."
    ]
  ]
end

to finish-day
  set ukupni-troskovi (broj-aktivnih-tehnicara * cijena-po-satu * (radno-vrijeme-kraj / 60))
  set zarada zarada - ukupni-troskovi
  show (word "Ukupna dnevna zarada: " zarada)
  show (word "Ukupni dnevni troškovi: " ukupni-troskovi)
  show (word "Broj uspješnih popravaka: " popravke)
  show (word "Broj neuspjelih popravaka: " neuspjele-popravke)
  save-results
end

to save-results
  file-open "C:\\Users\\Franjo\\Desktop\\Inteligentni agenti - projekt\\rezultati.csv"
  file-print (word "Ukupna dnevna zarada: " zarada)
  file-print (word "Ukupni dnevni troskovi: " ukupni-troskovi)
  file-print (word "Broj uspjesnih popravaka: " popravke)
  file-print (word "Broj neuspjelih popravaka: " neuspjele-popravke)
  file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1271
552
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-40
40
-20
20
0
0
1
ticks
30.0

BUTTON
20
28
83
61
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
96
28
159
61
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
59
76
122
109
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
122
183
155
broj-aktivnih-tehnicara
broj-aktivnih-tehnicara
0
5
2.0
1
1
NIL
HORIZONTAL

MONITOR
1286
17
1388
62
Ukupna zarada:
zarada
17
1
11

MONITOR
1392
17
1497
62
Ukupni troškovi:
ukupni-troskovi
17
1
11

MONITOR
1287
72
1413
117
Uspješne popravke:
popravke
17
1
11

MONITOR
1287
123
1415
168
Neuspjele popravke:
neuspjele-popravke
17
1
11

@#$#@#$#@
# Simulacija rada servisa za popravak tehničkih uređaja

Servis za popravke _**„SmartFix DF“**_ raznih tehničkih uređaja (PC, laptopi, mrežni uređaji,  mobiteli, printeri, periferni uređaji (tipkovnica, miš…), hard i SSD diskovi i sl.). 

## Opis rada servisa

### 1. Tehničari i plaće:

 Servis ima na raspolaganju **5 tehničara**
 Plaća svakog tehničara iznosi **120 KM po satu**

### 2. Vrijeme popravka i zarada:

 Prosjek vremena potrebnog za popravak uređaja je **30 minuta (30 ticks)**
 Cijena popravka prema **vrsti kvara**

**Vrste kvara:** 
 Osnovni popravak: **80 KM**
 Složeni popravak: **120 KM**
 Hitni popravak: **150 KM**
	

### 3. Raspored dolazaka uređaja:

 Od 09:00 do 12:00 – **25 uređaja po satu**
 Od 12:00 do 15:00 – **15 uređaja po satu**
 Od 15:00 do 17:00 – **10 uređaja po satu**


### 4. Model agenata:

 Agenti predstavljaju **tehničare** i **uređaje** koji dolaze na popravak
 Svaki otkucaj vremena simulacije predstavlja **jedan minut** radnog vremena servisa


### 5. Parametri kontrole:

 Broj aktivnih tehničara kontrolira se klizačem (može biti od **0 do 5**)
 Ukoliko uređaj nakon pregleda kvara čeka **više od 30 minuta,** pretpostavka je da je ostavljen po strani te da je popravka iz nekog razloga nemoguća ili neisplativa te uređaj kao takav „umire“


### 6. Optimizacija i uspješnost:
 Uspješnost odabranog broja radnih mjesta ogleda se u odnosu **ukupne zarade** servisa (zbroj obavljenih popravaka) i **cijene rada** angažiranih tehničara.
 U Excelu se tablično prikazuju dobiveni rezultati koji označavaju **optimalno rješenje**

## Zaključak

> Ovu simulacija daje nam mogućnost eksperimentiranja s brojem aktivnih tehničara kako bi pronašli optimalnu konfiguraciju koja minimizira vrijeme čekanja i maksimizira dobit servisa. Pritom prikazuje ukupnu zaradu, broj obavljenih popravaka i druge relevantne parametre.

## Dodatno (prof. Krešimir)

> Odraditi zadatak i realizirati simulacijski model u kojem pojedini tehničari mogu popravljati samo neke skupine uređaja!
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

computer
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
