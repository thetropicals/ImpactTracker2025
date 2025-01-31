#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "RN26";        // Change to your WiFi SSID
const char* password = "12345678"; // Change to your WiFi password

String serverUrl = "https://script.google.com/macros/s/AKfycbyrN7FOKv9CS5tcJgn-fEKUgy9KnuX1ZHI1G68gcJXWxt9VZ2-cc3ko_1k0lw2fUQG_/exec"; // Replace with Google Apps Script URL

void setup() {
    Serial.begin(115200);  // Serial for debugging ESP32
    Serial2.begin(9600, SERIAL_8N1, 16, 17); // RX = 16, TX = 17 (ESP32 Serial2)

    WiFi.begin(ssid, password);
    Serial.print("Connecting to WiFi");
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nConnected to WiFi");
}

void loop() {
    if (Serial2.available()) {
        String receivedData = Serial2.readStringUntil('\n');  // Read incoming data from Arduino
        receivedData.trim();  // Remove leading/trailing spaces

        if (receivedData.startsWith("<") && receivedData.endsWith(">")) {
            receivedData = receivedData.substring(1, receivedData.length() - 1); // Remove '<' and '>'
            sendDataToGoogleSheets(receivedData);
        } else {
            Serial.println("Invalid Data Received, Discarding...");
            return;         
           
        }
    }
}

void sendDataToGoogleSheets(String data) {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        String fullUrl = serverUrl + "?data=" + data;
        http.begin(fullUrl);
        int httpResponseCode = http.GET();
        if (httpResponseCode > 0) {
            Serial.println("Data sent successfully: " + String(httpResponseCode));
        } else {
            Serial.println("Error sending data: " + String(httpResponseCode));
        }
        http.end();
    } else {
        Serial.println("WiFi Disconnected");
    }
}
