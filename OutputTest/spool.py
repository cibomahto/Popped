import random

CONTROLLERS = [8,9]

CONTROLLER_COUNT = 32
BALLOONS_PER_CONTROLLER = 16
POP_DELAY = 10000

out = open("sequence.txt","w")

for balloon in range(0,BALLOONS_PER_CONTROLLER):
  for controller in CONTROLLERS:
    position = controller*BALLOONS_PER_CONTROLLER + balloon
    out.write("%i %i\n"%(position, POP_DELAY))
