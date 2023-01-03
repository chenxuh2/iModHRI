# this script follows through the pyactr tutorial https://github.com/jakdot/pyactr/wiki
import pyactr as actr

# initialize the model with an environment
environment = actr.Environment()
playing_memory = actr.ACTRModel(environment=environment) # here the environment is an artificial computer screen

# visual module
# visual stimuli is a list of dictionaries
# first is empty because nothing appears at the beginning
memory = [{}, {"A": {'text': 'A', 'position': (100, 100)}}, {"A": {'text': 'A', 'position': (100, 100)}}]

goal=playing_memory.set_goal("goal")
# define chunktype 'playgame' two slots 'game' and 'activity'
actr.chunktype("playgame", "game, activity, key, object")


# production rules
playing_memory.productionstring(name="startplaying", string="""
=goal>
isa  playgame
game memory
activity None
==>
=goal>
isa playgame
activity presskey""") #this rule will be modified later

# Model 2 - introduction to the motor module
# The motor module simulates a key press on a keyboard
playing_memory.productionstring(name="presskey", string="""
=goal>
isa  playgame
game memory
activity presskey
key =k
==>
+manual>
isa _manual 
cmd press_key
key =k
=goal>
isa playgame
activity attend""") # the _manual chunk is pre-specified in pyactr, with two slots cmd and key value

playing_memory.productionstring(name="attendobject", string="""
=goal>
isa  playgame
game memory
activity attend
=visual_location>
isa _visuallocation
?manual>
state free
==>
=goal>
isa playgame
activity storeobject
+visual>
isa _visual
cmd move_attention
screen_pos =visual_location""") # visual attention is moved (command move_attention) to the position specified by the visual_location buffer

#store the attended object to goal buffer
playing_memory.productionstring(name="storeobject", string="""
=goal>
isa  playgame
game memory
activity storeobject
=visual>
isa _visual
value =v
==>
=goal>
isa playgame
activity None
object =v""")

playing_memory.productionstring(name="startplaying", string="""
=goal>
isa  playgame
game memory
activity None
object None
==>
=goal>
isa playgame
activity presskey""") # only start playing before any object is recalled

playing_memory.productionstring(name="continueplaying", string="""
=goal>
isa  playgame
game memory
activity None
object ~None
==>
=goal>
isa playgame
game memory
activity recall""") # recall if the object is not None

# recall a chunk with a particular value
playing_memory.productionstring(name="recallvalue", string="""
=goal>
isa  playgame
game memory
activity recall
object =val
==>
=goal>
isa  playgame
game memory
activity checkrecalled
+retrieval>
isa playgame
object =val""")

# check if retrieved
playing_memory.productionstring(name="recallsuccessful", string="""
=goal>
isa  playgame
game memory
activity checkrecalled
object =val
?retrieval>
buffer full
=retrieval>
isa playgame
key =k
==>
=goal>
isa playgame
key =k
activity done""")

playing_memory.productionstring(name="recallfailed", string="""
=goal>
isa  playgame
game memory
activity checkrecalled
key 1
object =val
?retrieval>
state error
==>
~goal>
+goal>
isa playgame
game memory
activity presskey
key 2""")

#We have to specify what environment process it should be tied to.
#The class Environment specifies one process, which proceeds by printing one stimulus after another whenever a trigger is pressed, or time expires.

# starting chunk
initial_chunk = actr.makechunk(typename="playgame", game="memory", key="1")
goal.add(initial_chunk)
simulation = playing_memory.simulation(gui=False, environment_process=environment.environment_process, stimuli=memory, triggers=['1', '2', '3'])
simulation.run(max_time=2)

print(goal)
print(playing_memory.decmem)


for i in range(1, 9):
    playing_memory.productionstring(name="recallfailed" + str(i), string="""
    =goal>
    isa  playgame
    game memory
    activity checkrecalled
    key """ + str(i) + """
    object =val
    ?retrieval>
    state error
    ==>
    ~goal>
    +goal>
    isa playgame
    game memory
    activity presskey
    key """ + str((i + 1) % 10))

playing_memory.productionstring(name="recallfailed9", string="""
=goal>
isa  playgame
game memory
activity checkrecalled
key 0
object =val
?retrieval>
state error
==>
~goal>""")

memory = [{}] + [{i: {'text': i, 'position': (100, 100)}} for i in "BCDEFGHDIJ"]
goal.add(initial_chunk)
print(goal)
playing_memory.retrieval.pop()
simulation = playing_memory.simulation(environment_process=environment.environment_process, stimuli=memory, triggers=[str(i%10) for i in range(1,11)] + ['0'])

while True:
    simulation.step()
    if simulation.current_event.action == "RULE FIRED: recallsuccessful":
        break
print(goal)
print(simulation.show_time())