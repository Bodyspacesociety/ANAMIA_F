turtles-own [orientation rejection acceptance minReject maxReject minSupport maxSupport satisfaction sendMessage message perceivedMessage orientationHistory typereplies nextorientation]
globals [messageBoard sender positiveMessageBoard negativeMessageBoard positive_replies negative_replies average_orientation averagePositive averageNegative 
  positive negative nbPositive nbNegative nbExtremes listeOrPos listeOrNeg stdDevPos stdDevNeg stdDevOr listeOr stationary Allpositive_replies Allnegative_replies sortie nbSortie acceptanceChange]

 
   
to initialize
  __clear-all-and-reset-ticks
   set sortie false
   fabriqueAgents
   ifelse l_acceptance >= l_rejection [set acceptanceChange (((random (l_rejection * 10)) / 10)) ]
                       [set acceptanceChange l_acceptance]
   if acceptanceChange = 0 [set acceptanceChange 0.1]
   ask turtles [set acceptance acceptanceChange
                set rejection l_rejection]
   averageCalculation
   set Allpositive_replies 0
   set Allnegative_replies 0
  
end

 

to oneStep
  if (stationary = 5000) or (ticks = 50000) [
                                             stop]
  let t average_orientation
  let m count turtles
  starStep
  messageExchange
  let val 0
  ask turtles [set val orientation
              if positive != 0 [ifelse  (positive >= minSupport) and (positive <= maxSupport) [set val orientation - ((orientation - positive) * influenceMu)] 
                                                                                               [if (positive <= minReject) or (positive >= maxReject) [set val orientation + ((orientation - positive) * influenceMu)]]]
                          
              if negative != 0 [ifelse (negative >= minSupport) and (negative <= maxSupport) [set val orientation - ((orientation - negative) * influenceMu)] 
                                                                                                 [if (negative <= minReject) or (negative >= maxReject) [set val orientation + ((orientation - negative) * influenceMu)]]] 
                                   
              ifelse (val > 1) [set nextorientation 1 ]
                   [ifelse (val < -1) [set nextorientation -1 ]
                                      [set nextorientation val]]]
   ask turtles [set orientation nextorientation
                set orientationHistory lput orientation orientationHistory
                ifelse (orientation > 0)  [set color green] [set color orange]]
            
 

  averageCalculation
 
  let t' average_orientation
 
  if exit? = true [testeDepart]
                   ;;if nbNegative = 0 or nbPositive = 0 [stop]]
  if entry? = true [
                    let n count turtles
                    if n < 2 * nbAgents [ajouteAgents]]
  let m' count turtles
 
  ifelse t' <= t + 0.05 and t' >= t - 0.05 and m = m' [set stationary stationary + 1
               set t 0
               set t' 0
               ]
              [set stationary 0
               ]
 
  tick
  
  
end  

to fabriqueAgents
 
    create-turtles nbAgents
  [
    set color white
    set size 0.5 
    setxy random-xcor random-ycor
    set shape   "circle"
  ;; set orientation random-float 1
     set orientation ( -1 + random-float 2) ;; orientation entre -1 et 1
    ifelse (orientation > 0)  [set color green] [set color orange]
    set orientationHistory (list orientation)    
 
    set typereplies (list 0)
  ]
 

end

to testeDepart
  let n 0
  let i 0
  ask sender [set typereplies lput (positive_replies - negative_replies) typereplies
              if length typereplies >= patience [while [i < patience] [if item ((length typereplies) - (1 + i)) typereplies < 0 [set n  n + 1 ]
                                                                     set i i + 1 ]]]
  if n = patience [ask sender [die]
                   set sortie true
                   set nbSortie nbSortie + 1]
end

to starStep
  clear-links 
  ask turtles [set sendMessage false
               set perceivedMessage 0
               set minSupport max (list -1 (orientation - acceptance))
               set maxSupport min (list 1 (orientation + acceptance))
               set minReject max (list -1 (orientation - rejection)) 
               set maxReject min (list 1 (orientation + rejection))]
 
 
end

to ajouteAgents
 if sortie = true [create-turtles 1
  [
    set color white
    set size 0.5 
    setxy random-xcor random-ycor
    set shape   "circle"
    set orientation (random-float 1) ;; orientation entre 0 et 1
    ifelse (orientation > 0)  [set color green] [set color orange]
    set orientationHistory (list orientation)    
 
    set typereplies (list 0)
  ] 
  set sortie false]
end 
  
