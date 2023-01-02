# this script follows through the pyactr tutorial https://github.com/jakdot/pyactr/wiki
import pyactr as actr

# initialize the model with an environment
environment = actr.environment()
playing_memory = actr.ACTRModel(environment=environment) # here the environment is an artificial computer screen

# visual module
# visual stimuli is a list of dictionaries



# define chunktype 'playgame' two slots 'game' and 'activity'
actr.chunktype("playgame", "game, activity")

# starting chunk
initial_chunk = actr.makechunk(typename="playgame", game="memory")

goal=playing_memory.set_goal("goal")

goal.add(initial_chunk)

print(goal)

playing_memory.productionstring(name="startplaying", string="""
=goal>
isa  playgame
game memory
activity None
==>
=goal>
isa playgame
activity presskey""") #this rule will be modified later

simulation_game = playing_memory.simulation()

simulation_game.run()

print(goal)

final_chunk = goal.pop()
print(final_chunk)
len(final_chunk) #lenth of the chunk, tuple
for slot_value in final_chunk: #check slot values
    print(slot_value)

print(final_chunk.game)

# Model 2 - introduction to the motor module
# The motor module simulates a key press on a keyboard
playing_memory.productionstring(name="presskey", string="""
=goal>
isa  playgame
game memory
activity presskey
==>
+manual>
isa _manual 
cmd press_key
key 1
=goal>
isa playgame
activity None""") #this rule is NOT correct; the _manual chunk is pre-specified in pyactr, with two slots cmd and key value

playing_memory.productionstring(name="startplaying", string="""
=goal>
isa  playgame
game memory
activity None
?manual>
state free
==>
=goal>
isa playgame
activity presskey""")

goal.add(initial_chunk)
simulation_game = playing_memory.simulation()
simulation_game.run()

