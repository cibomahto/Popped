
CONTROLLER_COUNT = 8
BALLOONS_PER_CONTROLLER = 16

out = open("sequence.txt","w")

for balloon in range(0,BALLOONS_PER_CONTROLLER):
  for controller in range(0,CONTROLLER_COUNT):
    out.write("%i\n"%(controller*BALLOONS_PER_CONTROLLER+balloon))
