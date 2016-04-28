extensions [array matrix]

globals [
  positions_matrix
]

turtles-own[
  rotation
]

patches-own [
 ;;f_val = g_val + h_val (A* Search algorithm)
 f_val
 g_val
 h_val
 parent_patch ;;predecessor patch for get_path
]

;; Can rotate
to-report can_rotate [direction]
  if (who mod 4 = 0)[
    let result-rotate false
   ifelse (direction = 1)
   [
     let a 0
     let b 0
     let xself ([xcor] of self)
     let yself ([ycor] of self)
     ask turtle (who + 1)[
      set a ([xcor] of self) - xself
      set b ([ycor] of self) - yself
     ]
     set a (xself - a)
     set b (yself - b)
     ask patch a b [
       ifelse (pcolor != white ) and (pcolor != brown)[
         ifelse(not any? turtles-on self)[
           set result-rotate true
         ][set result-rotate false]
       ][set result-rotate false]
     ]
   ]
   [
     let adiagonal 0
     let bdiagonal 0
     let aoneline 0
     let boneline 0
     let a 0
     let b 0
     ask turtle (who + 2)[
      set aoneline ([xcor] of self)
      set boneline ([ycor] of self)
     ]
     ask turtle (who + 1)[
      set adiagonal ([xcor] of self)
      set bdiagonal ([ycor] of self)
     ]
     if (adiagonal = aoneline) [
       set a adiagonal
       set b (boneline - bdiagonal)
     ]
     if (bdiagonal = boneline) [
       set a (aoneline - adiagonal)
       set b bdiagonal
     ]
     ask patch a b [
       ifelse (pcolor != white ) and (pcolor != brown)[
         ifelse(not any? turtles-on self)[
           set result-rotate true
         ] [set result-rotate false]
       ] [set result-rotate false]

     ]
   ]
   report result-rotate
  ]
end
;; Default procedures; setup & go
to setup
  clear-all

  ;; initialize global variable
  set positions_matrix matrix:make-constant 4 8 0

  ;; initialize turtles
  set-default-shape turtles "square"
  let i 0
  while [ i != 4] [
    let x random-pxcor
    let y random-pycor

    ;; set turtle 0, 4, 8, 12
    create-turtles 1 [setxy x y set color one-of base-colors]
    matrix:set positions_matrix i 0 x
    matrix:set positions_matrix i 1 y
    ;; set turtle 1-3, 5-7, 9-11, 13-15
    let other_color one-of base-colors
    create-turtles 1 [setxy x - 1 y - 1 set color other_color]
    matrix:set positions_matrix i 2 x - 1
    matrix:set positions_matrix i 3 y - 1
    create-turtles 1 [setxy x - 1 y set color other_color]
    matrix:set positions_matrix i 4 x - 1
    matrix:set positions_matrix i 5 y
    create-turtles 1 [setxy x + 1 y set color other_color]
    matrix:set positions_matrix i 6 x + 1
    matrix:set positions_matrix i 7 y

    set i i + 1
    reset-ticks
  ]
  ask turtles [
   set heading 0
  ]
end

to go
  create_borders
  ask turtles [
  if (who mod 4 = 0) [
    move random 360
  ]
]
end

;; Procedures for turtles
to set_position [x y]
  ifelse (who mod 4 = 0) [
   ask turtle who       [setxy x y]
   ask turtle (who + 1) [setxy x - 1 y - 1]
   ask turtle (who + 2) [setxy x - 1 y]
   ask turtle (who + 3) [setxy x + 1 y] ]
  [
    print "error on set_position"]
end

;; BELUM DICEK apa bisa gerak atau engga
to move [direction]
  ;; 315   0  45
  ;; 270   T  90
  ;; 225  180 135
  let listdx [0 1 1 1 0 -1 -1 -1]
  let listdy [1 1 0 -1 -1 -1 0 1]
  ifelse (who mod 4 = 0) [
    ask turtle who [setxy xcor + item (direction / 45) listdx ycor + item (direction / 45) listdy]
    ask turtle (who + 1) [setxy xcor + item (direction / 45) listdx ycor + item (direction / 45) listdy]
    ask turtle (who + 2) [setxy xcor + item (direction / 45) listdx ycor + item (direction / 45) listdy]
    ask turtle (who + 3) [setxy xcor + item (direction / 45) listdx ycor + item (direction / 45) listdy]
  ]
  [
    print "error on move"]
end

;;move ke salah satu patch yang bertetangga
;;asumsi patch selalu bertetangga
;;BELUM DICEK apa bisa gerak atau engga
to move_towards [ptch]
  ifelse (who mod 4 = 0) [

     let direction 0
     let is_stop false
     while [is_stop = false] [
      set heading direction
      let ahead patch-ahead 1

      ;;print ahead
      ifelse ([pxcor] of ahead = [pxcor] of ptch and [pycor] of ahead = [pycor] of ptch) [
        set is_stop true
      ][
        set direction direction + 45
        if direction > 359 [
         print "error on move_towards : patch not found"
         die ]
      ]
     ]

    move direction
    print "move" ]
  [
    print "error on move_towards"]
