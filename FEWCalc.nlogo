;Version 1.0.1
;Assembled by Jirapat (Mos) Phetheet and Professor Mary C. Hill, Department of Geology, University of Kansas

extensions [csv bitmap]

globals [
  cropland-patches aquifer-patches river-patches wind-bar solar-bar wind-patches solar-patches corn-patches
  crop-area crop-color radius-of-%area total-area area-multiplier crop-background
  precip_raw current-elev patch-change yrs-seq zero-line precip_RCP8.5 precip_RCP4.5 gw-level
  corn-data corn-GCMs corn-sum_1 corn-sum_2 corn-price corn-yield_1 corn-irrig_1 corn-yield_2 corn-irrig_2 corn-yield_3 corn-irrig_3 corn-yield_4 corn-irrig_4 corn-yield_5 corn-irrig_5 corn-yield_6 corn-irrig_6
  wheat-data wheat-GCMs wheat-sum_1 wheat-sum_2 wheat-price wheat-yield_1 wheat-irrig_1 wheat-yield_2 wheat-irrig_2 wheat-yield_3 wheat-irrig_3 wheat-yield_4 wheat-irrig_4 wheat-yield_5 wheat-irrig_5 wheat-yield_6 wheat-irrig_6
  soybeans-data soybeans-GCMs soybeans-sum_1 soybeans-sum_2 soybeans-price soybeans-yield_1 soybeans-irrig_1 soybeans-yield_2 soybeans-irrig_2 soybeans-yield_3 soybeans-irrig_3 soybeans-yield_4 soybeans-irrig_4 soybeans-yield_5 soybeans-irrig_5 soybeans-yield_6 soybeans-irrig_6
  milo-data milo-GCMs milo-sum_1 milo-sum_2 milo-price milo-yield_1 milo-irrig_1 milo-yield_2 milo-irrig_2 milo-yield_3 milo-irrig_3 milo-yield_4 milo-irrig_4 milo-yield_5 milo-irrig_5 milo-yield_6 milo-irrig_6
  corn-expenses wheat-expenses soybeans-expenses milo-expenses
  corn-tot-income wheat-tot-income soybeans-tot-income milo-tot-income
  corn-net-income wheat-net-income soybeans-net-income milo-net-income
  corn-history wheat-history soybeans-history milo-history
  corn-coverage wheat-coverage soybeans-coverage milo-coverage
  corn-price-FM wheat-price-FM soybeans-price-FM milo-price-FM
  corn-income-guarantee wheat-income-guarantee soybeans-income-guarantee milo-income-guarantee corn-claimed wheat-claimed soybeans-claimed milo-claimed
  corn-yield-guarantee wheat-yield-guarantee soybeans-yield-guarantee milo-yield-guarantee
  corn-ins-claimed wheat-ins-claimed soybeans-ins-claimed milo-ins-claimed corn-yield-deficiency wheat-yield-deficiency soybeans-yield-deficiency milo-yield-deficiency
  corn-mean-yield wheat-mean-yield soybeans-mean-yield milo-mean-yield
  corn-tot-yield wheat-tot-yield soybeans-tot-yield milo-tot-yield
  corn-irrig-increment wheat-irrig-increment soybeans-irrig-increment milo-irrig-increment
  corn-use-in wheat-use-in soybeans-use-in milo-use-in water-use-feet gw-change calibrated-water-use dryland-check? GCM-random-year level-low level-low-patch level-60 level-60-patch gw-upper-limit
  corn-N-app wheat-N-app soybeans-N-app milo-N-app N-accu N-accu2 N-accu-temp
  #Solar_panels solar-production solar-production_temp count-solar-lifespan solar-cost solar-sell solar-sell_temp solar-net-income %Solar-production count-solar-lifespan-sell term-loan_S interest-rate_S term-loan_W interest-rate_W
  wind-production wind-production_temp wind-cost wind-sell wind-sell_temp wind-net-income energy-net-income %Wind-production count-wind-lifespan count-wind-lifespan-cost count-wind-lifespan-sell
]

