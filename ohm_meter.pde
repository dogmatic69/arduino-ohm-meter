#include <LiquidCrystal.h>

/** 
 * config these for your setup 
 */
/**
 * the pull up resistor being used, this will affect the reading.
 */
float Rknown = 4390.0;

/**
 * Analogue Input pin used on Arduino
 */
int readPin = 0;

/**
 * LCD data pins
 */
const int data1 = 3;
const int data2 = 4;
const int data3 = 5;
const int data4 = 6;

/**
 * backlight pin for the lcd, used to control the brightness of the backlight
 */
const int lcdBackLight = 13;

/**
 * Analogue output 0 -> 1023
 */
int raw = 0;

/**
 * Calculated voltage with unknown resistor from raw
 */
float Vout = 0.0;

/**
 * The resitor we are trying to calculate
 */
float Runknown = 0.0;

/**
 * Voltage being fed, calculated from arduino chip
 */ 
float Vin, I = 0.0;

/** 
 * temp value to round the bigger numbers with 
 */
int tmp = 0;

/**
 * RS - Register selection input. (pin 4 on 16x2 HD44780)
 */
int lcdRS = 12;

/**
 * R/W - (pin 5 on 16x2 HD44780)
 */
int lcdRW = 11;

/**
 * E - Read/write enable signal. (pin 6 on 16x2 HD44780)
 */
int lcdE = 10;

/**
 * Setup the lcd
 */
LiquidCrystal lcd(lcdRS, lcdRW, lcdE, data4, data3, data2, data1);

/**
 * Setup function called by arduino when the board is powered up
 */
void setup(){
	lcd.begin(16, 2);
	lcd.print("ohm meter v0.001");
	lcd.setCursor(0, 1);
	lcd.print("By: dogmatic69");
	delay(1000);  
}

float readVcc() {
	long result;
	ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
	delay(2); // Wait for Vref to settle
	ADCSRA |= _BV(ADSC); // Convert
	while (bit_is_set(ADCSRA, ADSC));
	result = ADCL;
	result |= ADCH<<8;
	result = 1126400L / result; // Back-calculate AVcc in mV
	
	return result / 1000;
}

/**
 * Called when there is no resistor in the circuit
 * Could be something like a 1M ohm or broken resistor
 */
void disconnected(){
	lcd.print(Runknown);
	lcd.setCursor(0, 1);
	lcd.print("Disconnected");
	lcd.print(Vin);
}

/**
 * called when there is a short in the circuit.
 * This could mean that its something like a 1ohm resistor or a piece of wire
 */
void shorted(){
	lcd.print(Runknown);
	lcd.setCursor(0, 1);
	lcd.print("Dead short");
}

void loop(){
	lcd.clear();
	lcd.setCursor(0, 0);
	raw = analogRead(readPin); // Read in val (0-1023)
	Vin = readVcc();
  
	if(raw == 1023){
		disconnected();
	}
  
	else if(raw == 0){
		shorted();
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


