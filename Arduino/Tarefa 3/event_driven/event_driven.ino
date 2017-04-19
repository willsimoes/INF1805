#define BUT1_PIN A1
#define BUT2_PIN A2

int but1State = HIGH;
int but2State = HIGH;
int listenBut1 = 0;
int listenBut2 = 0;
int listenTimer = 0;
int interval;

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
  listenTimer = 1;
  interval = ms;
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
  
  if(listenBut1) {
    int currentBut1State = digitalRead(BUT1_PIN);
    if(currentBut1State!=but1State) {
      but1State = currentBut1State;
      button_changed(BUT1_PIN, currentBut1State);
    }
  }   

  if(listenBut2) {
    int currentBut2State = digitalRead(BUT2_PIN);
    if(currentBut2State!=but2State) {
      but2State = currentBut2State;
      button_changed(BUT2_PIN, currentBut2State);
    }
  }  
  
}


