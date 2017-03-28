#define BUT1_PIN A1
#define BUT2_PIN A2
#define LED_PIN 13


int ledState = HIGH;
int but1State = HIGH;
int but2State = HIGH;

int listenBut1 = 0;
int listenBut2 = 0;
long interval;

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
}

void setup() {
  init_app();

}

void loop() {
   
  unsigned long time = millis();
  unsigned long time_but1 = 0;
  unsigned long time_but2 = 0;
  
  digitalWrite(LED_PIN, ledState);
  if(time - current >= interval) {
     current = time;
     timer_expired();
     if(ledState == HIGH) {
       ledState = LOW;
     } else {
        ledState = HIGH;
     }
  }

  int currentBut1State = digitalRead(BUT1_PIN);
  int currentBut2State = digitalRead(BUT2_PIN);

  if (currentBut1State==LOW && but1State==HIGH) {
      interval += 50;
      time_but1 = millis();
  } 
  
  if (currentBut2State==LOW && but2State==HIGH) {
      interval -= 50;
      time_but2 = millis();
  } 

  unsigned long diff_time;
  if(currentBut1State==LOW && currentBut2State==LOW) {
    diff_time = time_but1 - time_but2;
    if(diff_time < -1) {
      diff_time = time_but2 - time_but1;
    } 
    
    if(diff_time<= 500) {
      digitalWrite(LED_PIN, HIGH);
      exit(1);
    }
  }

  if(currentBut1State != but1State) {
    but1State = currentBut1State;
    if(listenBut1) {
        button_changed(BUT1_PIN, currentBut1State);
      }
  }

  if(currentBut2State != but2State) {
    but2State = currentBut2State;
    if(listenBut1) {
        button_changed(BUT2_PIN, currentBut2State);
     }
  }

}