end

to rotate
  ifelse (who mod 4 = 0)[
    if ([rotation] of turtle who = 0)[
      ask turtle (who + 1) [setxy xcor ycor + 2]
      ask turtle (who + 2) [setxy xcor + 1 ycor + 1]
      ask turtle (who + 3) [setxy xcor - 1 ycor - 1]
    ]
    if ([rotation] of turtle who = 1)[
      ask turtle (who + 1) [setxy xcor + 2 ycor]
      ask turtle (who + 2) [setxy xcor + 1 ycor - 1]
      ask turtle (who + 3) [setxy xcor - 1 ycor + 1]
    ]
    if ([rotation] of turtle who = 2)[
      ask turtle (who + 1) [setxy xcor ycor - 2]
      ask turtle (who + 2) [setxy xcor - 1 ycor - 1]
      ask turtle (who + 3) [setxy xcor + 1 ycor + 1]
    ]
    if ([rotation] of turtle who = 3)[
      ask turtle (who + 1) [setxy xcor - 2 ycor]
      ask turtle (who + 2) [setxy xcor - 1 ycor + 1]
      ask turtle (who + 3) [setxy xcor + 1 ycor - 1]
    ]
    ask turtle who [set rotation rotation + 1]
      if ([rotation] of turtle who = 4)[
        ask turtle who [set rotation 0]
      ]
    ]
  [
    print "error on rotate"]
end

to trace_path [tik in_path]

  let path in_path
  let init_length length path
  print init_length
  let i tik
  if (tik < init_length) [
    let dest_patch item i path

    print (word "x,y:" [xcor] of self "," [ycor] of self)
    print (word "i: " i )
    print (word "moving to: " dest_patch)
    ;;if i > 0 and i < init_length - 1[
     move_towards dest_patch
    ;;]     ;;set path remove-item 0 path
      set i i + 1
  ]

  set heading 0
end

;; Procedures for patch
to draw
  if mouse-inside? and mouse-down?[
   ask patch mouse-xcor mouse-ycor  [
     set pcolor white
   ]
  ]
end

to create_borders
  ask patches with [pcolor = white] [
    ask neighbors with [pcolor != white] [
     set pcolor brown
    ]
  ]
end

;; Procedures for path finding
to-report get_path [source_patch dest_patch]
  let is_search_done false
  let search_path []
  let current_patch 0
  let queue []
  let visited []

  set queue lput source_patch queue

  while [is_search_done = false] [
    ifelse length queue != 0
    [
      set queue sort-by [[f_val] of ?1 < [f_val] of ?2] queue

      set current_patch item 0 queue
      set queue remove-item 0 queue

      set visited lput current_patch visited

      ask current_patch [
        ifelse any? neighbors with [ (pxcor = [pxcor] of dest_patch) and (pycor = [pycor] of dest_patch) and abs ([pxcor] of current_patch - [pxcor] of self) <= 1 and abs ([pycor] of current_patch - [pycor] of self) <= 1]
        [
          set is_search_done true ]
        [
          ask neighbors with [pcolor != brown and pcolor != white and (not member? self visited) and (self != parent_patch)] [
            if not member? self queue and self != source_patch and self != dest_patch [
              if abs ([pxcor] of current_patch - [pxcor] of self) <= 1 and abs ([pycor] of current_patch - [pycor] of self) <= 1 [ ;;Mengatasi kasus overflow dari monitor

                set queue lput self queue

                set parent_patch current_patch
                set g_val [g_val] of parent_patch + 1
                set h_val distance dest_patch
                set f_val (g_val + h_val) ] ] ]
        ]
      ]
    ]
    [
      print("Path doesn't exist")
      report []
    ]
  ]

  set search_path lput current_patch search_path

  let temp_path first search_path
  while [temp_path != source_patch] [
    set search_path lput [parent_patch] of temp_path search_path
    set temp_path [parent_patch] of temp_path
  ]

  set search_path fput dest_patch search_path
  set search_path reverse search_path

  report search_path
end

;;TEST PROCEDURE
to test
  let origin 0
  ask patches [
   if pxcor = 0 and pycor = 0 [
    set origin self
   ]
  ]
  let t 0
  ask turtles [
    if(who = 0) [
     set t patch-here
    ]
  ]
  print origin
  print t
  let path get_path t origin
  ;;print path


  ask turtles [print who]
  let i 1
  while [i < 20][
    ask turtle 0 [
      trace_path i path
      set i i + 1
    ]
    tick
  ]
  ;;print path
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1065
418
32
14
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
-32
32
-14
14
1
1
1
ticks
30.0

BUTTON
15
191
70
224
NIL
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

BUTTON
12
34
96
67
Obstacle
draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
78
75
111
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

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 5.3.1
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
