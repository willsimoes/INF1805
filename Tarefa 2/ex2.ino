#define LED_PIN 13
#define BUT1_PIN A1
#define BUT2_PIN A2

int ledState = HIGH;
int but1State = HIGH;
int but2State = HIGH;

long interval = 1000;

unsigned long current = 0;
// the setup function runs once when you press reset or power the brd
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_PIN, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  
  unsigned long time = millis();
  digitalWrite(LED_PIN, ledState);
  if(time - current >= interval) {
     current = time;
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
  } 
  
  if (currentBut2State==LOW && but2State==HIGH) {
      interval -= 50;
  } 

  if(currentBut1State != but1State) {
    but1State = currentBut1State;
  }

  if(currentBut2State != but2State) {
    but2State = currentBut2State;
  }
}
