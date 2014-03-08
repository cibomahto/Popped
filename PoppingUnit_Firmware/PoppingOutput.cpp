#include "PoppingOutput.h"

uint8_t outputPins[OUTPUT_PINCOUNT] = {
   1, // PD3- Output 1 - Note: Not usable on RevA
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
  for(uint8_t output = 0; output < OUTPUT_PINCOUNT; output++) {
    pinMode(outputPins[output], OUTPUT);
    digitalWrite(outputPins[output], LOW);
  }

//  int output = 0;
//  while(true) {
//    digitalWrite(outputPins[output + 8], HIGH);
//    delay(3000);
//    digitalWrite(outputPins[output + 8], LOW);
//    delay(1000);
//    
//    output = (output + 1) % 8;
//  }
}

// Turn the specified output on for 3 seconds
// TODO: Make me a timer?
void PoppingOutput::pop(uint8_t output, uint32_t time) {
  if(output < OUTPUT_PINCOUNT) {
    digitalWrite(outputPins[output], HIGH);
    delay(time);
    digitalWrite(outputPins[output], LOW);
  }
}
