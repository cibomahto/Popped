import controlP5.*;
import processing.serial.*;

ControlP5 cp5;

String VERSION_STRING = "0.1";

int NUMBER_OF_CHANNELS = 1*16;

boolean Heartbeat = true;
int PopLength;

Protocol balloons;
String portName;

boolean readyToPop = false;
int balloonToPop;

void setup() {
  size(1200,300);
  frameRate(30);
  cp5 = new ControlP5(this);
  
  // auto connect to the first arduino-like thing we find
  for(String p : Serial.list()) {
    if(p.startsWith("/dev/cu.usbmodem")) {
      portName = p;
      balloons = new Protocol(this, p);
    }
  }
  
  cp5.addToggle("Heartbeat")
   .setPosition(10,10)
   ;
   
  cp5.addNumberbox("PopLength")
     .setPosition(100,10)
     .setSize(100,14)
     .setScrollSensitivity(50)
     .setValue(2000)
     ;

  for(int i = 0; i < NUMBER_OF_CHANNELS; i++) {
    int speakersPerCol = 16;
    
    Bang b = cp5.addBang("balloon"+i)
       .setPosition(40+i*60, 80)
       .setSize(40, 40)
       .setId(i)
       ;
  }
  
  // Debug info
  cp5.addTextlabel("label1")
    .setText("Debugger version " + VERSION_STRING)
    .setPosition(10,265)
    ;

  if(portName != "") {
    cp5.addTextlabel("label2")
     .setText("Transmitting on " + portName)
     .setPosition(10,280)
     ;
  } else {
    cp5.addTextlabel("label2")
     .setText("Could not find a port to transmit on!")
     .setPosition(10,280)
     ;
  }   
}

void draw() {
  background(0);
  stroke(255);
  
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
