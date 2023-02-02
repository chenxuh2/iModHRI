(clear-all)

(define-model tea-making-sequences

  (sgp :seed (101 0))
  (sgp :v t :trace-detail medium)

(chunk-type container name heating content)

;available objects for the action
(chunk-type action name object1 object2 object3)

;chunks:
;actions, with slots that contain objects which can afford the action
;objects, state of the object---location, purpose, can they contain, or heat up things


;goal buffer:
;keep track of the current action
;need additional slot to keep track of the sequence?
;imaginal buffer:
;situation awareness---modify the state of the objects
;top down versus bottom up??


(add-dm
  (kettle isa container name "kettle" heating true)
  (mug isa container name "mug" heating false)

  ;currently actions are simplified,
  ;for example, "pick up" and "lift" are both "take"

  (near isa action name "step near")
  (press isa action name "button press" object1 kettle)
  (wait isa action name "wait")
  (take isa action name "take" object1 spoon object2 kettle object3 mug)
  (pour isa action name "pour")
  (back isa action name "put back" object1 spoon object2 kettle object3 mug)





)
