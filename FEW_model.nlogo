;Assembled by Mos Phetheet and Mary Hill, University of Kansas

extensions [csv bitmap]

globals [
  cropland-patches aquifer-patches river-patches wind-bar solar-bar wind-patches solar-patches corn-patches
  crop-area crop-color radius-of-%area total-area area-multiplier crop-background
  precip_raw current-elev patch-change yrs-seq zero-line turbine_size
  corn-data corn-sum corn-price corn-yield_1 corn-irrig_1 corn-yield_2 corn-irrig_2 corn-yield_3 corn-irrig_3 corn-yield_4 corn-irrig_4
  wheat-data wheat-sum wheat-price wheat-yield_1 wheat-irrig_1 wheat-yield_2 wheat-irrig_2 wheat-yield_3 wheat-irrig_3 wheat-yield_4 wheat-irrig_4
  soybean-data soybean-sum soybean-price soybean-yield_1 soybean-irrig_1 soybean-yield_2 soybean-irrig_2 soybean-yield_3 soybean-irrig_3 soybean-yield_4 soybean-irrig_4
  milo-data milo-sum milo-price milo-yield_1 milo-irrig_1 milo-yield_2 milo-irrig_2 milo-yield_3 milo-irrig_3 milo-yield_4 milo-irrig_4
  corn-expenses wheat-expenses soybean-expenses milo-expenses
  corn-tot-income wheat-tot-income soybean-tot-income milo-tot-income
  corn-net-income wheat-net-income soybean-net-income milo-net-income
  corn-history wheat-history soybean-history milo-history
  corn-coverage wheat-coverage soybean-coverage milo-coverage
  corn-base-price wheat-base-price soybean-base-price milo-base-price
  corn-guarantee wheat-guarantee soybean-guarantee milo-guarantee
  corn-mean-yield wheat-mean-yield soybean-mean-yield milo-mean-yield
  corn-tot-yield wheat-tot-yield soybean-tot-yield milo-tot-yield
  corn-use-in wheat-use-in soybean-use-in milo-use-in water-use-feet gw-change
  corn-N-app wheat-N-app soybean-N-app milo-N-app N-accu
  corn-N-use wheat-N-use soybean-N-use milo-N-use
  corn-N-use_1 wheat-N-use_1 soybean-N-use_1 milo-N-use_1
  corn-N-use_2 wheat-N-use_2 soybean-N-use_2 milo-N-use_2
  corn-N-use_3 wheat-N-use_3 soybean-N-use_3 milo-N-use_3
  corn-N-use_4 wheat-N-use_4 soybean-N-use_4 milo-N-use_4
  #Solar_panels solar-production wind-production solar-cost solar-sell wind-cost wind-sell solar-net-income wind-net-income energy-net-income %Solar-production %Wind-production
]

