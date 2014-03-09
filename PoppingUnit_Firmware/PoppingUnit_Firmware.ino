#include "Protocol.h"
#include "PoppingOutput.h"

// Address that this device responds to. Change this for each board.
#define DEVICE_ADDRESS   0

// System baud rate. Leave at xxx
#define BAUD_RATE 9600

#define PIN_STATUS_LED    13  // PC7
#define PIN_STATUS_1_LED   1  // PD3 *Note: Must disable TX, might not actually work.


#define SIGNAL_DISPLAY_TIMEOUT 100  // Number of seconds to continue flashing the display LED, 
long lastSignalTime;


Protocol usbReceiver;
Protocol rs485Receiver;

PoppingOutput popper;

void setup() {
  // USB input (The baud rate specified here doesn't matter)
  Serial.begin(115200);
  usbReceiver.reset();

  // RS485 input
  Serial1.begin(BAUD_RATE);
  rs485Receiver.reset();
    
  // Status LEDs
  pinMode(PIN_STATUS_LED, OUTPUT);
  analogWrite(PIN_STATUS_LED, 128);
  TCCR4B |= (1<<CS43);
  TCCR4B |= (1<<CS42);
  TCCR4B |= (1<<CS41);
  TCCR4B |= (1<<CS40);


// PIN_STATUS_1_LED conflicts with the USART TX pin, so we need to disable it
// Note that this may not work.
  UCSR1B &= ~(1<<TXEN1);
  pinMode(PIN_STATUS_1_LED, OUTPUT);
  digitalWrite(PIN_STATUS_1_LED, LOW);
  
  // Popping outputs
  popper.init();
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
      digitalWrite(PIN_STATUS_1_LED, HIGH);
      popper.pop(balloon - DEVICE_ADDRESS*OUTPUT_PINCOUNT, time);
      digitalWrite(PIN_STATUS_1_LED, LOW);
    }
    
    return true;
  }
    
  return false;
}


void loop() {
  if(millis() > lastSignalTime + SIGNAL_DISPLAY_TIMEOUT) {
    analogWrite(PIN_STATUS_LED, 255);
  }
  
  // Handle incoming data from USB
  if(Serial.available()) {
    analogWrite(PIN_STATUS_LED, 128);
    lastSignalTime = millis();
    
    if(usbReceiver.parseByte(Serial.read())) {
      uint8_t dataSize = usbReceiver.getPacketSize();
      uint16_t* data = usbReceiver.getPacket16();
      handleData(dataSize, data);
    }
  }

  // Handle incoming data from RS485  
  if(Serial1.available()) {
    analogWrite(PIN_STATUS_LED, 128);
    lastSignalTime = millis();
    
    if(rs485Receiver.parseByte(Serial1.read())) {
      uint8_t dataSize = rs485Receiver.getPacketSize();
      uint16_t* data = rs485Receiver.getPacket16();
      handleData(dataSize, data);
    }
  }
}




