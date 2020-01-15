;Assembled by Mos Phetheet and Mary Hill, University of Kansas

extensions [csv bitmap]

globals [
  cropland-patches aquifer-patches river-patches wind-bar solar-bar wind-patches solar-patches
  crop-area crop-color radius-of-%area total-area
  corn wheat soybean milo
  %local-energy %grid-energy
  image
  precip_raw precip thickness_inch current-elev
  corn-data corn-sum corn-price corn-yield_1 corn-irrig_1 corn-yield_2 corn-irrig_2 corn-yield_3 corn-irrig_3 corn-yield_4 corn-irrig_4 corn-expenses corn-annual-income_1
  wheat-data wheat-sum wheat-price wheat-yield_1 wheat-irrig_1 wheat-yield_2 wheat-irrig_2 wheat-yield_3 wheat-irrig_3 wheat-yield_4 wheat-irrig_4 wheat-expenses wheat-annual-income_1
  soybean-data soybean-sum soybean-price soybean-yield_1 soybean-irrig_1 soybean-yield_2 soybean-irrig_2 soybean-yield_3 soybean-irrig_3 soybean-yield_4 soybean-irrig_4 soybean-expenses soybean-annual-income_1
  milo-data milo-sum milo-price milo-yield_1 milo-irrig_1 milo-yield_2 milo-irrig_2 milo-yield_3 milo-irrig_3 milo-yield_4 milo-irrig_4 milo-expenses milo-annual-income_1
  corn-tot-income wheat-tot-income soybean-tot-income milo-tot-income
  corn-history wheat-history soybean-history milo-history
  corn-coverage wheat-coverage soybean-coverage milo-coverage
  corn-base-price wheat-base-price soybean-base-price milo-base-price
  corn-guarantee wheat-guarantee soybean-guarantee milo-guarantee
  mean-corn-yield mean-wheat-yield mean-soybean-yield mean-milo-yield
  annual-income_1 avg-annual-income_1
  corn-tot-yield wheat-tot-yield soybean-tot-yield milo-tot-yield
  corn-use-in wheat-use-in soybean-use-in milo-use-in water-use-feet gw-change
  consuming-patches
  #Solar_panels solar-production wind-production solar-cost solar-sell wind-cost wind-sell solar-net-income wind-net-income energy-net-income %Solar-production %Wind-production
  yrs-seq
  aquifer-at-risk
  zero-line
  area-multiplier
]