to setup
  ca                                                                                                ;Clear all
  import-data                                                                                       ;Import data from csv file in the FEWCalc folder
  set turbine_size 2                                                                                ;Set wind turbine size 2MW (change this value will affect installation and O&M costs
  energy-calculation                                                                                ;Initialize the amount of energy
  set zero-line 0                                                                                   ;Use to draw a zero line in plots
  set total-area (corn-area + wheat-area + soybean-area + milo-area)                                ;Calculate total crop area
  set current-elev 69                                                                               ;Set top of aquifer = max pycor of "aquifer patches"
  set area-multiplier 3000                                                                          ;Scale size of crop circles
  set corn-coverage 0.75                                                                            ;Level of coverage
  set wheat-coverage 0.7                                                                            ;Level of coverage
  set soybean-coverage 0.7                                                                          ;Level of coverage
  set milo-coverage 0.65                                                                            ;Level of coverage
  set corn-base-price 4.12                                                                          ;Base price for crop insurance calculation
  set wheat-base-price 6.94                                                                         ;Base price for crop insurance calculation
  set soybean-base-price 9.39                                                                       ;Base price for crop insurance calculation
  set milo-base-price 3.14                                                                          ;Base price for crop insurance calculation
  set N-accu 0                                                                                      ;Assume there is no N accumulation in soil (fertilizer)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; cropland patches ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set cropland-patches patches with [pxcor < 66]                                                    ;Divide the world where pxcor < 66 into cropland-patches

  set crop-background bitmap:import "center_pivot.jpg"                                              ;Import background
  bitmap:copy-to-pcolors crop-background false

  ask patches with [pxcor > 65] [                                                                   ;Set area outside "cropland-patches" to be black
    set pcolor black]

  ask patch -71 -97 [                                                                               ;Add patch label
    set plabel "Cropland"
    set plabel-color black
  ]

  set crop-area []                                                                                  ;Keep crop area in a list, namely "crop-area"
  set crop-area lput corn-area crop-area
  set crop-area lput wheat-area crop-area
  set crop-area lput soybean-area crop-area
  set crop-area lput milo-area crop-area

  set radius-of-%area []                                                                            ;crop areas are calculated as percentage of total area

  let n 0                                                                                           ;Set temporary variable
  let m 0
  foreach crop-area [ x ->
    set radius-of-%area lput sqrt ((x / (sum crop-area) * area-multiplier) / pi) radius-of-%area    ;Calculate radius of crop circle
  ]

  ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
  ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
  ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
  ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]

  ask patch 6 -20 [
    set plabel "Corn"]
  ask patch -9 63 [
    set plabel "Wheat"
    set plabel-color black]
  ask patch -39 -72 [
    set plabel "Soybean"
    set plabel-color black]
  ask patch -46 -5 [
    set plabel "Milo"]

  import-drawing "crop-symbol.png"                                                                  ;Overlay each crop circle by its symbol

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;; Aquifer patches ;;;;;;;;;;;;;;;;;;                                            ;Set "aquifer-patches" and patch's color
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set aquifer-patches patches with [pxcor > 66 and pxcor < 83 and pycor < 70]
  ask aquifer-patches [set pcolor blue]
  ask patch 79 -97 [set plabel "GW"]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;; River patches ;;;;;;;;;;;;;;;;;;;                                            ;Set "river-patches" and patch's color
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set river-patches patches with [pxcor > 66 and pxcor < 83 and pycor > 70]
  ask river-patches [set pcolor 87]
  ask patch 78 96 [
    set plabel "SW"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;; Solar patches ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set %Solar-production (Solar-production * 100 / (Solar-production + Wind-production))             ;Calculate % of solar production
  set %Wind-production (Wind-production * 100 / (Solar-production + Wind-production))               ;Calculate % of wind production

  set solar-bar patches with [pxcor > 83]                                                           ;Set a place to locate solar scale-bar
  ask solar-bar with [pycor > (-100 + (2 * %Wind-production))] [
    set pcolor [255 165 0]]

  ask patch 93 96 [                                                                                 ;Label
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
  set wind-bar patches with [pxcor > 83]                                                            ;Set a place to locate wind scale-bar
  ask wind-bar with [pycor < (-100 + (2 * %Wind-production))] [
    set pcolor yellow]

  ask patch 93 -91 [                                                                                ;Label
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
  set wind-patches patches with [pxcor > 0 and pxcor < 65 and pycor < -35 and pycor > -100]         ;Set a location to place wind symbols

  let w 0                                                                                           ;Set a temporary variable
    repeat #wind_turbines [                                                                         ;Place wind turbines as a grid within "wind-patches"
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
  set solar-patches patches with [pxcor > 0 and pxcor < 65 and pycor > 33 and pycor < 100]          ;Set a location to place solar symbols

  let t 0                                                                                           ;Set a temporary variable
    repeat #solar_panel_sets [                                                                      ;Place solar panels as a grid within "solar-patches"
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
  reset-ticks                                                                                       ;Reset tick to zero
end

to go
  if ticks = Input-years [stop]
  reset-symbols
  future_processes
  contaminant
  treatment
  tick
end

to import-data                                                                                      ;Create a number of lists to store values from csv files
  set precip_raw []                                                                                 ;A list for precipitation data
  set corn-data []                                                                                  ;All crop data including headings of the table
  set corn-sum []                                                                                   ;All crop data excluding headings of the table
  set corn-price []                                                                                 ;Historical crop price
  set corn-yield_1 []                                                                               ;Yield_1 means simulated yield from historical data
  set corn-irrig_1 []                                                                               ;Irrig_1 means simulated irrigation from historical data
  set corn-yield_2 []                                                                               ;Yield_2 means simulated yield from dryland simulation
  set corn-irrig_2 []                                                                               ;Irrig_2 means simulated irrigation from dryland simualtion (= zero)
  set corn-yield_3 []                                                                               ;Yield_3 means simulated yield from Global Climate Models (GCMs) data (projection)
  set corn-irrig_3 []                                                                               ;Irrig_3 means simulated irrigation from GCMs data (projection)
  set corn-yield_4 []                                                                               ;Yield_4 means simulated yield from GCMs data + dryland simulation (dryland projection)
  set corn-irrig_4 []                                                                               ;Irrig_4 means simulated irrigation from GCMs data + dryland simulation (dryland projection)
  set corn-N-app []                                                                                 ;N application
  set corn-N-use_1 []                                                                               ;N used by corn from historical +  irrigated
  set corn-N-use_2 []                                                                               ;N used by corn from historical + dryland
  set corn-N-use_3 []                                                                               ;N used by corn from GCM + irrigated
  set corn-N-use_4 []                                                                               ;N used by corn from GCM + dryland

  set wheat-data []                                                                                 ;See above from corn
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
  set wheat-N-app []
  set wheat-N-use_1 []
  set wheat-N-use_2 []
  set wheat-N-use_3 []
  set wheat-N-use_4 []

  set soybean-data []                                                                               ;See above from corn
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
  set soybean-N-app []
  set soybean-N-use_1 []
  set soybean-N-use_2 []
  set soybean-N-use_3 []
  set soybean-N-use_4 []

  set milo-data []                                                                                  ;See above from corn
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
  set milo-N-app []
  set milo-N-use_1 []
  set milo-N-use_2 []
  set milo-N-use_3 []
  set milo-N-use_4 []

  set corn-data lput csv:from-file "1_Corn_inputs.csv" corn-data                                    ;Import all corn values to a corn-data list
  set wheat-data lput csv:from-file "2_Wheat_inputs.csv" wheat-data                                 ;Import all wheat values to a corn-data list
  set soybean-data lput csv:from-file "3_Soybean_inputs.csv" soybean-data                           ;Import all soybean values to a corn-data list
  set milo-data lput csv:from-file "4_Milo_inputs.csv" milo-data                                    ;Import all milo values to a corn-data list

  let m 1                                                                                           ;Set a temporary variable
  while [m < 11] [                                                                                  ;10 loops for 10-year data
    foreach corn-data [x -> set corn-sum lput item m x corn-sum]                                    ;Get rid of headings of the table (starting from item 1 instead of item 0)
      foreach corn-sum [y -> set precip_raw lput item 1 y precip_raw]                               ;Item 1 of a csv file is precipitation
      foreach corn-sum [y -> set corn-price lput item 2 y corn-price]                               ;Item 2 of a csv file is historical crop price
      foreach corn-sum [y -> set corn-yield_1 lput item 3 y corn-yield_1]                           ;Item 3 of a csv file is yield_1 (yield_1 see "import-data" for more detail)
      foreach corn-sum [y -> set corn-irrig_1 lput item 4 y corn-irrig_1]                           ;Item 4 of a csv file is irrig_1
      foreach corn-sum [y -> set corn-yield_2 lput item 5 y corn-yield_2]                           ;Item 5 of a csv file is yield_2
      foreach corn-sum [y -> set corn-irrig_2 lput item 6 y corn-irrig_2]                           ;Item 6 of a csv file is irrig_2
      foreach corn-sum [y -> set corn-yield_3 lput item 7 y corn-yield_3]                           ;Item 7 of a csv file is yield_3
      foreach corn-sum [y -> set corn-irrig_3 lput item 8 y corn-irrig_3]                           ;Item 8 of a csv file is irrig_3
      foreach corn-sum [y -> set corn-yield_4 lput item 9 y corn-yield_4]                           ;Item 9 of a csv file is yield_4
      foreach corn-sum [y -> set corn-irrig_4 lput item 10 y corn-irrig_4]                          ;Item 10 of a csv file is irrig_4
      foreach corn-sum [y -> set corn-N-app lput item 11 y corn-N-app]                              ;Item 11 of a csv file is N-app
      foreach corn-sum [y -> set corn-N-use_1 lput item 12 y corn-N-use_1]                          ;Item 12 of a csv file is N-use_1
      foreach corn-sum [y -> set corn-N-use_2 lput item 13 y corn-N-use_2]                          ;Item 12 of a csv file is N-use_2
      foreach corn-sum [y -> set corn-N-use_3 lput item 14 y corn-N-use_3]                          ;Item 12 of a csv file is N-use_3
      foreach corn-sum [y -> set corn-N-use_4 lput item 15 y corn-N-use_4]                          ;Item 12 of a csv file is N-use_4
    foreach wheat-data [x -> set wheat-sum lput item m x wheat-sum]                                 ;See above
      foreach wheat-sum [y -> set wheat-price lput item 2 y wheat-price]
      foreach wheat-sum [y -> set wheat-yield_1 lput item 3 y wheat-yield_1]
      foreach wheat-sum [y -> set wheat-irrig_1 lput item 4 y wheat-irrig_1]
      foreach wheat-sum [y -> set wheat-yield_2 lput item 5 y wheat-yield_2]
      foreach wheat-sum [y -> set wheat-irrig_2 lput item 6 y wheat-irrig_2]
      foreach wheat-sum [y -> set wheat-yield_3 lput item 7 y wheat-yield_3]
      foreach wheat-sum [y -> set wheat-irrig_3 lput item 8 y wheat-irrig_3]
      foreach wheat-sum [y -> set wheat-yield_4 lput item 9 y wheat-yield_4]
      foreach wheat-sum [y -> set wheat-irrig_4 lput item 10 y wheat-irrig_4]
      foreach wheat-sum [y -> set wheat-N-app lput item 11 y wheat-N-app]
      foreach wheat-sum [y -> set wheat-N-use_1 lput item 12 y wheat-N-use_1]
      foreach wheat-sum [y -> set wheat-N-use_2 lput item 13 y wheat-N-use_2]
      foreach wheat-sum [y -> set wheat-N-use_3 lput item 14 y wheat-N-use_3]
      foreach wheat-sum [y -> set wheat-N-use_4 lput item 15 y wheat-N-use_4]
    foreach soybean-data [x -> set soybean-sum lput item m x soybean-sum]                           ;See above
      foreach soybean-sum [y -> set soybean-price lput item 2 y soybean-price]
      foreach soybean-sum [y -> set soybean-yield_1 lput item 3 y soybean-yield_1]
      foreach soybean-sum [y -> set soybean-irrig_1 lput item 4 y soybean-irrig_1]
      foreach soybean-sum [y -> set soybean-yield_2 lput item 5 y soybean-yield_2]
      foreach soybean-sum [y -> set soybean-irrig_2 lput item 6 y soybean-irrig_2]
      foreach soybean-sum [y -> set soybean-yield_3 lput item 7 y soybean-yield_3]
      foreach soybean-sum [y -> set soybean-irrig_3 lput item 8 y soybean-irrig_3]
      foreach soybean-sum [y -> set soybean-yield_4 lput item 9 y soybean-yield_4]
      foreach soybean-sum [y -> set soybean-irrig_4 lput item 10 y soybean-irrig_4]
      foreach soybean-sum [y -> set soybean-N-app lput item 11 y soybean-N-app]
      foreach soybean-sum [y -> set soybean-N-use_1 lput item 12 y soybean-N-use_1]
      foreach soybean-sum [y -> set soybean-N-use_2 lput item 13 y soybean-N-use_2]
      foreach soybean-sum [y -> set soybean-N-use_3 lput item 14 y soybean-N-use_3]
      foreach soybean-sum [y -> set soybean-N-use_4 lput item 15 y soybean-N-use_4]
    foreach milo-data [x -> set milo-sum lput item m x milo-sum]                                    ;See above
      foreach milo-sum [y -> set milo-price lput item 2 y milo-price]
      foreach milo-sum [y -> set milo-yield_1 lput item 3 y milo-yield_1]
      foreach milo-sum [y -> set milo-irrig_1 lput item 4 y milo-irrig_1]
      foreach milo-sum [y -> set milo-yield_2 lput item 5 y milo-yield_2]
      foreach milo-sum [y -> set milo-irrig_2 lput item 6 y milo-irrig_2]
      foreach milo-sum [y -> set milo-yield_3 lput item 7 y milo-yield_3]
      foreach milo-sum [y -> set milo-irrig_3 lput item 8 y milo-irrig_3]
      foreach milo-sum [y -> set milo-yield_4 lput item 9 y milo-yield_4]
      foreach milo-sum [y -> set milo-irrig_4 lput item 10 y milo-irrig_4]
      foreach milo-sum [y -> set milo-N-app lput item 11 y milo-N-app]
      foreach milo-sum [y -> set milo-N-use_1 lput item 12 y milo-N-use_1]
      foreach milo-sum [y -> set milo-N-use_2 lput item 13 y milo-N-use_2]
      foreach milo-sum [y -> set milo-N-use_3 lput item 14 y milo-N-use_3]
      foreach milo-sum [y -> set milo-N-use_4 lput item 15 y milo-N-use_4]

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
        if length corn-N-app != 10 [set corn-N-app []]
        if length corn-N-use_1 != 10 [set corn-N-use_1 []]
        if length corn-N-use_2 != 10 [set corn-N-use_2 []]
        if length corn-N-use_3 != 10 [set corn-N-use_3 []]
        if length corn-N-use_4 != 10 [set corn-N-use_4 []]

        if length wheat-price != 10 [set wheat-price []]
        if length wheat-yield_1 != 10 [set wheat-yield_1 []]
        if length wheat-irrig_1 != 10 [set wheat-irrig_1 []]
        if length wheat-yield_2 != 10 [set wheat-yield_2 []]
        if length wheat-irrig_2 != 10 [set wheat-irrig_2 []]
        if length wheat-yield_3 != 10 [set wheat-yield_3 []]
        if length wheat-irrig_3 != 10 [set wheat-irrig_3 []]
        if length wheat-yield_4 != 10 [set wheat-yield_4 []]
        if length wheat-irrig_4 != 10 [set wheat-irrig_4 []]
        if length wheat-N-app != 10 [set wheat-N-app []]
        if length wheat-N-use_1 != 10 [set wheat-N-use_1 []]
        if length wheat-N-use_2 != 10 [set wheat-N-use_2 []]
        if length wheat-N-use_3 != 10 [set wheat-N-use_3 []]
        if length wheat-N-use_4 != 10 [set wheat-N-use_4 []]

        if length soybean-price != 10 [set soybean-price []]
        if length soybean-yield_1 != 10 [set soybean-yield_1 []]
        if length soybean-irrig_1 != 10 [set soybean-irrig_1 []]
        if length soybean-yield_2 != 10 [set soybean-yield_2 []]
        if length soybean-irrig_2 != 10 [set soybean-irrig_2 []]
        if length soybean-yield_3 != 10 [set soybean-yield_3 []]
        if length soybean-irrig_3 != 10 [set soybean-irrig_3 []]
        if length soybean-yield_4 != 10 [set soybean-yield_4 []]
        if length soybean-irrig_4 != 10 [set soybean-irrig_4 []]
        if length soybean-N-app != 10 [set soybean-N-app []]
        if length soybean-N-use_1 != 10 [set soybean-N-use_1 []]
        if length soybean-N-use_2 != 10 [set soybean-N-use_2 []]
        if length soybean-N-use_3 != 10 [set soybean-N-use_3 []]
        if length soybean-N-use_4 != 10 [set soybean-N-use_4 []]

        if length milo-price != 10 [set milo-price []]
        if length milo-yield_1 != 10 [set milo-yield_1 []]
        if length milo-irrig_1 != 10 [set milo-irrig_1 []]
        if length milo-yield_2 != 10 [set milo-yield_2 []]
        if length milo-irrig_2 != 10 [set milo-irrig_2 []]
        if length milo-yield_3 != 10 [set milo-yield_3 []]
        if length milo-irrig_3 != 10 [set milo-irrig_3 []]
        if length milo-yield_4 != 10 [set milo-yield_4 []]
        if length milo-irrig_4 != 10 [set milo-irrig_4 []]
        if length milo-N-app != 10 [set milo-N-app []]
        if length milo-N-use_1 != 10 [set milo-N-use_1 []]
        if length milo-N-use_2 != 10 [set milo-N-use_2 []]
        if length milo-N-use_3 != 10 [set milo-N-use_3 []]
        if length milo-N-use_4 != 10 [set milo-N-use_4 []]

    set m (m + 1)
  ]

  set corn-history corn-yield_1                                                                     ;Set historical production list for crop insurance calculation
  set wheat-history wheat-yield_1                                                                   ;Set historical production list for crop insurance calculation
  set soybean-history soybean-yield_1                                                               ;Set historical production list for crop insurance calculation
  set milo-history milo-yield_1                                                                     ;Set historical production list for crop insurance calculation
end

to calculate-expenses_yield_1                                                                       ;Expenses for irrigated farming [ref: AgManager.info (K-State, 2020 report)]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_1) < 210 [set corn-expenses (786.23 * corn-area)]
  if (item (item k yrs-seq) corn-yield_1) >= 210 and (item (item k yrs-seq) corn-yield_1) <= 237.5 [set corn-expenses (861.41 * corn-area)]
  if (item (item k yrs-seq) corn-yield_1) > 237.5 [set corn-expenses (920.04 * corn-area)]

  if (item (item k yrs-seq) wheat-yield_1) < 62.5 [set wheat-expenses (498.13 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_1) >= 62.5 and (item (item k yrs-seq) wheat-yield_1) <= 67.5 [set wheat-expenses (523.43 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_1) > 67.5 [set wheat-expenses (548.74 * wheat-area)]

  if (item (item k yrs-seq) soybean-yield_1) < 58 [set soybean-expenses (542.07 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_1) >= 58 and (item (item k yrs-seq) soybean-yield_1) <= 64 [set soybean-expenses (572.48 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_1) > 64 [set soybean-expenses (620.95 * soybean-area)]

  if (item (item k yrs-seq) milo-yield_1) < 150 [set milo-expenses (618.55 * milo-area)]
  if (item (item k yrs-seq) milo-yield_1) >= 150 and (item (item k yrs-seq) milo-yield_1) <= 170 [set milo-expenses (666.17 * milo-area)]
  if (item (item k yrs-seq) milo-yield_1) > 170 [set milo-expenses (713.79 * milo-area)]
end

to calculate-expenses_yield_2                                                                       ;Expenses for dryland farming [ref: AgManager.info (K-State, 2020 report)]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_2) < 66 [set corn-expenses (273.10 * corn-area)]
  if (item (item k yrs-seq) corn-yield_2) >= 66 and (item (item k yrs-seq) corn-yield_2) <= 91 [set corn-expenses (337.57 * corn-area)]
  if (item (item k yrs-seq) corn-yield_2) > 91 [set corn-expenses (377.54 * corn-area)]

  if (item (item k yrs-seq) wheat-yield_2) < 37.5 [set wheat-expenses (245.47 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_2) >= 37.5 and (item (item k yrs-seq) wheat-yield_2) <= 46.5 [set wheat-expenses (277.41 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_2) > 46.5 [set wheat-expenses (309.35 * wheat-area)]

  if (item (item k yrs-seq) soybean-yield_2) < 22.5 [set soybean-expenses (224.51 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_2) >= 22.5 and (item (item k yrs-seq) soybean-yield_2) <= 27.5 [set soybean-expenses (248.50 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_2) > 27.5 [set soybean-expenses (272.48 * soybean-area)]

  if (item (item k yrs-seq) milo-yield_2) < 68 [set milo-expenses (263.01 * milo-area)]
  if (item (item k yrs-seq) milo-yield_2) >= 68 and (item (item k yrs-seq) milo-yield_2) <= 93 [set milo-expenses (314.41 * milo-area)]
  if (item (item k yrs-seq) milo-yield_2) > 93 [set milo-expenses (361.86 * milo-area)]
end

to calculate-expenses_yield_3                                                                       ;Expenses for irrigated farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_3) < 210 [set corn-expenses (786.23 * corn-area)]
  if (item (item k yrs-seq) corn-yield_3) >= 210 and (item (item k yrs-seq) corn-yield_3) <= 237.5 [set corn-expenses (861.41 * corn-area)]
  if (item (item k yrs-seq) corn-yield_3) > 237.5 [set corn-expenses (920.04 * corn-area)]

  if (item (item k yrs-seq) wheat-yield_3) < 62.5 [set wheat-expenses (498.13 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_3) >= 62.5 and (item (item k yrs-seq) wheat-yield_3) <= 67.5 [set wheat-expenses (523.43 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_3) > 67.5 [set wheat-expenses (548.74 * wheat-area)]

  if (item (item k yrs-seq) soybean-yield_3) < 58 [set soybean-expenses (542.07 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_3) >= 58 and (item (item k yrs-seq) soybean-yield_3) <= 64 [set soybean-expenses (572.48 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_3) > 64 [set soybean-expenses (620.95 * soybean-area)]

  if (item (item k yrs-seq) milo-yield_3) < 150 [set milo-expenses (618.55 * milo-area)]
  if (item (item k yrs-seq) milo-yield_3) >= 150 and (item (item k yrs-seq) milo-yield_3) <= 170 [set milo-expenses (666.17 * milo-area)]
  if (item (item k yrs-seq) milo-yield_3) > 170 [set milo-expenses (713.79 * milo-area)]
end

to calculate-expenses_yield_4                                                                       ;Expenses for dryland farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_4) < 66 [set corn-expenses (273.10 * corn-area)]
  if (item (item k yrs-seq) corn-yield_4) >= 66 and (item (item k yrs-seq) corn-yield_4) <= 91 [set corn-expenses (337.57 * corn-area)]
  if (item (item k yrs-seq) corn-yield_4) > 91 [set corn-expenses (377.54 * corn-area)]

  if (item (item k yrs-seq) wheat-yield_4) < 37.5 [set wheat-expenses (245.47 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_4) >= 37.5 and (item (item k yrs-seq) wheat-yield_4) <= 46.5 [set wheat-expenses (277.41 * wheat-area)]
  if (item (item k yrs-seq) wheat-yield_4) > 46.5 [set wheat-expenses (309.35 * wheat-area)]

  if (item (item k yrs-seq) soybean-yield_4) < 22.5 [set soybean-expenses (224.51 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_4) >= 22.5 and (item (item k yrs-seq) soybean-yield_4) <= 27.5 [set soybean-expenses (248.50 * soybean-area)]
  if (item (item k yrs-seq) soybean-yield_4) > 27.5 [set soybean-expenses (272.48 * soybean-area)]

  if (item (item k yrs-seq) milo-yield_4) < 68 [set milo-expenses (263.01 * milo-area)]
  if (item (item k yrs-seq) milo-yield_4) >= 68 and (item (item k yrs-seq) milo-yield_4) <= 93 [set milo-expenses (314.41 * milo-area)]
  if (item (item k yrs-seq) milo-yield_4) > 93 [set milo-expenses (361.86 * milo-area)]
end

to calculate-net-income                                                                             ;Calculate farm net income
  set corn-net-income (corn-tot-income - corn-expenses)
  set wheat-net-income (wheat-tot-income - wheat-expenses)
  set soybean-net-income (soybean-tot-income - soybean-expenses)
  set milo-net-income (milo-tot-income - milo-expenses)
end

to future_processes
if Future_Process = "Repeat Historical"                                                             ;Repeat historical scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
       [set corn-N-use corn-N-use_1                                                                 ;Classify nitrogen uses into different scenario
        set wheat-N-use wheat-N-use_1                                                               ;Classify nitrogen uses into different scenario
        set soybean-N-use soybean-N-use_1                                                           ;Classify nitrogen uses into different scenario
        set milo-N-use milo-N-use_1                                                                 ;Classify nitrogen uses into different scenario
        food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -74                                                                   ;Is aquifer thickness greater that 20% of its initial thickness?
         [set corn-N-use corn-N-use_1
          set wheat-N-use wheat-N-use_1
          set soybean-N-use soybean-N-use_1
          set milo-N-use milo-N-use_1
          food-calculation_1-2                                                                      ;Irrigated farming
          energy-calculation
          gw-depletion_1]

         [set corn-N-use corn-N-use_2                                                               ;Dryland farming
          set wheat-N-use wheat-N-use_2
          set soybean-N-use soybean-N-use_2
          set milo-N-use milo-N-use_2
          print (word "Seq " ticks ", year " (ticks + 2008) " dryland farming")
          dryland-farming_1
          gw-depletion_dryland
          energy-calculation]
       ]
    ]

  if Future_Process = "Wetter Future"                                                               ;Wetter years scenario
    [ifelse ticks <= 9                                                                              ;First 10 year data based on history
       [set corn-N-use corn-N-use_1
        set wheat-N-use wheat-N-use_1
        set soybean-N-use soybean-N-use_1
        set milo-N-use milo-N-use_1
        food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -74                                                                   ;Is aquifer thickness greater that 20% of its initial thickness?
          [set corn-N-use corn-N-use_1
           set wheat-N-use wheat-N-use_1
           set soybean-N-use soybean-N-use_1
           set milo-N-use milo-N-use_1
           food-calculation_2                                                                       ;Irrigated farming
           energy-calculation
           gw-depletion_2]

          [set corn-N-use corn-N-use_2                                                              ;Dryland farming
           set wheat-N-use wheat-N-use_2
           set soybean-N-use soybean-N-use_2
           set milo-N-use milo-N-use_2
           print (word "Seq " ticks ", year " (ticks + 2008) " dryland farming")
           dryland-farming_2
           gw-depletion_dryland
           energy-calculation]
       ]
    ]

  if Future_Process = "Dryer Future"                                                                 ;Dryer years scenario
    [ifelse ticks <= 9                                                                              ;First 10 year data based on history
       [set corn-N-use corn-N-use_1
        set wheat-N-use wheat-N-use_1
        set soybean-N-use soybean-N-use_1
        set milo-N-use milo-N-use_1
        food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -74                                                                   ;Is aquifer thickness greater that 20% of its initial thickness?
          [set corn-N-use corn-N-use_1
           set wheat-N-use wheat-N-use_1
           set soybean-N-use soybean-N-use_1
           set milo-N-use milo-N-use_1
           food-calculation_3                                                                       ;Irrigated farming
           energy-calculation
           gw-depletion_3]

          [set corn-N-use corn-N-use_2                                                              ;Dryland farming
           set wheat-N-use wheat-N-use_2
           set soybean-N-use soybean-N-use_2
           set milo-N-use milo-N-use_2
           print (word "Seq " ticks ", year " (ticks + 2008) " dryland farming")
           dryland-farming_3
           gw-depletion_dryland
           energy-calculation]
       ]
    ]

  if Future_Process = "Impose T, P, & S Changes"                                                    ;Climate projection scenario
    [ifelse ticks <= 9                                                                              ;First 10 year data based on history
       [set corn-N-use corn-N-use_1
        set wheat-N-use wheat-N-use_1
        set soybean-N-use soybean-N-use_1
        set milo-N-use milo-N-use_1
        food-calculation_1-1
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > -74                                                                   ;Is aquifer thickness greater that 20% of its initial thickness?
          [set corn-N-use corn-N-use_3
           set wheat-N-use wheat-N-use_3
           set soybean-N-use soybean-N-use_3
           set milo-N-use milo-N-use_3
           food-calculation_4                                                                       ;Irrigated farming
           energy-calculation
           gw-depletion_4]

          [set corn-N-use corn-N-use_4                                                              ;Dryland farming
           set wheat-N-use wheat-N-use_4
           set soybean-N-use soybean-N-use_4
           set milo-N-use milo-N-use_4
           print (word "Seq " ticks ", year " (ticks + 2008) " dryland farming")
           dryland-farming_4
           gw-depletion_dryland
           energy-calculation]
       ]
    ]
end


;Agricultural part -- contact: Wade Heger KU (wheger@ku.edu), Allan Andales CSU (Allan.Andales@colostate.edu), Garvey Smith CSU (Garvey.Smith@colostate.edu)
to food-calculation_1-1                                                                             ;First 10 year data based on historical data
  set yrs-seq [0 1 2 3 4 5 6 7 8 9]
  let n (ticks)

  ;print (word "food" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set corn-tot-income (item n corn-yield_1 * item n corn-price * corn-area)
  set wheat-tot-income (item n wheat-yield_1 * item n wheat-price * wheat-area)
  set soybean-tot-income (item n soybean-yield_1 * item n soybean-price * soybean-area)
  set milo-tot-income (item n milo-yield_1 * item n milo-price * milo-area)


  set corn-tot-yield (item n corn-yield_1)
  set wheat-tot-yield (item n wheat-yield_1)
  set soybean-tot-yield (item n soybean-yield_1)
  set milo-tot-yield (item n milo-yield_1)

  calculate-expenses_yield_1
  calculate-net-income

end

to food-calculation_1-2                                                                             ;Repeat historical data successively after 10 year simulation
  set yrs-seq [0 1 2 3 4 5 6 7 8 9]
  let n (ticks)

  ;print (word "food" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set corn-tot-yield (item (n mod 10) corn-yield_1)                                                 ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (n mod 10) wheat-yield_1)                                               ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybean-tot-yield (item (n mod 10) soybean-yield_1)                                           ;Each tick, soybean yield will be accessed from a "soybean-yield_1" list
  set milo-tot-yield (item (n mod 10) milo-yield_1)                                                 ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (n mod 10) corn-yield_1 * item (n mod 10) corn-price * corn-area)       ;Calculate farm gross income
  set wheat-tot-income (item (n mod 10) wheat-yield_1 * item (n mod 10) wheat-price * wheat-area)
  set soybean-tot-income (item (n mod 10) soybean-yield_1 * item (n mod 10) soybean-price * soybean-area)
  set milo-tot-income (item (n mod 10) milo-yield_1 * item (n mod 10) milo-price * milo-area)

  calculate-expenses_yield_1                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_1"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center
end

to food-calculation_2                                                                               ;Randomly choose wet year
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 9 9 9 9 0 6 7 8 9]                                                                ;List of wetter years
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  ;print (word "food" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)                                           ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_1)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_1" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)                                           ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

;  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * item (item n yrs-seq) corn-price * corn-area)               ;Calculate farm gross income
;  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * item (item n yrs-seq) wheat-price * wheat-area)
;  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * item (item n yrs-seq) soybean-price * soybean-area)
;  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * item (item n yrs-seq) milo-price * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * one-of corn-price * corn-area)               ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * one-of wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * one-of soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * one-of milo-price * milo-area)

  calculate-expenses_yield_1                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_1"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
    ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center


  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
    ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
    ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
    ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center
end

to food-calculation_3                                                                               ;Randomly choose dry year
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 0 4 3 4 5 7 4 4 4]                                                                ;List of dryer years
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

 ; print (word "food" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)                                           ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_1)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_1" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)                                           ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

;  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * item (item n yrs-seq) corn-price * corn-area)              ;Calculate farm gross income
;  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * item (item n yrs-seq) wheat-price * wheat-area)
;  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * item (item n yrs-seq) soybean-price * soybean-area)
;  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * item (item n yrs-seq) milo-price * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * one-of corn-price * corn-area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * one-of wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_1 * one-of soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * one-of milo-price * milo-area)

  calculate-expenses_yield_1                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_1"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center
