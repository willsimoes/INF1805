#define LED_PIN 12
#define BUT1_PIN 35
#define BUT2_PIN 37
#include <stdlib.h>

//variáveis globais de estado do led e dos butões
int but1State = HIGH;
int ledState = HIGH;
int but2State = HIGH;

int waitForButton1 = 0;
int waitForButton2 = 0;

long interval = 1000;
unsigned long current = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT); //registra pino do led como saída
  pinMode(BUT1_PIN, INPUT); //registra pino do butão 1 como entrada
  pinMode(BUT2_PIN, INPUT); //registra pino do butão 2 como entrada
}

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

  // se o botão 1 for apertado (ou seja, somente de  HIGH->LOW), desacelera
  if (currentBut2State==LOW && but2State==HIGH) {
      interval += 50;
      if(waitForButton1 && waitForButton1 <= 500) { // se estiver esperando por ele a 500ms ou menos, para
        waitForButton1 = 0;
        digitalWrite(LED_PIN, HIGH);
        exit(1);
      } else {
        waitForButton2 = millis(); // se não, espera pelo botão 2
      }
      
  } 

  // se o botão 2 for apertado (ou seja, somente de  HIGH->LOW), acelera
  if (currentBut2State==LOW && but2State==HIGH) {
      interval -= 50;
      if(waitForButton2 && waitForButton2 <= 500) { // se estiver esperando por ele a 500ms ou menos, par
        waitForButton1 = 0;
        digitalWrite(LED_PIN, HIGH);
        exit(1);
      } else {
        waitForButton1 = millis(); // se não, espera pelo botão 1
      }
  } 

  if(currentBut1State != but1State) {
    but1State = currentBut1State;
  }

  if(currentBut2State != but2State) {
    but2State = currentBut2State;
  }
}
