#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <WebSocketsServer.h> //import for websocket

#define ledpin1 12 //defining the OUTPUT pin for LED
#define ledpin2 14 //defining the OUTPUT pin for LED
#define ledpin3 27 //defining the OUTPUT pin for LED
#define ledpin4 26 //defining the OUTPUT pin for LED

const char *ssid =  "esp_wifi";   //Wifi SSID   
const char *pass =  "44445555"; //wifi password

WebSocketsServer webSocket = WebSocketsServer(81); //websocket init with port 81

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
//webscket event method
    String cmd = "";
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.println("Websocket is disconnected");
            //case when Websocket is disconnected
            break;
        case WStype_CONNECTED:{
            //wcase when websocket is connected
            Serial.println("Websocket is connected");
            Serial.println(webSocket.remoteIP(num).toString());
            webSocket.sendTXT(num, "connected");}
            break;
        case WStype_TEXT:
            cmd = "";
            for(int i = 0; i < length; i++) {
                cmd = cmd + (char) payload[i]; 
            } //merging payload to single string
            Serial.println(cmd);

            if(cmd == "D0on"){digitalWrite(ledpin1, HIGH);}
            else if(cmd == "D0off"){digitalWrite(ledpin1, LOW);}
            else if(cmd == "D1on"){digitalWrite(ledpin2, HIGH);}
            else if(cmd == "D1off"){digitalWrite(ledpin2, LOW);}
            else if(cmd == "D2on"){digitalWrite(ledpin3, HIGH);}
            else if(cmd == "D2off"){digitalWrite(ledpin3, LOW);}
            else if(cmd == "D3on"){digitalWrite(ledpin4, HIGH);}
            else if(cmd == "D3off"){digitalWrite(ledpin4, LOW);}
             webSocket.sendTXT(num, cmd);
             //send response to mobile, if command is "poweron" then response will be "poweron:success"
             //this response can be used to track down the success of command in mobile app.
            break;
        case WStype_FRAGMENT_TEXT_START:
            break;
        case WStype_FRAGMENT_BIN_START:
            break;
        case WStype_BIN:
            //hexdump(payload, length);
            break;
        default:
            break;
    }
}

void setup() {
   pinMode(ledpin1, OUTPUT); //set ledpin (D2) as OUTPUT pin
   pinMode(ledpin2, OUTPUT); //set ledpin (D0) as OUTPUT pin
   pinMode(ledpin3, OUTPUT); //set ledpin (D4) as OUTPUT pin
   pinMode(ledpin4, OUTPUT); //set ledpin (D15) as OUTPUT pin

   Serial.begin(9600); //serial start

   Serial.println("Connecting to wifi");
   
   IPAddress apIP(192, 168, 0, 1);   //Static IP for wifi gateway
   WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); //set Static IP gateway on NodeMCU
   WiFi.softAP(ssid, pass); //turn on WIFI

   webSocket.begin(); //websocket Begin
   webSocket.onEvent(webSocketEvent); //set Event for websocket
   Serial.println("Websocket is started");
}

void loop() {
   webSocket.loop(); //keep this line on loop method
}
