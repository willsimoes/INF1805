#include "tarefa2.h"
#include "observer_tarefa2.h"

int ledState = LOW;

// flags para controle simultâneo dos dois botões
int waitForButton1 = 0; 
int waitForButton2 = 0;

void init_app() {
  Serial.begin(9600);

  //registra os listeners 
  button_listen(BUT1_PIN);
  button_listen(BUT2_PIN);
  timer_set(1000);

  // configura os pinos de led e dos botões 
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUT1_PIN, INPUT);
  pinMode(BUT2_PIN, INPUT);

  //inicializa primeiro estado do led
  digitalWrite(LED_PIN, ledState);
}

void button_changed(int pin, int v) {
  if(pin == BUT1_PIN && v == LOW) { // se é o botão 1 e foi apertado (ou seja, somente de  HIGH->LOW), desacelera
      interval += 50;
      timer_set(interval);

     if(waitForButton1 && waitForButton1 <= 500) { // se estiver esperando por ele a 500ms ou menos, apaga o led e para
        waitForButton1 = 0;
        digitalWrite(LED_PIN, LOW);
        exit(1);
      } else if(listenBut2){
        waitForButton2 = millis(); // se não, espera pelo botão 2
      }
  }

  if(pin == BUT2_PIN && v==LOW) { // se é o botão 2 e foi apertado (ou seja, somente de  HIGH->LOW), acelera
    interval -= 50;
    timer_set(interval);
    if(waitForButton2 && waitForButton2 <= 500) { // se estiver esperando por ele a 500ms ou menos, apaga o led e para
      waitForButton1 = 0;
      digitalWrite(LED_PIN, LOW);
      exit(1);
    } else if(listenBut1){
      waitForButton1 = millis(); // se não, espera pelo botão 2
    }
  }
    
}


void timer_expired (void) {
  Serial.println("Tempo expirou!!");

  // troca o estado do led
  if(ledState==HIGH) {
    ledState==LOW;
  } else {
    ledState==HIGH;
  }

  digitalWrite(LED_PIN, ledState);

  //reinicia a contagem do tempo
  timer_set(interval); 
}

