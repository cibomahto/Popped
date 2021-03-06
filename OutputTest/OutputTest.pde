import controlP5.*;
import processing.serial.*;

int NUMBER_OF_RECEIVERS = 32;
int OUTPUTS_PER_RECEIVER = 16;

int NUMBER_OF_CHANNELS = NUMBER_OF_RECEIVERS * OUTPUTS_PER_RECEIVER;

ControlP5 cp5;

Textarea statusWindow;
Textlabel timeRemaining;
Textlabel timeTillNextPop;
Bang[] balloonOutputs = new Bang[NUMBER_OF_CHANNELS];

String VERSION_STRING = "1.1";

boolean Heartbeat = true;
int PopLength;

Protocol balloons;          // balloon popping output
String portName;

boolean userPopScheduled = false; // true if there is a user scheduled pop
int balloonToPop;           // user scheduled pop

boolean Playback = false;   // toggle for playback
boolean playing = false;    // true if we are playing back
int nextPopTime;            // next time a balloon should be popped (compare to millis())
Sequencer sequencer;        // Where we get the popping sequence from

void sendHeartbeat() {
  if (balloons == null) {
    //    displayMessage("Could not send heartbeat, no balloon hardware found!");
    return;
  }

  // Heartbeat
  //    displayMessage("Sending heartbeat");
  int message[] = new int[1];
  message[0] = 0x1234;
  balloons.sendUpdate(message);
}

void sendPopCommand(int balloon, int len) {
  displayMessage("Popping " + balloon
    + " (" + (balloon/OUTPUTS_PER_RECEIVER)
    + "-" + (balloon%OUTPUTS_PER_RECEIVER) + ")");
  balloonOutputs[balloon].setColorForeground(color(60, 0, 60));

  if (balloons == null) {
    //    displayMessage("Could not send popping command, no balloon hardware found!");
    return;
  }

  if (balloon >= NUMBER_OF_CHANNELS || balloon < 0) {
    displayMessage("Balloon " + balloon + " out of range!");
    return;
  }

  // Pop a balloon
  int message[] = new int[2];
  message[0] = balloon;
  message[1] = len;

  // Send the message 5 times, just in case there is some line noise
  for (int i = 0; i < 5; i++) {
    balloons.sendUpdate(message);
  }
}

void displayMessage(String message) {
  println(message);

  String text = statusWindow.getText();

  text += message + "\n";

  statusWindow.setText(text);
  statusWindow.scroll(1);
}

