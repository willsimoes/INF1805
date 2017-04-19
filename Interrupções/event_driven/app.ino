#include "app.h"
#include "event_driven.h"

#define LED_PIN 13
#define BUT1_PIN A1
#define BUT2_PIN A2


void init_app() {
  Serial.begin(115200);
  button_listen(BUT1_PIN);
  button_listen(BUT2_PIN);
  
  timer_set(1000);

  pinMode(BUT1_PIN, INPUT);
  pinMode(BUT2_PIN, INPUT);
  
  pinMode(LED_PIN, OUTPUT);
}


void pciSetup(byte pin) {
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));  // enable pin
    PCIFR  |= bit (digitalPinToPCICRbit(pin)); // clear any outstanding interrupt
    PCICR  |= bit (digitalPinToPCICRbit(pin)); // enable interrupt for the group 
}

void button_changed() {
  int currStateBut1 = digitalRead(BUT1_PIN);
  int currStateBut2 = digitalRead(BUT2_PIN);
  
  int state;

  Serial.print("Botao mudou:");
  if(currStateBut1!=but1State) {
    Serial.println(" A1");
    state=currStateBut1;
    but1State=currStateBut1;
  }
  
  if(currStateBut2!=but2State) {
    Serial.println(" A2");
    state=currStateBut2;
    but2State=currStateBut2;
  }
  
  Serial.print("Para o estado:");
  if(state==HIGH) {
    Serial.println("HIGH");
  } else {
    Serial.println("LOW");
  }
    
}

void timer_expired(void) {
   Serial.println("Tempo expirou!!!");
   listenTimer = 0;
   
   digitalWrite(LED_PIN, LOW);
   delay(1);
   digitalWrite(LED_PIN, HIGH);
  
  
}
  
