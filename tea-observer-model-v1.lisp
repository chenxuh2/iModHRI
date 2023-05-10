(clear-all)

(define-model tea-making-sequences

  (sgp :seed (101 0))
  (sgp :v t :trace-detail medium)
  (sgp :save-p-history t)

;list of all actions
;actions: step near, pick up, pour water, put (away), take (out), mix, drink

;list of all objects
;objects: kettle, cup, tea bag, spoon

;DM: pre-knowledge, what we expect the participants to already know
;define chunk types

;temporarily put data as a set of chunks to test model
(chunk-type goal action object next-act next-obj)
; !!!next slot is newly added to distinguish from two existing lists
; but this is not enough currently
(chunk-type action-list start end next currentA currentO)

;situation awareness---modify the state of the objects
;&&&&&&& NEED CURRENT ACTION AND OBJECT???????
(chunk-type SA currentPhase updated taskStarted waterBoiled waterInMug teaInMug)

;phases of tea making
(chunk-type phaseAction currentPhase currentAction currentObject nextAction nextObject)

;goal buffer: keep track of the current action
;imaginal buffer: SA

(add-dm

  ;phase information chunk
  ;waterBoiled is already completed at the beginning
  ;only two possibilities:

  (waterInMugStep1 isa phaseAction currentPhase waterInMug currentAction pickUp currentObject kettle nextAction pourWater nextObject cup)
  (waterInMugStep2 isa phaseAction currentPhase waterInMug currentAction pourWater currentObject cup nextAction put nextObject kettle)
  (waterInMugStep3 isa phaseAction currentPhase waterInMug currentAction put currentObject kettle)

  (teaInMugStep1 isa phaseAction currentPhase teaInMug currentAction take currentObject tea nextAction put nextObject tea)
  (teaInMugStep2 isa phaseAction currentPhase teaInMug currentAction put currentObject tea)

  (mixTeaStep1 isa phaseAction currentPhase mixTea currentAction pickUp currentObject spoon nextAction mix nextObject Tea)
  (mixTeaStep2 isa phaseAction currentPhase mixTea currentAction mix currentObject Tea nextAction put nextObject spoon)
  (mixTeaStep3 isa phaseAction currentPhase mixTea currentAction put currentObject spoon)


  ;test data
  (s1 isa action-list start stepNear end drink next pickUp)

  ;(a1 isa goal action stepNear next-act pickUp next-obj kettle)
  ;(a2 isa goal action pickUp object kettle next-act pourWater next-obj cup)
  ;(a3 isa goal action pourWater object cup next-act put next-obj kettle)
  ;(a4 isa goal action put object kettle next-act take next-obj tea)
  ;(a5 isa goal action take object tea next-act put next-obj tea)
  ;(a6 isa goal action put object tea next-act pickUp next-obj spoon)
  ;(a7 isa goal action pickUp object spoon next-act mix next-obj tea)
  ;(a8 isa goal action mix object tea next-act put next-obj spoon)
  ;(a9 isa goal action put object spoon next-act pickUp next-obj cup)
  ;(a10 isa goal action pickUp object cup next-act drink)

  ;test data 2
  (s2 isa action-list start stepNear end drink next take)

  (b1 isa goal action stepNear next-act take next-obj tea)
  (b2 isa goal action take object tea next-act put next-obj tea)
  (b3 isa goal action put object tea next-act pickUp next-obj kettle)
  (b4 isa goal action pickUp object kettle next-act pourWater next-obj cup)
  (b5 isa goal action pourWater object cup next-act put next-obj kettle)
  (b6 isa goal action put object kettle next-act pickUp next-obj spoon)
  (b7 isa goal action pickUp object spoon next-act mix next-obj tea)
  (b8 isa goal action mix object tea next-act put next-obj spoon)
  (b9 isa goal action put object spoon next-act pickUp next-obj cup)
  (b10 isa goal action pickUp object cup next-act drink)
)

;set an initial goal, focus on the goal chunk named s1
;(goal-focus s1)
(goal-focus s2)

;start if step near action is detected
;create SA in imaginal buffer
(p start
  =goal>
    isa action-list
    start =start ;stepNear
    next =firstAction ;to distinguish between goals
    currentA nil
    currentO nil
  ?imaginal>
    state free
    buffer empty ;see Q1
==>
  =goal>
    isa action-list
    currentA =start
  +imaginal>
    isa SA
    currentPhase waterBoiled ;set this to where the task actually starts
    updated yes ;set this to yes at the beginning
    taskStarted yes ;task always starts at stepNear
    waterBoiled yes ;assumption is water in kettle and boiled
    waterInMug nil
    teaInMug nil
    !output! (currentPhase is waterBoiled)
   +retrieval>
     isa goal
     action =start ;retrieve the goal where current action is stepNear
     next-act =firstAction ; a1 versus b1
)

;iterate through actions
(p iteration
   =goal>
     isa action-list
     currentA =currAction
   - end =currAction
   =retrieval>
     isa goal
     action =currAction   ;here current is start
     next-act =nextAction
     next-obj =nextObject
   ;only continues to iterate if SA in imaginal buffer has been updated
   =imaginal>
     isa SA
     updated yes
==>
   =goal>
     isa action-list
     currentA =nextAction
     currentO =nextObject
   +retrieval>
     isa goal
     action =nextAction       ;the first action after 'start/step near'
     object =nextObject
     !output! (=nextAction)
     !output! (=nextObject)
   ;set SA update status to no after iterating to the next action from data
   ;this means the current action needs to be processed
   =imaginal>
     isa SA
     updated no
)

;update water boiled and output next actions
;may need to retrieve phases
;but remember to GO BACK to chunk-type goal so that we can continue the iteration
;e.g., back to A2
(p get-phase
   =imaginal>  ;not updated, but knows current phase
     isa SA
     updated no
     currentPhase =currPhase
   =retrieval>  ;has information about the real action, e.g., current action after start
     isa goal
     action =currAction
     object =currObject
==>
   =imaginal>  ;does not change? test for phase completion??
   +retrieval>  ;retrieve the corresponding action in a phase, output next action, update phase if completed
     isa phaseAction
     currentAction =currAction
     currentObject =currObject
)

;LAST STEP in the waterInMug phase
(p update-sa-endPhase-waterInMug
   =imaginal>
     isa SA
     updated no
   =retrieval>
     isa phaseAction
     currentPhase waterInMug
     currentAction =currAction
     currentObject =currObject  ;to retrieve data chunk for continued iteration
     nextAction nil
     nextObject nil  ;end of a phase
==>
   =imaginal>
     isa SA
     updated yes  ;still need some test for completed phase or not
     waterInMug yes
   +retrieval>
     isa goal
     action =currAction
     object =currObject
   !output! (SA updated waterInMug completed)
)

;LAST STEP in the teaInMug phase
(p update-sa-endPhase-teaInMug
   =imaginal>
     isa SA
     updated no
   =retrieval>
     isa phaseAction
     currentPhase teaInMug
     currentAction =currAction
     currentObject =currObject  ;to retrieve data chunk for continued iteration
     nextAction nil
     nextObject nil  ;end of a phase
==>
   =imaginal>
     isa SA
     updated yes  ;still need some test for completed phase or not
     teaInMug yes
   +retrieval>
     isa goal
     action =currAction
     object =currObject
   !output! (SA updated teaInMug completed)
)

;update SA in imaginal buffer and iterate back to the next action
(p update-sa-midPhase
   =imaginal>
     isa SA
     updated no
   =retrieval>
     isa phaseAction
     currentPhase =updatePhase
     currentAction =currAction
     currentObject =currObject  ;to retrieve data chunk for continued iteration
     nextAction =predAction
     nextObject =predObject  ;to output predicted information
==>
   =imaginal>
     isa SA
     updated yes  ;still need some test for completed phase or not
     currentPhase =updatePhase ;update current phase to the current phase given phaseAction
   +retrieval>
     isa goal
     action =currAction
     object =currObject
   !output! (predicted action is =predAction)
   !output! (predicted object is =predObject)
)



;if situation awareness shows all steps are completed
;predict drink tea
(p stop
  =goal>
    isa action-list
    currentA =endAction
    end =endAction
==>
  =goal>
  !output! (=endAction)
)



) ;do not delete end-of-file