void setup() {
  size(1366, 768);
  frameRate(30);
  cp5 = new ControlP5(this);

  // auto connect to the first arduino-like thing we find
  for (String p : Serial.list()) {
    if (p.startsWith("/dev/cu.usbmodem")) {
      portName = p;
      balloons = new Protocol(this, p);
    }
  }

  cp5.addTextlabel("title")
    .setText("Popping Control System")
      .setPosition(10, 10)
        .setFont(createFont("Georgia", 17))
          ;

  // Heartbeat toggle
  cp5.addToggle("Heartbeat")
    .setPosition(10, 60)
      ;

  // Popping length
  cp5.addSlider("PopLength")
    .setPosition(10, 120)
      .setSize(100, 14)
        .setRange(1000, 5000)
          .setValue(3000)
            .setNumberOfTickMarks(41)
              .showTickMarks(false)
                ;

  cp5.addToggle("Playback")
    .setPosition(10, 180)
      ;

  // Debug info
  timeRemaining = cp5.addTextlabel("timeRemaining")
    .setText("Time remaining:")
      .setPosition(10, 300)
        .setFont(createFont("Georgia", 15))
        ;

  // Debug info
  timeTillNextPop = cp5.addTextlabel("timeTillNextPop")
    .setText("Time till next pop:")
      .setPosition(10, 320)
        .setFont(createFont("Georgia", 15))
        ;

  statusWindow = cp5.addTextarea("statusWindow")
    .setPosition(10, 360)
      .setSize(180, 350)
        .setFont(createFont("arial", 12))
          .setLineHeight(14)
            .setColor(color(200))
              .setColorBackground(color(255, 100))
                .setColorForeground(color(255, 100));
  ;

  // Debug info
  cp5.addTextlabel("label1")
    .setText("Debugger version " + VERSION_STRING)
      .setPosition(10, 700)
        ;

  if (portName != "") {
    cp5.addTextlabel("label2")
      .setText("Transmitting on " + portName)
        .setPosition(10, 715)
          ;
  } 
  else {
    cp5.addTextlabel("label2")
      .setText("Could not find a port to transmit on!")
        .setPosition(10, 715)
          ;
  }   

  // Poppers
  int POPPERS_X_OFFSET = 300;
  int POPPERS_Y_OFFSET = 25;
  int POPPERS_X_SPACING = 64;
  int POPPERS_Y_SPACING = 23;


  for (int i = 0; i < NUMBER_OF_CHANNELS; i++) {
    balloonOutputs[i] = cp5.addBang("balloon"+i)
      .setPosition(POPPERS_X_OFFSET+(i%OUTPUTS_PER_RECEIVER)*POPPERS_X_SPACING, 
      POPPERS_Y_OFFSET+(i/OUTPUTS_PER_RECEIVER)*POPPERS_Y_SPACING)
        .setSize(60, 19)
          .setId(i)
            .setLabelVisible(false);
    ;
  }

  // Labels for poppers
  for (int i = 0; i < OUTPUTS_PER_RECEIVER; i++) {
    cp5.addTextlabel("output" + str(i))
      .setText("Output" + str(i))
        .setPosition(POPPERS_X_OFFSET + i*POPPERS_X_SPACING + 3, POPPERS_Y_OFFSET - 12)
          ;
  }

  for (int i = 0; i < NUMBER_OF_RECEIVERS; i++) {
    cp5.addTextlabel("receiver" + str(i))
      .setText("Receiver" + str(i))
        .setPosition(POPPERS_X_OFFSET - 60, POPPERS_Y_OFFSET + i*POPPERS_Y_SPACING + 3)
          ;
  }

  sequencer = new Sequencer("sequence.txt");
}

void draw() {
  background(0);
  stroke(255);

  pushStyle();
  stroke(50);
  fill(50);
  rect(0, 0, 210, 768);
  popStyle();

  if (userPopScheduled) {
    sendPopCommand(balloonToPop, PopLength);

    userPopScheduled = false;
  }
  else if (playing && (millis() > nextPopTime)) {
    PopCommand nextCommand = sequencer.getNextCommand();
    int newPopSpacing = nextCommand.m_delay;
    int newPosition = nextCommand.m_position;

    if (newPosition == -1) {
      playing = false;
    }
    else {
      nextPopTime = millis() + newPopSpacing;

      sendPopCommand(newPosition, PopLength);
    }
  }
  else if (Heartbeat) {
    sendHeartbeat();
  }

  float timeToPop = (playing?max(0, (nextPopTime - millis())/1000.1):0);
  float timeRemain = sequencer.getRemainingTime()/1000.1 + timeToPop;

  timeRemaining.setText("Time remaining:\n" + nf(timeRemain, 3, 2)
    + "s (" + nf(timeRemain/60, 2, 2) + "m)");

  timeTillNextPop.setText("Time till next pop:\n" + nf(timeToPop,2,2) + "s");
}

public void controlEvent(ControlEvent theEvent) {
  for (int i=0; i<NUMBER_OF_CHANNELS; i++) {
    if (theEvent.getController().getName().equals("balloon"+i)) {
      // Ignore multiple pops from user
      balloonToPop = i;
      userPopScheduled = true;
    }
  }

  if (theEvent.controller().getName().equals("Playback")) {
    if (Playback == true) {
      playing = true;
      nextPopTime = millis();
    }
    else {
      playing = false;
    }
  }

  //  println(
  //  "## controlEvent / id:"+theEvent.controller().id()+
  //    " / name:"+theEvent.controller().name()+
  //    " / label:"+theEvent.controller().label()+
  //    " / value:"+theEvent.controller().value()
  //    );
}

