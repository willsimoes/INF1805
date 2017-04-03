#define TRIG_PIN 22 // Pino TRIG do sensor que dispara o pulso ultrassônico
#define ECHO_PIN 2 // Pino ECHO do sensor que recebe o pulso ultrassônico de volta
#define BUZZ_PIN 9 // Pino do Buzzer

#define LED_RED     12
#define LED_GREEN   11
#define LED_BLUE    10

#define KEY_LEFT    34
#define KEY_RIGHT   35

float tempo;
float distancia;

int atraso = 1000;
int duration = 200;

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

  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT);

  pinMode(BUT_LEFT, INPUT);
  pinMode(BUT_RIGHT, INPUT);

}

void loop() {
  int beep = digitalRead(BUT_LEFT);
  int freq = digitalRead(BUT_RIGHT);
  
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
 
 // medir tempo de ida e volta do pulso ultrassonico
 tempo = pulseIn(ECHO_PIN, HIGH);
 
 float distancia = tempo / 29.4 / 2;
 Serial.print("Distancia: ");
 Serial.print(distancia);
 Serial.println(" cm");

 if(beep) {
   tocarBeep(distancia);
 } else {
   tocarFrequencias(distancia);
 }
 void tocarBeep(float distancia);
 void tocarFrequencias(float distancia);

}
 
void tocarBeep(float distancia) {
   if(distancia>20 && distancia<30) {
    ascendeLed(0, 255, 0);  // green
    atraso = 2000;
   }
   else if(distancia >15 && distancia <20) {
    ascendeLed(255, 255, 0);  // yellow
    atraso = 1400;
   }
   else if(distancia >10 && distancia<15){
    ascendeLed(255, 255, 0);  // yellow
    atraso = 600;
   }
   else if(distancia < 10){
    ascendeLed(255, 0, 0);  // red
    atraso = 200;
   }
  
   if(distancia <40) {
    tone(BUZZ_PIN, 2000, duration);
   } else {
    noTone(BUZZ_PIN);
   }
}


void tocarFrequencias(float distancia) {
   if( distancia <= 30 && distancia > 2 ) {
     int frequencia = map(distancia, 2, 30, 900, 50);
     tone(BUZZ_PIN, frequencia, 100);
     acendeLed(distancia);
   } else {
     desligarLeds();
     noTone(BUZZ_PIN);
   }
    delay(1);
  }
}

void acendeLed(float distancia) {
  desligarLeds();
  if(distancia < 30 && distancia > 20) {
    ascendeLed(0, 255, 0);  // green
  }
  else if(distancia < 20 && distancia > 10) {
    ascendeLed(255, 255, 0);  // yellow
  }
  else if (distancia < 10) {
    ascendeLed(255, 0, 0);  // red
  }
}

void desligarLeds() {
  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_BLUE, LOW);
}

void ascendeLed(int red, int green, int blue)
{
  analogWrite(LED_RED, red);
  analogWrite(LED_GREEN, green);
  analogWrite(LED_BLUE, blue);  
}


