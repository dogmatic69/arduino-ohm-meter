#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 10, 6, 5, 4, 3); 

int raw = 0; // The raw analogue value
float Vout = 0.0; // Voltage at point between resistors

float Runknown = 0.0;
float I = 0.0;
int tmp = 0;


/** config these for your setup */
float Vin = 4.91; // Vcc measure with multi meter on +5 and gnd
float Rknown = 4390.0; // the pull up resistor
int readPin = 0; // Analogue Input on Arduino

void setup(){
  lcd.begin(16, 2);
  lcd.print("ohm meter v0.001");
  delay(500);  
}
void loop(){
  lcd.clear();
  lcd.setCursor(0, 0);
  raw = analogRead(readPin); // Read in val (0-1023)
  
  if(raw == 1023){
    lcd.print(Runknown);
    lcd.setCursor(0, 1);
    lcd.print("Disconnected");
  }
  
  else if(raw == 0){
    lcd.print(Runknown);
    lcd.setCursor(0, 1);
    lcd.print("Dead short");
  }
  
  else{
    Vout = (float(Vin) / 1024.0) * float(raw);
    I = (Vin - Vout) / Rknown;
    Runknown = (Vout / I);
    
    lcd.setCursor(6, 0);
    lcd.print(Vout);
    
    tmp = 0;
    if(Runknown > 100){
      if(Runknown > 1000){
        if(Runknown > 5000){
          if(Runknown > 20000){
            if(Runknown > 100000){
              tmp = int(Runknown / 10000) * 10000;
            }
            else{
              tmp = int(Runknown / 1000) * 1000;
            }
          }
          else{
            tmp = int(Runknown / 100) * 100;
          }
        }
        else{
          tmp = int(Runknown / 10) * 10;
        }
      }
      else{
        tmp = int(Runknown);
      }
    }
    
    lcd.setCursor(0, 1);
    if(tmp > 0){
      lcd.print(tmp);
    }
    else{
      lcd.print(Runknown);
    }
  }
  delay(500);
}


