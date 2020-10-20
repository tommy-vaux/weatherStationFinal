#include <Arduino.h>
#include <LiquidCrystal.h>
#include <TimerOne.h>

#define DIAMETER 0.135

int windSensorPin = 12;
double speed = 0;
int count = 0;

// Variables will change:
int outputState = HIGH;         // the current state of the output pin
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin

// the following variables are unsigned longs because the time, measured in
// milliseconds, will quickly become a bigger number than can be stored in an int.
unsigned long lastDebounceTime = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 5;    // the debounce time; increase if the output flickers

LiquidCrystal lcd(8, 9, 4, 5, 6, 7);

void updateSpeed(void);

void setup() {
  // put your setup code here, to run once:
  pinMode(windSensorPin, INPUT);
  Timer1.initialize(1000000);
  Timer1.attachInterrupt(updateSpeed);

}
void loop() {
  // put your main code here, to run repeatedly:
  int reading = digitalRead(windSensorPin);
  if(reading != lastButtonState) {
      lastDebounceTime = millis();
  }

  if((millis() - lastDebounceTime) > debounceDelay) {
      if(reading != buttonState) {
          buttonState = reading;
      }

      if(buttonState == HIGH) {
          outputState = !outputState;
      }
  }

  if(outputState) {
      count++;
  }

  lastButtonState = reading;
  
  
}

void updateSpeed(void) {
    speed = PI * DIAMETER * (double)count;
    lcd.setCursor(0,0);
    //lcd.print("Wind: ");
    lcd.print(count);
    lcd.print(",");
    lcd.print(speed);
    lcd.print("       ");
    //lcd.print(" m/s         ");
    count = 0;
}