#ifndef _POPPING_OUTPUT_h
#define _POPPING_OUTPUT_h

#include <Arduino.h>

#define OUTPUT_PINCOUNT 16

class PoppingOutput {
private:

public:
  // Init the popping unit outputs
  void init();
  
  // Pop an output by turning it on for a short time
  // uint8_t output: Output to pop
  // uint32_t delay: Amount of time to heat, in miliseconds
  void pop(uint8_t output, uint32_t time);
};

#endif