to setup
  ca
  import-data
  energy-calculation
  set zero-line 0
  set total-area (corn-area + wheat-area + soybean-area + milo-area)
  set current-elev 69
  set area-multiplier 3000
  set corn-coverage 0.75
  set wheat-coverage 0.7
  set soybean-coverage 0.7
  set milo-coverage 0.65
  set corn-base-price 4.12
  set wheat-base-price 6.94
  set soybean-base-price 9.39
  set milo-base-price 3.14

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; cropland patches ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set cropland-patches patches with [pxcor < 80]

  set image bitmap:import "center_pivot.jpg"
  bitmap:copy-to-pcolors image false

  ask patches with [pxcor > 65] [
    set pcolor black]

  ask patch -71 -97 [
    set plabel "Cropland"
    set plabel-color black
  ]

  set crop-color [37 22 36 34]

  set crop-area []
  set crop-area lput corn-area crop-area
  set crop-area lput wheat-area crop-area
  set crop-area lput soybean-area crop-area
  set crop-area lput milo-area crop-area

  set radius-of-%area []                                                                            ;crop areas are calculated as percentage of total
                                                                                                    ;radii showing in the world are calculated from % of crop areas
  let n 0
  let m 0
  foreach crop-area [ x ->
    set radius-of-%area lput sqrt ((x / (sum crop-area) * area-multiplier) / pi) radius-of-%area
  ]

  crt 4
  ask turtle 0 [setxy -1 0
    ask cropland-patches in-radius item 0 radius-of-%area [set pcolor item 0 crop-color]
    ask patch 6 -20 [
      set plabel "Corn"
    ]
    die]
  ask turtle 1 [setxy -18 84
    ask cropland-patches in-radius item 1 radius-of-%area [set pcolor item 1 crop-color]
    ask patch -9 63 [
      set plabel "Wheat"
      set plabel-color black
    ]
    die]
  ask turtle 2 [setxy -51.5 -51
    ask cropland-patches in-radius item 2 radius-of-%area [set pcolor item 2 crop-color]
    ask patch -39 -72 [
      set plabel "Soybean"
      set plabel-color black
    ]
    die]
  ask turtle 3 [setxy -52 16
    ask cropland-patches in-radius item 3 radius-of-%area [set pcolor item 3 crop-color]
    ask patch -46 -5 [
      set plabel "Milo"
    ]
    die]

  import-drawing "crop-symbol.png"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;; Aquifer patches ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set aquifer-patches patches with [pxcor > 66 and pxcor < 83 and pycor < 70]
  ask aquifer-patches [set pcolor blue]
  ask patch 79 -97 [set plabel "GW"]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;; River patches ;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set river-patches patches with [pxcor > 66 and pxcor < 83 and pycor > 70]
  ask river-patches [set pcolor 87]
  ask patch 78 96 [
    set plabel "SW"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;; Solar patches ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set %Solar-production (Solar-production * 100 / (Solar-production + Wind-production))
  set %Wind-production (Wind-production * 100 / (Solar-production + Wind-production))

  set solar-bar patches with [pxcor > 83]

  ask solar-bar with [pycor > (-100 + (2 * %Wind-production))] [
    set pcolor [255 165 0]]

  ask patch 93 96 [
    set plabel round (%Solar-production)
    set plabel-color black]
  ask patch 98 96 [
    set plabel "%"
    set plabel-color black]
  ask patch 99 90 [
    set plabel "Solar"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;; Wind patches ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set wind-bar patches with [pxcor > 83]

  ask wind-bar with [pycor < (-100 + (2 * %Wind-production))] [
    set pcolor yellow]

  ask patch 93 -91 [
    set plabel round (%Wind-production)
    set plabel-color black]
  ask patch 98 -91 [
    set plabel "%"
    set plabel-color black]
  ask patch 99 -97 [
    set plabel "Wind"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Wind icons ;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set wind-patches patches with [pxcor > 0 and pxcor < 65 and pycor < -35 and pycor > -100]
  let w 0
    repeat #wind_turbines [
      ifelse w < 2 [
        crt 1 [
        setxy (35 + (w * 22)) -97
        set shape "wind"
        set size (turbine_size * 30)
        set w (w + 1)]
      ]
        [ifelse w < 4 [
          crt 1 [
          setxy (25 + ((w - 2) * 22)) -65
          set shape "wind"
          set size (turbine_size * 30)
          set w (w + 1)]
         ]

         [crt 1 [
          setxy (35 + ((w - 4) * 22)) -31
          set shape "wind"
          set size (turbine_size * 30)
          set w (w + 1)]
          ]
       ]
     ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Solar icons ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set solar-patches patches with [pxcor > 0 and pxcor < 65 and pycor > 33 and pycor < 100]
  let t 0
    repeat #solar_panel_sets [
      ifelse t < 5 [
        crt 1 [
        setxy 56 (93 - (t * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]

      [ifelse t < 10 [
        crt 1 [
        setxy 37 (93 - ((t - 5) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]

      [crt 1 [
        setxy 18 (93 - ((t - 10) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
    ]
  ]
  initial_expenses
  reset-ticks
end

to go
  if ticks = Input-years [stop]
  recalculate
  calculate-expenses
  future_processes
  contaminant
  treatment
  tick
end

to import-data
  set precip []
  set precip_raw []
  set corn-data []
  set corn-sum []
  set corn-price []
  set corn-yield_1 []
  set corn-irrig_1 []
  set corn-yield_2 []
  set corn-irrig_2 []
  set corn-yield_3 []
  set corn-irrig_3 []
  set corn-yield_4 []
  set corn-irrig_4 []

  set wheat-data []
  set wheat-sum []
  set wheat-price []
  set wheat-yield_1 []
  set wheat-irrig_1 []
  set wheat-yield_2 []
  set wheat-irrig_2 []
  set wheat-yield_3 []
  set wheat-irrig_3 []
  set wheat-yield_4 []
  set wheat-irrig_4 []

  set soybean-data []
  set soybean-sum []
  set soybean-price []
  set soybean-yield_1 []
  set soybean-irrig_1 []
  set soybean-yield_2 []
  set soybean-irrig_2 []
  set soybean-yield_3 []
  set soybean-irrig_3 []
  set soybean-yield_4 []
  set soybean-irrig_4 []

  set milo-data []
  set milo-sum []
  set milo-price []
  set milo-yield_1 []
  set milo-irrig_1 []
  set milo-yield_2 []
  set milo-irrig_2 []
  set milo-yield_3 []
  set milo-irrig_3 []
  set milo-yield_4 []
  set milo-irrig_4 []

  set corn-data lput csv:from-file "1_Corn_inputs.csv" corn-data
  set wheat-data lput csv:from-file "2_Wheat_inputs.csv" wheat-data
  set soybean-data lput csv:from-file "3_Soybean_inputs.csv" soybean-data
  set milo-data lput csv:from-file "4_Milo_inputs.csv" milo-data

  let m 1

  while [m < 11] [
    foreach corn-data [x -> set corn-sum lput item m x corn-sum]
      foreach corn-sum [y -> set precip_raw lput item 1 y precip_raw]
      foreach corn-sum [y -> set corn-price lput item 2 y corn-price]
      foreach corn-sum [y -> set corn-yield_1 lput item 3 y corn-yield_1]
      foreach corn-sum [y -> set corn-irrig_1 lput item 4 y corn-irrig_1]
      foreach corn-sum [y -> set corn-yield_2 lput item 5 y corn-yield_2]
      foreach corn-sum [y -> set corn-irrig_2 lput item 6 y corn-irrig_2]
      foreach corn-sum [y -> set corn-yield_3 lput item 7 y corn-yield_3]
      foreach corn-sum [y -> set corn-irrig_3 lput item 8 y corn-irrig_3]
      foreach corn-sum [y -> set corn-yield_4 lput item 9 y corn-yield_4]
      foreach corn-sum [y -> set corn-irrig_4 lput item 10 y corn-irrig_4]
    foreach wheat-data [x -> set wheat-sum lput item m x wheat-sum]
      foreach wheat-sum [y -> set wheat-price lput item 2 y wheat-price]
      foreach wheat-sum [y -> set wheat-yield_1 lput item 3 y wheat-yield_1]
      foreach wheat-sum [y -> set wheat-irrig_1 lput item 4 y wheat-irrig_1]
      foreach wheat-sum [y -> set wheat-yield_2 lput item 5 y wheat-yield_2]
      foreach wheat-sum [y -> set wheat-irrig_2 lput item 6 y wheat-irrig_2]
      foreach wheat-sum [y -> set wheat-yield_3 lput item 7 y wheat-yield_3]
      foreach wheat-sum [y -> set wheat-irrig_3 lput item 8 y wheat-irrig_3]
      foreach wheat-sum [y -> set wheat-yield_4 lput item 9 y wheat-yield_4]
      foreach wheat-sum [y -> set wheat-irrig_4 lput item 10 y wheat-irrig_4]
    foreach soybean-data [x -> set soybean-sum lput item m x soybean-sum]
      foreach soybean-sum [y -> set soybean-price lput item 2 y soybean-price]
      foreach soybean-sum [y -> set soybean-yield_1 lput item 3 y soybean-yield_1]
      foreach soybean-sum [y -> set soybean-irrig_1 lput item 4 y soybean-irrig_1]
      foreach soybean-sum [y -> set soybean-yield_2 lput item 5 y soybean-yield_2]
      foreach soybean-sum [y -> set soybean-irrig_2 lput item 6 y soybean-irrig_2]
      foreach soybean-sum [y -> set soybean-yield_3 lput item 7 y soybean-yield_3]
      foreach soybean-sum [y -> set soybean-irrig_3 lput item 8 y soybean-irrig_3]
      foreach soybean-sum [y -> set soybean-yield_4 lput item 9 y soybean-yield_4]
      foreach soybean-sum [y -> set soybean-irrig_4 lput item 10 y soybean-irrig_4]
    foreach milo-data [x -> set milo-sum lput item m x milo-sum]
      foreach milo-sum [y -> set milo-price lput item 2 y milo-price]
      foreach milo-sum [y -> set milo-yield_1 lput item 3 y milo-yield_1]
      foreach milo-sum [y -> set milo-irrig_1 lput item 4 y milo-irrig_1]
      foreach milo-sum [y -> set milo-yield_2 lput item 5 y milo-yield_2]
      foreach milo-sum [y -> set milo-irrig_2 lput item 6 y milo-irrig_2]
      foreach milo-sum [y -> set milo-yield_3 lput item 7 y milo-yield_3]
      foreach milo-sum [y -> set milo-irrig_3 lput item 8 y milo-irrig_3]
      foreach milo-sum [y -> set milo-yield_4 lput item 9 y milo-yield_4]
      foreach milo-sum [y -> set milo-irrig_4 lput item 10 y milo-irrig_4]

    if length precip_raw != 10 [set precip_raw []]

    if length corn-price != 10 [set corn-price []]
    if length corn-yield_1 != 10 [set corn-yield_1 []]
    if length corn-irrig_1 != 10 [set corn-irrig_1 []]
    if length corn-yield_2 != 10 [set corn-yield_2 []]
    if length corn-irrig_2 != 10 [set corn-irrig_2 []]
    if length corn-yield_3 != 10 [set corn-yield_3 []]
    if length corn-irrig_3 != 10 [set corn-irrig_3 []]
    if length corn-yield_4 != 10 [set corn-yield_4 []]
    if length corn-irrig_4 != 10 [set corn-irrig_4 []]

    if length wheat-price != 10 [set wheat-price []]
    if length wheat-yield_1 != 10 [set wheat-yield_1 []]
    if length wheat-irrig_1 != 10 [set wheat-irrig_1 []]
    if length wheat-yield_2 != 10 [set wheat-yield_2 []]
    if length wheat-irrig_2 != 10 [set wheat-irrig_2 []]
    if length wheat-yield_3 != 10 [set wheat-yield_3 []]
    if length wheat-irrig_3 != 10 [set wheat-irrig_3 []]
    if length wheat-yield_4 != 10 [set wheat-yield_4 []]
    if length wheat-irrig_4 != 10 [set wheat-irrig_4 []]

    if length soybean-price != 10 [set soybean-price []]
    if length soybean-yield_1 != 10 [set soybean-yield_1 []]
    if length soybean-irrig_1 != 10 [set soybean-irrig_1 []]
    if length soybean-yield_2 != 10 [set soybean-yield_2 []]
    if length soybean-irrig_2 != 10 [set soybean-irrig_2 []]
    if length soybean-yield_3 != 10 [set soybean-yield_3 []]
    if length soybean-irrig_3 != 10 [set soybean-irrig_3 []]
    if length soybean-yield_4 != 10 [set soybean-yield_4 []]
    if length soybean-irrig_4 != 10 [set soybean-irrig_4 []]

    if length milo-price != 10 [set milo-price []]
    if length milo-yield_1 != 10 [set milo-yield_1 []]
    if length milo-irrig_1 != 10 [set milo-irrig_1 []]
    if length milo-yield_2 != 10 [set milo-yield_2 []]
    if length milo-irrig_2 != 10 [set milo-irrig_2 []]
    if length milo-yield_3 != 10 [set milo-yield_3 []]
    if length milo-irrig_3 != 10 [set milo-irrig_3 []]
    if length milo-yield_4 != 10 [set milo-yield_4 []]
    if length milo-irrig_4 != 10 [set milo-irrig_4 []]
    set m (m + 1)

    set precip map [? -> ? * 1] precip_raw
  ]

  set corn-history corn-yield_1
  set wheat-history wheat-yield_1
  set soybean-history soybean-yield_1
  set milo-history milo-yield_1

  show corn-history
end

to initial_expenses
  if (item 0 corn-yield_1) < 195 [set corn-expenses (617.38 * corn-area)]
  if (item 0 corn-yield_1 >= 195) and (item 0 corn-yield_1 < 250) [set corn-expenses (671.06 * corn-area)]
  if (item 0 corn-yield_1 >= 250) [set corn-expenses (714.18 * corn-area)]

  if (item 0 wheat-yield_1) < 60 [set wheat-expenses (513.76 * wheat-area)]
  if (item 0 wheat-yield_1 >= 60) and (item 0 wheat-yield_1 < 70) [set corn-expenses (540.65 * wheat-area)]
  if (item 0 wheat-yield_1 >= 70) [set wheat-expenses (567.53 * wheat-area)]

  if (item 0 soybean-yield_1) < 55 [set soybean-expenses (558.17 * soybean-area)]
  if (item 0 soybean-yield_1 >= 55) and (item 0 soybean-yield_1 < 67) [set soybean-expenses (590.41 * soybean-area)]
  if (item 0 soybean-yield_1 >= 67) [set soybean-expenses (642.54 * soybean-area)]

  if (item 0 milo-yield_1) < 140 [set milo-expenses (631.96 * milo-area)]
  if (item 0 milo-yield_1 >= 140) and (item 0 milo-yield_1 < 180) [set milo-expenses (681.41 * milo-area)]
  if (item 0 milo-yield_1 >= 180) [set milo-expenses (730.87 * milo-area)]
end

to calculate-expenses
  if (item (ticks mod 10) corn-yield_1) < 195 [set corn-expenses (617.38 * corn-area)]
  if (item (ticks mod 10) corn-yield_1 >= 195) and (item (ticks mod 10) corn-yield_1 < 250) [set corn-expenses (671.06 * corn-area)]
  if (item (ticks mod 10) corn-yield_1 >= 250) [set corn-expenses (714.18 * corn-area)]

  if (item (ticks mod 10) wheat-yield_1) < 60 [set wheat-expenses (513.76 * wheat-area)]
  if (item (ticks mod 10) wheat-yield_1 >= 60) and (item (ticks mod 10) wheat-yield_1 < 70) [set corn-expenses (540.65 * wheat-area)]
  if (item (ticks mod 10) wheat-yield_1 >= 70) [set wheat-expenses (567.53 * wheat-area)]

  if (item (ticks mod 10) soybean-yield_1) < 55 [set soybean-expenses (558.17 * soybean-area)]
  if (item (ticks mod 10) soybean-yield_1 >= 55) and (item (ticks mod 10) soybean-yield_1 < 67) [set soybean-expenses (590.41 * soybean-area)]
  if (item (ticks mod 10) soybean-yield_1 >= 67) [set soybean-expenses (642.54 * soybean-area)]

  if (item (ticks mod 10) milo-yield_1) < 140 [set milo-expenses (631.96 * milo-area)]
  if (item (ticks mod 10) milo-yield_1 >= 140) and (item (ticks mod 10) milo-yield_1 < 180) [set milo-expenses (681.41 * milo-area)]
  if (item (ticks mod 10) milo-yield_1 >= 180) [set milo-expenses (730.87 * milo-area)]
end

to future_processes
if Future_Process = "Repeat Historical"
   [ ifelse ticks <= 9                             ;tick starts from 0
       [food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -66
         [food-calculation_1-2
          energy-calculation
          gw-depletion_1]

         [dryland-farming_1
          energy-calculation]
       ]
    ]

  if Future_Process = "Wetter Years"
    [ ifelse ticks <= 9                             ;tick starts from 0
       [food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -66
          [food-calculation_2
           energy-calculation
           gw-depletion_2]

          [dryland-farming_2
           energy-calculation]
       ]
    ]

  if Future_Process = "Dryer Years"
    [ ifelse ticks <= 9                             ;tick starts from 0
       [food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -66
          [food-calculation_3
           energy-calculation
           gw-depletion_3]

          [dryland-farming_3
           energy-calculation]
       ]
    ]

  if Future_Process = "Climate Projection"
    [ ifelse ticks <= 9                             ;tick starts from 0
       [food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -66
          [food-calculation_4
           energy-calculation
           gw-depletion_4]

          [dryland-farming_4
           energy-calculation]
       ]
    ]
end

to food-calculation_1-1                                                                ; Wade Heger, Allan Andales CSU (Allan.Andales@colostate.edu) , Garvey Smith (Garvey.Smith@colostate.edu)
  let n (ticks)

  set corn-tot-income (item n corn-yield_1 * item n corn-price * corn-area)
  set wheat-tot-income (item n wheat-yield_1 * item n wheat-price * wheat-area)
  set soybean-tot-income (item n soybean-yield_1 * item n soybean-price * soybean-area)
  set milo-tot-income (item n milo-yield_1 * item n milo-price * milo-area)

  set corn-tot-yield (item n corn-yield_1)
  set wheat-tot-yield (item n wheat-yield_1)
  set soybean-tot-yield (item n soybean-yield_1)
  set milo-tot-yield (item n milo-yield_1)
end

to food-calculation_1-2
  let n (ticks)

  set corn-tot-yield (item (n mod 10) corn-yield_1)
  set wheat-tot-yield (item (n mod 10) wheat-yield_1)
  set soybean-tot-yield (item (n mod 10) soybean-yield_1)
  set milo-tot-yield (item (n mod 10) milo-yield_1)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (n mod 10) corn-yield_1 * item (n mod 10) corn-price * corn-area)
  set wheat-tot-income (item (n mod 10) wheat-yield_1 * item (n mod 10) wheat-price * wheat-area)
  set soybean-tot-income (item (n mod 10) soybean-yield_1 * item (n mod 10) soybean-price * soybean-area)
  set milo-tot-income (item (n mod 10) milo-yield_1 * item (n mod 10) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]  ;tick stats from 0, so tick 0 = year 2008

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income
end

to food-calculation_2

  if (ticks mod 10) = 0
  [ set yrs-seq [0 9 9 9 9 0 6 7 8 9]
    set yrs-seq shuffle yrs-seq
  ]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_1)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]  ;tick stats from 0, so tick 0 = year 2008

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income
end

to food-calculation_3

  if (ticks mod 10) = 0
  [ set yrs-seq [4 1 2 3 4 5 6 4 5 6]
    set yrs-seq shuffle yrs-seq]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_1)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income
end

to food-calculation_4

  if (ticks mod 10) = 0
  [ set yrs-seq [0 1 2 3 4 5 6 7 8 9]
    set yrs-seq shuffle yrs-seq]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_3)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_3)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_3)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_3)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_3 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_3 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_3 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_3 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income
end

to dryland-farming_1
  let n (ticks)

  set corn-tot-income (item (n mod 10) corn-yield_2 * item (n mod 10) corn-price * corn-area)
  set wheat-tot-income (item (n mod 10) wheat-yield_2 * item (n mod 10) wheat-price * wheat-area)
  set soybean-tot-income (item (n mod 10) soybean-yield_2 * item (n mod 10) soybean-price * soybean-area)
  set milo-tot-income (item (n mod 10) milo-yield_2 * item (n mod 10) milo-price * milo-area)

  set corn-tot-yield (item (n mod 10) corn-yield_2)
  set wheat-tot-yield (item (n mod 10) wheat-yield_2)
  set soybean-tot-yield (item (n mod 10) soybean-yield_2)
  set milo-tot-yield (item (n mod 10) milo-yield_2)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]  ;tick stats from 0, so tick 0 = year 2008

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2
  set wheat-use-in item (k mod 10) wheat-irrig_2
  set soybean-use-in item (k mod 10) soybean-irrig_2
  set milo-use-in item (k mod 10) milo-irrig_2
end

to dryland-farming_2
  if (ticks mod 10) = 0
  [ set yrs-seq [0 9 9 9 9 0 6 7 8 9]
    set yrs-seq shuffle yrs-seq]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_2)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2
  set wheat-use-in item (k mod 10) wheat-irrig_2
  set soybean-use-in item (k mod 10) soybean-irrig_2
  set milo-use-in item (k mod 10) milo-irrig_2
end

to dryland-farming_3
  if (ticks mod 10) = 0
  [ set yrs-seq [4 1 2 3 4 5 6 4 5 6]
    set yrs-seq shuffle yrs-seq]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_2)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2
  set wheat-use-in item (k mod 10) wheat-irrig_2
  set soybean-use-in item (k mod 10) soybean-irrig_2
  set milo-use-in item (k mod 10) milo-irrig_2
end

to dryland-farming_4
  if (ticks mod 10) = 0
  [ set yrs-seq [0 9 9 9 9 0 6 7 8 9]
    set yrs-seq shuffle yrs-seq]

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_4)
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_4)
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_4)
  set milo-tot-yield (item (item n yrs-seq) milo-yield_4)

  set corn-history lput corn-tot-yield but-first corn-history
  set wheat-history lput wheat-tot-yield but-first wheat-history
  set soybean-history lput soybean-tot-yield but-first soybean-history
  set milo-history lput milo-tot-yield but-first milo-history

  ;show corn-history

  set mean-corn-yield mean corn-history
  set mean-wheat-yield mean wheat-history
  set mean-soybean-yield mean soybean-history
  set mean-milo-yield mean milo-history

  ;show mean-corn-yield

  set corn-guarantee ((mean-corn-yield * corn-coverage * corn-base-price) * corn-area)
  set wheat-guarantee ((mean-wheat-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((mean-soybean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((mean-milo-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_4 * item (item n yrs-seq) corn-price * corn-area)
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_4 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_4 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_4 * item (item n yrs-seq) milo-price * milo-area)

  ;show corn-tot-income
  ;show corn-guarantee

  ifelse corn-tot-income > corn-guarantee
    [set corn-tot-income corn-tot-income]
    [set corn-tot-income corn-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]

  ifelse wheat-tot-income > wheat-guarantee
    [set wheat-tot-income wheat-tot-income]
    [set wheat-tot-income wheat-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]

  ifelse soybean-tot-income > soybean-guarantee
    [set soybean-tot-income soybean-tot-income]
    [set soybean-tot-income soybean-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]

  ifelse milo-tot-income > milo-guarantee
    [set milo-tot-income milo-tot-income]
    [set milo-tot-income milo-guarantee
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]

  ;show corn-tot-income

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_4
  set wheat-use-in item (k mod 10) wheat-irrig_4
  set soybean-use-in item (k mod 10) soybean-irrig_4
  set milo-use-in item (k mod 10) milo-irrig_4
end

to energy-calculation                                                                ; Bob Johnson (bobjohnson@centurylink.net), Earnie Lehman (earnielehman@gmail.com)
  set #Solar_panels (#solar_panel_sets * 1000)
  set solar-production (#Solar_Panels * Panel_power * 5 * 365 / 1000000)             ; MWh = power(Watt) * 5hrs/day * 365days/year / 1000000
  set wind-production (#wind_turbines * Turbine_size * 0.425 * 24 * 365)             ; MWh = power(MW) * Kansas_wind_capacity * 24hrs/day * 365days/year                          ;45% (Bob)
  set solar-cost (#Solar_Panels * Panel_power / 1000 * 3050)                         ; Solar cost = #Solar_Panels * Panel_power * $3050/kW
  set solar-sell (solar-production * 38)                                             ; Sell = MWh * $38/MWh                         --> (Wholesale was $22-24/MWh, Retail price is $105/MWh (**reference))
                                                                                     ; Wholesale < Coop $65 < Retail
  set wind-cost (((3000000 / 30) + 100000)) * #wind_turbines                         ; For 2MW wind turbine, Wind cost = 3000000/30 + (300000 maintenance/yr) * #wind_turbines  ??????check
  set wind-sell (wind-production * 38)                                               ; Sell = MWh * $38/MWh
  set solar-net-income (solar-sell - (solar-cost / 30))                              ; assuming the cost spreads over 30 years with no interest or maintenance
  set wind-net-income  (wind-sell - (wind-cost))                                     ; assuming the cost spreads over 30 years with no interest or maintenance
  set energy-net-income (solar-net-income + wind-net-income)
end

to gw-depletion_1
  let k ticks

  set corn-use-in item (k mod 10) corn-irrig_1
  set wheat-use-in item (k mod 10) wheat-irrig_1
  set soybean-use-in item (k mod 10) soybean-irrig_1
  set milo-use-in item (k mod 10) milo-irrig_1

  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-8.6628 * water-use-feet) + 8.4722)

  set consuming-patches (gw-change * 170 / (aquifer-thickness))

  if current-elev > 69 [set consuming-patches 0]

  ifelse consuming-patches < 0
    [ask aquifer-patches with [pycor > (current-elev + (consuming-patches))] [
      set pcolor 7]         ;gray
    ]
    [ask aquifer-patches with [pycor < (current-elev + (consuming-patches))] [
      set pcolor 105]       ;blue
    ]

  set current-elev (current-elev + consuming-patches)

  if current-elev < -66 [
    ask aquifer-patches with [pycor < current-elev] [
      set pcolor 14]
  ]
end

to gw-depletion_2
  let k (ticks mod 10)
  set corn-use-in item (item k yrs-seq) corn-irrig_1
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1
  set soybean-use-in item (item k yrs-seq) soybean-irrig_1
  set milo-use-in item (item k yrs-seq) milo-irrig_1

  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-8.6628 * water-use-feet) + 8.4722)

  set consuming-patches (gw-change * 170 / (aquifer-thickness))

  if current-elev > 69 [set consuming-patches 0]

  ifelse consuming-patches < 0
    [ask aquifer-patches with [pycor > (current-elev + (consuming-patches))] [
      set pcolor 7]         ;gray
    ]
    [ask aquifer-patches with [pycor < (current-elev + (consuming-patches))] [
      set pcolor 105]       ;blue
    ]

  set current-elev (current-elev + consuming-patches)

  if current-elev < -66 [
    ask aquifer-patches with [pycor < current-elev] [
      set pcolor 14]
  ]
end

to gw-depletion_3
  let k (ticks mod 10)
  set corn-use-in item (item k yrs-seq) corn-irrig_1
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1
  set soybean-use-in item (item k yrs-seq) soybean-irrig_1
  set milo-use-in item (item k yrs-seq) milo-irrig_1

  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-8.6628 * water-use-feet) + 8.4722)

  set consuming-patches (gw-change * 170 / (aquifer-thickness))

  if current-elev > 69 [set consuming-patches 0]

  ifelse consuming-patches < 0
    [ask aquifer-patches with [pycor > (current-elev + (consuming-patches))] [
      set pcolor 7]         ;gray
    ]
    [ask aquifer-patches with [pycor < (current-elev + (consuming-patches))] [
      set pcolor 105]       ;blue
    ]

  set current-elev (current-elev + consuming-patches)

  if current-elev < -66 [
    ask aquifer-patches with [pycor < current-elev] [
      set pcolor 14]
  ]
end

to gw-depletion_4
  let k (ticks mod 10)
  set corn-use-in item (item k yrs-seq) corn-irrig_3
  set wheat-use-in item (item k yrs-seq) wheat-irrig_3
  set soybean-use-in item (item k yrs-seq) soybean-irrig_3
  set milo-use-in item (item k yrs-seq) milo-irrig_3

  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-8.6628 * water-use-feet) + 8.4722)

  set consuming-patches (gw-change * 170 / (aquifer-thickness))

  if current-elev > 69 [set consuming-patches 0]

  ifelse consuming-patches < 0
    [ask aquifer-patches with [pycor > (current-elev + (consuming-patches))] [
      set pcolor 7]         ;gray
    ]
    [ask aquifer-patches with [pycor < (current-elev + (consuming-patches))] [
      set pcolor 105]       ;blue
    ]

  set current-elev (current-elev + consuming-patches)

  if current-elev < -66 [
    ask aquifer-patches with [pycor < current-elev] [
      set pcolor 14]
  ]
