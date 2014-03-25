#include "PoppingOutput.h"

uint8_t outputPins[OUTPUT_COUNT] = {
   2, // PD1- Output 1
   5, // PC6- Output 2
  10, // PB6- Output 3
   9, // PB5- Output 4
   8, // PB4- Output 5
   6, // PD7- Output 6
  12, // PD6- Output 7
   4, // PD4- Output 8 
   7, // PE6- Output 9
  11, // PB7- Output 10
  23, // PF0- Output 11
  22, // PF1- Output 12
  21, // PF4- Output 13
  20, // PF5- Output 14
  19, // PF6- Output 15
  18, // PF7- Output 16
};

void PoppingOutput::init() {
  for(uint8_t output = 0; output < OUTPUT_COUNT; output++) {
    pinMode(outputPins[output], OUTPUT);
    digitalWrite(outputPins[output], LOW);
    
    popExpireTime[output] = 0;
    isPopping[output] = false;
  }
  
  // PIN_STATUS_1_LED conflicts with the USART TX pin, so we need to disable that function.
  UCSR1B &= ~(1<<TXEN1);
  pinMode(PIN_STATUS_1_LED, OUTPUT);
  digitalWrite(PIN_STATUS_1_LED, LOW);
}

uint8_t PoppingOutput::getPopCount() {
  uint8_t count = 0;
  
  for(uint8_t output = 0; output < OUTPUT_COUNT; output++) {  
    if(isPopping[output]) {
      count++;
    }
  }

  return count;
}

void PoppingOutput::update() {
  for(uint8_t output = 0; output < OUTPUT_COUNT; output++) {
    if(isPopping[output]) {
      if(millis() > popExpireTime[output]) {
        digitalWrite(outputPins[output], LOW);
        isPopping[output] = false;
      }
    }
  }
    
  if(getPopCount() == 0) {
    digitalWrite(PIN_STATUS_1_LED, LOW);
  }
}


void PoppingOutput::pop(uint8_t output, uint32_t time) {
  // If we aren't already popping the maximum outputs,
  // and this is a valid output
  if(output < OUTPUT_COUNT
     && getPopCount() < MAX_CONCURRENT_POPS) {

    // Clip the time to the maximum
    if(time > MAX_POP_TIME) {
      time = MAX_POP_TIME;
    }
       
    // If this output isn't already being popped
    if(isPopping[output] == false) {
      popExpireTime[output] = millis() + time;
      isPopping[output] = true;
      digitalWrite(outputPins[output], HIGH);
      digitalWrite(PIN_STATUS_1_LED, HIGH);
    }
  }
}