to setup
  ca                                                                                                ;Clear all
  import-data                                                                                       ;Import data from csv file in the FEWCalc folder


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;; ADVANCED USER INPUTS ;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Level of coverage
  set corn-coverage 0.75                                                                            ;Level of coverage
  set wheat-coverage 0.7                                                                            ;Level of coverage
  set soybeans-coverage 0.7                                                                         ;Level of coverage
  set milo-coverage 0.65                                                                            ;Level of coverage

  ;Future market price
  set corn-price-FM 4.12                                                                            ;Futures market price for crop insurance calculation
  set wheat-price-FM 6.94                                                                           ;Futures market price for crop insurance calculation
  set soybeans-price-FM 9.39                                                                        ;Futures market price for crop insurance calculation
  set milo-price-FM 3.14                                                                            ;Futures market price for crop insurance calculation

  ;Finance: the recent work, term loan = lifespan of the equipments
  set term-loan_S Nyear_S                                                                           ;Set solar production term loan = solar panel lifespan (Future work)
  set interest-rate_S 0                                                                             ;Set solar production interest rate = 0% per year (Future work)
  set term-loan_W Nyear_W                                                                           ;Set wind production loan = wind turbine lifespan (Future work)
  set interest-rate_W 0                                                                             ;Set wind production interest rate = 0% per year (Future work)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;; cropland patches ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set total-area (Corn_area + Wheat_area + Soybeans_area + SG_area)                                 ;Calculate total crop area
  set area-multiplier 3000                                                                          ;A factor for scaling size of crop circles (it does not affect the calculation)
  set N-accu 0                                                                                      ;No N accumulation in soil at the beginning
  set N-accu2 0                                                                                     ;No N accumulation in surface-water bodies at the beginning
  set dryland-check? 1                                                                              ;Check first dryland farming, Dryland-check? = 1 means that it's the first dryland farming

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
  set crop-area lput Corn_area crop-area
  set crop-area lput Wheat_area crop-area
  set crop-area lput Soybeans_area crop-area
  set crop-area lput SG_area crop-area

  set radius-of-%area []                                                                            ;crop areas are calculated as percentage of total area

  let n 0                                                                                           ;Set temporary variable
  let m 0
  foreach crop-area [ x ->
    set radius-of-%area lput sqrt ((x / (sum crop-area) * area-multiplier) / pi) radius-of-%area    ;Calculate radius of crop circle
  ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                            ;Set "aquifer-patches" and patch's color
  ;;;;;;;;;;;;;;;;;;; Aquifer patches ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set current-elev 69                                                                               ;Set top of aquifer = max pycor of "aquifer patches" (pycor = 69)
  set gw-level Aquifer_thickness                                                                    ;Initialize gw-level variable
  set aquifer-patches patches with [pxcor > 66 and pxcor < 83 and pycor < 70]                       ;Introduce aquifer-patches
  ask aquifer-patches [set pcolor blue]                                                             ;Set aquifer-patches = blue
  ask patch 79 -97 [set plabel "GW"]                                                                ;Label GW

  set gw-upper-limit (Min_Aq_Thickness + 30)                                                        ;Set upper threshold of gw level during dryland farming
  set level-low-patch (Min_Aq_Thickness * 170 / Aquifer_thickness)                                  ;Calculate #patches below Min_AQ_Thickness in gw-patches (lower limit)
  set level-60-patch (gw-upper-limit * 170 / Aquifer_thickness)                                     ;Calculate #patches below 60 feet in gw-patches (upper limit)
  set level-low (-100 + level-low-patch)                                                            ;Locate a level where lower level is.
  set level-60 (-100 + level-60-patch)                                                              ;Locate a level where upper level is.

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                            ;Set "river-patches" and patch's color
  ;;;;;;;;;;;;;;;;;;;; River patches ;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set river-patches patches with [pxcor > 66 and pxcor < 83 and pycor > 70]
  ask river-patches [set pcolor 87]
  ask patch 78 96 [                                                                                 ;Label "SW"
    set plabel "SW"
    set plabel-color black]

    ask patch 64 96 [                                                                               ;Label "Nitrate in SW"
    set plabel "Nitrate in SW"
    set plabel-color white]

  ask patch 64 87 [                                                                                 ;Label "lbs"
    set plabel "lbs"
    set plabel-color white]

  ask patch 54 87 [                                                                                 ;Print a cumulative amount of nitrate in surface water
    set plabel round (N-accu2)
    set plabel-color white]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                            ;Set "solar-patches" and patch's color
  ;;;;;;;;;;;;;;;;;;; Solar patches ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set count-solar-lifespan 0                                                                        ;Initialize solar lifespan = 0
  set count-wind-lifespan 0                                                                         ;Initialize wind lifespan = 0
  set count-wind-lifespan-cost 0                                                                    ;Initialize wind lifespan = 0 for cost calculation
  set count-wind-lifespan-sell 0                                                                    ;Initialize wind lifespan = 0 for income calculation
  set count-solar-lifespan-sell 0                                                                   ;Initialize solar lifespan = 0 for income calculation
  set zero-line 0                                                                                   ;Use to draw a zero line in plots

  initialize-energy                                                                                 ;Initialize the amount of energy (see "to initialize-energy")

  set %Solar-production (Solar-production * 100 / (Solar-production + Wind-production))             ;Calculate % of solar production
  set %Wind-production (Wind-production * 100 / (Solar-production + Wind-production))               ;Calculate % of wind production

  set solar-bar patches with [pxcor > 83]                                                           ;Set a place to locate solar scale-bar
  ask solar-bar with [pycor > (-100 + (2 * %Wind-production))] [
    set pcolor [255 165 0]]

  ask patch 93 96 [                                                                                 ;Print %solar capacity in the World
    set plabel round (%Solar-production)
    set plabel-color black]
  ask patch 98 96 [                                                                                 ;Label "%"
    set plabel "%"
    set plabel-color black]
  ask patch 99 90 [                                                                                 ;Label "Solar"
    set plabel "Solar"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;; Wind patches ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set wind-bar patches with [pxcor > 83]                                                            ;Set a place to locate wind scale-bar
  ask wind-bar with [pycor < (-100 + (2 * %Wind-production))] [
    set pcolor yellow]

  ask patch 93 -91 [                                                                                ;Print %wind capacity in the World
    set plabel round (%Wind-production)
    set plabel-color black]
  ask patch 98 -91 [                                                                                ;Label "%"
    set plabel "%"
    set plabel-color black]
  ask patch 99 -97 [                                                                                ;Label "Wind"
    set plabel "Wind"
    set plabel-color black]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;; Crop Circles ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if Corn_area > 0 [                                                                                ;Check: Is corn simulated?
    ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]                 ;Create a crop circle
    import-drawing "Symbol-corn.png"                                                                ;There is "a problem" with this image. It disappears.
    import-drawing "Symbol-corn.png"                                                                ;To solve the problem, we import this image twice.
    ask patch 6 -27 [set plabel "Corn"]]                                                            ;Label "Corn"

  if Wheat_area > 0 [                                                                               ;Check: Is wheat simulated?
    ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]               ;Create a crop circle
    import-drawing "Symbol-wheat.png"                                                               ;Import a wheat symbol.
    ask patch -9 63 [
        set plabel "Wheat"                                                                          ;Label "Wheat"
        set plabel-color black]]

  if Soybeans_area > 0 [                                                                            ;Check: Are soybeans simulated?
    ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]            ;Create a crop circle
    import-drawing "Symbol-soybeans.png"                                                            ;Import a soybean symbol.
    ask patch -38 -72 [
        set plabel "soybeans"                                                                       ;Label "Soybeans"
        set plabel-color black]]

  if SG_area > 0 [                                                                                  ;Check: Is grain sorghum simulated?
    ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]               ;Create a crop circle
    import-drawing "Symbol-milo.png"                                                                ;Import a grain sorghum symbol.
    ask patch -43 -6 [set plabel "Grain"]                                                           ;Label "Grain"
    ask patch -38 -13 [set plabel "sorghum"]]                                                       ;Label "sorghum"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Wind icons ;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set wind-patches patches with [pxcor > 0 and pxcor < 65 and pycor < -35 and pycor > -100]         ;Set a location to place wind symbols

  let w 0                                                                                           ;Set a temporary variable
    repeat #wind_turbines [                                                                         ;Using ifelse statement to place wind turbines as grid arrangement
      ifelse w < 2 [
        crt 1 [
        setxy (35 + (w * 22)) -97
        set shape "wind"
        set size (Capacity_W * 30)
        set w (w + 1)]
      ]
        [ifelse w < 4 [
          crt 1 [
          setxy (25 + ((w - 2) * 22)) -65
          set shape "wind"
          set size (Capacity_W * 30)
          set w (w + 1)]
         ]
         [crt 1 [
           setxy (35 + ((w - 4) * 22)) -31
           set shape "wind"
           set size (Capacity_W * 30)
           set w (w + 1)]
         ]
       ]
     ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Solar icons ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set solar-patches patches with [pxcor > 0 and pxcor < 65 and pycor > 33 and pycor < 100]         ;Set a location to place solar symbols

  let t 0                                                                                          ;Set a temporary variable
    repeat ceiling #Panel_sets [                                                                           ;Using ifelse statement to place solar panels as grid arrangement
      ifelse t < 5 [
        crt 1 [
        setxy 56 (65 - (t * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
       [ifelse t < 10 [
         crt 1 [
         setxy 37 (65 - ((t - 5) * 12))
         set shape "solar"
         set size 20
         set t (t + 1)]
       ]
        [crt 1 [
          setxy 18 (65 - ((t - 10) * 12))
          set shape "solar"
          set size 20
          set t (t + 1)]
        ]
      ]
    ]

  reset-ticks                                                                                       ;Reset tick to zero
end

to go                                                                                               ;Go procedure
  if ticks = Simulation_period [stop]                                                               ;FEWCalc stops simulation when ticks exceed simulation_period
  check-area                                                                                        ;If a crop is not applied, FEWCalc sets all input variables to zero.
  reset-symbols                                                                                     ;In case variables are changed on the fly, solar panel or wind turbine symbols are changed.
  set GCM-random-year (random 80)                                                                   ;Create a random sequence of GCM (Available for advanced simulation because simulation period ranges from 0 to 90 years)
  future_processes                                                                                  ;See "to future-process"
  contaminant                                                                                       ;See "to contaminant"
  ;treatment                                                                                        ;Not applicable
  tick                                                                                              ;Advance tick
end

to import-data                                                                                      ;Create a number of lists to store values from csv files
  set precip_raw []                                                                                 ;A list for precipitation data
  set precip_RCP8.5 []                                                                              ;A list for GCM RCP8.5 precipitation data
  set precip_RCP4.5 []                                                                              ;A list for GCM RCP4.5 precipitation data
  set corn-data []                                                                                  ;All crop data including headings of the table
  set corn-GCMs []                                                                                  ;All crop data including headings of the table
  set corn-sum_1 []                                                                                 ;All crop data excluding headings of the table
  set corn-sum_2 []                                                                                 ;All crop data excluding headings of the table
  set corn-price []                                                                                 ;Historical crop price
  set corn-yield_1 []                                                                               ;Yield_1 means simulated yield from historical data
  set corn-irrig_1 []                                                                               ;Irrig_1 means simulated irrigation from historical data
  set corn-yield_2 []                                                                               ;Yield_2 means simulated yield from dryland simulation
  set corn-irrig_2 []                                                                               ;Irrig_2 means simulated irrigation from dryland simualtion (= zero)
  set corn-yield_3 []                                                                               ;Yield_3 means simulated yield from Global Climate Models (GCMs) data (RCP8.5)
  set corn-irrig_3 []                                                                               ;Irrig_3 means simulated irrigation from GCMs data (RCP8.5)
  set corn-yield_4 []                                                                               ;Yield_4 means simulated yield from GCMs data + dryland simulation (dryland RCP8.5)
  set corn-irrig_4 []                                                                               ;Irrig_4 means simulated irrigation from GCMs data + dryland simulation (dryland RCP8.5)
  set corn-yield_5 []                                                                               ;Yield_5 means simulated yield from Global Climate Models (GCMs) data (RCP4.5)
  set corn-irrig_5 []                                                                               ;Irrig_5 means simulated irrigation from GCMs data (RCP4.5)
  set corn-yield_6 []                                                                               ;Yield_6 means simulated yield from GCMs data + dryland simulation (dryland RCP4.5)
  set corn-irrig_6 []                                                                               ;Irrig_6 means simulated irrigation from GCMs data + dryland simulation (dryland RCP4.5)
  set corn-N-app []                                                                                 ;N application

  set wheat-data []                                                                                 ;See above from corn
  set Wheat-GCMs []
  set wheat-sum_1 []
  set wheat-sum_2 []
  set wheat-price []
  set wheat-yield_1 []
  set wheat-irrig_1 []
  set wheat-yield_2 []
  set wheat-irrig_2 []
  set wheat-yield_3 []
  set wheat-irrig_3 []
  set wheat-yield_4 []
  set wheat-irrig_4 []
  set wheat-yield_5 []
  set wheat-irrig_5 []
  set wheat-yield_6 []
  set wheat-irrig_6 []
  set wheat-N-app []

  set soybeans-data []                                                                              ;See above from corn
  set soybeans-GCMs []
  set soybeans-sum_1 []
  set soybeans-sum_2 []
  set soybeans-price []
  set soybeans-yield_1 []
  set soybeans-irrig_1 []
  set soybeans-yield_2 []
  set soybeans-irrig_2 []
  set soybeans-yield_3 []
  set soybeans-irrig_3 []
  set soybeans-yield_4 []
  set soybeans-irrig_4 []
  set soybeans-yield_5 []
  set soybeans-irrig_5 []
  set soybeans-yield_6 []
  set soybeans-irrig_6 []
  set soybeans-N-app []

  set milo-data []                                                                                  ;See above from corn
  set milo-GCMs []
  set milo-sum_1 []
  set milo-sum_2 []
  set milo-price []
  set milo-yield_1 []
  set milo-irrig_1 []
  set milo-yield_2 []
  set milo-irrig_2 []
  set milo-yield_3 []
  set milo-irrig_3 []
  set milo-yield_4 []
  set milo-irrig_4 []
  set milo-yield_5 []
  set milo-irrig_5 []
  set milo-yield_6 []
  set milo-irrig_6 []
  set milo-N-app []

  set corn-data lput csv:from-file "1_Corn_inputs.csv" corn-data                                    ;Import all corn values to a corn-data list
  set wheat-data lput csv:from-file "2_Wheat_inputs.csv" wheat-data                                 ;Import all wheat values to a wheat-data list
  set soybeans-data lput csv:from-file "3_Soybeans_inputs.csv" soybeans-data                        ;Import all soybeans values to a soybeans-data list
  set milo-data lput csv:from-file "4_Milo_inputs.csv" milo-data                                    ;Import all milo values to a milo-data list
  set corn-GCMs lput csv:from-file "5_Corn_GCMs.csv" corn-GCMs                                      ;Import all corn values to a corn-GCMs list
  set wheat-GCMs lput csv:from-file "6_Wheat_GCMs.csv" wheat-GCMs                                   ;Import all wheat values to a wheat-GCMs list
  set soybeans-GCMs lput csv:from-file "7_Soybeans_GCMs.csv" soybeans-GCMs                          ;Import all soybeans values to a soybeans-GCMs list
  set milo-GCMs lput csv:from-file "8_Milo_GCMs.csv" milo-GCMs                                      ;Import all milo values to a milo-GCMs list

  let m 1                                                                                           ;Set a temporary variable
  while [m < 11] [                                                                                  ;10 loops for 10-year data
    foreach corn-data [x -> set corn-sum_1 lput item m x corn-sum_1]                                ;Get rid of headings of the table (starting from item 1 instead of item 0)
      foreach corn-sum_1 [y -> set precip_raw lput item 1 y precip_raw]                             ;Item 1 of a csv file is precipitation
      foreach corn-sum_1 [y -> set corn-price lput item 2 y corn-price]                             ;Item 2 of a csv file is historical crop price
      foreach corn-sum_1 [y -> set corn-yield_1 lput item 3 y corn-yield_1]                         ;Item 3 of a csv file is yield_1 (yield_1 see "import-data" for more detail)
      foreach corn-sum_1 [y -> set corn-irrig_1 lput item 4 y corn-irrig_1]                         ;Item 4 of a csv file is irrig_1
      foreach corn-sum_1 [y -> set corn-yield_2 lput item 5 y corn-yield_2]                         ;Item 5 of a csv file is yield_2
      foreach corn-sum_1 [y -> set corn-irrig_2 lput item 6 y corn-irrig_2]                         ;Item 6 of a csv file is irrig_2
      foreach corn-sum_1 [y -> set corn-N-app lput item 7 y corn-N-app]                             ;Item 7 of a csv file is N-app

    foreach wheat-data [x -> set wheat-sum_1 lput item m x wheat-sum_1]                             ;See above
      foreach wheat-sum_1 [y -> set wheat-price lput item 2 y wheat-price]
      foreach wheat-sum_1 [y -> set wheat-yield_1 lput item 3 y wheat-yield_1]
      foreach wheat-sum_1 [y -> set wheat-irrig_1 lput item 4 y wheat-irrig_1]
      foreach wheat-sum_1 [y -> set wheat-yield_2 lput item 5 y wheat-yield_2]
      foreach wheat-sum_1 [y -> set wheat-irrig_2 lput item 6 y wheat-irrig_2]
      foreach wheat-sum_1 [y -> set wheat-N-app lput item 7 y wheat-N-app]

    foreach soybeans-data [x -> set soybeans-sum_1 lput item m x soybeans-sum_1]                    ;See above
      foreach soybeans-sum_1 [y -> set soybeans-price lput item 2 y soybeans-price]
      foreach soybeans-sum_1 [y -> set soybeans-yield_1 lput item 3 y soybeans-yield_1]
      foreach soybeans-sum_1 [y -> set soybeans-irrig_1 lput item 4 y soybeans-irrig_1]
      foreach soybeans-sum_1 [y -> set soybeans-yield_2 lput item 5 y soybeans-yield_2]
      foreach soybeans-sum_1 [y -> set soybeans-irrig_2 lput item 6 y soybeans-irrig_2]
      foreach soybeans-sum_1 [y -> set soybeans-N-app lput item 7 y soybeans-N-app]

    foreach milo-data [x -> set milo-sum_1 lput item m x milo-sum_1]                                ;See above
      foreach milo-sum_1 [y -> set milo-price lput item 2 y milo-price]
      foreach milo-sum_1 [y -> set milo-yield_1 lput item 3 y milo-yield_1]
      foreach milo-sum_1 [y -> set milo-irrig_1 lput item 4 y milo-irrig_1]
      foreach milo-sum_1 [y -> set milo-yield_2 lput item 5 y milo-yield_2]
      foreach milo-sum_1 [y -> set milo-irrig_2 lput item 6 y milo-irrig_2]
      foreach milo-sum_1 [y -> set milo-N-app lput item 7 y milo-N-app]

      if length precip_raw != 10 [set precip_raw []]

      if length corn-price != 10 [set corn-price []]
      if length corn-yield_1 != 10 [set corn-yield_1 []]
      if length corn-irrig_1 != 10 [set corn-irrig_1 []]
      if length corn-yield_2 != 10 [set corn-yield_2 []]
      if length corn-irrig_2 != 10 [set corn-irrig_2 []]
      if length corn-N-app != 10 [set corn-N-app []]

      if length wheat-price != 10 [set wheat-price []]
      if length wheat-yield_1 != 10 [set wheat-yield_1 []]
      if length wheat-irrig_1 != 10 [set wheat-irrig_1 []]
      if length wheat-yield_2 != 10 [set wheat-yield_2 []]
      if length wheat-irrig_2 != 10 [set wheat-irrig_2 []]
      if length wheat-N-app != 10 [set wheat-N-app []]

      if length soybeans-price != 10 [set soybeans-price []]
      if length soybeans-yield_1 != 10 [set soybeans-yield_1 []]
      if length soybeans-irrig_1 != 10 [set soybeans-irrig_1 []]
      if length soybeans-yield_2 != 10 [set soybeans-yield_2 []]
      if length soybeans-irrig_2 != 10 [set soybeans-irrig_2 []]
      if length soybeans-N-app != 10 [set soybeans-N-app []]

      if length milo-price != 10 [set milo-price []]
      if length milo-yield_1 != 10 [set milo-yield_1 []]
      if length milo-irrig_1 != 10 [set milo-irrig_1 []]
      if length milo-yield_2 != 10 [set milo-yield_2 []]
      if length milo-irrig_2 != 10 [set milo-irrig_2 []]
      if length milo-N-app != 10 [set milo-N-app []]

    set m (m + 1)
  ]

let n 1                                                                                             ;Set a temporary variable
  while [n < 82] [                                                                                  ;10 loops for 10-year data
    foreach corn-GCMs [x -> set corn-sum_2 lput item n x corn-sum_2]                                ;Get rid of headings of the table (starting from item 1 instead of item 0)
      foreach corn-sum_2 [y -> set precip_RCP8.5 lput item 1 y precip_RCP8.5]                       ;Item 1 of a csv file is precipitation (RCP8.5)
      foreach corn-sum_2 [y -> set corn-yield_3 lput item 2 y corn-yield_3]                         ;Item 2 of a csv file is yield_3
      foreach corn-sum_2 [y -> set corn-irrig_3 lput item 3 y corn-irrig_3]                         ;Item 3 of a csv file is irrig_3
      foreach corn-sum_2 [y -> set corn-yield_4 lput item 4 y corn-yield_4]                         ;Item 4 of a csv file is yield_4
      foreach corn-sum_2 [y -> set corn-irrig_4 lput item 5 y corn-irrig_4]                         ;Item 5 of a csv file is irrig_4
      foreach corn-sum_2 [y -> set precip_RCP4.5 lput item 6 y precip_RCP4.5]                       ;Item 1 of a csv file is precipitation (RCP4.5)
      foreach corn-sum_2 [y -> set corn-yield_5 lput item 7 y corn-yield_5]                         ;Item 2 of a csv file is yield_5
      foreach corn-sum_2 [y -> set corn-irrig_5 lput item 8 y corn-irrig_5]                         ;Item 3 of a csv file is irrig_5
      foreach corn-sum_2 [y -> set corn-yield_6 lput item 9 y corn-yield_6]                         ;Item 4 of a csv file is yield_6
      foreach corn-sum_2 [y -> set corn-irrig_6 lput item 10 y corn-irrig_6]                        ;Item 5 of a csv file is irrig_6

    foreach wheat-GCMs [x -> set wheat-sum_2 lput item n x wheat-sum_2]                             ;See above
      foreach wheat-sum_2 [y -> set wheat-yield_3 lput item 1 y wheat-yield_3]
      foreach wheat-sum_2 [y -> set wheat-irrig_3 lput item 2 y wheat-irrig_3]
      foreach wheat-sum_2 [y -> set wheat-yield_4 lput item 3 y wheat-yield_4]
      foreach wheat-sum_2 [y -> set wheat-irrig_4 lput item 4 y wheat-irrig_4]
      foreach wheat-sum_2 [y -> set wheat-yield_5 lput item 5 y wheat-yield_5]
      foreach wheat-sum_2 [y -> set wheat-irrig_5 lput item 6 y wheat-irrig_5]
      foreach wheat-sum_2 [y -> set wheat-yield_6 lput item 7 y wheat-yield_6]
      foreach wheat-sum_2 [y -> set wheat-irrig_6 lput item 8 y wheat-irrig_6]

    foreach soybeans-GCMs [x -> set soybeans-sum_2 lput item n x soybeans-sum_2]                    ;See above
      foreach soybeans-sum_2 [y -> set soybeans-yield_3 lput item 1 y soybeans-yield_3]
      foreach soybeans-sum_2 [y -> set soybeans-irrig_3 lput item 2 y soybeans-irrig_3]
      foreach soybeans-sum_2 [y -> set soybeans-yield_4 lput item 3 y soybeans-yield_4]
      foreach soybeans-sum_2 [y -> set soybeans-irrig_4 lput item 4 y soybeans-irrig_4]
      foreach soybeans-sum_2 [y -> set soybeans-yield_5 lput item 5 y soybeans-yield_5]
      foreach soybeans-sum_2 [y -> set soybeans-irrig_5 lput item 6 y soybeans-irrig_5]
      foreach soybeans-sum_2 [y -> set soybeans-yield_6 lput item 7 y soybeans-yield_6]
      foreach soybeans-sum_2 [y -> set soybeans-irrig_6 lput item 8 y soybeans-irrig_6]

    foreach milo-GCMs [x -> set milo-sum_2 lput item n x milo-sum_2]                                ;See above
      foreach milo-sum_2 [y -> set milo-yield_3 lput item 1 y milo-yield_3]
      foreach milo-sum_2 [y -> set milo-irrig_3 lput item 2 y milo-irrig_3]
      foreach milo-sum_2 [y -> set milo-yield_4 lput item 3 y milo-yield_4]
      foreach milo-sum_2 [y -> set milo-irrig_4 lput item 4 y milo-irrig_4]
      foreach milo-sum_2 [y -> set milo-yield_5 lput item 5 y milo-yield_5]
      foreach milo-sum_2 [y -> set milo-irrig_5 lput item 6 y milo-irrig_5]
      foreach milo-sum_2 [y -> set milo-yield_6 lput item 7 y milo-yield_6]
      foreach milo-sum_2 [y -> set milo-irrig_6 lput item 8 y milo-irrig_6]

      if length precip_RCP8.5 != 81 [set precip_RCP8.5 []]
      if length corn-yield_3 != 81 [set corn-yield_3 []]
      if length corn-irrig_3 != 81 [set corn-irrig_3 []]
      if length corn-yield_4 != 81 [set corn-yield_4 []]
      if length corn-irrig_4 != 81 [set corn-irrig_4 []]
      if length precip_RCP4.5 != 81 [set precip_RCP4.5 []]
      if length corn-yield_5 != 81 [set corn-yield_5 []]
      if length corn-irrig_5 != 81 [set corn-irrig_5 []]
      if length corn-yield_6 != 81 [set corn-yield_6 []]
      if length corn-irrig_6 != 81 [set corn-irrig_6 []]

      if length wheat-yield_3 != 81 [set wheat-yield_3 []]
      if length wheat-irrig_3 != 81 [set wheat-irrig_3 []]
      if length wheat-yield_4 != 81 [set wheat-yield_4 []]
      if length wheat-irrig_4 != 81 [set wheat-irrig_4 []]
      if length wheat-yield_5 != 81 [set wheat-yield_5 []]
      if length wheat-irrig_5 != 81 [set wheat-irrig_5 []]
      if length wheat-yield_6 != 81 [set wheat-yield_6 []]
      if length wheat-irrig_6 != 81 [set wheat-irrig_6 []]

      if length soybeans-yield_3 != 81 [set soybeans-yield_3 []]
      if length soybeans-irrig_3 != 81 [set soybeans-irrig_3 []]
      if length soybeans-yield_4 != 81 [set soybeans-yield_4 []]
      if length soybeans-irrig_4 != 81 [set soybeans-irrig_4 []]
      if length soybeans-yield_5 != 81 [set soybeans-yield_5 []]
      if length soybeans-irrig_5 != 81 [set soybeans-irrig_5 []]
      if length soybeans-yield_6 != 81 [set soybeans-yield_6 []]
      if length soybeans-irrig_6 != 81 [set soybeans-irrig_6 []]

      if length milo-yield_3 != 81 [set milo-yield_3 []]
      if length milo-irrig_3 != 81 [set milo-irrig_3 []]
      if length milo-yield_4 != 81 [set milo-yield_4 []]
      if length milo-irrig_4 != 81 [set milo-irrig_4 []]
      if length milo-yield_5 != 81 [set milo-yield_5 []]
      if length milo-irrig_5 != 81 [set milo-irrig_5 []]
      if length milo-yield_6 != 81 [set milo-yield_6 []]
      if length milo-irrig_6 != 81 [set milo-irrig_6 []]

    set n (n + 1)
  ]

  set corn-history corn-yield_1                                                                     ;Set historical production list for crop insurance calculation
  set wheat-history wheat-yield_1                                                                   ;Set historical production list for crop insurance calculation
  set soybeans-history soybeans-yield_1                                                             ;Set historical production list for crop insurance calculation
  set milo-history milo-yield_1                                                                     ;Set historical production list for crop insurance calculation
end

to calculate-expenses_yield_1                                                                       ;Expenses for irrigated farming [ref: AgManager.info (K-State, 2020 report)]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_1) < 210 [set corn-expenses (786.23 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_1) >= 210 and (item (item k yrs-seq) corn-yield_1) <= 237.5 [set corn-expenses (861.41 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_1) > 237.5 [set corn-expenses (920.04 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_1) < 62.5 [set wheat-expenses (498.13 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_1) >= 62.5 and (item (item k yrs-seq) wheat-yield_1) <= 67.5 [set wheat-expenses (523.43 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_1) > 67.5 [set wheat-expenses (548.74 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_1) < 58 [set soybeans-expenses (542.07 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_1) >= 58 and (item (item k yrs-seq) soybeans-yield_1) <= 64 [set soybeans-expenses (572.48 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_1) > 64 [set soybeans-expenses (620.95 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_1) < 150 [set milo-expenses (618.55 * SG_area)]
  if (item (item k yrs-seq) milo-yield_1) >= 150 and (item (item k yrs-seq) milo-yield_1) <= 170 [set milo-expenses (666.17 * SG_area)]
  if (item (item k yrs-seq) milo-yield_1) > 170 [set milo-expenses (713.79 * SG_area)]
end

to calculate-expenses_yield_2                                                                       ;Expenses for dryland farming [ref: AgManager.info (K-State, 2020 report)]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_2) < 66 [set corn-expenses (273.10 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_2) >= 66 and (item (item k yrs-seq) corn-yield_2) <= 91 [set corn-expenses (337.57 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_2) > 91 [set corn-expenses (377.54 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_2) < 37.5 [set wheat-expenses (245.47 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_2) >= 37.5 and (item (item k yrs-seq) wheat-yield_2) <= 46.5 [set wheat-expenses (277.41 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_2) > 46.5 [set wheat-expenses (309.35 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_2) < 22.5 [set soybeans-expenses (224.51 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_2) >= 22.5 and (item (item k yrs-seq) soybeans-yield_2) <= 27.5 [set soybeans-expenses (248.50 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_2) > 27.5 [set soybeans-expenses (272.48 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_2) < 68 [set milo-expenses (263.01 * SG_area)]
  if (item (item k yrs-seq) milo-yield_2) >= 68 and (item (item k yrs-seq) milo-yield_2) <= 93 [set milo-expenses (314.41 * SG_area)]
  if (item (item k yrs-seq) milo-yield_2) > 93 [set milo-expenses (361.86 * SG_area)]
end

to calculate-expenses_yield_3                                                                       ;Expenses for irrigated farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_3) < 210 [set corn-expenses (786.23 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_3) >= 210 and (item (item k yrs-seq) corn-yield_3) <= 237.5 [set corn-expenses (861.41 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_3) > 237.5 [set corn-expenses (920.04 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_3) < 62.5 [set wheat-expenses (498.13 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_3) >= 62.5 and (item (item k yrs-seq) wheat-yield_3) <= 67.5 [set wheat-expenses (523.43 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_3) > 67.5 [set wheat-expenses (548.74 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_3) < 58 [set soybeans-expenses (542.07 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_3) >= 58 and (item (item k yrs-seq) soybeans-yield_3) <= 64 [set soybeans-expenses (572.48 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_3) > 64 [set soybeans-expenses (620.95 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_3) < 150 [set milo-expenses (618.55 * SG_area)]
  if (item (item k yrs-seq) milo-yield_3) >= 150 and (item (item k yrs-seq) milo-yield_3) <= 170 [set milo-expenses (666.17 * SG_area)]
  if (item (item k yrs-seq) milo-yield_3) > 170 [set milo-expenses (713.79 * SG_area)]
end

to calculate-expenses_yield_4                                                                       ;Expenses for dryland farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_4) < 66 [set corn-expenses (273.10 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_4) >= 66 and (item (item k yrs-seq) corn-yield_4) <= 91 [set corn-expenses (337.57 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_4) > 91 [set corn-expenses (377.54 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_4) < 37.5 [set wheat-expenses (245.47 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_4) >= 37.5 and (item (item k yrs-seq) wheat-yield_4) <= 46.5 [set wheat-expenses (277.41 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_4) > 46.5 [set wheat-expenses (309.35 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_4) < 22.5 [set soybeans-expenses (224.51 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_4) >= 22.5 and (item (item k yrs-seq) soybeans-yield_4) <= 27.5 [set soybeans-expenses (248.50 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_4) > 27.5 [set soybeans-expenses (272.48 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_4) < 68 [set milo-expenses (263.01 * SG_area)]
  if (item (item k yrs-seq) milo-yield_4) >= 68 and (item (item k yrs-seq) milo-yield_4) <= 93 [set milo-expenses (314.41 * SG_area)]
  if (item (item k yrs-seq) milo-yield_4) > 93 [set milo-expenses (361.86 * SG_area)]
end

to calculate-expenses_yield_5                                                                       ;Expenses for irrigated farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_5) < 210 [set corn-expenses (786.23 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_5) >= 210 and (item (item k yrs-seq) corn-yield_5) <= 237.5 [set corn-expenses (861.41 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_5) > 237.5 [set corn-expenses (920.04 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_5) < 62.5 [set wheat-expenses (498.13 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_5) >= 62.5 and (item (item k yrs-seq) wheat-yield_5) <= 67.5 [set wheat-expenses (523.43 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_5) > 67.5 [set wheat-expenses (548.74 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_5) < 58 [set soybeans-expenses (542.07 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_5) >= 58 and (item (item k yrs-seq) soybeans-yield_5) <= 64 [set soybeans-expenses (572.48 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_5) > 64 [set soybeans-expenses (620.95 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_5) < 150 [set milo-expenses (618.55 * SG_area)]
  if (item (item k yrs-seq) milo-yield_5) >= 150 and (item (item k yrs-seq) milo-yield_5) <= 170 [set milo-expenses (666.17 * SG_area)]
  if (item (item k yrs-seq) milo-yield_5) > 170 [set milo-expenses (713.79 * SG_area)]
end

to calculate-expenses_yield_6                                                                       ;Expenses for dryland farming (using GCMs data) [ref: AgManager.info]
  let k (ticks mod 10)
  if (item (item k yrs-seq) corn-yield_6) < 66 [set corn-expenses (273.10 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_6) >= 66 and (item (item k yrs-seq) corn-yield_6) <= 91 [set corn-expenses (337.57 * Corn_area)]
  if (item (item k yrs-seq) corn-yield_6) > 91 [set corn-expenses (377.54 * Corn_area)]

  if (item (item k yrs-seq) wheat-yield_6) < 37.5 [set wheat-expenses (245.47 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_6) >= 37.5 and (item (item k yrs-seq) wheat-yield_6) <= 46.5 [set wheat-expenses (277.41 * Wheat_area)]
  if (item (item k yrs-seq) wheat-yield_6) > 46.5 [set wheat-expenses (309.35 * Wheat_area)]

  if (item (item k yrs-seq) soybeans-yield_6) < 22.5 [set soybeans-expenses (224.51 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_6) >= 22.5 and (item (item k yrs-seq) soybeans-yield_6) <= 27.5 [set soybeans-expenses (248.50 * Soybeans_area)]
  if (item (item k yrs-seq) soybeans-yield_6) > 27.5 [set soybeans-expenses (272.48 * Soybeans_area)]

  if (item (item k yrs-seq) milo-yield_6) < 68 [set milo-expenses (263.01 * SG_area)]
  if (item (item k yrs-seq) milo-yield_6) >= 68 and (item (item k yrs-seq) milo-yield_6) <= 93 [set milo-expenses (314.41 * SG_area)]
  if (item (item k yrs-seq) milo-yield_6) > 93 [set milo-expenses (361.86 * SG_area)]
end

to calculate-insurance
  if Corn_area > 0 [
  set corn-claimed "NO"                                                                             ;Default = "NO"
  ifelse corn-tot-yield > corn-yield-guarantee                                                      ;Apply crop insurance?
    [set corn-tot-income corn-tot-income
     ask patch 13 -35 [
      set plabel " "]]
    [set corn-yield-deficiency (corn-yield-guarantee - corn-tot-yield)                              ;Calculate yield deficiency
     ifelse corn-tot-income > corn-income-guarantee                                                 ;If current yield > guarantee yield
      [set corn-tot-income corn-tot-income]                                                         ;FEWCalc does not apply crop insurance.
      [set corn-claimed "YES"                                                                       ;Else: Apply crop insurance
       set corn-ins-claimed (corn-income-guarantee - corn-tot-income)                               ;Calculate indemnity paid
       set corn-tot-income corn-tot-income + (corn-yield-deficiency * corn-price-FM * Corn_area)    ;Calculate annual income

       ask patch 13 -35 [
       set plabel "Ins. Claim"                                                                      ;Print "Ins. Claim"
       set plabel-color red
       ]
      ]
    ]
  ]

  if Wheat_area > 0 [
  set wheat-claimed "NO"                                                                            ;Default = "NO"
  ifelse wheat-tot-yield > wheat-yield-guarantee                                                    ;Apply crop insurance?
    [set wheat-tot-income wheat-tot-income
     ask patch -5 56 [
      set plabel " "]]
    [set wheat-yield-deficiency (wheat-yield-guarantee - wheat-tot-yield)                           ;Calculate yield deficiency
     ifelse wheat-tot-income > wheat-income-guarantee                                               ;If current yield > guarantee yield
      [set wheat-tot-income wheat-tot-income]                                                       ;FEWCalc does not apply crop insurance.
      [set wheat-claimed "YES"                                                                      ;Else: Apply crop insurance
       set wheat-ins-claimed (wheat-income-guarantee - wheat-tot-income)                            ;Calculate indemnity paid
       set wheat-tot-income wheat-tot-income + (wheat-yield-deficiency * wheat-price-FM * Wheat_area) ;Calculate annual income

       ask patch -5 56 [
       set plabel "Ins. Claim"                                                                      ;Print "Ins. Claim"
       set plabel-color red
       ]
      ]
    ]
  ]

  if Soybeans_area > 0 [
  set soybeans-claimed "NO"                                                                         ;Default = "NO"
  ifelse soybeans-tot-yield > soybeans-yield-guarantee                                              ;Apply crop insurance?
    [set soybeans-tot-income soybeans-tot-income
     ask patch -37 -79 [
      set plabel " "]]
    [set soybeans-yield-deficiency (soybeans-yield-guarantee - soybeans-tot-yield)                  ;Calculate yield deficiency
     ifelse soybeans-tot-income > soybeans-income-guarantee                                         ;If current yield > guarantee yield
      [set soybeans-tot-income soybeans-tot-income]                                                 ;FEWCalc does not apply crop insurance.
      [set soybeans-claimed "YES"                                                                   ;Else: Apply crop insurance
       set soybeans-ins-claimed (soybeans-income-guarantee - soybeans-tot-income)                   ;Calculate indemnity paid
       set soybeans-tot-income soybeans-tot-income + (soybeans-yield-deficiency * soybeans-price-FM * Soybeans_area) ;Calculate annual income

       ask patch -37 -79 [
       set plabel "Ins. Claim"                                                                      ;Print "Ins. Claim"
       set plabel-color red
       ]
      ]
    ]
  ]

  if SG_area > 0 [
  set milo-claimed "NO"                                                                             ;Default = "NO"
  ifelse milo-tot-yield > milo-yield-guarantee                                                      ;Apply crop insurance?
    [set milo-tot-income milo-tot-income
     ask patch -37 -21 [
      set plabel " "]]
    [set milo-yield-deficiency (milo-yield-guarantee - milo-tot-yield)                              ;Calculate yield deficiency
     ifelse milo-tot-income > milo-income-guarantee                                                 ;If current yield > guarantee yield
      [set milo-tot-income milo-tot-income]                                                         ;FEWCalc does not apply crop insurance.
      [set milo-claimed "YES"                                                                       ;Else: Apply crop insurance
       set milo-ins-claimed (milo-income-guarantee - milo-tot-income)                               ;Calculate indemnity paid
       set milo-tot-income milo-tot-income + (milo-yield-deficiency * milo-price-FM * SG_area)      ;Calculate annual income

       ask patch -37 -21 [
       set plabel "Ins. Claim"                                                                      ;Print "Ins. Claim"
       set plabel-color red
       ]
      ]
    ]
  ]
end

to calculate-net-income                                                                             ;Calculate farm net income
  set corn-net-income (corn-tot-income - corn-expenses)
  set wheat-net-income (wheat-tot-income - wheat-expenses)
  set soybeans-net-income (soybeans-tot-income - soybeans-expenses)
  set milo-net-income (milo-tot-income - milo-expenses)
end

to future_processes
if Future_Process = "Repeat Historical"                                                             ;Repeat historical scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
     [food-calculation_1-1
      energy-calculation
      gw-depletion_1]

     [ifelse current-elev > level-60                                                                ;Irrigated farming
       [food-calculation_1-2
        energy-calculation
        gw-depletion_1]

       [ifelse current-elev > level-low and dryland-check? = 1                                      ;Irrigated farming
         [food-calculation_1-2
          energy-calculation
          gw-depletion_1]

            [dryland-farming_1                                                                      ;Dryland farming
             gw-depletion_dryland
             energy-calculation
             set dryland-check? 0
             if current-elev > level-60 [set dryland-check? 1]]
       ]
     ]
  ]

  if Future_Process = "Wetter Future"                                                               ;Wetter years scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
     [food-calculation_1-1
      energy-calculation
      gw-depletion_1]

     [ifelse current-elev > level-60                                                                ;Irrigated farming
       [food-calculation_2
        energy-calculation
        gw-depletion_2]

       [ifelse current-elev > level-low and dryland-check? = 1                                      ;Irrigated farming
         [food-calculation_2
          energy-calculation
          gw-depletion_2]

            [dryland-farming_2                                                                      ;Dryland farming
             gw-depletion_dryland
             energy-calculation
             set dryland-check? 0
             if current-elev > level-60 [set dryland-check? 1]]
       ]
     ]
  ]

  if Future_Process = "Dryer Future"                                                                ;Dryer years scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
     [food-calculation_1-1
      energy-calculation
      gw-depletion_1]

     [ifelse current-elev > level-60                                                                ;Irrigated farming
       [food-calculation_3
        energy-calculation
        gw-depletion_3]

       [ifelse current-elev > level-low and dryland-check? = 1                                      ;Irrigated farming
         [food-calculation_3
          energy-calculation
          gw-depletion_3]

            [dryland-farming_3                                                                      ;Dryland farming
             gw-depletion_dryland
             energy-calculation
             set dryland-check? 0
             if current-elev > level-60 [set dryland-check? 1]]
       ]
     ]
  ]

  if Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP8.5"                       ;Climate projection scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
     [food-calculation_1-1
      energy-calculation
      gw-depletion_1]

     [ifelse current-elev > level-60                                                                ;Irrigated farming
       [food-calculation_4
        energy-calculation
        gw-depletion_4]

       [ifelse current-elev > level-low and dryland-check? = 1                                      ;Irrigated farming
         [food-calculation_4
          energy-calculation
          gw-depletion_4]

            [dryland-farming_4                                                                      ;Dryland farming
             gw-depletion_dryland
             energy-calculation
             set dryland-check? 0
             if current-elev > level-60 [set dryland-check? 1]]
       ]
     ]
  ]

  if Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP4.5"                       ;Climate projection scenario
   [ifelse ticks <= 9                                                                               ;First 10 year data based on history
     [food-calculation_1-1
      energy-calculation
      gw-depletion_1]

     [ifelse current-elev > level-60                                                                ;Irrigated farming
       [food-calculation_5
        energy-calculation
        gw-depletion_5]

       [ifelse current-elev > level-low and dryland-check? = 1                                      ;Irrigated farming
         [food-calculation_5
          energy-calculation
          gw-depletion_5]

            [dryland-farming_5                                                                      ;Dryalnd farming
             gw-depletion_dryland
             energy-calculation
             set dryland-check? 0
             if current-elev > level-60 [set dryland-check? 1]]
       ]
     ]
  ]

end

to check-area                                                                                       ;Set all variables to zero if a crop area is zero

  if Corn_area = 0 [
    set corn-yield_1 (n-values 10 [0])
    set corn-irrig_1 (n-values 10 [0])
    set corn-yield_2 (n-values 10 [0])
    set corn-irrig_2 (n-values 10 [0])
    set corn-yield_3 (n-values 81 [0])
    set corn-irrig_3 (n-values 81 [0])
    set corn-yield_4 (n-values 81 [0])
    set corn-irrig_4 (n-values 81 [0])
    set corn-yield_5 (n-values 81 [0])
    set corn-irrig_5 (n-values 81 [0])
    set corn-yield_6 (n-values 81 [0])
    set corn-irrig_6 (n-values 81 [0])
    set corn-N-app (n-values 10 [0])
  ]

  if Wheat_area = 0 [
    set wheat-yield_1 (n-values 10 [0])
    set wheat-irrig_1 (n-values 10 [0])
    set wheat-yield_2 (n-values 10 [0])
    set wheat-irrig_2 (n-values 10 [0])
    set wheat-yield_3 (n-values 81 [0])
    set wheat-irrig_3 (n-values 81 [0])
    set wheat-yield_4 (n-values 81 [0])
    set wheat-irrig_4 (n-values 81 [0])
    set wheat-yield_5 (n-values 81 [0])
    set wheat-irrig_5 (n-values 81 [0])
    set wheat-yield_6 (n-values 81 [0])
    set wheat-irrig_6 (n-values 81 [0])
    set wheat-N-app (n-values 10 [0])
  ]

  if Soybeans_area = 0 [
    set soybeans-yield_1 (n-values 10 [0])
    set soybeans-irrig_1 (n-values 10 [0])
    set soybeans-yield_2 (n-values 10 [0])
    set soybeans-irrig_2 (n-values 10 [0])
    set soybeans-yield_3 (n-values 81 [0])
    set soybeans-irrig_3 (n-values 81 [0])
    set soybeans-yield_4 (n-values 81 [0])
    set soybeans-irrig_4 (n-values 81 [0])
    set soybeans-yield_5 (n-values 81 [0])
    set soybeans-irrig_5 (n-values 81 [0])
    set soybeans-yield_6 (n-values 81 [0])
    set soybeans-irrig_6 (n-values 81 [0])
    set soybeans-N-app (n-values 10 [0])
  ]

  if SG_area = 0 [
    set milo-yield_1 (n-values 10 [0])
    set milo-irrig_1 (n-values 10 [0])
    set milo-yield_2 (n-values 10 [0])
    set milo-irrig_2 (n-values 10 [0])
    set milo-yield_3 (n-values 81 [0])
    set milo-irrig_3 (n-values 81 [0])
    set milo-yield_4 (n-values 81 [0])
    set milo-irrig_4 (n-values 81 [0])
    set milo-yield_5 (n-values 81 [0])
    set milo-irrig_5 (n-values 81 [0])
    set milo-yield_6 (n-values 81 [0])
    set milo-irrig_6 (n-values 81 [0])
    set milo-N-app (n-values 10 [0])
  ]

end

;Agricultural part
to food-calculation_1-1                                                                             ;Crop calculation during a base period
  set yrs-seq [0 1 2 3 4 5 6 7 8 9]                                                                 ;Set yrs-seq: 0 = 2008, 1 = 2009, ... , 9 = 2017
  let n (ticks)                                                                                     ;Set a temp variable

  set corn-tot-income (item n corn-yield_1 * item n corn-price * Corn_area)                         ;Calculate ag net income
  set wheat-tot-income (item n wheat-yield_1 * item n wheat-price * Wheat_area)
  set soybeans-tot-income (item n soybeans-yield_1 * item n soybeans-price * Soybeans_area)
  set milo-tot-income (item n milo-yield_1 * item n milo-price * SG_area)

  set corn-tot-yield (item n corn-yield_1)                                                          ;Set (import) yield from csv file (variable)
  set wheat-tot-yield (item n wheat-yield_1)
  set soybeans-tot-yield (item n soybeans-yield_1)
  set milo-tot-yield (item n milo-yield_1)

  calculate-expenses_yield_1                                                                        ;See "to calculate-expenses_yield_1"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to food-calculation_1-2                                                                             ;Repeat historical data successively after 10 year simulation
  set yrs-seq [0 1 2 3 4 5 6 7 8 9]
  let n (ticks)

  set corn-tot-yield (item (n mod 10) corn-yield_1)                                                 ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (n mod 10) wheat-yield_1)                                               ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybeans-tot-yield (item (n mod 10) soybeans-yield_1)                                         ;Each tick, soybeans yield will be accessed from a "soybeans-yield_1" list
  set milo-tot-yield (item (n mod 10) milo-yield_1)                                                 ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate income guarantee
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (n mod 10) corn-yield_1 * item (n mod 10) corn-price * Corn_area)       ;Calculate farm gross income
  set wheat-tot-income (item (n mod 10) wheat-yield_1 * item (n mod 10) wheat-price * Wheat_area)
  set soybeans-tot-income (item (n mod 10) soybeans-yield_1 * item (n mod 10) soybeans-price * Soybeans_area)
  set milo-tot-income (item (n mod 10) milo-yield_1 * item (n mod 10) milo-price * SG_area)

  calculate-expenses_yield_1                                                                        ;See "to calculate-expenses_yield_1"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to food-calculation_2                                                                               ;Randomly choose wet year
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 7 7 7 7 0 6 7 8 9]                                                                ;List of wetter years. Year 7, 8, 9 are wet years; year 0, 6 are normal years.
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)                                           ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybeans-tot-yield (item (item n yrs-seq) soybeans-yield_1)                                   ;Each tick, soybeans yield will be accessed from a "soybeans-yield_1" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)                                           ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * one-of corn-price * Corn_area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * one-of wheat-price * Wheat_area)
  set soybeans-tot-income (item (item n yrs-seq) soybeans-yield_1 * one-of soybeans-price * Soybeans_area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * one-of milo-price * SG_area)

  calculate-expenses_yield_1                                                                        ;See "to calculate-expenses_yield_1"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to food-calculation_3                                                                               ;Randomly choose dry year
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 0 4 3 4 5 7 4 4 4]                                                                ;List of dryer years
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_1)                                           ;Each tick, corn yield will be accessed from a "corn-yield_1" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_1)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_1" list
  set soybeans-tot-yield (item (item n yrs-seq) soybeans-yield_1)                                   ;Each tick, soybeans yield will be accessed from a "soybeans-yield_1" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_1)                                           ;Each tick, milo yield will be accessed from a "milo-yield_1" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_1 * one-of corn-price * Corn_area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_1 * one-of wheat-price * Wheat_area)
  set soybeans-tot-income (item (item n yrs-seq) soybeans-yield_1 * one-of soybeans-price * Soybeans_area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_1 * one-of milo-price * SG_area)

  calculate-expenses_yield_1                                                                        ;See "to calculate-expenses_yield_1"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to food-calculation_4                                                                               ;Randomly choose data from GCMs RCP8.5
  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-tot-yield (item m corn-yield_3)                                                         ;Access data from GCM8.5 list
   set wheat-tot-yield (item m wheat-yield_3)
   set soybeans-tot-yield (item m soybeans-yield_3)
   set milo-tot-yield (item m milo-yield_3)]
  [set corn-tot-yield (item GCM-random-year corn-yield_3)                                           ;For year after 2098 (using a random sequence)
   set wheat-tot-yield (item GCM-random-year wheat-yield_3)
   set soybeans-tot-yield (item GCM-random-year soybeans-yield_3)
   set milo-tot-yield (item GCM-random-year milo-yield_3)]

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (corn-tot-yield * (one-of corn-price) * Corn_area)                            ;Calculate farm gross income
  set wheat-tot-income (wheat-tot-yield * (one-of wheat-price) * Wheat_area)
  set soybeans-tot-income (soybeans-tot-yield * (one-of soybeans-price) * Soybeans_area)
  set milo-tot-income (milo-tot-yield * (one-of milo-price) * SG_area)

  calculate-expenses_yield_3                                                                        ;See "to calculate-expenses_yield_3"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to food-calculation_5                                                                               ;Randomly choose data from GCMs RCP4.5
  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-tot-yield (item m corn-yield_5)                                                         ;Access data from GCM4.5 list
   set wheat-tot-yield (item m wheat-yield_5)
   set soybeans-tot-yield (item m soybeans-yield_5)
   set milo-tot-yield (item m milo-yield_5)]
  [set corn-tot-yield (item GCM-random-year corn-yield_5)                                           ;For year after 2098 (using a random sequence)
   set wheat-tot-yield (item GCM-random-year wheat-yield_5)
   set soybeans-tot-yield (item GCM-random-year soybeans-yield_5)
   set milo-tot-yield (item GCM-random-year milo-yield_5)]

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (corn-tot-yield * (one-of corn-price) * Corn_area)                            ;Calculate farm gross income
  set wheat-tot-income (wheat-tot-yield * (one-of wheat-price) * Wheat_area)
  set soybeans-tot-income (soybeans-tot-yield * (one-of soybeans-price) * Soybeans_area)
  set milo-tot-income (milo-tot-yield * (one-of milo-price) * SG_area)

  calculate-expenses_yield_5                                                                        ;See "to calculate-expenses_yield_5"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"
end

to dryland-farming_1
  let n (ticks)

  set corn-tot-yield (item (n mod 10) corn-yield_2)                                                 ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (n mod 10) wheat-yield_2)                                               ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybeans-tot-yield (item (n mod 10) soybeans-yield_2)                                         ;Each tick, soybeans yield will be accessed from a "soybeans-yield_2" list
  set milo-tot-yield (item (n mod 10) milo-yield_2)                                                 ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (n mod 10) corn-yield_2 * item (n mod 10) corn-price * Corn_area)       ;Calculate farm gross income
  set wheat-tot-income (item (n mod 10) wheat-yield_2 * item (n mod 10) wheat-price * Wheat_area)
  set soybeans-tot-income (item (n mod 10) soybeans-yield_2 * item (n mod 10) soybeans-price * Soybeans_area)
  set milo-tot-income (item (n mod 10) milo-yield_2 * item (n mod 10) milo-price * SG_area)

  calculate-expenses_yield_2                                                                        ;See "to calculate-expenses_yield_2"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_2                                              ;Each tick, irrigation will be accessed from a "soybeans-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_2
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 7 7 7 7 0 6 7 8 9]                                                                ;List of wetter years (must be the same seq as "food-calculation_2")
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)                                           ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybeans-tot-yield (item (item n yrs-seq) soybeans-yield_2)                                   ;Each tick, soybeans yield will be accessed from a "soybeans-yield_2" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)                                           ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * one-of corn-price * Corn_area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * one-of wheat-price * Wheat_area)
  set soybeans-tot-income (item (item n yrs-seq) soybeans-yield_2 * one-of soybeans-price * Soybeans_area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * one-of milo-price * SG_area)

  calculate-expenses_yield_2                                                                        ;See "to calculate-expenses_yield_2"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_2                                              ;Each tick, irrigation will be accessed from a "soybeans-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_3
  if (ticks mod 10) = 0                                                                             ;Shuffle yrs-seq every 10 years
  [set yrs-seq [0 0 4 3 4 5 7 4 4 4]                                                                ;List of dryer years (must be the same seq as "food-calculation_3")
   set yrs-seq shuffle yrs-seq]                                                                     ;Shuffle command

  let n (ticks mod 10)

  set corn-tot-yield (item (item n yrs-seq) corn-yield_2)                                           ;Each tick, corn yield will be accessed from a "corn-yield_2" list
  set wheat-tot-yield (item (item n yrs-seq) wheat-yield_2)                                         ;Each tick, wheat yield will be accessed from a "wheat-yield_2" list
  set soybeans-tot-yield (item (item n yrs-seq) soybeans-yield_2)                                   ;Each tick, soybeans yield will be accessed from a "soybeans-yield_2" list
  set milo-tot-yield (item (item n yrs-seq) milo-yield_2)                                           ;Each tick, milo yield will be accessed from a "milo-yield_2" list

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (item (item n yrs-seq) corn-yield_2 * one-of corn-price * Corn_area)          ;Calculate farm gross income
  set wheat-tot-income (item (item n yrs-seq) wheat-yield_2 * one-of wheat-price * Wheat_area)
  set soybeans-tot-income (item (item n yrs-seq) soybeans-yield_2 * one-of soybeans-price * Soybeans_area)
  set milo-tot-income (item (item n yrs-seq) milo-yield_2 * one-of milo-price * SG_area)

  calculate-expenses_yield_2                                                                        ;See "to calculate-expenses_yield_2"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_2                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_2" list
  set wheat-use-in item (k mod 10) wheat-irrig_2                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_2" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_2                                              ;Each tick, irrigation will be accessed from a "soybeans-irrig_2" list
  set milo-use-in item (k mod 10) milo-irrig_2                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_2" list
end

to dryland-farming_4
  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-tot-yield (item m corn-yield_4)                                                         ;Access data from GCM8.5 list
   set wheat-tot-yield (item m wheat-yield_4)
   set soybeans-tot-yield (item m soybeans-yield_4)
   set milo-tot-yield (item m milo-yield_4)]
  [set corn-tot-yield (item GCM-random-year corn-yield_4)                                           ;For year after 2098 (using a random sequence)
   set wheat-tot-yield (item GCM-random-year wheat-yield_4)
   set soybeans-tot-yield (item GCM-random-year soybeans-yield_4)
   set milo-tot-yield (item GCM-random-year milo-yield_4)]

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (corn-tot-yield * (one-of corn-price) * Corn_area)                            ;Calculate farm gross income
  set wheat-tot-income (wheat-tot-yield * (one-of wheat-price) * Wheat_area)
  set soybeans-tot-income (soybeans-tot-yield * (one-of soybeans-price) * Soybeans_area)
  set milo-tot-income (milo-tot-yield * (one-of milo-price) * SG_area)

  calculate-expenses_yield_4                                                                        ;See "to calculate-expenses_yield_4"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_4                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_4" list
  set wheat-use-in item (k mod 10) wheat-irrig_4                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_4" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_4                                              ;Each tick, irrigation will be accessed from a "soybeans-irrig_4" list
  set milo-use-in item (k mod 10) milo-irrig_4                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_4" list
end

to dryland-farming_5
  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-tot-yield (item m corn-yield_6)                                                         ;Access data from GCM4.5 list
   set wheat-tot-yield (item m wheat-yield_6)
   set soybeans-tot-yield (item m soybeans-yield_6)
   set milo-tot-yield (item m milo-yield_6)]
  [set corn-tot-yield (item GCM-random-year corn-yield_6)                                           ;For year after 2098 (using a random sequence)
   set wheat-tot-yield (item GCM-random-year wheat-yield_6)
   set soybeans-tot-yield (item GCM-random-year soybeans-yield_6)
   set milo-tot-yield (item GCM-random-year milo-yield_6)]

  set corn-history lput corn-tot-yield but-first corn-history                                       ;Add the most recent yield in a "corn-history" list and remove the oldest one
  set wheat-history lput wheat-tot-yield but-first wheat-history                                    ;Add the most recent yield in a "wheat-history" list and remove the oldest one
  set soybeans-history lput soybeans-tot-yield but-first soybeans-history                           ;Add the most recent yield in a "soybeans-history" list and remove the oldest one
  set milo-history lput milo-tot-yield but-first milo-history                                       ;Add the most recent yield in a "milo-history" list and remove the oldest one

  set corn-mean-yield mean corn-history                                                             ;Average corn production for the last 10 years
  set wheat-mean-yield mean wheat-history                                                           ;Average wheat production for the last 10 years
  set soybeans-mean-yield mean soybeans-history                                                     ;Average soybeans production for the last 10 years
  set milo-mean-yield mean milo-history                                                             ;Average milo production for the last 10 years

  set corn-yield-guarantee (corn-mean-yield * corn-coverage)                                        ;Calculate yield guarantee
  set wheat-yield-guarantee (wheat-mean-yield * wheat-coverage)
  set soybeans-yield-guarantee (soybeans-mean-yield * soybeans-coverage)
  set milo-yield-guarantee (milo-mean-yield * milo-coverage)

  set corn-income-guarantee ((corn-yield-guarantee * corn-price-FM) * Corn_area)                    ;Calculate guarantee growth crop income
  set wheat-income-guarantee ((wheat-yield-guarantee * wheat-price-FM) * Wheat_area)
  set soybeans-income-guarantee ((soybeans-yield-guarantee * soybeans-price-FM) * Soybeans_area)
  set milo-income-guarantee ((milo-yield-guarantee * milo-price-FM) * SG_area)

  set corn-tot-income (corn-tot-yield * (one-of corn-price) * Corn_area)                            ;Calculate farm gross income
  set wheat-tot-income (wheat-tot-yield * (one-of wheat-price) * Wheat_area)
  set soybeans-tot-income (soybeans-tot-yield * (one-of soybeans-price) * Soybeans_area)
  set milo-tot-income (milo-tot-yield * (one-of milo-price) * SG_area)

  calculate-expenses_yield_6                                                                        ;See "to calculate-expenses_yield_6"
  calculate-insurance                                                                               ;See "to calculate-insurance"
  calculate-net-income                                                                              ;See "to calculate-net-income"

  let k ticks
  set corn-use-in item (k mod 10) corn-irrig_6                                                      ;Each tick, irrigation will be accessed from a "corn-irrig_6" list
  set wheat-use-in item (k mod 10) wheat-irrig_6                                                    ;Each tick, irrigation will be accessed from a "wheat-irrig_6" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_6                                              ;Each tick, irrigation will be accessed from a "soybeans-irrig_6" list
  set milo-use-in item (k mod 10) milo-irrig_6                                                      ;Each tick, irrigation will be accessed from a "milo-irrig_6" list
end

to energy-calculation
  ;Bob Johnson (bobjohnson@centurylink.net), Earnie Lehman (earnielehman@gmail.com), and Hongyu Wu (hongyuwu@ksu.edu)

  ;;;;;;;;;;;;;;;;;;
  ;;Solar capacity;;
  ;;;;;;;;;;;;;;;;;;

  if count-solar-lifespan <= Nyear_S [
  ifelse count-solar-lifespan = 0 [                                                                 ;Year 1 without degradation rate -- Count 10 years (0 to 9). Because we set "count-solar-lifespan" = 0 at the beginning
    set solar-production_temp (#Solar_Panels * Capacity_S * Sun_hrs * 365 / 1000000)                ;MWh = power(Watt) * average peak sun hours * 365days/year / 1000000
    set solar-production solar-production_temp                                                      ;Set temp capacity
    set count-solar-lifespan (count-solar-lifespan + 1)]                                            ;Advance one year

   [set solar-production ((1 - (Degrade_S / 100)) * solar-production_temp)                          ;Else: year 2 to the end. Calculate capacity by applying a degradation rate
    set solar-production_temp (solar-production)                                                    ;Set temp variable
    set count-solar-lifespan (count-solar-lifespan + 1)                                             ;Advance one year
    if count-solar-lifespan = Nyear_S [set count-solar-lifespan 0]                                  ;Equipment is replaced
    ]
  ]

  ;;;;;;;;;;;;;;;;;
  ;;Wind capacity;;
  ;;;;;;;;;;;;;;;;;

  if count-wind-lifespan <= Nyear_W [
  ifelse count-wind-lifespan <= 9 [                                                                 ;First 10 years without degradation rate. Count 10 years (0 to 9). Because we set "count-wind-lifespan" = 0 at the beginning
    set wind-production_temp (#wind_turbines * Capacity_W * (wind_factor * 0.01) * 24 * 365)        ;MWh = power(MW) * Kansas_wind_Capacity_S * 24hrs/day * 365days/year, Capacity_S 42.1% (Berkeley Lab)
    set wind-production wind-production_temp                                                        ;Set temp capacity
    set count-wind-lifespan (count-wind-lifespan + 1)]                                              ;Advance one year

   [set wind-production ((1 - (Degrade_W / 100)) * wind-production_temp)                            ;Else: year 11 to the end. Calculate capacity by applying a degradation rate
    set wind-production_temp (wind-production)                                                      ;Set temp variable
    set count-wind-lifespan (count-wind-lifespan + 1)                                               ;Advance one year
    if count-wind-lifespan = Nyear_W [set count-wind-lifespan 0]                                    ;Equipment is replaced
    ]
  ]

  ;;;;;;;;;;;;;;
  ;;Solar cost;;
  ;;;;;;;;;;;;;;

  ifelse #Solar_Panels * (Capacity_S / 1000) < 0.01                                                 ;Calculate solar panel's capital costs for different scales (10kW = 0.01MW)
  [set solar-cost ((#Solar_Panels * (Capacity_S / 1000) * Cost_S / term-loan_S + (22 * #solar_panels * (Capacity_S / 1000))) * (1 - (ITC_S / 100)))]      ;Residential
  [set solar-cost ((#Solar_Panels * (Capacity_S / 1000) * Cost_S / term-loan_S + (18 * #solar_panels * (Capacity_S / 1000))) * (1 - (ITC_S / 100)))]      ;Commercial

  ;;;;;;;;;;;;;;;;
  ;;Solar income;;
  ;;;;;;;;;;;;;;;;

  if count-solar-lifespan-sell <= Nyear_S [
  ifelse count-solar-lifespan-sell <= 9 [                                                           ;First 10 years (PTC). Because we set "count-solar-lifespan-sell" = 0 at the beginning
     set solar-sell_temp (solar-production * (Energy_value + (100 * PTC_S)))                        ;Calculate temp income
     set solar-sell solar-sell_temp                                                                 ;Set income
     set count-solar-lifespan-sell (count-solar-lifespan-sell + 1)]                                 ;Advance one year

    [set solar-sell_temp (solar-production * Energy_value)                                          ;Else: year 10 to the end. Calculate income without PTC.
     set solar-sell solar-sell_temp                                                                 ;Set income
     set count-solar-lifespan-sell (count-solar-lifespan-sell + 1)                                  ;Advance one year
     if count-solar-lifespan-sell = Nyear_S [set count-solar-lifespan-sell 0]                       ;Equipment is replaced
     ]
   ]

  ;;;;;;;;;;;;;
  ;;Wind cost;;
  ;;;;;;;;;;;;;

  ;Wind cost = $1470/kW + (O&M costs) * #wind_turbines, (ref. Berkeley Lab, Hongyu Wu)
  ;Operations and maintenance costs: $45,000/MW for turbine aged between 0 and 10 years, and $50,000/MW beyond 10 years

  if count-wind-lifespan-cost <= Nyear_W [
  ifelse count-wind-lifespan-cost <= 9 [                                                            ;First 10 years, O&M costs = $45/kW
    set wind-cost (((Cost_W * 1000) * Capacity_W / term-loan_W) + (45000 * Capacity_W)) * #wind_turbines * (1 - (ITC_W / 100))
    set count-wind-lifespan-cost (count-wind-lifespan-cost + 1)                                     ;Advance one year
    ]

    [set wind-cost (((Cost_W * 1000) * Capacity_W / term-loan_W) + (50000 * Capacity_W)) * #wind_turbines * (1 - (ITC_W / 100))    ;Else: year 11 to the end. O&M costs = $50/kW
     set count-wind-lifespan-cost (count-wind-lifespan-cost + 1)                                    ;Advance one year
     if count-wind-lifespan-cost = Nyear_W [set count-wind-lifespan-cost 0]                         ;Equipment is replaced
    ]
  ]

  ;;;;;;;;;;;;;;;
  ;;Wind income;;
  ;;;;;;;;;;;;;;;

  if count-wind-lifespan-sell <= Nyear_W [
  ifelse count-wind-lifespan-sell <= 9 [                                                            ;First 10 years with PTC
     set wind-sell_temp (wind-production * (Energy_value + (100 * PTC_W)))                          ;Calculate temp wind income
     set wind-sell wind-sell_temp                                                                   ;Set wind income
     set count-wind-lifespan-sell (count-wind-lifespan-sell + 1)]                                   ;Advance one year

    [set wind-sell_temp (wind-production * Energy_value)                                            ;Else: year 11 to the end without PTC
     set wind-sell wind-sell_temp                                                                   ;Set wind income
     set count-wind-lifespan-sell (count-wind-lifespan-sell + 1)                                    ;Advance one year
     if count-wind-lifespan-sell = Nyear_W [set count-wind-lifespan-sell 0]                         ;Equipment is replaced
     ]
   ]

  set solar-net-income (solar-sell - solar-cost)                                                    ;Calculate solar net income
  set wind-net-income  (wind-sell - wind-cost)                                                      ;Calculate wind net income
  set energy-net-income (solar-net-income + wind-net-income)                                        ;Calculate energy net income
end

to gw-depletion_1
  let k ticks                                                                                       ;Set a temporary variable
  set corn-use-in item (k mod 10) corn-irrig_1                                                      ;Irrigation will be accessed from a "corn-irrig_1" list
  set wheat-use-in item (k mod 10) wheat-irrig_1                                                    ;Irrigation will be accessed from a "wheat-irrig_1" list
  set soybeans-use-in item (k mod 10) soybeans-irrig_1                                              ;Irrigation will be accessed from a "soybeans-irrig_1" list
  set milo-use-in item (k mod 10) milo-irrig_1                                                      ;Irrigation will be accessed from a "milo-irrig_1" list

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_2
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_1                                                ;Irrigation will be accessed from a "corn-irrig_1" list (seq is linked to "food_calculation_1")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1                                              ;Irrigation will be accessed from a "wheat-irrig_1" list (seq is linked to "food_calculation_1")
  set soybeans-use-in item (item k yrs-seq) soybeans-irrig_1                                        ;Irrigation will be accessed from a "soybeans-irrig_1" list (seq is linked to "food_calculation_1")
  set milo-use-in item (item k yrs-seq) milo-irrig_1                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_1")

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_3
  let k (ticks mod 10)                                                                              ;Set a temporary variable
  set corn-use-in item (item k yrs-seq) corn-irrig_1                                                ;Irrigation will be accessed from a "corn-irrig_1" list (seq is linked to "food_calculation_1")
  set wheat-use-in item (item k yrs-seq) wheat-irrig_1                                              ;Irrigation will be accessed from a "wheat-irrig_1" list (seq is linked to "food_calculation_1")
  set soybeans-use-in item (item k yrs-seq) soybeans-irrig_1                                         ;Irrigation will be accessed from a "soybeans-irrig_1" list (seq is linked to "food_calculation_1")
  set milo-use-in item (item k yrs-seq) milo-irrig_1                                                ;Irrigation will be accessed from a "milo-irrig_1" list (seq is linked to "food_calculation_1")

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_4

  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-use-in (item m corn-irrig_3)                                                            ;Before 2098
   set wheat-use-in (item m wheat-irrig_3)
   set soybeans-use-in (item m soybeans-irrig_3)
   set milo-use-in (item m milo-irrig_3)]
  [set corn-use-in (item GCM-random-year corn-irrig_3)                                              ;Create a random sequence after 2098
   set wheat-use-in (item GCM-random-year wheat-irrig_3)
   set soybeans-use-in (item GCM-random-year soybeans-irrig_3)
   set milo-use-in (item GCM-random-year milo-irrig_3)]

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_5
  ifelse ticks < 91
  [let m (ticks - 10)
   set corn-use-in (item m corn-irrig_5)                                                            ;Before 2098
   set wheat-use-in (item m wheat-irrig_5)
   set soybeans-use-in (item m soybeans-irrig_5)
   set milo-use-in (item m milo-irrig_5)]
  [set corn-use-in (item GCM-random-year corn-irrig_5)                                              ;Create a random sequence after 2098
   set wheat-use-in (item GCM-random-year wheat-irrig_5)
   set soybeans-use-in (item GCM-random-year soybeans-irrig_5)
   set milo-use-in (item GCM-random-year milo-irrig_5)]

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to gw-depletion_dryland
  let k (ticks mod 10)
  set corn-use-in 0                                                                                 ;Set water use to zero
  set wheat-use-in 0                                                                                ;Set water use to zero
  set soybeans-use-in 0                                                                             ;Set water use to zero
  set milo-use-in 0                                                                                 ;Set water use to zero

  ;Normalize water use
  set water-use-feet (((corn-use-in * Corn_area) + (wheat-use-in * Wheat_area) + (soybeans-use-in * Soybeans_area) + (milo-use-in * SG_area)) / (12 * total-area))

  ;Two-step process
  set calibrated-water-use ((0.114 * water-use-feet) + 0.211)                                       ;STEP1: Calibrate DSSAT simulated results with historical data
  set gw-change ((-32.386 * calibrated-water-use) + 8.001)                                          ;STEP2: Calculate water-level change using a regression equation

  set patch-change (gw-change * 170 / Aquifer_thickness)                                            ;Convert water-level change to patch change

  groundwater_level_change                                                                          ;See "to groundwater_level_change"

  ifelse patch-change < 0                                                                           ;Is water level decreasing?
    [ask aquifer-patches with [pycor > (current-elev + patch-change)] [                             ;Yes
     set pcolor 7]]                                                                                 ;Set patches above "new" level of aquifer (new current elevation) to be gray
    [ask aquifer-patches with [pycor < (current-elev + patch-change)] [                             ;No
     set pcolor 105]]                                                                               ;Set patches below "new" level of aquifer (new current elevation) to be blue

  set current-elev (current-elev + patch-change)                                                    ;Set new current elevation (new top of aquifer)
  if current-elev > 69 [set current-elev 69]                                                        ;Exceed Capacity_S

  if current-elev < level-low [                                                                     ;Is the top of aquifer below 30 feet?
    ask aquifer-patches with [pycor < current-elev] [                                               ;Yes
      set pcolor 14]                                                                                ;Set "aquifer-patches" to be red
  ]
end

to groundwater_level_change
  set gw-level (gw-level + gw-change)                                                               ;Update groundwater level
end

to contaminant                                                                                      ;Surface water contamination
  let k (ticks mod 10)
  set N-accu-temp (0.1 * 2.205 * (((item (item k yrs-seq) corn-N-app) * Corn_area) + ((item (item k yrs-seq) wheat-N-app) * Wheat_area) + ((item (item k yrs-seq) soybeans-N-app) * Soybeans_area) + ((item (item k yrs-seq) milo-N-app) * SG_area))) ;convert from kg to pound, multiply the mass value by 2.205

  set N-accu (N-accu + N-accu-temp)                                                                 ;N accumulation before transporting to the stream

  ask patch -1 0 [ask n-of (0.0001 * (item (item k yrs-seq) corn-N-app) / 1.12 * Corn_area) patches in-radius (item 0 radius-of-%area) [set pcolor brown]]                ;dots shown in a circle are in a unit area (lbs/ac); kg/ha to lb/ac, dividing by 1.12
  ask patch -18 84 [ask n-of (0.0001 * (item (item k yrs-seq) wheat-N-app) / 1.12 * Wheat_area) patches in-radius (item 1 radius-of-%area) [set pcolor brown]]            ;dots shown in a circle are in a unit area (lbs/ac); kg/ha to lb/ac, dividing by 1.12
  ask patch -51.5 -51 [ask n-of (0.0001 * (item (item k yrs-seq) soybeans-N-app) / 1.12 * Soybeans_area) patches in-radius (item 2 radius-of-%area) [set pcolor brown]]   ;dots shown in a circle are in a unit area (lbs/ac); kg/ha to lb/ac, dividing by 1.12
  ask patch -52 16 [ask n-of (0.0001 * (item (item k yrs-seq) milo-N-app) / 1.12 * SG_area) patches in-radius (item 3 radius-of-%area) [set pcolor brown]]                ;dots shown in a circle are in a unit area (lbs/ac); kg/ha to lb/ac, dividing by 1.12

  ;;;;;;;;;;;;;;;
  ;;Base period;;
  ;;;;;;;;;;;;;;;

  ifelse ticks < 11 [
    if (item k yrs-seq) = 7 or (item k yrs-seq) = 8 or (item k yrs-seq) = 9 [                       ;yrs-seq = 7, 8, and 9 are wet years
    ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]            ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream

    set N-accu2 (N-accu2 + N-accu)                                                                  ;N-accu2 is amount of nitrate in the stream

    ask patch 54 87 [                                                                               ;Show a number in the World
    set plabel round (N-accu2)
    set plabel-color white]

    set N-accu 0                                                                                    ;N-accu (in crop circles) is reset because nitrate is transported into the river
    ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
    ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
    ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
    ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
  ]]

  ;;;;;;;;;;;;;;;;;;
  ;;Future Process;;
  ;;;;;;;;;;;;;;;;;;

  [                                                                                                 ;Else (Open square bracket): Future process
  ;;;;;;;;;;;;;;;;;;
  ;;Scenario 1,2,3;;
  ;;;;;;;;;;;;;;;;;;

  ifelse Future_Process = "Repeat Historical" or Future_Process = "Wetter Future" or Future_Process = "Dryer Future"
    [if (item k yrs-seq) = 7 or (item k yrs-seq) = 8 or (item k yrs-seq) = 9 [                      ;yrs-seq = 7, 8, and 9 are wet years
     ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]           ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream

     set N-accu2 (N-accu2 + N-accu)                                                                 ;N-accu2 is amount of nitrate in the stream

     ask patch 54 87 [                                                                              ;Show a number in the World
     set plabel round (N-accu2)
     set plabel-color white]

     set N-accu 0                                                                                   ;N-accu (in crop circles) is reset because nitrate is transported into the river
     ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
     ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
     ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
     ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]]
    ]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;RCP8.5 sim to year 2098;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    [ifelse (Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP8.5" and ticks < 91 and (item (ticks - 11) precip_RCP8.5) >= 20)            ;Years that precip >= 20 inches are wet years
      [ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]         ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream
       set N-accu2 (N-accu2 + N-accu)                                                               ;N-accu2 is amount of nitrate in the stream

       ask patch 54 87 [                                                                            ;Show a number in the World
       set plabel round (N-accu2)
       set plabel-color white]

       set N-accu 0                                                                                 ;N-accu (in crop circles) is reset because nitrate is transported into the river
       ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
       ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
       ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
       ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
      ]

      ;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;RCP8.5 sim after 2098;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;

      [ifelse (Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP8.5" and ticks >= 91 and (item (GCM-random-year) precip_RCP8.5) >= 20)           ;Years that precip >= 20 inches are wet years
        [ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]       ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream
         set N-accu2 (N-accu2 + N-accu)                                                             ;N-accu2 is amount of nitrate in the stream

         ask patch 54 87 [                                                                          ;Show a number in the World
         set plabel round (N-accu2)
         set plabel-color white]

         set N-accu 0                                                                               ;N-accu (in crop circles) is reset because nitrate is transported into the river
         ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
         ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
         ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
         ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
        ]

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;RCP4.5 sim to year 2098;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;

        [ifelse (Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP4.5" and ticks < 91 and (item (ticks - 11) precip_RCP4.5) >= 20)            ;Years that precip >= 20 inches are wet years
          [ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]     ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream
           set N-accu2 (N-accu2 + N-accu)                                                           ;N-accu2 is amount of nitrate in the stream

           ask patch 54 87 [
           set plabel round (N-accu2)
           set plabel-color white]

           set N-accu 0                                                                             ;N-accu (in crop circles) is reset because nitrate is transported into the river
           ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
           ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
           ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
           ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
          ]

          ;;;;;;;;;;;;;;;;;;;;;
          ;;RCP4.5 after 2098;;
          ;;;;;;;;;;;;;;;;;;;;;

          [if (Future_Process = "Impose T, P, & S Changes" and Climate_Model = "RCP4.5" and ticks >= 91 and (item (GCM-random-year) precip_RCP4.5) >= 20)            ;Years that precip >= 20 inches are wet years
            [ask up-to-n-of (0.0001 * N-accu) river-patches with [pcolor = 87] [set pcolor brown]   ;0.0001 is a scaling factor, graphically used to reduce number of dots in stream
             set N-accu2 (N-accu2 + N-accu)                                                         ;N-accu2 is amount of nitrate in the stream

             ask patch 54 87 [
             set plabel round (N-accu2)
             set plabel-color white]

             set N-accu 0                                                                           ;N-accu (in crop circles) is reset because nitrate is transported into the river
             ask patch -1 0 [ask patches in-radius (item 0 radius-of-%area) [set pcolor 37]]
             ask patch -18 84 [ask patches in-radius (item 1 radius-of-%area) [set pcolor 22]]
             ask patch -51.5 -51 [ask patches in-radius (item 2 radius-of-%area) [set pcolor 36]]
             ask patch -52 16 [ask patches in-radius (item 3 radius-of-%area) [set pcolor 34]]
            ]
          ]
        ]
      ]
    ]
  ]                                                                                                 ;Else (Close square bracket): Future process

end

to treatment                                                                                        ;Treatment (Not applicable)
  if random 10 = 1 [                                                                                ;10% chance
    ask river-patches [
      if any? river-patches with [pcolor = brown] [
        ask one-of river-patches with [pcolor = brown] [
          set pcolor 87]
      ]
    ]
  ]
end

to initialize-energy                                                                                ;Initialize energy parameter in order to change the numbers over time
  set #Solar_panels (#Panel_sets * 1000)                                                            ;Calculate total solar panels
  set solar-production (#Solar_Panels * Capacity_S * Sun_hrs * 365 / 1000000)                       ;Calculate solar production
  set wind-production (#wind_turbines * Capacity_W * (wind_factor * 0.01) * 24 * 365)               ;Calculate wind production
  set %Solar-production (Solar-production * 100 / (Solar-production + Wind-production))             ;Calculate percentage
  set %Wind-production (Wind-production * 100 / (Solar-production + Wind-production))               ;Calculate percentage

  ask patch 93 -91 [                                                                                ;Print %
    set plabel round (%Wind-production)
    set plabel-color black]

  set solar-bar patches with [pxcor > 83]                                                           ;Change scale bar
    ask solar-bar with [pycor > (-100 + (2 * %Wind-production))] [
    set pcolor [255 165 0]]

  ask patch 93 96 [                                                                                 ;Print %
    set plabel round (%Solar-production)
    set plabel-color black]

  set wind-bar patches with [pxcor > 83]                                                            ;Change scale bar
    ask wind-bar with [pycor < (-100 + (2 * %Wind-production))] [
    set pcolor yellow]
end

to reset-symbols                                                                                    ;Reset number of wind turbines and solar panels every tick
  ask turtles [die]                                                                                 ;Code below is similar to "setup" procedure showing above

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
        set size (Capacity_W * 30)
        set w (w + 1)]
      ]
        [ifelse w < 4 [
          crt 1 [
          setxy (25 + ((w - 2) * 22)) -65
          set shape "wind"
          set size (Capacity_W * 30)
          set w (w + 1)]
         ]
          [crt 1 [
          setxy (35 + ((w - 4) * 22)) -31
          set shape "wind"
          set size (Capacity_W * 30)
          set w (w + 1)]
          ]
       ]
       ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;; Solar icons ;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set solar-patches patches with [pxcor > 0 and pxcor < 65 and pycor > 33 and pycor < 100]
  let t 0
    repeat #Panel_sets [

      ifelse t < 5 [
        crt 1 [
        setxy 56 (65 - (t * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
      [ifelse t < 10 [
        crt 1 [
        setxy 37 (65 - ((t - 5) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
      [crt 1 [
        setxy 18 (65 - ((t - 10) * 12))
        set shape "solar"
        set size 20
        set t (t + 1)]
      ]
    ]
  ]

  if ticks = 0 [
    set solar-production (#Solar_Panels * Capacity_S * Sun_hrs * 365 / 1000000)
    set wind-production (#wind_turbines * Capacity_W * (wind_factor * 0.01) * 24 * 365)]

  set solar-production solar-production
  set wind-production wind-production
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

  ask patch 64 96 [
    set plabel "Nitrate in SW"
    set plabel-color white]

  ask patch 64 87 [
    set plabel "lbs"
    set plabel-color white]

  ask patch 54 87 [
    set plabel round (N-accu2)
    set plabel-color white]
end

to Default                                                                                          ;Default button
  set simulation_period 60
  set corn_area 200
  set wheat_area 125
  set soybeans_area 0
  set SG_area 125
  set Energy_value 38
  set #Panel_sets 3
  set Nyear_S 25
  set ITC_S 0
  set Capacity_S 250
  set Degrade_S 0.5
  set PTC_S 0
  set #Wind_turbines 2
  set Nyear_W 30
  set ITC_W 0
  set Capacity_W 2
  set Degrade_W 1
  set PTC_W 0
  set Aquifer_thickness 200
  set Min_Aq_Thickness 30
  set Future_Process "Repeat Historical"
  set Climate_Model "RCP4.5"
  set cost_S 1750
  set cost_W 1470
  set sun_hrs 5.6
  set Wind_factor 42.1
end
@#$#@#$#@
GRAPHICS-WINDOW
386
29
817
461
-1
-1
2.1045
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
215
10
270
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
66
86
126
Corn_area
200.0
1
0
Number

INPUTBOX
88
66
167
126
Wheat_area
125.0
1
0
Number

INPUTBOX
169
66
253
126
Soybeans_area
0.0
1
0
Number

INPUTBOX
255
66
335
126
SG_area
125.0
1
0
Number

TEXTBOX
7
48
386
72
Agriculture -------------------------------------\n
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
"Corn" 1.0 0 -4079321 true "" "plot corn-net-income"
"Wheat" 1.0 0 -3844592 true "" "plot wheat-net-income"
"Soybeans" 1.0 0 -13210332 true "" "plot soybeans-net-income"
"SG" 1.0 0 -12440034 true "" "plot milo-net-income"
"US$0" 1.0 2 -8053223 true "" "plot zero-line"

BUTTON
271
10
326
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
8
414
185
446
Water -----------------
13
95.0
1

TEXTBOX
6
142
382
174
Energy -----------------------------------------
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
"Corn" 1.0 0 -4079321 true "" "plot corn-use-in"
"Wheat" 1.0 0 -3844592 true "" "plot wheat-use-in"
"Soybeans" 1.0 0 -13210332 true "" "plot soybeans-use-in"
"SG" 1.0 0 -12440034 true "" "plot milo-use-in"

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
"Corn" 1.0 0 -4079321 true "" "plot corn-tot-yield\n"
"Wheat" 1.0 0 -3844592 true "" "plot wheat-tot-yield"
"Soybeans" 1.0 0 -13210332 true "" "plot soybeans-tot-yield"
"SG" 1.0 0 -12440034 true "" "plot milo-tot-yield"

BUTTON
327
10
382
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
7
294
118
327
#Wind_turbines
#Wind_turbines
1
6
2.0
1
1
NIL
HORIZONTAL

SLIDER
8
512
168
545
Aquifer_thickness
Aquifer_thickness
70
300
200.0
10
1
Ft
HORIZONTAL

SLIDER
7
245
118
278
Capacity_S
Capacity_S
100
300
250.0
10
1
W
HORIZONTAL

SLIDER
7
210
118
243
#Panel_sets
#Panel_sets
0
8
3.0
0.1
1
NIL
HORIZONTAL

MONITOR
7
924
148
969
solar-production (MWh)
round solar-production
17
1
11

MONITOR
7
993
148
1038
Wind-production (MWh)
round Wind-production
17
1
11

MONITOR
154
924
239
969
solar-cost ($)
solar-cost
17
1
11

MONITOR
409
924
536
969
solar-sell ($ per year)
solar-sell
17
1
11

MONITOR
154
993
239
1038
wind-cost ($)
wind-cost
17
1
11

MONITOR
409
993
535
1038
wind-sell ($ per year)
round wind-sell
17
1
11

MONITOR
245
924
403
969
Solar-cost / 30 ($ per year)
round (Solar-cost / 30)
17
1
11

MONITOR
245
993
404
1038
wind-cost / 30 ($ per year)
wind-cost / 30
17
1
11

MONITOR
541
994
650
1039
wind-net-income
round wind-net-income
17
1
11

MONITOR
541
924
650
969
solar-net-income
round solar-net-income
17
1
11

TEXTBOX
7
127
329
145
Circles show proportional crop areas (acres), SG =Grain sorghum.
10
63.0
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
2000.0
true
true
"set-plot-background-color 28" ""
PENS
"Solar        " 1.0 0 -5298144 true "" "ifelse ticks = 0 [set solar-production 0\nplot solar-production]\n[plot solar-production]"
"Wind      " 1.0 0 -14070903 true "" "ifelse ticks = 0 [set wind-production 0\nplot wind-production]\n[plot wind-production]"
"0 MWh" 1.0 2 -8053223 true "" "plot zero-line"

TEXTBOX
8
904
158
922
Solar outputs
11
0.0
1

TEXTBOX
9
976
159
994
Wind outputs
11
0.0
1

TEXTBOX
192
415
377
445
Climate Scenario ------------
12
0.0
1

CHOOSER
192
478
367
523
Future_Process
Future_Process
"Repeat Historical" "Wetter Future" "Dryer Future" "Impose T, P, & S Changes"
0

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
"Crop" 1.0 0 -12087248 true "" "ifelse ticks = 0 [set corn-expenses 0\nset wheat-expenses 0\nset soybeans-expenses 0\nset milo-expenses 0\nplot (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybeans-tot-income - soybeans-expenses) + (milo-tot-income - milo-expenses)]\n[plot (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybeans-tot-income - soybeans-expenses) + (milo-tot-income - milo-expenses)]"
"Energy     " 1.0 0 -955883 true "" "ifelse ticks = 0 [set energy-net-income 0\nplot energy-net-income]\n[plot energy-net-income]"
"All" 1.0 0 -16777216 true "" "ifelse ticks = 0 [set energy-net-income 0\nplot (energy-net-income) + (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybeans-tot-income - soybeans-expenses) + (milo-tot-income - milo-expenses)]\n[plot (energy-net-income) + (corn-tot-income - corn-expenses) + (wheat-tot-income - wheat-expenses) + (soybeans-tot-income - soybeans-expenses) + (milo-tot-income - milo-expenses)]"
"US$0" 1.0 2 -8053223 true "" "plot zero-line"

TEXTBOX
8
280
65
308
• Wind:
11
25.0
1

TEXTBOX
7
196
47
214
• Solar:
11
25.0
1

PLOT
1112
173
1396
293
Energy Net Income
Years
$
0.0
60.0
0.0
15000.0
true
true
"set-plot-background-color 28" ""
PENS
"Solar        " 1.0 0 -5298144 true "" "ifelse ticks = 0 [set solar-net-income 0\nplot (solar-net-income)]\n[plot (solar-net-income)]"
"Wind" 1.0 0 -14070903 true "" "ifelse ticks = 0 [set wind-net-income 0\nplot (wind-net-income)]\n[plot (wind-net-income)]"
"US$0" 1.0 2 -8053223 true "" "plot zero-line"

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
386
468
814
503
• First 10 years use historical data (2008-2017), subsequent years apply Future Process.
10
5.0
1

TEXTBOX
7
468
189
514
• Water is assumed to come from groundwater (GW) pumping.
11
95.0
1

MONITOR
853
925
932
970
NIL
current-elev
3
1
11

MONITOR
1011
925
1101
970
NIL
patch-change
3
1
11

MONITOR
935
925
1008
970
NIL
gw-change
3
1
11

MONITOR
757
925
850
970
NIL
water-use-feet
3
1
11

TEXTBOX
386
486
814
504
• Year in the plots represents a sequential year. Year 1 is 2008 and year 60 is 2067.
10
5.0
1

TEXTBOX
390
37
540
56
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
6
10
158
43
Simulation_period
Simulation_period
1
90
60.0
1
1
Yrs
HORIZONTAL

PLOT
1112
460
1396
580
Income From Crop Insurance
NIL
$
0.0
60.0
0.0
10.0
true
true
"" ""
PENS
"Corn" 1.0 2 -4079321 true "" "ifelse corn-claimed = \"YES\" [plot corn-ins-claimed]\n[plot zero-line]"
"Wheat" 1.0 2 -3844592 true "" "ifelse wheat-claimed = \"YES\" [plot wheat-ins-claimed]\n[plot zero-line]"
"Soybeans" 1.0 2 -13210332 true "" "ifelse soybeans-claimed = \"YES\" [plot soybeans-ins-claimed]\n[plot zero-line]"
"SG" 1.0 2 -12440034 true "" "ifelse milo-claimed = \"YES\" [plot milo-ins-claimed]\n[plot zero-line]"

TEXTBOX
1112
438
1410
458
Crop Insurance -------------------
15
0.0
1

PLOT
1112
316
1396
436
Groundwater Level
NIL
Feet
0.0
60.0
0.0
10.0
true
true
"set-plot-background-color 88" ""
PENS
"GW level   " 1.0 0 -14454117 true "" "plot gw-level"
"Min Aq" 1.0 2 -5298144 true "" "plot (Min_Aq_Thickness)"
"Min+30" 1.0 2 -7500403 true "" "plot (gw-upper-limit)"

TEXTBOX
386
505
812
523
• FEWCalc requires NetLogo version 6.1.0 or higher.
10
5.0
1

TEXTBOX
1039
113
1110
135
SG = Grain \nsorghum
9
0.0
1

TEXTBOX
1039
398
1097
420
SG = Grain \nsorghum
9
0.0
1

TEXTBOX
1327
125
1385
147
SG = Grain \nsorghum
9
0.0
1

TEXTBOX
1328
542
1385
564
SG = Grain \nsorghum
9
0.0
1

TEXTBOX
192
434
378
492
Climate scenario controls annual temperature (T), precipitation (P), and solar radiation (S).
11
0.0
1

CHOOSER
192
541
367
586
Climate_Model
Climate_Model
"RCP4.5" "RCP8.5"
0

TEXTBOX
385
525
820
572
• The Representative Concentration Pathways (RCPs) are used for making climate projections largely based on greenhouse gas (GHG) emissions. RCP4.5 is representative of an intermediate scenario, whearas RCP8.5 is a scenario with very high GHG emissions.
10
5.0
1

TEXTBOX
192
526
373
554
For \"Impose T, P, and S Changes\"
11
0.0
1

TEXTBOX
8
434
180
461
• Effects on surface water (SW) quality are accumulated.
11
95.0
1

SLIDER
120
329
245
362
Degrade_W
Degrade_W
0
2
1.0
0.1
1
%/yr
HORIZONTAL

TEXTBOX
51
282
261
300
Wind degradation applies after 10 yrs
9
25.0
1

SLIDER
7
162
166
195
Energy_value
Energy_value
0
50
38.0
0.1
1
$/MWh
HORIZONTAL

SLIDER
120
210
245
243
Nyear_S
Nyear_S
20
30
25.0
1
1
Yrs
HORIZONTAL

SLIDER
120
294
245
327
Nyear_W
Nyear_W
20
30
30.0
1
1
Yrs
HORIZONTAL

SLIDER
288
378
380
411
PTC_W
PTC_W
0
0.03
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
7
329
118
362
Capacity_W
Capacity_W
1
2
2.0
1
1
MW
HORIZONTAL

SLIDER
195
378
287
411
ITC_W
ITC_W
0
40
0.0
1
1
%
HORIZONTAL

SLIDER
7
378
99
411
ITC_S
ITC_S
0
40
0.0
1
1
%
HORIZONTAL

SLIDER
101
378
193
411
PTC_S
PTC_S
0
0.03
0.0
0.001
1
NIL
HORIZONTAL

TEXTBOX
266
161
382
183
*NYear is lifespan (years)
9
25.0
1

SLIDER
120
245
245
278
Degrade_S
Degrade_S
0
1
0.5
0.1
1
%/yr
HORIZONTAL

TEXTBOX
548
10
650
41
FEWCalc 1.0.1
14
0.0
1

SLIDER
8
553
168
586
Min_Aq_Thickness
Min_Aq_Thickness
0
50
30.0
1
1
Ft
HORIZONTAL

TEXTBOX
7
363
92
381
• Tax Credits: 
11
25.0
1

SLIDER
247
210
381
243
Cost_S
Cost_S
1000
4000
1750.0
1
1
$/kW
HORIZONTAL

SLIDER
247
294
381
327
Cost_W
Cost_W
1000
2500
1470.0
1
1
$/kW
HORIZONTAL

TEXTBOX
86
365
416
387
Choose 1, ITC: Investment TC (%) OR PTC: Production TC ($/kWh)
9
25.0
1

TEXTBOX
50
198
195
216
1 set = 1,000 panels
9
25.0
1

BUTTON
159
10
214
43
Default
Default
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
247
245
381
278
Sun_hrs
Sun_hrs
0
8
5.6
0.1
1
hrs/day
HORIZONTAL

SLIDER
247
329
381
362
Wind_factor
Wind_factor
20
60
42.1
0.1
1
%
HORIZONTAL

@#$#@#$#@
# FEWCalc
**FEWCalc** is the **Food-Energy-Water Calculator** assembled by Jirapat (Mos) Phetheet -- a Master's student and Professor Mary C. Hill from Department of Geology, the University of Kansas. 

The calculation is divided into two parts. The first part is crop calculation using a crop model called Decision Support System for Agrotechnology Transfer (DSSAT) which was developed by [Jones et al., 2003](https://doi.org/10.1016/S1161-0301(02)00107-7) from the University of Florida. The other is the FEWCalc conducted using NetLogo agent-based modeling software by [Uri Wilensky, 1999](https://ccl.northwestern.edu/netlogo/docs). 

The location considered is the area around Garden City in [Finney County, Kansas.](https://en.wikipedia.org/wiki/Finney_County,_Kansas) FEWCalc is developed and tested using data from the southern High Plains aquifer (HPA), where groundwater has been decreasing at an alarming rate these days. Fortunately, Kansas is well positioned in the nation's wind belt that has access to a robust renewable energy source (Anderson et al., 2012). Economically, Kansas is the second leading state, with about 50% of the electricity sold in the state being met by wind (Wiser and Bolinger, 2018).

FEWCalc is an interactive tool integrating agriculture, energy, and water components; calculating farm income; as well as visualizing results in the NetLogo World.

![HPA](file:HPA_Lifetime.png)

![WIND](file:Wind_Map.png)

## Load input data and initialize parameters
### Load input data
There are eight input files in comma-separated values (.csv) format under "FEWCalc" folder. Input values (e.g., precipitation and crop price) were from historical data between 2008 and 2017. Besides, they were calculated from DSSAT (e.g., yield and irrigation) using the same dataset (1-4) and global climate models (GCMs) (5-8). The input files listed below are separated into four major crop types in Kansas which are corn, wheat, soybean, and milo (grain sorghum).

  * _**1_Corn_inputs.csv**_
  * _**2_Wheat_inputs.csv**_
  * _**3_Soybean_inputs.csv**_
  * _**4_Milo_inputs.csv**_
  * _**5_Corn_GCMs.csv**_
  * _**6_Wheat_GCMs.csv**_
  * _**7_Soybean_GCMs.csv**_
  * _**8_Milo_GCMs.csv**_

These files are composed of a number of columns which column headers are not well-defined. Here is a detailed explanation of those values.

  * **Year:** simulation year.
  * **Precip (in):** historical precipitation.
  * **Price ($/bu):** historical crop price.
  * **Yield_1 (bu/ac):** simulated yield from irrigated farming using historical data.
  * **Irrig_1 (in):** simulated irrigation from irrigated farming using historical data.
  * **Yield_2 (bu/ac):** simulated yield from dryland farming using historical data.
  * **Irrig_2 (in):** simulated irrigation from dryland farming using historical data. Values in this column are always zero.
  * **N-app (kh/ha):** Nitrogen fertilizer rate
  * **Precip8.5 (in):** Precipitation projection under PRPCP8.5
  * **Yield_3 (bu/ac):** simulated yield from irrigated farming using GCM data under RCP8.5 scenario.
  * **Irrig_3 (in):** simulated irrigation from irrigated farming using GCM data under RCP8.5 scenario.
  * **Yield_4 (bu/ac):** simulated yield from dryland farming using GCM data under RCP8.5 scenario.
  * **Irrig_4 (in):** simulated irrigation from dryland farming using GCM data under RCP8.5 scenario. Values in this column are always zero.
  * **Precip4.5 (in):** Precipitation projection under PRPCP4.5
  * **Yield_5 (bu/ac):** simulated yield from irrigated farming using GCM data under RCP4.5 scenario.
  * **Irrig_5 (in):** simulated irrigation from irrigated farming using GCM data under RCP4.5 scenario.
  * **Yield_6 (bu/ac):** simulated yield from dryland farming using GCM data under RCP4.5 scenario.
  * **Irrig_6 (in):** simulated irrigation from dryland farming using GCM data under RCP4.5 scenario. Values in this column are always zero.
  * **Unit explanation:** in is inch, $ is US dollar, bu is bushel, and ac is acre.

**Unit conversion**

  * 1 bushel corn or milo per acre = 62.77 kilograms per hectare
  * 1 bushel wheat or soybean per acre = 67.25 kilograms per hectare

### Initialize parameters

FEWCalc allows users to specify parameters for their own simulation in the NetLogo's interface. It is designed to define those numbers easily by using input box, slider, and chooser. Each parameter is described below.

  * **Simulation_period:** A period of simulation.
  * **Agriculture**
    * **Corn-area:** A total area of corn in acre.
    * **Wheat-area:** A total area of wheat in acre.
    * **Soybean-area:** A area of soybeans in acre.
    * **Milo-area:** A total area of grain sorghum (milo) in acre.
  * **Energy**
    * **Energy_value:** Energy buyback rate
    * **#Panel_sets:** A number of solar panel set (one set is 1000 panels).
    * **Capacity_S:** Installed PV capacity, for each panel
    * **Nyear_S:** Solar panel lifespan
    * **Degrade_S:** Annual degradation rate
    * **Cost_S:** Solar panel capital costs
    * **ITC_S:** Investment Tax Credit
    * **PTC_S:** Production Tax Credit
    * **#Wind_turbines:** A number of wind turbines
    * **Capacity_W:** Installed wind capacity, for each turbine
    * **Nyear_W:** Wind turbine lifespan
    * **Degrade_W:** Annual degradation rate
    * **Cost_W:** Wind turbine capital costs
    * **ITC_W:** Investment Tax Credit
    * **PTC_W:** Production Tax Credit  
  * **Water**
    * **Aquifer_thickness:** Saturated thickness of the aquifer
    * **Min_Aq_Thickness:** Minimum available aquifer thickness
  * **Future_Process:** A drop-down menu of future process. Future process will be activated automatically after year 10 using historical data from 2008 to 2017 and GCM data (2018-2098).
    * **Repeat Historical:** Ten-year DSSAT results are repeated consecutively.
    * **Wetter Years:** A future that is wetter than historical period.
    * **Dryer Years:** A future that is drier than historical period.
    * **Impose P, T, & S:** A future involved climate change.
        * **Climate_Model:** RCP4.5 and RCP8.5

## Model function


### Agriculture

Crop simulations in FEWCalc are from simulated data from DSSAT. Results from DSSAT were based on both historical weather data from 2008 to 2017 and statistically downscaled Global Climate Models (GCMs) data under RCP4.5 and RCP8.5. Users have to select one of the future processes under **Climate Scenario** section. There are 4 options including _(1) Repeat Historical, (2) Wetter Years, (3) Dryer Years, and (4) Impose T, P, & S Changes._ Climate Projection scenario is the only one option applying GCM data for the projection.

**IRRIGATED FARMING**
FEWCalc assumes that water for irrigation is all from groundwater. The model simulates irrigated farmland if the water is available and the aquifer thickness is not less than a minimum aquifer thickness defined by users.

**DRYLAND FARMING**
During the simulation, groundwater is being consumed to supply water through the system. When the aquifer thickness is below a minimum aquifer thickness, the model stops irrigating and then applies dryland farming in the system. During dryland farming, the groundwater level rises due to the recharge rate.

### Energy

This recent version of FEWCalc assumes that installation cost spreads over 30 years. Users can define the number of solar panels and wind turbines in the interface under **Energy** section. A default wind turbine power is set at 2 megawatts.

_EQUATIONS:_

>  * Solar production (MWh) = #solar panels * Capacity_S * average peak sun hours * Degrade_S * 365 days/yr
  * Wind production (MWh) = #wind turbine * Capacity_W * capacity factor * Degrade_W * 8,760 hrs/yr
  * Solar cost ($) = #solar panels * Capacity_S / 1000 * Cost_S / Nyear_S * (1 - ITC_S / 100)
  * Wind cost ($) = #wind turbines * [(Capacity_W * Cost_W / Nyear_W) + O&M costs] * (1 - ITC_W / 100)
  * Solar sell ($) = solar production * Energy_value
  * Wind sell ($) = wind production * Energy_value

Default values are in Appendix C.

Contact: Bob Johnson (bobjohnson@centurylink.net), Earnie Lehman (earnielehman@gmail.com), and Hongyu Wu (hongyuwu@ksu.edu)

### Water

**SURFACE WATER**

  * **Nitrogen Concentration in Surface Water**
About 10% of applied nitrogen fertilizer remains in the soil during dry and moderate years until it is moved to surface-water bodies in wet years. The equation used are as follows.

_EQUATIONS:_

> N_field = 10% × N_applied × N_acres / 1.12	 -> _Accumulated until moved_
  N_stream = ∑time (N_field) 	                 -> _Moved in wet or extremely wet years_

**GROUNDWATER**

  * **Water-level change versus water use:**
[Whittemore et al (2016)](https://doi.org/10.1080/02626667.2014.959958) assessed the main drivers of water-level changes in the High Plain aquifer. They computed linear regression equations for correlation of mean annual water-level changes with reported water use during 1996-2012. They also evaluated the predicted response of the HPA and concluded that (1) water pumped for irrigation is the major driver of water-level changes. Besides, (2) a pumping reduction of 22% would stabilize the water level, and this could help extend the usable lifetime of the aquifer.
  * **Groundwater depletion:** 
FEWCalc employs a statistical method to determine the specific relationship between water-level change and water use for agriculture. A two-step process is used to calculate grounwater-level changes in this work (see section 2.5.2 in the article). Linear regression equations below were calculated based on historical data from 2008 to 2017 in Finney County, Kansas.

_EQUATIONS:_

> Step 1: **Reported gw use (ft)** = [0.114 * DSSAT water use (ft)] + 0.211
  Step 2: Average annual water-level change (ft) = [-32.386 * **Reported gw use (ft)**] + 8.001


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
Rectangle -16777216 true false 30 75 270 225
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
<experiments>
  <experiment name="100 runs of Wetter Future" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>corn-use-in</metric>
    <metric>wheat-use-in</metric>
    <metric>soybeans-use-in</metric>
    <metric>milo-use-in</metric>
    <enumeratedValueSet variable="Aquifer-thickness">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Soybeans-area">
      <value value="125"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#Solar_panel_sets">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Corn-area">
      <value value="125"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Wheat-area">
      <value value="125"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Panel_power">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#Wind_turbines">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Future_Process">
      <value value="&quot;Wetter Future&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Input-years">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Milo-area">
      <value value="125"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
