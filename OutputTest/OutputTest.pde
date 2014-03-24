import controlP5.*;
import processing.serial.*;

ControlP5 cp5;

String VERSION_STRING = "0.1";

int NUMBER_OF_RECEIVERS = 35;
int OUTPUTS_PER_RECEIVER = 16;

int NUMBER_OF_CHANNELS = NUMBER_OF_RECEIVERS * OUTPUTS_PER_RECEIVER;

boolean Heartbeat = true;
int PopLength;

Protocol balloons;
String portName;

boolean readyToPop = false;
int balloonToPop;

void setup() {
  size(1366,768);
  frameRate(30);
  cp5 = new ControlP5(this);
  
  // auto connect to the first arduino-like thing we find
  for(String p : Serial.list()) {
    if(p.startsWith("/dev/cu.usbmodem")) {
      portName = p;
      balloons = new Protocol(this, p);
    }
  }
  
  // Heartbeat toggle
  cp5.addToggle("Heartbeat")
   .setPosition(10,10)
   ;
   
  // Popping length
  cp5.addNumberbox("PopLength")
     .setPosition(10,60)
     .setSize(100,14)
     .setScrollSensitivity(50)
     .setValue(2000)
     ;

  // Debug info
  cp5.addTextlabel("label1")
    .setText("Debugger version " + VERSION_STRING)
    .setPosition(10,700)
    ;

  if(portName != "") {
    cp5.addTextlabel("label2")
     .setText("Transmitting on " + portName)
     .setPosition(10,715)
     ;
  } else {
    cp5.addTextlabel("label2")
     .setText("Could not find a port to transmit on!")
     .setPosition(10,715)
     ;
  }   

  // Poppers
  int POPPERS_X_OFFSET = 300;
  int POPPERS_Y_OFFSET = 25;
  int POPPERS_X_SPACING = 54;
  int POPPERS_Y_SPACING = 21;
  
  for(int i = 0; i < NUMBER_OF_CHANNELS; i++) {
    Bang b = cp5.addBang("balloon"+i)
       .setPosition(POPPERS_X_OFFSET+(i%OUTPUTS_PER_RECEIVER)*POPPERS_X_SPACING,
                    POPPERS_Y_OFFSET+(i/OUTPUTS_PER_RECEIVER)*POPPERS_Y_SPACING)
       .setSize(50, 17)
       .setId(i)
       .setLabelVisible(false);
       ;
  }
  
  // Labels for poppers
  for(int i = 0; i < OUTPUTS_PER_RECEIVER; i++) {
    cp5.addTextlabel("output" + str(i))
     .setText("Output" + str(i))
     .setPosition(POPPERS_X_OFFSET + i*POPPERS_X_SPACING + 3, POPPERS_Y_OFFSET - 12)
     ;
  }
  
  for(int i = 0; i < NUMBER_OF_RECEIVERS; i++) {
    cp5.addTextlabel("receiver" + str(i))
     .setText("Receiver" + str(i))
     .setPosition(POPPERS_X_OFFSET - 60, POPPERS_Y_OFFSET + i*POPPERS_Y_SPACING + 3)
     ;
  }
}

void draw() {
  background(0);
  stroke(255);
  
  pushStyle();
    stroke(50);
    fill(50);
    rect(0,0,210,768);
  popStyle();
  
  if(readyToPop) {
    print("popping ");
    println(balloonToPop);    
    // Pop a balloon
    int message[] = new int[2];
    message[0] = balloonToPop;
    message[1] = PopLength;
    balloons.sendUpdate(message);
    
    readyToPop = false;
    
    println("Sending pop command");
  }
  else if(Heartbeat) {
    // Heartbeat
    int message[] = new int[1];
    message[0] = 0x1234;
    balloons.sendUpdate(message);
    println("Sending heartbeat");
  }
}

public void controlEvent(ControlEvent theEvent) {
  for (int i=0; i<NUMBER_OF_CHANNELS; i++) {
    if (theEvent.getController().getName().equals("balloon"+i)) {
      balloonToPop = i;
      readyToPop = true;
    }
  }
  
  println(
  "## controlEvent / id:"+theEvent.controller().id()+
    " / name:"+theEvent.controller().name()+
    " / label:"+theEvent.controller().label()+
    " / value:"+theEvent.controller().value()
    );
}
