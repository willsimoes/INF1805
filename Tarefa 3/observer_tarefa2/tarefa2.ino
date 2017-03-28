#include "tarefa2.h"
#include "observer_tarefa2.h"

void init_app() {
  button_listen(A1);
  button_listen(A2);
  timer_set(1000);

  Serial.begin(9600);
  //Serial.print("Ola");
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUT1_PIN, INPUT);
  pinMode(BUT2_PIN, INPUT);
}

void button_changed(int pin, int v) {
  Serial.print("Botao mudou:");
  if(pin==A1) {
    Serial.print(" A1. ");
  }
  if(pin==A2) {
    Serial.print (" A2. ");
  }
  
  Serial.print("Para o estado:");
  if(v==HIGH) {
    Serial.println(" HIGH");
  } else {
    Serial.println(" LOW");
    if(pin==A1) {
      Serial.println("(Desacelerando LED...)");
    } else if(pin==A2) {
      Serial.println("(Acelerando LED...)");
    }
  }
    
}


void timer_expired (void) {
  Serial.println("Tempo expirou!!");
}

