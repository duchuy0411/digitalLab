/**
 * ESP32 pinout:
 * We need 04 pins (wires) to communicate btw esp32 & FPGA
 * ssFPGA    5// pin selects slave ID
 * MOSI      23// 
 * MISO      19//
 * SCK       18//
 **/

#include <SPI.h>

uint8_t const ssFPGA = 5;
uint8_t const maxSpeed = 50000000;
#define Set_CS 0 //LOW is selected
#define Reset_CS 1 //

void setup()
{
    Serial.begin(115200);
    while (!Serial) {
      ; // wait
    }
    Serial.println("Serial Begin");
    
    SPI.begin();   
    Serial.println("SPI Begin");   
    
    pinMode(ssFPGA, OUTPUT); 
    Serial.println("Please type input: 0 or 1");   
}

void loop() 
{
    while (!Serial.available()){
      ;
    }
    byte mosi = Serial.read();
    delay(10);
    SPI.beginTransaction(SPISettings(maxSpeed, MSBFIRST, SPI_MODE0)); //config SPI transaction with 03 parametter: maxSpeed/ dataOrder/ dataMode
                                                                          //need to be adapted with FPGA KIT
    digitalWrite(ssFPGA, Set_CS);//select slave
    uint8_t miso = SPI.transfer(mosi);
    Serial.print("SPI transfered to FPGA: ");
    Serial.println(mosi, HEX);
    Serial.print("Data received from FPGA: ");
    Serial.println(miso, HEX);
    digitalWrite(ssFPGA, Reset_CS);
    SPI.endTransaction();
    
//
//  static int ii = 0;
//  if (++ii % 1024 == 0) {
//    Serial.print(".");  // show a sign of life
//  }
}
