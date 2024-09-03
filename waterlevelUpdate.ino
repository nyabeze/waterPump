#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "Elephant Villa";
const char* password = "villa2024E";
const char* updateUrl = "http://localhost:3000/api/water-level"; // Use your server's IP address or domain name
const int waterlevelSignalPin = 35;
const int pumpPin = 5;
const double minValue = 0;
const double maxValue = 300;
const int interval = 250;
int lastUpdate = 0;

HTTPClient http;
double signalValue = 0;
int water_level = 0;
bool pumpState = LOW;

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connecting to WiFi...");
    delay(1000);
  }
  Serial.println("WiFi connected!");

  pinMode(waterlevelSignalPin, INPUT);
  pinMode(pumpPin, OUTPUT);
}

void loop() {
  if (millis() > lastUpdate + interval) { // running code every interval (250ms)
    lastUpdate = millis();
    getSensorValue();
    updateServer();
  }
}

void getSensorValue() {
  signalValue = analogRead(waterlevelSignalPin); // read the analog value from sensor
  water_level = 100 * (signalValue - minValue) / maxValue;
  Serial.print("signalValue: ");
  Serial.print(signalValue);
  Serial.print(" water_level: ");
  Serial.println(water_level);  
}

void updateServer() {
  if (WiFi.status() == WL_CONNECTED) { // Check WiFi connection
    http.begin(updateUrl);
    http.addHeader("Content-Type", "application/json");
    StaticJsonDocument<200> requestBody;
    requestBody["water_level"] = water_level;
    String requestBodyString;
    serializeJson(requestBody, requestBodyString);
    int httpResponseCode = http.POST(requestBodyString);
    Serial.println("HTTP response code: " + String(httpResponseCode));
    
    if (httpResponseCode == HTTP_CODE_OK) {
      DynamicJsonDocument data(1024);
      String responsePayload = http.getString();
      deserializeJson(data, responsePayload);
      pumpState = data["pumpState"];
      Serial.println("HTTP response payload: " + responsePayload);
    } else {
      Serial.println("Failed to receive a valid response");
    }

    Serial.print("pumpState: ");
    Serial.println(pumpState);
    digitalWrite(pumpPin, pumpState ? HIGH : LOW);

    http.end(); // Close the connection
  } else {
    Serial.println("WiFi not connected");
  }
}