to messageExchange
  set messageBoard (list ticks)
  set positiveMessageBoard (list ticks)  
  set negativeMessageBoard (list ticks)
  set negative 0
  set positive 0
  let val 0
  let coul 0
  ask one-of turtles [set sendMessage true
                      set val orientation
                      set message orientation
                      set sender self
                      set messageBoard lput message messageBoard
                      ]
  
  ask (turtles with [sendMessage = false])  [if random (rate_participation - 1) = 0 [
                                             if (val >= minSupport) and (val <= maxSupport) [set perceivedMessage val 
                                                                                           set sendMessage true
                                                                                           set message orientation
                                                                                           set messageBoard lput message messageBoard 
                                                                                           set positiveMessageBoard lput message positiveMessageBoard
                                                                                           set positive positive + message
                                                                                           create-link-with sender [set color cyan]]
                                             if (val <= minReject) or (val >= maxReject) [set perceivedMessage val 
                                                                                           set sendMessage true
                                                                                           set message orientation
                                                                                           set messageBoard lput message messageBoard 
                                                                                           set negativeMessageBoard lput message negativeMessageBoard
                                                                                           set negative negative + message
                                                                                           create-link-with sender [set color red]]
                                              ]]
   set positiveMessageBoard but-first positiveMessageBoard ;; la liste positiveAnswer qui contient la liste des messages positifs est remise aux normes (en retirant le premier élément, informant du pas de temps de la liste des réponses positives)
   set negativeMessageBoard but-first negativeMessageBoard
   set positive_replies (length positiveMessageBoard ) ;; mesure de chaque type de réponses pour affichage - utile
   set negative_replies (length negativeMessageBoard  )
   if positive != 0 [set positive positive / positive_replies]
   if negative != 0 [set negative negative / negative_replies]
   set Allpositive_replies Allpositive_replies + positive_replies 
   set Allnegative_replies Allnegative_replies + negative_replies 
end

 
 
 to averageCalculation
    set listeOrPos []
   set listeOrNeg []
   set listeOr [] 

  ask turtles with [orientation > 0] [set listeOrPos lput orientation listeOrPos
                                set listeOr lput orientation listeOr]
   ask turtles with [orientation <= 0] [ set listeOrNeg lput orientation listeOrNeg
                                 set listeOr lput orientation listeOr]
 
 
  if length listeOrPos > 0 [ set averagePositive mean listeOrPos]
  ifelse length listeOrPos > 1  [set stdDevPos standard-deviation listeOrPos]
                                 [set stdDevPos 0]
  if length listeOrNeg > 0 [set averageNegative mean listeOrNeg]
 ifelse length listeOrNeg > 1  [set stdDevNeg standard-deviation listeOrNeg]
                                 [set stdDevNeg 0]
  if length listeOr > 0 [set average_orientation mean listeOr]
  ifelse length listeOr > 1  [set stdDevOr standard-deviation listeOr]
                                 [set stdDevOr 0]
 
  set nbPositive count turtles with [orientation > 0]
  set nbNegative count turtles with [orientation <= 0]
  

plot-average_orientations
 end

to plot-average_orientations

   set-current-plot "average_orientations"
   set-current-plot-pen "average"
   ifelse length listeOr > 0 [plot average_orientation]
                             [plot-pen-up]
   set-current-plot-pen "positive"
   ifelse length listeOrPos > 0 [plot averagePositive]
                             [plot-pen-up]
   set-current-plot-pen "negative"
   ifelse length listeOrNeg > 0 [plot averageNegative]
                             [plot-pen-up]
                             
   set-current-plot "stdev_orientations"
   set-current-plot-pen "pen-2"
   ifelse length listeOrPos > 0 and length listeOrNeg > 0 [plot stdDevOr]
                                                   [plot-pen-up]
   set-current-plot-pen "pen-1"
   ifelse length listeOrPos > 0 [plot stdDevPos]
                                [plot-pen-up]
   set-current-plot-pen "default"
   ifelse length listeOrNeg > 0 [plot stdDevNeg]
                                [plot-pen-up]
end
 

;;to update-plot
  ;; set-current-plot "replies"
  ;;   set-current-plot-pen "negative"
  ;;plot length negativeMessageBoard 
  ;;  set-current-plot-pen "positive"
  ;;plot length positiveMessageBoard  
;;end
@#$#@#$#@
GRAPHICS-WINDOW
509
56
999
567
16
16
14.55
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

INPUTBOX
6
10
81
70
nbAgents
200
1
0
Number

BUTTON
361
12
442
45
NIL
oneStep
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
871
10
991
43
influenceMu
influenceMu
0
1
0.1
0.1
1
NIL
HORIZONTAL

PLOT
9
159
480
347
average_orientations
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"average" 1.0 0 -16777216 false "" ""
"negative" 1.0 0 -6995700 true "" ""
"positive" 1.0 0 -13840069 true "" ""

BUTTON
246
10
344
43
NIL
initialize\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
536
11
628
44
l_acceptance
l_acceptance
0
2
1
0.1
1
NIL
HORIZONTAL

SLIDER
645
12
737
45
l_rejection
l_rejection
l_acceptance
2
1.9
0.1
1
NIL
HORIZONTAL

SWITCH
-1
73
102
106
exit?
exit?
0
1
-1000

SWITCH
0
115
103
148
entry?
entry?
0
1
-1000

PLOT
1001
301
1259
471
replies
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"negative" 1.0 0 -8053223 true "" "plot negative_replies"
"positive" 1.0 0 -15582384 true "" "plot positive_replies"

