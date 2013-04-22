/**
** Pulse Oximeter (Analog Sensor Averaging)
**
** by Christopher Peplin (chris.peplin@rhubarbtech.com)
** for August 23, 1966 (GROCS Project Group)
** University of Michigan, 2009
*/

const int SENSOR_PIN = 0;
const int AVERAGE_COUNT = 20;

int averageLevel = 0;
int averageIndex = 0;

/**
 * The Pulse Oximeter sketch is an Arduino sketch intended for use with an
 * analog sensor reading the amount of light passing through a human finger.
 *
 * It could be made more generically into an analog signal averaging sketch.
 * There is nothing here that specifically deals with heart rate measurement.
 */
void setup() {
    pinMode(SENSOR_PIN, INPUT);
    Serial.begin(115200);
}

void loop() {
    int lightLevel = analogRead(SENSOR_PIN);
    if(lightLevel > 100) {

        averageLevel += lightLevel;
        averageIndex++;
        if(averageIndex >= AVERAGE_COUNT) {
            averageLevel /= AVERAGE_COUNT;

            Serial.println(averageLevel);

            averageLevel = 0;
            averageIndex = 0;
        }
    }
}