end

to food-calculation_4                                                                               ;Randomly choose data from GCMs
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 1 2 3 4 5 6 7 8 9]                                                                ;List of data
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  ;print (word "food" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set corn-tot-yield (item (item n yrs-seq) corn-yield_3)                                           ;Each tick, corn yield will be accessed from a "corn-yield_3" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_3)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_3" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_3)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_3" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_3)                                           ;Each tick, milo yield will be accessed from a "milo-yield_3" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_3 * item (item n yrs-seq) corn-price * corn-area)                ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_3 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_3 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_3 * item (item n yrs-seq) milo-price * milo-area)

  calculate-expenses_yield_3                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_3"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center
end

to dryland-farming_1
  let n (ticks)

  set corn-tot-yield (item (n mod 10) corn-yield_2)                                                 ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (n mod 10) wheat-yield_2)                                               ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybean-tot-yield (item (n mod 10) soybean-yield_2)                                           ;Each tick, soybean yield will be accessed from a "soybean-yield_2" list
  set milo-tot-yield (item (n mod 10) milo-yield_2)                                                 ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (n mod 10) corn-yield_2 * item (n mod 10) corn-price * corn-area)       ;Calculate farm gross income
  set wheat-tot-income (item (n mod 10) wheat-yield_2 * item (n mod 10) wheat-price * wheat-area)
  set soybean-tot-income (item (n mod 10) soybean-yield_2 * item (n mod 10) soybean-price * soybean-area)
  set milo-tot-income (item (n mod 10) milo-yield_2 * item (n mod 10) milo-price * milo-area)

  calculate-expenses_yield_2                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_1"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybean-use-in item (k mod 10) soybean-irrig_2                                                ;Each tick, irrigation will be accessed from a "soybean-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_2
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 9 9 9 9 0 6 7 8 9]                                                                ;List of wetter years (must be the same seq as "food-calculation_2")
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)                                           ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_2)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_2" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)                                           ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

