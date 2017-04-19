#define BUT1_PIN A1
#define BUT2_PIN A2
#include "timerservice.h"

int but1State = LOW;
int but2State = LOW;
int listenBut1 = 0;
int listenBut2 = 0;
int but1=0;
int but2=0;
int listenTimer = 0;

TimerService myTimer;


void button_listen(int pin) {
  if(pin == BUT1_PIN) {
    listenBut1 = 1;
    pciSetup(BUT1_PIN);
  }

  if(pin == BUT2_PIN) {
    listenBut2 = 1;
    pciSetup(BUT2_PIN);
  }
}

void timer_set(int ms) {
  listenTimer = 1;
  myTimer.init();
  myTimer.set(0, ms/1000, timer_expired);
  
}

void setup() {
  init_app();
}

ISR (PCINT1_vect)
 {
    button_changed();   
}  


void loop() {
}


