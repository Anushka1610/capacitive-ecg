int LDR = 0;                  // analog input pin
boolean BTconnected = false;  // BT connected flag
const byte BTpin = 4;         // BT connected pin
/*
 * BLUETOOTH
 * PIN CONFIGURATION: uses actual serial, so rx/tx -> tx/rx
 * - ECG signal     -> A0
 * - HC-05 VCC, GND -> 5V, GND
 * - HC-05 TX, RX   -> RX0, TX1 (0, 1)
 * - HC-05 STATE    -> D4
 * Each cycle takes delay + ~576 us
 * sampling rate is mildly non-const
 *  - maximum difference between two loop times: 12 us
 * sampling rate doesn't reflect actual signal timescale
*/
// initialize the serial port (at 115200 baud rate), set aref to defualt, and declare inputs and outputs
void setup() {
  pinMode(LDR, INPUT);
  analogReference(DEFAULT);
  Serial.begin(115200);  // HC-05 baud rate. To change, see AT.ino

  // wait until connected to start transmitting
  while (!BTconnected)
    {
      if ( digitalRead(BTpin)==HIGH)  { BTconnected = true;};
    }
  // timing: check starting micros
  //Serial.println(micros());
}
// read from the analog input connected to the LDR and print the value to the serial port.
// the delay is only to avoid sending so much data as to make it unreadable.
void loop() {
  float v = analogRead(LDR);
  float voltage=5.0/1024.0*1000.0*v;  // avoid using floats
  Serial.println(voltage);            // write voltage to serial
  Serial.println(micros());
  delay(5);                          // delay is tweakable
  // timing: print newest micros 
}
