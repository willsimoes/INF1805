#include "app.h"
#include "event_driven.h"

#define LED_PIN 13
#define BUT1_PIN A1
#define BUT2_PIN A2

void init_app() {
  button_listen(BUT1_PIN);
  button_listen(BUT2_PIN);
  timer_set(1000);

  pinMode(BUT1_PIN, INPUT);
  pinMode(BUT2_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
}

void button_changed(int pin, int v) {
  Serial.print("Botao mudou:");
  if(pin==A1) {
    Serial.println(" A1");
  }
  if(pin==A2) {
    Serial.println(" A2");
  }
  
  Serial.print("Para o estado:");
  if(v==HIGH) {
    Serial.println("HIGH");
  } else {
    Serial.println("LOW");
  }
    
}

void timer_expired(void) {
  unsigned long time = millis();

  while(1) {
   digitalWrite(LED_PIN, LOW);
   if(time - millis()>=1000) {
      digitalWrite(LED_PIN, HIGH);
      return;
   } 
  } 
}
  
