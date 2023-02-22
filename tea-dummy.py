"""
This is a dummy model of an act-r agent making tea
"""

import pyactr as actr

tea_making = actr.ACTRModel()

# create chunk types
actr.chunktype("container", ("is_empty", "can_heat_water"))
actr.chunktype("action_sequences")
