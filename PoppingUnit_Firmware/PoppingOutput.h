#ifndef _POPPING_OUTPUT_h
#define _POPPING_OUTPUT_h

#include <Arduino.h>

#define PIN_STATUS_1_LED   1  // PD3 Note: Must disable USART1 TX for this to work

#define OUTPUT_PINCOUNT 16
#define MAX_CONCURRENT_POPS 1

class PoppingOutput {
private:
  bool isPopping[OUTPUT_PINCOUNT];      // True if the output is currently being popped
  long popExpireTime[OUTPUT_PINCOUNT];  // Time to expire the current pop operation
  
  uint8_t getPopCount(); // Get the number of outputs currently being popped

public:
  // Init the popping unit outputs
  void init();
  
  // Re-evaluate the popping state machine
  // Call this often (once every loop()) for better timing
  // of the pop pulse
  void update();
  
  // Turn on the specified output, and set it to turn off after the specified delay
  // uint8_t output: Output to pop
  // uint32_t delay: Amount of time to heat, in miliseconds
  void pop(uint8_t output, uint32_t time);
};

#endif