;  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * item (item n yrs-seq) corn-price * corn-area)               ;Calculate farm gross income
;  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * item (item n yrs-seq) wheat-price * wheat-area)
;  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * item (item n yrs-seq) soybean-price * soybean-area)
;  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * item (item n yrs-seq) milo-price * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * one-of corn-price * corn-area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * one-of wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * one-of soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * one-of milo-price * milo-area)

  calculate-expenses_yield_2                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_2"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybean-use-in item (k mod 10) soybean-irrig_2                                                ;Each tick, irrigation will be accessed from a "soybean-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_3
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 0 4 3 4 5 7 4 4 4]                                                                ;List of dryer years (must be the same seq as "food-calculation_3")
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)                                           ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_2)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_2" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)                                           ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

;  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * item (item n yrs-seq) corn-price * corn-area)                 ;Calculate farm gross income
;  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * item (item n yrs-seq) wheat-price * wheat-area)
;  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * item (item n yrs-seq) soybean-price * soybean-area)
;  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * item (item n yrs-seq) milo-price * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * one-of corn-price * corn-area)                 ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * one-of wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_2 * one-of soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * one-of milo-price * milo-area)

  calculate-expenses_yield_2                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_2"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybean-use-in item (k mod 10) soybean-irrig_2                                                ;Each tick, irrigation will be accessed from a "soybean-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_4
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [ set yrs-seq [0 1 2 3 4 5 6 7 8 9]                                                               ;List of data (must be the same seq as "food-calculation_4")
    set yrs-seq shuffle yrs-seq]                                                                    ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_4)                                           ;Each tick, corn yield will be accessed from a "corn-yield_4" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_4)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_4" list
  set soybean-tot-yield (item (item n yrs-seq) soybean-yield_4)                                     ;Each tick, soybean yield will be accessed from a "soybean-yield_4" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_4)                                           ;Each tick, milo yield will be accessed from a "milo-yield_4" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybean-history lput soybean-tot-yield but-first soybean-history                              ;Add the most recent yield in a "soybean-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybean-mean-yield mean soybean-history                                                       ;Average soybean production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-guarantee ((corn-mean-yield * corn-coverage * corn-base-price) * corn-area)              ;Calculate guarantee price
  set wheat-guarantee ((wheat-mean-yield * wheat-coverage * wheat-base-price) * wheat-area)
  set soybean-guarantee ((soybean-mean-yield * soybean-coverage * soybean-base-price) * soybean-area)
  set milo-guarantee ((milo-mean-yield * milo-coverage * milo-base-price) * milo-area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_4 * item (item n yrs-seq) corn-price * corn-area)                 ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_4 * item (item n yrs-seq) wheat-price * wheat-area)
  set soybean-tot-income (item (item n yrs-seq) soybean-yield_4 * item (item n yrs-seq) soybean-price * soybean-area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_4 * item (item n yrs-seq) milo-price * milo-area)

  calculate-expenses_yield_4                                                                        ;Get farm expenses -- Link to "calculate-expenses_yield_4"
  calculate-net-income                                                                              ;Calculate farm net income

  ifelse corn-tot-income > corn-guarantee                                                           ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 12 -27 [
      set plabel " "]]
    [set corn-tot-income corn-guarantee
     ask patch 12 -27 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies corn insurance")]                  ;Print message in the Command Center

  ifelse wheat-tot-income > wheat-guarantee                                                         ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-tot-income wheat-guarantee
     ask patch -5 56 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies wheat insurance")]                 ;Print message in the Command Center

  ifelse soybean-tot-income > soybean-guarantee                                                     ;Apply crop insurance?
    [set soybean-tot-income soybean-tot-income
     ask patch -39 -79 [
      set plabel " "]]
    [set soybean-tot-income soybean-guarantee
     ask patch -39 -79 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies soybean insurance")]               ;Print message in the Command Center

  ifelse milo-tot-income > milo-guarantee                                                           ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -39 -12 [
      set plabel " "]]
    [set milo-tot-income milo-guarantee
     ask patch -39 -12 [
      set plabel "INSURED"
      set plabel-color red
      ]
     print (word "Seq " ticks ", year " (ticks + 2008) " applies milo insurance")]                  ;Print message in the Command Center

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_4                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_4" list
  set wheat-use-in item (k mod 10) wheat-irrig_4                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_4" list
  set soybean-use-in item (k mod 10) soybean-irrig_4                                                ;Each tick, irrigation will be accessed from a "soybean-irrig_4" list
  set milo-use-in item (k mod 10) milo-irrig_4                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_4" list
end

to energy-calculation
  ;Bob Johnson (bobjohnson@centurylink.net), Earnie Lehman (earnielehman@gmail.com), and Hongyu Wu (hongyuwu@ksu.edu)
  ;assuming the cost spreads over 30 years with no interest
  set #Solar_panels (#solar_panel_sets * 1000)
  set solar-production (#Solar_Panels * Panel_power * 5 * 365 / 1000000)                            ;MWh = power(Watt) * 5hrs/day * 365days/year / 1000000
  set wind-production (#wind_turbines * turbine_size * 0.421 * 24 * 365)                            ;MWh = power(MW) * Kansas_wind_capacity * 24hrs/day * 365days/year, capacity 42.1% (Berkeley Lab)
  set solar-cost (#Solar_Panels * (Panel_power / 1000) * 3050 / 30)                                 ;Solar cost = #Solar_Panels * Panel_power * $3050/kW
  set solar-sell (solar-production * 38)                                                            ;Sell = MWh * $38/MWh (Bob and Mary)
                                                                                                    ;Wholesale < Coop $65 < Retail, , (Wholesale was $22-24/MWh, Retail price is $105/MWh)

  ;Wind installation cost = $1000/kW or $1000000/MW, Annual O&M = 3% of installation cost
  ;For 2MW, Wind cost = 2,000,000/30 + (60,000/yr) * #wind_turbines, (ref. Berkeley Lab, Hongyu Wu)
  set wind-cost (((1000000 * turbine_size / 30) + (0.03 * 1000000 * turbine_size))) * #wind_turbines
  set wind-sell (wind-production * 38)                                                              ;Sell = MWh * $38/MWh
  set solar-net-income (solar-sell - solar-cost)
  set wind-net-income  (wind-sell - wind-cost)
  set energy-net-income (solar-net-income + wind-net-income)
end

to gw-depletion_1
  let k ticks                                                                                       ;Set a temporary variable

  ;print (word "gw" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set corn-use-in item (k mod 10) corn-irrig_1                                                      ;Irrigation will be accessed from a "corn-irrig_1" list
  set wheat-use-in item (k mod 10) wheat-irrig_1                                                    ;Irrigation will be accessed from a "wheat-irrig_1" list
  set soybean-use-in item (k mod 10) soybean-irrig_1                                                ;Irrigation will be accessed from a "soybean-irrig_1" list
  set milo-use-in item (k mod 10) milo-irrig_1                                                      ;Irrigation will be accessed from a "milo-irrig_1" list

  ;Normalize water use
  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-32.306 * water-use-feet) + 7.98)                                                 ;Calculate water-level change using a regression equation (Whittemore et al., 2016)

  ;print (word "Year" (ticks + 2008) ": " water-use-feet)

  set patch-change (gw-change * 170 / aquifer-thickness)                                            ;Convert water-level change to patch change

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed capacity

  if current-elev < -74 [                                                                           ;Is the top of aquifer below 80% of initial thickness?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_2
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_1                                                ;Irrigation will be accessed from a "corn-irrig_1" list (seq is linked to "food_calculation_1")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1                                              ;Irrigation will be accessed from a "wheat-irrig_1" list (seq is linked to "food_calculation_1")
  set soybean-use-in item (item k yrs-seq) soybean-irrig_1                                          ;Irrigation will be accessed from a "soybean-irrig_1" list (seq is linked to "food_calculation_1")
  set milo-use-in item (item k yrs-seq) milo-irrig_1                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_1")

  ;print (word "gw" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Normalize water use
  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-32.306 * water-use-feet) + 7.98)                                                 ;Calculate water-level change using a regression equation (Whittemore et al., 2016)

  set patch-change (gw-change * 170 / aquifer-thickness)                                            ;Convert water-level change to patch change

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed capacity

  if current-elev < -74 [                                                                           ;Is the top of aquifer below 80% of initial thickness?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_3
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_1                                                ;Irrigation will be accessed from a "corn-irrig_1" list (seq is linked to "food_calculation_1")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1                                              ;Irrigation will be accessed from a "wheat-irrig_1" list (seq is linked to "food_calculation_1")
  set soybean-use-in item (item k yrs-seq) soybean-irrig_1                                          ;Irrigation will be accessed from a "soybean-irrig_1" list (seq is linked to "food_calculation_1")
  set milo-use-in item (item k yrs-seq) milo-irrig_1                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_1")

  ;print (word "gw" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Normalize water use
  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-32.306 * water-use-feet) + 7.98)                                                 ;Calculate water-level change using a regression equation (Whittemore et al., 2016)

  set patch-change (gw-change * 170 / aquifer-thickness)                                            ;Convert water-level change to patch change

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed capacity

  if current-elev < -74 [                                                                           ;Is the top of aquifer below 80% of initial thickness?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_4
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_3                                                ;Irrigation will be accessed from a "corn-irrig_3" list (seq is linked to "food_calculation_3")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_3                                              ;Irrigation will be accessed from a "wheat-irrig_3" list (seq is linked to "food_calculation_3")
  set soybean-use-in item (item k yrs-seq) soybean-irrig_3                                          ;Irrigation will be accessed from a "soybean-irrig_3" list (seq is linked to "food_calculation_3")
  set milo-use-in item (item k yrs-seq) milo-irrig_3                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_3")

  ;print (word "gw" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Normalize water use
  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-32.306 * water-use-feet) + 7.98)                                                 ;Calculate water-level change using a regression equation (Whittemore et al., 2016)

  set patch-change (gw-change * 170 / aquifer-thickness)                                            ;Convert water-level change to patch change

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed capacity

  if current-elev < -74 [                                                                           ;Is the top of aquifer below 80% of initial thickness?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_dryland
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_2                                                ;Irrigation will be accessed from a "corn-irrig_3" list (seq is linked to "food_calculation_3")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_2                                              ;Irrigation will be accessed from a "wheat-irrig_3" list (seq is linked to "food_calculation_3")
  set soybean-use-in item (item k yrs-seq) soybean-irrig_2                                          ;Irrigation will be accessed from a "soybean-irrig_3" list (seq is linked to "food_calculation_3")
  set milo-use-in item (item k yrs-seq) milo-irrig_2                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_3")

  ;print (word "gw" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Normalize water use
  set water-use-feet (((corn-use-in * corn-area) + (wheat-use-in * wheat-area) + (soybean-use-in * soybean-area) + (milo-use-in * milo-area)) / (12 * total-area))
  set gw-change ((-32.306 * water-use-feet) + 7.98)                                                 ;Calculate water-level change using a regression equation (Whittemore et al., 2016)

  set patch-change (gw-change * 170 / aquifer-thickness)                                            ;Convert water-level change to patch change

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed capacity

  if current-elev < -74 [                                                                           ;Is the top of aquifer below 80% of initial thickness?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to contaminant                                                                                      ;Surface water contamination
  let k (ticks mod 10)
  let N-accu-temp (0.07 * (((item (item k yrs-seq) corn-N-app) * corn-area) + ((item (item k yrs-seq) wheat-N-app) * wheat-area) + ((item (item k yrs-seq) soybean-N-app) * soybean-area) + ((item (item k yrs-seq) milo-N-app) * milo-area) / 1.12)) ;1.12 (convert from kg/ha to pound/ac)

  set N-accu (N-accu + N-accu-temp)

  ask patch -1 0 [ask n-of (0.07 * (item (item k yrs-seq) corn-N-app) / 1.12) patches in-radius (item 0 radius-of-%area) [set pcolor brown]]        ;show dots in lbs/ac
  ask patch -18 84 [ask n-of (0.07 * (item (item k yrs-seq) corn-N-app) / 1.12) patches in-radius (item 0 radius-of-%area) [set pcolor brown]]      ;show dots in lbs/ac
  ask patch -51.5 -51 [ask n-of (0.07 * (item (item k yrs-seq) corn-N-app) / 1.12) patches in-radius (item 0 radius-of-%area) [set pcolor brown]]   ;show dots in lbs/ac
  ask patch -52 16 [ask n-of (0.07 * (item (item k yrs-seq) corn-N-app) / 1.12) patches in-radius (item 0 radius-of-%area) [set pcolor brown]]      ;show dots in lbs/ac

  if (item k yrs-seq) = 7 or (item k yrs-seq) = 8 or (item k yrs-seq) = 9 [
    ask n-of (0.001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]                   ;0.001 is a scaling factor
      if any? river-patches with [pcolor = brown][
        ask one-of river-patches [set pcolor 87]
      ]
    set N-accu 0
    ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
    ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
    ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
    ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
  ]

  ;print (word "Temp. var. k: " k)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "corn-N-use" corn-N-use)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "wheat-N-use" wheat-N-use)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "soybean-N-use" soybean-N-use)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "milo-N-use" milo-N-use)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "corn-N-use item k: " (item (item k yrs-seq) corn-N-use)) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "wheat-N-use item k: " (item (item k yrs-seq) wheat-N-use)) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "soybean-N-use item k: " (item (item k yrs-seq) soybean-N-use)) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "milo-N-use item k: " (item (item k yrs-seq) milo-N-use)) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "N-accu-temp" N-accu-temp)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "N-accu" N-accu)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;print (word "contaminant" yrs-seq)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