SLIDER
107
13
213
46
patience
patience
0
10
2
1
1
NIL
HORIZONTAL

PLOT
1015
136
1215
286
nbAgents
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -11085214 true "" "plot nbPositive"
"pen-1" 1.0 0 -955883 true "" "plot nbNegative"

SLIDER
319
59
491
92
rate_participation
rate_participation
2
100
10
1
1
NIL
HORIZONTAL

PLOT
11
367
485
556
stdev_orientations
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" ""
"pen-1" 1.0 0 -13840069 true "" ""
"pen-2" 1.0 0 -16514813 true "" ""

@#$#@#$#@
## WHAT IS IT?

This model accompanies the research article "Not all those who wander are lost: Modeling support and conflict over medical mediation in ana-mia online forums" by Antonio A. Casilli, Juliette Rouchier, and Paola Tubaro, under consideration for Revue Française de Sociologie (as of 16 August 2013).

The model investigates how social interactions may shift the balance between different orientations in self-moderated online patient communities. Specifically, it represents an online forum about eating disorders, where teenagers and young adults can discuss with peers in the same situation. Moral panic has surrounded these communities, often labelled “pro-ana” and considered as potentially powerful sources of negative influences, reinforcing or even inducing unhealthy behaviours. The model helps disentangle the complex dialectical relationship between radical viewpoints that resist or confront medical mediation, and pro-recovery attitudes.



## HOW IT WORKS

The model represents an online forum for persons with eating disorders. The View features a group of nodes (agents) and the environment within which they interact. Three elements compose the model:

1) an influence model, based on Jager and Amblard (2005), where each agent adjusts its orientation after contact with others:

Agents' orientations are defined on the [-1; +1] interval. We take positive values to represent pro-recovery attitudes (green in the main View in the model interface) and negative values to represent pro-ana orientations (orange).

Each agent has a “latitude of acceptance” (in [0 ; 1]) defining an interval within which other agents’ orientations can influence it positively (i.e. their orientations will get closer). It also has a "latitude of rejection" (also in [0; 1]) within which other agents influence it negatively (their orientations will diverge further). 

2) an interaction model of which agents interact with which other agents:

An interaction represents a topic thread, started when one randomly chosen agent sends an original message to the forum. Other members can reply (provided the content of the message falls within their acceptance or rejection intervals). Their reply will be supportive if they agree, and hostile otherwise. In either case, the reply is a message whose content expresses the replying agent’s orientation. The View represents this process graphically as a star network, centred on the initiator of the message, and in which links represent replies, each of the color of the sending agent (orange or green).

The "replies" plot represents the sequence of replies to messages, representing supportive replies in blue, and hostile ones in red.

3) a framework of participation representing the macro structure allowing to entry, contribute to, and exit from, a forum.

Only a proportion of forum members (determined by the rate_participation parameter) will reply to each message; the other members remain passive.  

If exit is authorized, agents that have received a majority of hostile replies for a given number of successive time steps (determined by the "patience" parameter) quit the system.

If entry is authorized, incoming agents are allowed in to replace exiting ones. They have random initial orientation. 


## HOW TO USE IT

User-defined parameters are:

- nbAgents determines the number of agents at initialization.

- Patience is the number of messages followed by a majority of negative feedbacks, after which the agent leaves.

- rate_participation is the proportion of agents that reply to a message - it is not a property of agents in this version, but a property of the system - from 2 to 100 %, counting that at least 1 agent always sends a message. So if the value is 10, each agent has 10 % chance of participating to the answer.  

- l_acceptance is the latitude of acceptance, and l_rejection is the latitude of rejection. Both are equal for all agents, while orientations are defined at individual level and may change throughout a simulation.

- influenceMu is the speed of influence, a property of the interaction setting.

- exit? enables the user to decide whether to keep the population fixed, or allow agents that have received too many negative replies to exit the system;

- entry? enables to user to decide whether to replace an exiting agent by a newcomer (with random orientation and the same latitudes of acceptance and rejection of the others).

- initialize creates the population and defines the basic properties of the forum.

- oneStep launches the simulation.



Monitors:

- average_orientations represents the average of pro-recovery orientations (green), of pro-ana ones (orange), and the total forum average (black).

- stdev_orientations represents the standard deviation of pro-recovery orientations (green), of pro-ana ones (orange), and the total forum average (black).


- nbAgents represents the size of the population throughout a simulation run, taking into account initial size as well as exits and entries (if authorized).

- replies represents supportive replies (blue) and hostile ones (red) over time, throughout a simulation run.



## CREDITS AND REFERENCES

The model has been programmed by Juliette Rouchier, with support from Antonio A. Casilli and Paola Tubaro, in September 2012 - March 2013.

This research is part of the project ‘Ana-Mia sociability: an online/offline social networks approach to eating disorders’ (ANAMIA), supported by Agence Nationale de la Recherche (grant ANR-09-ALIA-001). 

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
