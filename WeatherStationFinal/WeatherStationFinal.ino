#include <SPI.h>
#include <WiFiNINA.h>
#include "arduino_secrets.h"

#define WIND_SENSOR 2
#define WATER_SENSOR 3

int windPin = 5;
int waterPin = 6;

int windState;
int lastWindState;

unsigned long windLastDebounceTime = 0;
unsigned long waterLastDebounceTime = 0;
unsigned long debounceDelay = 250; // 250 ms

int waterState;
int lastWaterState;


// for SPI communication to FPGA
const int slaveSelectPin = 10;
SPISettings spiSettings (10, MSBFIRST, SPI_MODE0);

// read in sensitive data from arduino_secrets.h (which is stored securely on the Arduino)
// WiFi network name and password
char ssid[] = WiFiSSID;
char pass[] = WiFiPass;
int keyIndex = 0; // only for WEP

// core WiFi variables
int status = WL_IDLE_STATUS;
WiFiClient client;
unsigned long lastConnectionTime = 0;
const unsigned long postingInterval = 30L * 1000L;

// server address
char server[] = "maker.ifttt.com";
char rain[] = "raining";
char wind[] = "strong_wind";


void setup() {
  // put your setup code here, to run once:

  // setup SPI
  pinMode (slaveSelectPin, OUTPUT);   

  //setup basic input
  pinMode (windPin, INPUT);
  pinMode (waterPin, INPUT);
  //digitalWrite(slaveSelectPin, HIGH);
  SPI.begin();

  // setup Serial
  Serial.begin(9600);
  /*while(!Serial) {
    
  }*/
  // we dont wanna wait for serial to connect, we want the code to run now so while !Serial has been removed

  // setup WiFi
  if(WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi Module failed!");
    // stop system now!
    while (true);
  }
  String fv = WiFi.firmwareVersion();
  if(fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("Please upgrade to the latest Arduino WiFi firmware");
  }

  // attempt to connect to the WiFi network
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(ssid, pass);

    // wait 2 seconds for connection:
    delay(2000);
  }
  // connected to WiFi now, so print the current connection 
  printWifiStatus();
}

void loop() {
  // put your main code here, to run repeatedly:
   int waterReading = !digitalRead(waterPin);
   int windReading = digitalRead(windPin);
  
   if(windReading != lastWindState) {
      windLastDebounceTime = millis();
   }

   if((millis() - windLastDebounceTime) > debounceDelay) {
      if(windReading != windState) {
        windState = windReading;

        if(windState == HIGH) {
            Serial.println("flag recieved from FPGA - send Wind notification ");
            if (millis() - lastConnectionTime > postingInterval) {
               httpRequest(wind);
            } else {
              Serial.println("Notification was too recent. Will start notifying once at least 30 seconds have passed.");
            }
        }
      }
   }

   //Serial.print(waterReading);

   if(waterReading != lastWaterState) {
      waterLastDebounceTime = millis();
   }

   if((millis() - waterLastDebounceTime) > debounceDelay) {
      if(waterReading != waterState) {
        waterState = waterReading;

        if(waterState == HIGH) {
            Serial.println("flag recieved from FPGA - send Rain notification ");
            if (millis() - lastConnectionTime > postingInterval) {
               httpRequest(rain);
            } else {
              Serial.println("Notification was too recent. Will start notifying once at least 30 seconds have passed.");
            }
        }
      }
   }
  lastWindState = windReading;
  lastWaterState = waterReading;
  /*if (millis() - lastConnectionTime > postingInterval) {
     
  }*/
  
  // display the response from the server in the serial connection for debugging purposes
  while (client.available()) {
    char c = client.read();
    Serial.write(c);
  }

  // when we get data from SPI, we want to display it in serial, then submit it to the server
  //Serial.println("Wind: " + SPIGetData(WIND_SENSOR));
  //delay(100);
  //Serial.println("Rain: " + SPIGetData(WATER_SENSOR));
  
  /*if(SPIGetData(WIND_SENSOR) > 3) {
    httpRequest(wind);
  }

  if(SPIGetData(WATER_SENSOR) > 0){
    httpRequest(rain);
  }*/
  
  
}

int SPIGetData(int sensorID) {
  int sensorData = 0;
  // send command
  SPI.beginTransaction(spiSettings);
  digitalWrite(slaveSelectPin, LOW);
  //SPI.beginTransaction(SPISettings(1000, MSBFIRST, SPI_MODE0)); // running at 10KHz because I don't actually need it to be very fast (only need a reading every few seconds). Plus slower = less likely to have issues.
  SPI.transfer(sensorID);
  sensorData = SPI.transfer(0x00); // read return data
  digitalWrite(slaveSelectPin, HIGH);
  SPI.endTransaction();
  //SPI.endTransaction();
  // recieve response data
  /*digitalWrite(slaveSelectPin, LOW);
  SPI.beginTransaction(SPISettings(5, MSBFIRST, SPI_MODE0));
  sensorData = SPI.transfer(0);
  digitalWrite(slaveSelectPin, HIGH);
  SPI.endTransaction();*/
  return sensorData;
}

// this method makes a HTTP connection to the server:
void httpRequest(char* trigger) {
  // close any connection before send a new request.
  // This will free the socket on the Nina module
  client.stop();

  char finalTarget[200];
  int len = snprintf(finalTarget, 200, "%s%s%s%s","/trigger/",trigger,"/with/key/",API_KEY);

  // if there's a successful connection:
  if (client.connectSSL(server, 443)) {
    Serial.println("connecting...");
    // send the HTTP PUT request:
    client.print("GET ");
    client.print(finalTarget);
    client.println(" HTTP/1.1");
    client.print("Host: ");
    client.println(server);
    client.println("User-Agent: ArduinoWiFi/1.1");
    client.println("Connection: close");
    client.println();

    // note the time that the connection was made:
    lastConnectionTime = millis();
  } else {
    // if you couldn't make a connection:
    Serial.println("connection failed");
  }
}


void printWifiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your board's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
