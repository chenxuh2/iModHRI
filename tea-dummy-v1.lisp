(clear-all)

(define-model tea-making-sequences

  (sgp :seed (101 0))
  (sgp :v t :trace-detail medium)

;list of all actions
;actions: step near, pick up, pour water, put (away), take (out), mix, drink

;list of all objects
;objects: kettle, cup, tea bag, spoon

;DM: pre-knowledge, what we expect the participants to already know
;define chunk types

;temporarily put data as a chunk to test model
;currently max(action slot)=12, max(object slot)=12
(chunk-type goal start action1 object1 action2 object2 action3 object3 action4 object4 action5 object5 action6 object6 action7 object7 action8 object8 action9 object9 action10 object10 action11 object11 complete)


;actions, with slots that contain objects which can afford the action
;currently max(slot)=n(object)
(chunk-type action name object1 object2 object3 object4)

;objects, state of the object---location, purpose, state
(chunk-type object name purpose container state)

;situation awareness---modify the state of the objects
(chunk-type SA current taskStarted waterBoiled waterInMug teaInMug)

;knowledge about order of events
;(chunk-type ordering saName order1 order2 order3)

;goal buffer: keep track of the current action
;imaginal buffer: SA

(add-dm
  ;test data
  (s1 isa goal start stepNear action1 pickUp object1 kettle action2 pourWater object2 cup action3 put object3 kettle action4 take object4 tea action5 put object5 tea action6 pickUp object6 spoon action7 mix object7 tea action8 put object8 spoon action9 pickUp object9 cup complete drink)

  ;actions, currently simplified,
  ;for example, "pick up" and "lift" are both "take"
  ;(near isa action name stepNear)
  (pick isa action name pickUp object1 kettle object2 cup object3 teaBag object4 spoon)
  (take isa action name take object1 spoon object2 kettle object3 cup)
  (pour isa action name pourWater object1 cup)
  (put isa action name put object1 kettle object2 tea object3 spoon)
  (mix isa action name mix object1 tea)
  (drink isa action name drink)

  ;objects
  (kettle isa object name kettle purpose boilWater container y state full)
  (cup isa object name cup purpose toContainTea container y state empty)
  (tea isa object name tea purpose teaBag container n)
  (spoon isa object name spoon purpose mixTea container n)

  ;ordering
  ;(ord1 isa ordering saName waterBoiled order1 order2 order3)
  ;(ord2 isa ordering saName waterInMug)
  ;(ord3 )
)

;set an initial goal, focus on the goal chunk named s1
(goal-focus s1)

;start if step near action is detected
;create SA in imaginal buffer
;need current action slot???
(p start
  =goal>
    isa goal
    start =start ;stepNear
    action1 =a1
  - action1 nil ;there is a list of actions existing
    object1 =obj1
  ?retrieval>
    state free
    buffer empty
  ?imaginal>
    state free
    buffer empty ;see Q1
==>
  ;retrieve the corresponding
  +retrieval>
    isa object
    name =obj1
  +imaginal>
    isa SA
    current =a1
    taskStarted yes ;task always starts at stepNear
    waterBoiled yes ;assumption is water in kettle and boiled
    waterInMug nil
    teaInMug nil
)

; iterate through slots in goal

;update water boiled and output next actions
(p updateWateredBoiled
  =goal>
    isa goal
  =imaginal>
    isa SA
    taskStarted =yes
    waterBoiled =yes
  ;=retrieval>
  ;  isa object
  ;  name =obj1
==>
  =imaginal>
  !output! waterBoiled
  ;get specific actions within the sub-step
)


;if situation awareness shows all steps are completed
;predict drink tea
(p finish
  =goal>
    isa goal
    complete =completed
  =imaginal>
    isa SA
    taskStarted =yes
    waterBoiled =yes
    waterInMug =yes
    teaInMug =yes
==>
  =goal>
  !output! complete
)

) ;do not delete end-of-file
