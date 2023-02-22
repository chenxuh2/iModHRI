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
(chunk-type goal action1 object1 action2 object2 action3 object3 action4 object4 action5 object5 action6 object6 action7 object7 action8 object8 action9 object9 action10 object10 action11 object11 action12 object12)

;actions, with slots that contain objects which can afford the action
;currently max(slot)=n(object)
(chunk-type action name object1 object2 object3 object4)

;objects, state of the object---location, purpose, state
(chunk-type object name purpose container state)

;situation awareness---modify the state of the objects
(chunk-type SA taskStarted waterBoiled waterInMug teaInMug)

;goal buffer: keep track of the current action
;imaginal buffer: SA

(add-dm
  ;test data
  (s1 isa goal action1 stepNear action2 pickUp object2 kettle action3 pourWater object3 cup action4 put object4 kettle action5 take object5 tea action6 put object6 tea action7 pickUp object7 spoon action8 mix object8 tea action9 put object9 spoon action10 pickUp object10 cup action11 drink)

  ;SA
  (sa isa SA taskStarted nil waterBoiled nil waterInMug nil teaInMug nil teaReady nil)

  ;actions, currently simplified,
  ;for example, "pick up" and "lift" are both "take"
  (near isa action name stepNear)
  (pick isa action name pickUp object1 kettle object2 cup object3 teaBag object4 spoon)
  (take isa action name take object1 spoon object2 kettle object3 cup)
  (pour isa action name pourWater object1 cup)
  (put isa action name put object1 kettle object2 tea object3 spoon)
  (mix isa action name mix object1 tea)
  (drink isa action name drink)

  ;objects
  (kettle isa object name kettle purpose boilWater container y state empty)
  (cup isa object name cup purpose toContainTea container y state empty)
  (tea isa object name tea purpose teaBag container n)
  (spoon isa object name spoon purpose mixTea container n)
)

;set an initial goal, focus on the goal chunk named s1
(goal-focus s1)

;start if step near action is detected
;modify SA
(p start
  =>goal>
  ISA goal

)








)
