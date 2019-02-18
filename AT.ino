#include <SoftwareSerial.h>

/*
 * AT COMMAND SCRIPT FOR HC-05 BLUETOOTH MODULE
 * used for setting module parameters.
 * 
 * PIN CONFIGURATION:
 * - HC-05 VCC, GND -> 5V, GND
 * - HC-05 TX, RX   -> D2, D3
 * - HC-05 STATE    -> D4
 * 
 * PUT HC-05 IN COMMAND MODE
 * 1. remove VCC wire from HC-05
 * 2. while holding down button on HC-05, re-insert VCC wire
 * SEND COMMANDS
 * 1. upload this script
 * 2. open serial monitor to 9600 baud.
 * 3. Type "AT" and send. If "OK", it's working
 * COMMON COMMANDS
 * - set baud rate:       "AT+UART={baud rate},1,0"
 * - restore to defaults: "AT+ORGL"
*/

SoftwareSerial BTSerial(2, 3); // RX | TX

void setup()
{
  pinMode(4, OUTPUT);  // this pin will pull the HC-05 pin 34 (key pin) HIGH to switch module to AT mode
  digitalWrite(4, HIGH);
  Serial.begin(9600);
  Serial.println("Enter AT commands:");
  BTSerial.begin(38400);  // HC-05 default speed in AT command more
}

void loop()
{

  // Keep reading from HC-05 and send to Arduino Serial Monitor
  if (BTSerial.available())
    Serial.write(BTSerial.read());

  // Keep reading from Arduino Serial Monitor and send to HC-05
  if (Serial.available())
    BTSerial.write(Serial.read());
}


