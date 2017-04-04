#define TRIG_PIN 22 // Pino TRIG do sensor que dispara o pulso ultrassônico
#define ECHO_PIN 2 // Pino ECHO do sensor que recebe o pulso ultrassônico de volta
#define BUZZ_PIN 9 // Pino do Buzzer

// Pinos do led RGB
#define LED_RED     12
#define LED_GREEN   11
#define LED_BLUE    10

// Pinos dos botoes
#define BUT_DOWN    36
#define BUT_UP      37


float tempo;
float distancia;

int modeBeep = 0;

int atraso = 1000;

//declaracao das funcoes
void desligarLeds();
void corLed(int red, int green, int blue);
void acendeLed(float distancia);
void tocarFrequencias(float distancia);
void tocarBeep(float distancia);

void setup() {
  Serial.begin(9600);
  
  //configurando pino de trigger como saída
  pinMode(TRIG_PIN, OUTPUT);
  //deixa pino de trigger em LOW
  digitalWrite(TRIG_PIN, LOW);

  //configurando pino Echo como entrada
  pinMode(ECHO_PIN, INPUT);
  //configurando pino do Buzzer como saída
  pinMode(BUZZ_PIN,OUTPUT);

  // interrupção do sensor de distancia - é acionada quando o sinal do pino Echo muda (CHANGE)
  //attachInterrupt(0, intSensor, CHANGE);

  //configurando pinos do led
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);

  //configurando pinos dos botoes
  pinMode(BUT_UP, INPUT);
  pinMode(BUT_DOWN, INPUT);

  //interrupção do botao - é acionada quando o botão passa pro estado HIGH (RISING)
 attachInterrupt(1, intBotao, RISING );

}

void loop() {
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
 
 // medir tempo de ida e volta do pulso ultrassonico
 tempo = pulseIn(ECHO_PIN, HIGH);
 
 float distancia = tempo / 29.4 / 2;
 Serial.print("Distancia: ");
 Serial.print(distancia);
 Serial.println(" cm");

 if(modeBeep) {
   tocarBeep(distancia);
 } else {
   tocarFrequencias(distancia);
 }

}

void intBotao() {
  //ativa modo frequencias
  if(digitalRead(BUT_UP)) {
    modeBeep = 0;   
  }

  //ativa modo beep
  if(digitalRead(BUT_DOWN)) {
    modeBeep = 1;
  }
  
}
 
void tocarBeep(float distancia) {
   desligarLeds();
   if(distancia>20 && distancia<30) {
    corLed(0, 255, 0);  // green
    atraso = 2000;
   }
   else if(distancia >15 && distancia <20) {
    corLed(255, 255, 0);  // yellow
    atraso = 1400;
   }
   else if(distancia >10 && distancia<15){
    corLed(255, 255, 0);  // yellow
    atraso = 600;
   }
   else if(distancia < 10){
    corLed(255, 0, 0);  // red
    atraso = 250;
   }
  
   if(distancia <40) {
    tone(BUZZ_PIN, 2000, 200);
   } else {
    desligarLeds();
    noTone(BUZZ_PIN);
   }

   delay(atraso);
}


void tocarFrequencias(float distancia) {
   int value_delay = 1;
   if( distancia <= 30 && distancia > 2 ) {
     int frequencia = map(distancia, 2, 30, 900, 30);
     if(distancia < 5) {
       frequencia = 900;
       value_delay = 150;
     }
     tone(BUZZ_PIN, frequencia, 100);
     acendeLed(distancia);
   } else {
     desligarLeds();
     noTone(BUZZ_PIN);
   }
    delay(value_delay);
  }

void acendeLed(float distancia) {
  desligarLeds();
  if(distancia < 30 && distancia > 20) {
    corLed(0, 255, 0);  // green
  }
  else if(distancia < 20 && distancia > 10) {
    corLed(255, 255, 0);  // yellow
  }
  else if (distancia < 10) {
    corLed(255, 0, 0);  // red
  }
}

void desligarLeds() {
  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_BLUE, LOW);
}

void corLed(int red, int green, int blue)
{
  analogWrite(LED_RED, red);
  analogWrite(LED_GREEN, green);
  analogWrite(LED_BLUE, blue);  
}


