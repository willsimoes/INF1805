#include "app.h"
#include "event_driven.h"

#define LED_PIN 13

void init_app() {
  button_listen(A1);
  timer_set(1000);
  
  pinMode(LED_PIN, OUTPUT);
}

void button_changed(int pin, int v) {
  Serial.print("Botao mudou:");
  if(pin==A1) {
    Serial.println(" A1");
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
  
