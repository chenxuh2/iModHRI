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
;currently max(slot)=12
(chunk-type goal action1 action2 action3 action4 action5 action6 action7 action8 action9 action10 action11 action12)

;actions, with slots that contain objects which can afford the action
;currently max(slot)=n(object)
(chunk-type action name object1 object2 object3 object4)
;objects, state of the object---location, purpose



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
