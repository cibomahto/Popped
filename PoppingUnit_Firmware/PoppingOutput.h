#ifndef _POPPING_OUTPUT_h
#define _POPPING_OUTPUT_h

#include <Arduino.h>

#define PIN_STATUS_1_LED   1   // PD3 Note: Must disable USART1 TX for this to work

#define OUTPUT_COUNT 16        // Number of outputs present in the hardware
#define MAX_CONCURRENT_POPS 1  // Number of outputs that can be active at once (Hardware limited)

#define MAX_POP_TIME 10000      // Maximum amount of time a popping output can be activated for (ms) 

// Class to manage the popping outputs
class PoppingOutput {
private:
  bool isPopping[OUTPUT_COUNT];      // True if the output is currently being popped
  long popExpireTime[OUTPUT_COUNT];  // Time to expire the current pop operation
  
  // Get the number of outputs currently being popped
  // @return Number of outputs currently active
  uint8_t getPopCount();

public:
  // Init the popping unit outputs
  void init();
  
  // Re-evaluate the popping state machine
  // Call this often (once every loop()) for stricter timing of the pop pulse
  void update();
  
  // Turn on the specified output, and set it to turn off after the specified delay
  // @param uint8_t output: Output to pop
  // @param uint32_t delay: Amount of time to heat, in miliseconds
  void pop(uint8_t output, uint32_t time);
};

#endif