to treatment                                                                                        ;Treatment
  if random 10 = 1 [                                                                                ;10% chance
    ask river-patches [
      if any? river-patches with [pcolor = brown] [
        ask one-of river-patches with [pcolor = brown] [
          set pcolor 87]
      ]
    ]
  ]
end

to reset-symbols                                                                                      ;Reset number of wind turbines and solar panels every tick
  ask turtles [die]                                                                                   ;It is similar to "setup" procedure showing above
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

  set solar-production (#Solar_Panels * Panel_power * 5 * 365 / 1000000)
  set wind-production (#wind_turbines * turbine_size * 0.425 * 24 * 365)
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
348
30
805
488
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
8
109
82
169
Corn-area
125.0
1
0
Number

INPUTBOX
85
109
159
169
Wheat-area
125.0
1
0
Number

INPUTBOX
162
109
244
169
Soybean-area
125.0
1
0
Number

INPUTBOX
247
109
321
169
Milo-area
125.0
1
0
Number

TEXTBOX
9
89
346
113
Agriculture -------------------------------\n
13
63.0
1

PLOT
1112
30
1396
150
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
"Corn" 1.0 0 -4079321 true "" ";ifelse ticks = 0 [set corn-expenses 0][plot (corn-tot-income - corn-expenses)]\nplot corn-net-income"
"Wheat" 1.0 0 -3844592 true "" ";ifelse ticks = 0 [set wheat-expenses 0][plot (wheat-tot-income - wheat-expenses)]\nplot wheat-net-income"
"Soybean" 1.0 0 -13210332 true "" ";ifelse ticks = 0 [set soybean-expenses 0][plot (soybean-tot-income - soybean-expenses)]\nplot soybean-net-income"
"Milo" 1.0 0 -12440034 true "" ";ifelse ticks = 0 [set milo-expenses 0][plot (milo-tot-income - milo-expenses)]\nplot milo-net-income"
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
7
365
345
384
Water ------------------------------------
13
95.0
1

TEXTBOX
8
195
347
215
Energy -----------------------------------
13
25.0
1

PLOT
824
316
1108
436
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
"Corn" 1.0 0 -4079321 true "" "ifelse corn-area = 0 \n  [set corn-use-in 0\n   plot corn-use-in]\n  [plot corn-use-in]"
"Wheat" 1.0 0 -3844592 true "" "ifelse wheat-area = 0 \n  [set wheat-use-in 0\n   plot wheat-use-in]\n  [plot wheat-use-in]"
"Soybean" 1.0 0 -13210332 true "" "ifelse soybean-area = 0 \n  [set soybean-use-in 0\n   plot soybean-use-in]\n  [plot soybean-use-in]"
"Milo" 1.0 0 -12440034 true "" "ifelse milo-area = 0 \n  [set milo-use-in 0\n   plot milo-use-in]\n  [plot milo-use-in]"

PLOT
824
30
1108
150
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
"Corn" 1.0 0 -4079321 true "" "ifelse corn-area = 0 \n  [set corn-tot-yield 0 \n   plot corn-tot-yield] \n  [plot corn-tot-yield]"
"Wheat" 1.0 0 -3844592 true "" "ifelse wheat-area = 0 \n  [set wheat-tot-yield 0 \n   plot wheat-tot-yield] \n  [plot wheat-tot-yield]"
"Soybean" 1.0 0 -13210332 true "" "ifelse soybean-area = 0 \n  [set soybean-tot-yield 0\n   plot soybean-tot-yield] \n  [plot soybean-tot-yield]"
"Milo" 1.0 0 -12440034 true "" "ifelse milo-area = 0 \n  [set milo-tot-yield 0\n   plot milo-tot-yield]\n  [plot milo-tot-yield]"

BUTTON
160
10
223
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
18
321
159
354
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
137
48
321
81
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
162
249
304
282
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
17
233
159
261
1 set = 1000 solar panels
11
0.0
1

SLIDER
17
249
159
282
#Solar_panel_sets
#Solar_panel_sets
0
8
3.0
1
1
NIL
HORIZONTAL

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
9
172
235
190
Circles show proportional crop areas (acres)
10
0.0
1

PLOT
824
173
1108
293
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
7
428
353
446
Climate Scenario ---------------------------------
12
0.0
1

CHOOSER
7
449
210
494
Future_Process
Future_Process
"Repeat Historical" "Wetter Future" "Dryer Future" "Impose T, P, & S Changes"
0

TEXTBOX
18
305
131
323
2-MW Wind Turbine
11
0.0
1

PLOT
824
460
1108
580
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
9
290
46
318
• Wind
11
25.0
1

TEXTBOX
9
218
49
236
• Solar
11
25.0
1

PLOT
1112
173
1396
293
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
825
10
1402
33
Agriculture ------------------------------------------------------
15
63.0
1

TEXTBOX
823
152
1402
171
Energy ----------------------------------------------------------
15
25.0
1

TEXTBOX
824
295
1398
314
Water ----------------------------------------------------------
15
95.0
1

TEXTBOX
347
491
802
526
*First 10 years use historical data from 2008 to 2017, subsequent years apply Future Process.
10
5.0
1

TEXTBOX
8
388
313
418
• Water is assumed to come from groundwater pumping. • Effects on water quality are represented.
11
95.0
1

MONITOR
933
716
1012
761
NIL
current-elev
3
1
11

MONITOR
1091
716
1181
761
NIL
patch-change
3
1
11

MONITOR
1015
716
1088
761
NIL
gw-change
3
1
11

MONITOR
837
716
930
761
NIL
water-use-feet
3
1
11

TEXTBOX
348
504
803
522
**Year in these plots represents a sequential year, i.e., year 1 is year 2008.
10
5.0
1

PLOT
1112
316
1396
436
Water-level Change
Years
Feet
0.0
60.0
0.0
5.0
true
true
"set-plot-background-color 88" ""
PENS
"Level      " 1.0 0 -14454117 true "" "plot gw-change"
"0 ft" 1.0 2 -8053223 true "" "plot zero-line"

TEXTBOX
1156
407
1344
425
Water declines if water use > 0.978 ft
9
105.0
1

TEXTBOX
349
10
499
29
World
15
0.0
1

TEXTBOX
824
438
1109
457
Farm Economy -------------------
15
0.0
1

SLIDER
8
48
134
81
Input-years
Input-years
0
200
60.0
5
1
NIL
HORIZONTAL

@#$#@#$#@
# FEWCalc
**FEWCalc** is the **Food-Energy-Water Calculator** assembled by Jirapat Phetheet and Professor Mary C. Hill from Department of Geology, the University of Kansas. 

The calculation is divided into two parts. The first part is crop calculation using a crop model called Decision Support System for Agrotechnology Transfer (DSSAT) which was developed by [Jones et al., 2003](https://doi.org/10.1016/S1161-0301(02)00107-7) from the University of Florida. The other is the FEWCalc conducted using NetLogo agent-based modeling software by [Uri Wilensky, 1999](https://ccl.northwestern.edu/netlogo/docs). 

The location considered is the area around Garden City in [Finney County, Kansas.](https://en.wikipedia.org/wiki/Finney_County,_Kansas) FEWCalc is developed and tested using data from the southern High Plains aquifer (HPA), where groundwater has been decreasing at an alarming rate these days. Fortunately, Kansas is well positioned in the nation's wind belt that has access to a robust renewable energy source (Anderson et al., 2012). Economically, Kansas is the second leading state, with about 50% of the electricity sold in the state being met by wind (Wiser and Bolinger, 2018).

FEWCalc is an interactive tool integrating agriculture, energy, and water components; calculating farm income; as well as visualizing results in the NetLogo World.

![HPA](file:HPA_Lifetime.png)

![WIND](file:Wind_Map.png)

## Load input data and initialize parameters
### Load input data
There are four input files in comma-separated values (.csv) format under "FEWCalc" folder. Input values (e.g., precipitation and crop price) were from historical data between 2008 and 2017. Besides, they were calculated from DSSAT (e.g., yield and irrigation) using the same dataset. The input files listed below are separated into four major crop types in Kansas which are corn, wheat, soybean, and milo (sorghum).

  * _**1_Corn_inputs.csv**_
  * _**2_Wheat_inputs.csv**_
  * _**3_Soybean_inputs.csv**_
  * _**4_Milo_inputs.csv**_

These files are composed of a number of columns which column headers are not well-defined. Here is a detailed explanation of those values.

  * **Year:** simulation year.
  * **Precip (in):** historical precipitation.
  * **Price ($/bu):** historical crop price.
  * **Yield_1 (bu/ac):** simulated yield from irrigated farming using historical data.
  * **Irrig_1 (in):** simulated irrigation from irrigated farming using historical data.
  * **Yield_2 (bu/ac):** simulated yield from dryland farming using historical data.
  * **Irrig_2 (in):** simulated irrigation from dryland farming using historical data. Values in this column are always zero.
  * **Yield_3 (bu/ac):** simulated yield from irrigated farming using Global Climate Models (GCMs) data.
  * **Irrig_3 (in):** simulated irrigation from irrigated farming using Global Climate Models (GCMs) data.
  * **Yield_4 (bu/ac):** simulated yield from dryland farming using Global Climate Models (GCMs) data.
  * **Irrig_4 (in):** simulated irrigation from dryland farming using Global Climate Models (GCMs) data. Values in this column are always zero.
  * **Unit explanation:** in is inch, $ is dollar, bu is bushel, and ac is acre.

**Unit conversion**

  * 1 bushel corn or milo per acre = 62.77 kilograms per hectare
  * 1 bushel wheat or soybean per acre = 67.25 kilograms per hectare

### Initialize parameters

FEWCalc allows users to specify parameters for their own simulation in the NetLogo's interface. It is designed to define those numbers easily by using input box, slider, and chooser. Each parameter is described below.

  * **Input-years:** a period of simulation.
  * **Aquifer-thickness:** a thickness of aquifer in foot unit.
  * **Corn-area:** an area of corn in acre unit.
  * **Wheat-area:** an area of wheat in acre unit.
  * **Soybean-area:** an area of soybean in acre unit.
  * **Milo-area:** an area of milo in acre unit.
  * **#Solar_panel_sets:** a number of solar panel set (each set has 1000 solar panels).
  * **Panel_power:** power of solar panel (a default value is 250 watts).
  * **#Wind_turbines:** a number of wind turbines.
  * **Future_Process:** a drop-down menu of future process. Future process will be activated automatically after 10-year simulation using historical data from 2008 to 2017.
    * Repeat Historical - 10-year DSSAT results are repeated consecutively.
    * Wetter Years - a future that is wetter than historical period.
    * Dryer Years - a future that is drier than historical period.
    * Climate Projection - a future involved climate change.

## Model function


### Agriculture

Crop simulations in FEWCalc are from simulated data from DSSAT. Results from DSSAT were based on both historical weather data from 2008 to 2017 and statistically downscaled Global Climate Models (GCMs) data under RCP8.5. Users have to select one of the future processes under **Climate Scenario** section. There are 4 options including _(1) Repeat Historical, (2) Wetter Years, (3) Dryer Years, and (4) Climate Projection._ Climate Projection scenario is the only one option applying GCMs data for the projection.

**IRRIGATED FARMING**
FEWCalc assumes that water for irrigation is all from groundwater. The model simulates irrigated farmland if the water is available and the aquifer thickness is not less than 20 percent of its initial thickness.

**DRYLAND FARMING**
During the simulation, groundwater is being consumed to supply water through the system. When the aquifer is depleted more than 80 percent of its initial thickness, the model stops irrigating and then applies dryland farming in the system. 


**CROP INSURANCE**
When crop production declines significantly, farmers would be able to claim insurance. Simulating crop insurance payment requires an understanding of insurance guarantees. Crop insurance guarantees are based on the level of coverage:

  * Corn 75%
  * Wheat 70%
  * Soybean 65-70%
  * Milo 65%

These guarantees are calculated by taking this equation:
>   * Insurance guarantee ($/ac) = average 10-year production history * level of coverage * base price

Contact: Wade Heger KU (wheger@ku.edu), Allan Andales CSU (Allan.Andales@colostate.edu), and Garvey Smith CSU (Garvey.Smith@colostate.edu)

### Energy

This recent version of FEWCalc assumes that installation cost spreads over 30 years. Users can define the number of solar panels and wind turbines in the interface under **Energy** section. A default wind turbine power is set at 2 megawatts.

_EQUATIONS:_

>  * Solar production (MWh) = number of solar panels * power * average peak sun hours
  * Wind production (MWh) = number of wind turbine * power * capacity factor
  * Solar cost ($) = number of solar panels * power * $3050/kW
  * Wind cost ($) = number of wind turbines * [($2,000,000 / 30 years) + $60,000]
  * Solar sell ($) = solar production * $38/MWh
  * Wind sell ($) = wind production * $38/MWh

Installation cost is $1000/kW. Hence, a 2-MW wind turbine costs $2,000,000 for installation (operate over 30 years). Operations and maintenance costs are about 3% of the installation cost, accounting for $60,000.

Contact: Bob Johnson (bobjohnson@centurylink.net), Earnie Lehman (earnielehman@gmail.com), and Hongyu Wu (hongyuwu@ksu.edu)

### Water

**GROUNDWATER**

  * **Water-level change versus water use:**
[Whittemore et al (2016)](https://doi.org/10.1080/02626667.2014.959958) assessed the main drivers of water-level changes in the High Plain aquifer. They computed linear regression equations for correlation of mean annual water-level changes with reported water use during 1996-2012. They also evaluated the predicted response of the HPA and concluded that (1) water pumped for irrigation is the major driver of water-level changes. Besides, (2) a pumping reduction of 22% would stabilize the water level, and this could help extend the usable lifetime of the aquifer.
  * **Groundwater depletion:** 
FEWCalc employs a statistical method to determine the specific relationship between water-level change and water use for agriculture. A linear regression equation below was calculated based on historical data from 2008 to 2017 in Finney County, Kansas.

> Water-level change (ft) = [-8.6628 * water use (ft)] + 8.4722

**FUTURE WORK:** SURFACE WATER

  * Surface water contamination
  * Treatment processes

Contact: Blake B. Wilson KGS (bwilson@kgs.ku.edu)

### Output displays


## Start the simulation
  1. Set model options (see "Initialize parameters")
  2. Click **Setup**
  3. Click **Go** to run the entire simulation or click **Go once** to advance the simulation one time step.

## References

Anderson, A.C., Gibson, B., White, S.W., & Hagedorn, L. (2012). The Economic Benefis of Kansas Wind Energy. Retrieved from https://www.renewableenergylawinsider.com/wp-content/uploads/sites/165/2012/11/Kansas-Wind-Report.pdf

Jones, J.W, Hoogenboom, G., Porter, C., Boote, K., Batchelor, W., Hunt, L., … Ritchie, J. (2003). The DSSAT cropping system model. European Journal of Agronomy, 18(3–4), 235–265. doi:10.1016/S1161-0301(02)00107-7.

Kansas Geological Survey (KGS). (2007). Estimated Usable Lifetime for the High Plains Aquifer in Kansas, available at: http://www.kgs.ku.edu/HighPlains/maps/index.shtml.

National Renewable Energy Laboratory (NREL). (2011). United States – Annual Average Wind Speed at 80 m., available at: https://www.nrel.gov/gis/wind.html.

Whittemore, D.O., Butler, J.J., & Wilson, B.B. (2016). Assessing the major drivers of water-level declines: new insights into the future of heavily stressed aquifers. 
Hydrological Sciences Journal, 61(1), 134-145. doi:10.1080/02626667.2014.959958.

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo. Center for Connected Learning and Computer-Based Modeling, Northwestern University. Evanston, IL.

Wiser, R., & Bolinger, M. (2019). 2018 Wind Technologies Market Report. U.S. Department of Energy. Retrieved from https://emp.lbl.gov/sites/default/files/wtmr_final_for_posting_8-9-19.pdf
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
