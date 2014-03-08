#include "Protocol.h"
#include "PoppingOutput.h"

// Address that this device responds to. Change this for each board.
#define DEVICE_ADDRESS   0

// System baud rate. Leave at 250000 (35 boards * 1 config byte * 16 bits/channel * 60fps = 74880baud minimum)
#define BAUD_RATE 250000

#define PIN_STATUS_LED   13

Protocol usbReceiver;
Protocol rs485Receiver;

PoppingOutput popper;


void setup() {
  pinMode(PIN_STATUS_LED, OUTPUT);
  digitalWrite(PIN_STATUS_LED, HIGH);
  
  // Popping outputs
  popper.init();

  // USB input (The baud rate specified here doesn't matter)
  Serial.begin(115200);
  usbReceiver.reset();

  // RS485 input
  Serial1.begin(BAUD_RATE);
  rs485Receiver.reset();
}

bool handleData(uint8_t dataSize, uint16_t* data) {
  // Heartbeat message: Just flash the LED
  // Length: 2
  // [bytes 0-1]: 0x1234
  if (dataSize == 2 && data[0] == 0x1234) {
    return true;
  }
  
  // Pop message: If the
  // [bytes 0-1]: Address of balloon to pop
  // [bytes 2-3]: Length of time to heat element, in ms (3000 is best)
  if (dataSize == 4) {
    uint16_t balloon = data[0];
    uint16_t time = data[1];
    
    if(balloon >= DEVICE_ADDRESS*OUTPUT_PINCOUNT
       && balloon < (DEVICE_ADDRESS + 1)*OUTPUT_PINCOUNT) {
      popper.pop(balloon - DEVICE_ADDRESS*OUTPUT_PINCOUNT, time);
    }
    
    return true;
  }
    
  return false;
}


void loop() {
  
  while(true) {
    popper.pop(5, 3000);
    delay(1000);
  }

  // Handle incoming data from USB
  if(Serial.available()) {
    digitalWrite(PIN_STATUS_LED, LOW);
    
    if(usbReceiver.parseByte(Serial.read())) {
      uint8_t dataSize = usbReceiver.getPacketSize();
      uint16_t* data = usbReceiver.getPacket16();
      handleData(dataSize, data);
    }
  }

  // Handle incoming data from RS485  
  if(Serial1.available()) {
    digitalWrite(PIN_STATUS_LED, LOW);
    
    if(rs485Receiver.parseByte(Serial1.read())) {
      uint8_t dataSize = rs485Receiver.getPacketSize();
      uint16_t* data = rs485Receiver.getPacket16();
      handleData(dataSize, data);
    }
    digitalWrite(PIN_STATUS_LED, HIGH);
  }
}