end

to contaminant
  if random 2 = 1 [
    ask n-of 3 river-patches with [pcolor = 87] [set pcolor brown]
    if any? river-patches with [pcolor = brown][
      ask one-of river-patches [
      set pcolor 87]
    ]
  ]
end

to treatment
  if random 10 = 1 [
  ask river-patches [
  if any? river-patches with [pcolor = brown] [
    ask one-of river-patches with [pcolor = brown] [
    set pcolor 87]
    ]
   ]
  ]
end

to recalculate
  ask turtles [die]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Wind icons ;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set wind-patches patches with [pxcor > 0 and pxcor < 65 and pycor < -35 and pycor > -100]
  let w 0

    repeat #wind_turbines [
      ifelse w < 2 [
        crt 1 [
        setxy (35 + (w * 22)) -97
        set shape "wind"
        set size (turbine_size * 30)
        set w (w + 1)]
      ]
        [ifelse w < 4 [
          crt 1 [
          setxy (25 + ((w - 2) * 22)) -65
          set shape "wind"
          set size (turbine_size * 30)
          set w (w + 1)]
         ]

         [crt 1 [
          setxy (35 + ((w - 4) * 22)) -31
          set shape "wind"
          set size (turbine_size * 30)
          set w (w + 1)]
          ]
       ]
       ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Solar icons ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set solar-patches patches with [pxcor > 0 and pxcor < 65 and pycor > 33 and pycor < 100]
  let t 0
    repeat #solar_panel_sets [

      ifelse t < 5 [
        crt 1 [
        setxy 56 (93 - (t * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]

      [ifelse t < 10 [
        crt 1 [
        setxy 37 (93 - ((t - 5) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]

      [crt 1 [
        setxy 18 (93 - ((t - 10) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
    ]
  ]

  set solar-production (#Solar_Panels * Panel_power * 5 * 365 / 1000000)            ; MWh = power(Watt) * 5hrs/day * 365days/year / 1000000
  set wind-production (#wind_turbines * Turbine_size * 0.425 * 24 * 365)            ; MWh = power(MW) * Kansas_wind_capacity * 24hrs/day * 365days/year                          ;45% (Bob)
  set %Solar-production (Solar-production * 100 / (Solar-production + Wind-production))
  set %Wind-production (Wind-production * 100 / (Solar-production + Wind-production))

  ask patch 93 -91 [
    set plabel round (%Wind-production)
    set plabel-color black]

  set solar-bar patches with [pxcor > 83]
    ask solar-bar with [pycor > (-100 + (2 * %Wind-production))] [
    set pcolor [255 165 0]]

  ask patch 93 96 [
    set plabel round (%Solar-production)
    set plabel-color black]

  set wind-bar patches with [pxcor > 83]
    ask wind-bar with [pycor < (-100 + (2 * %Wind-production))] [
    set pcolor yellow]
end
@#$#@#$#@
GRAPHICS-WINDOW
358
33
815
491
-1
-1
2.234
1
14
1
1
1
0
0
0
1
-100
100
-100
100
0
0
1
Years
30.0

BUTTON
8
10
74
43
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
6
134
80
194
Corn-area
125.0
1
0
Number

INPUTBOX
83
134
157
194
Wheat-area
125.0
1
0
Number

INPUTBOX
160
134
242
194
Soybean-area
125.0
1
0
Number

INPUTBOX
245
134
319
194
Milo-area
125.0
1
0
Number

INPUTBOX
7
49
81
109
Input-years
60.0
1
0
Number

TEXTBOX
7
114
344
138
Agriculture --------------------------------\n
13
63.0
1

PLOT
1122
176
1406
296
Ag Net Income
Years
$
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 58" ""
PENS
"Corn" 1.0 0 -4079321 true "" "plot (corn-tot-income - corn-expenses)"
"Wheat" 1.0 0 -3844592 true "" "plot (wheat-tot-income - wheat-expenses)"
"Soybean" 1.0 0 -13210332 true "" "plot (soybean-tot-income - soybean-expenses)"
"Milo" 1.0 0 -12440034 true "" "plot (milo-tot-income - milo-expenses)"
"$0" 1.0 2 -8053223 true "" "plot zero-line"

BUTTON
76
10
158
43
Go once
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
6
390
344
409
Water -------------------------------------
13
95.0
1

TEXTBOX
6
215
345
235
Energy ------------------------------------
13
25.0
1

SWITCH
1038
782
1157
815
Fill_deficit
Fill_deficit
0
1
-1000

PLOT
1122
34
1406
154
Crop Groundwater Irrigation
Years
Inches
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 88" ""
PENS
"Corn" 1.0 0 -4079321 true "" "plot corn-use-in"
"Wheat" 1.0 0 -3844592 true "" "plot wheat-use-in"
"Soybean" 1.0 0 -13210332 true "" "plot soybean-use-in"
"Milo" 1.0 0 -12440034 true "" "plot milo-use-in"

PLOT
835
176
1119
296
Crop Production
Years
Bu/ac
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 58" ""
PENS
"Corn" 1.0 0 -4079321 true "" "plot corn-tot-yield"
"Wheat" 1.0 0 -3844592 true "" "plot wheat-tot-yield"
"Soybean" 1.0 0 -13210332 true "" "plot soybean-tot-yield"
"Milo" 1.0 0 -12440034 true "" "plot milo-tot-yield"

BUTTON
161
10
224
43
NIL
Go
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
1161
781
1294
814
Turbine_size
Turbine_size
0
3
2.0
0.1
1
MW
HORIZONTAL

SLIDER
71
351
213
384
#Wind_turbines
#Wind_turbines
0
6
2.0
1
1
NIL
HORIZONTAL

SLIDER
85
49
274
82
Aquifer-thickness
Aquifer-thickness
0
300
250.0
10
1
Feet
HORIZONTAL

SLIDER
71
289
213
322
Panel_power
Panel_power
0
300
250.0
10
1
Watts
HORIZONTAL

TEXTBOX
71
237
204
255
1 set = 1000 panels
11
0.0
1

SLIDER
71
253
213
286
#Solar_Panel_Sets
#Solar_Panel_Sets
0
8
3.0
1
1
NIL
HORIZONTAL

MONITOR
219
253
324
298
Total Solar Panels
#Solar_panels
17
1
11

MONITOR
87
715
228
760
solar-production (MWh)
round solar-production
17
1
11

MONITOR
87
784
228
829
Wind-production (MWh)
round Wind-production
17
1
11

MONITOR
234
715
319
760
solar-cost ($)
solar-cost
17
1
11

MONITOR
489
715
616
760
solar-sell ($ per year)
solar-sell
17
1
11

MONITOR
234
784
319
829
wind-cost ($)
wind-cost
17
1
11

MONITOR
489
784
615
829
wind-sell ($ per year)
round wind-sell
17
1
11

MONITOR
325
715
483
760
Solar-cost / 30 ($ per year)
round (Solar-cost / 30)
17
1
11

MONITOR
325
784
484
829
wind-cost / 30 ($ per year)
wind-cost / 30
17
1
11

MONITOR
621
785
730
830
wind-net-income
round wind-net-income
17
1
11

MONITOR
621
715
730
760
solar-net-income
round solar-net-income
17
1
11

TEXTBOX
7
197
233
223
Circles show proportional crop areas (acres)
10
0.0
1

PLOT
835
319
1119
439
Farm Energy Production
Years
MWh
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 28" ""
PENS
"Solar      " 1.0 0 -5298144 true "" "ifelse ticks = 0 [set solar-production 0\nplot solar-production]\n[plot solar-production]"
"Wind      " 1.0 0 -14070903 true "" "ifelse ticks = 0 [set wind-production 0\nplot wind-production]\n[plot wind-production]"

TEXTBOX
88
695
238
713
Solar outputs
11
0.0
1

TEXTBOX
89
767
239
785
Wind outputs
11
0.0
1

TEXTBOX
5
445
350
475
Climate Scenario -----------------------------------
12
0.0
1

CHOOSER
69
466
240
511
Future_Process
Future_Process
"Repeat Historical" "Wetter Years" "Dryer Years" "Climate Projection"
0

TEXTBOX
71
335
184
353
2-MW Wind Turbine
11
0.0
1

PLOT
835
34
1119
154
Total Net Income
Years
$
0.0
60.0
0.0
10.0
true
true
"" ""
PENS
"Crop" 1.0 0 -12087248 true "" "ifelse ticks = 0 [set corn-expenses 0\nset wheat-expenses 0\nset soybean-expenses 0\nset milo-expenses 0]\n[plot (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybean-tot-income - soybean-expenses) + (milo-tot-income - milo-expenses)]"
"Energy  " 1.0 0 -955883 true "" "ifelse ticks = 0 [set energy-net-income 0\nplot energy-net-income]\n[plot energy-net-income]"
"All" 1.0 0 -16777216 true "" "ifelse ticks = 0 [set energy-net-income 0\nplot (energy-net-income) + (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybean-tot-income - soybean-expenses) + (milo-tot-income - milo-expenses)]\n[plot (energy-net-income) + (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybean-tot-income - soybean-expenses) + (milo-tot-income - milo-expenses)]"
"$0" 1.0 2 -8053223 true "" "plot zero-line"

TEXTBOX
5
334
42
362
• Wind
11
25.0
1

TEXTBOX
7
238
47
256
• Solar
11
25.0
1

PLOT
1122
319
1406
439
Energy Income
Years
$
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 28" ""
PENS
"Solar      " 1.0 0 -5298144 true "" "ifelse ticks = 0 [set solar-net-income 0\nplot (solar-net-income)]\n[plot (solar-net-income)]"
"Wind" 1.0 0 -14070903 true "" "ifelse ticks = 0 [set wind-net-income 0\nplot (wind-net-income)]\n[plot (wind-net-income)]"

TEXTBOX
836
156
1413
179
Agriculture ------------------------------------------------------
15
63.0
1

TEXTBOX
834
298
1413
317
Energy ----------------------------------------------------------
15
25.0
1

TEXTBOX
1121
13
1403
33
Water --------------------------
15
95.0
1

TEXTBOX
835
443
1407
478
*First 10 years use historical data from 2008 to 2017 and subsequent years apply Future Process
12
5.0
1

TEXTBOX
71
407
342
437
Water is assumed to come from groundwater pumping. Effects on water quality are represented.
11
0.0
1

MONITOR
357
10
478
55
NIL
current-elev
3
1
11

MONITOR
357
111
477
156
NIL
consuming-patches
3
1
11

MONITOR
357
61
478
106
NIL
gw-change
3
1
11

MONITOR
248
10
353
55
NIL
water-use-feet
3
1
11

@#$#@#$#@
## WHAT IS IT?

![Estimated Usable Lifetime](file:HPA_Lifetime.jpg)

![Wind Map](file:Wind_Map.jpg)

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

### Data Sources

#### Agriculture

#### Energy

#### Water
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

solar
false
1
Rectangle -1184463 true false 30 75 270 225
Line -16777216 false 90 75 90 225
Line -16777216 false 30 105 270 105
Line -16777216 false 30 135 270 135
Line -16777216 false 30 165 270 165
Line -16777216 false 30 195 270 195
Line -16777216 false 150 75 150 225
Line -16777216 false 210 75 210 225
Rectangle -16777216 false false 30 75 270 225

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

wind
false
3
Circle -1 true false 141 36 18
Polygon -1184463 true false 149 -28 141 30 150 26 159 30
Polygon -1 true false 147 53 153 53 160 150 141 150
Polygon -1184463 true false 153 58 164 54 165 44 202 82
Polygon -1184463 true false 147 58 136 54 135 44 98 82
Polygon -16777216 false false 165 44 202 82 153 58 164 55
Polygon -16777216 false false 135 44 98 82 147 58 136 55
Polygon -16777216 false false 141 30 149 -29 160 31 150 25

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
NetLogo 6.1.1
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
