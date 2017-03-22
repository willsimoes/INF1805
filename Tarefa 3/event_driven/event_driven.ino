#define BUT1_PIN A1

unsigned long current = 0;
int but1State = HIGH;
int listenBut1 = 0;
int interval;

void button_listen(int pin) {
  if(pin == BUT1_PIN) {
    listenBut1 = 1;
  }
}

void timer_set(int ms) {
  interval = ms;
}

void setup() {
  Serial.begin(9600);
  //Serial.print("Ola");
  init_app();
}

void loop() {
  unsigned long time = millis();
 
  if(time - current >= interval) {
    current = time;   
    timer_expired();
     
  }
  
  int currentBut1State = digitalRead(BUT1_PIN);
  
  if(listenBut1) {
    if(currentBut1State!=but1State) {
      but1State = currentBut1State;
      button_changed(BUT1_PIN, currentBut1State);
    }
  }   
  
}


