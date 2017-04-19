#include "tarefa2.h"
#include "observer_tarefa2.h"

long interval;

// estados defaults para os botões (não pressionados)
int but1State = HIGH;
int but2State = HIGH;

// inicializando flags do observer
int listenBut1 = 0;
int listenBut2 = 0;
int listenTimer = 0;

unsigned long current = 0;

void button_listen(int pin) {
  if(pin == BUT1_PIN) {
    listenBut1 = 1;
  }

  if(pin == BUT2_PIN) {
    listenBut2 = 1;
  }
}

void timer_set(int ms) {
  interval = ms;
  listenTimer = 1;
}

void setup() {
  init_app();
}

void loop() {
   if(listenTimer) {
    unsigned long time = millis();
    
    if(time - current >= interval) {    
      current = time;
      timer_expired();   
      listenTimer = 0;
    }
   }

  int currentBut1State = digitalRead(BUT1_PIN);
  int currentBut2State = digitalRead(BUT2_PIN);

 if(listenBut1) {
   if(currentBut1State != but1State) {
      but1State = currentBut1State;
      button_changed(BUT1_PIN, currentBut1State);
    }
 }

 if(listenBut2) {
   if(currentBut2State != but2State) {
      but2State = currentBut2State;
      button_changed(BUT2_PIN, currentBut2State);
    }
 }


}
