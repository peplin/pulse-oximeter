/**
** Heartbeat Pulse Viewer (analog data grapher with filtering)
**
** by Christopher Peplin (chris.peplin@rhubarbtech.com)
** for August 23, 1966 (GROCS Project Group)
** University of Michigan, 2009
*/

import processing.serial.*;

final float AVERAGE_COUNT = 10.0;
final int MINIMUM_VALUE_THRESHOLD = 100;
final int MAXIMUM_VALUE_THRESHOLD = 800;

Serial port;
ArrayList graphValues;
int overallAverage = 0;
int average = 0;
int averageCounter = 0;

boolean upbeat = false;

void setup() {
    size(1600, 400, P2D);
    graphValues = new ArrayList();
    port = new Serial(this, Serial.list()[0], 115200);
    stroke(255);
}

String[] readValues() {
    String value = "";
    if(port.available() > 0) {
        value = trim(port.readString());
    }
    return value.split("\n");
}

void draw() {
    background(0);

    for(String value : readValues()) {
        value = value.trim();
        int y;
        if(value != null && value != "") {
            try {
                y = Integer.parseInt(value);
            } catch (NumberFormatException e) {
                println("Couldn't parse an integer from " + value);
                continue;
            }
        } else {
            continue;
        }

        if(y < MAXIMUM_VALUE_THRESHOLD && y > MINIMUM_VALUE_THRESHOLD) {
            average += (y / AVERAGE_COUNT);
            averageCounter++;

            if(averageCounter == AVERAGE_COUNT) {
                if(graphValues.size() > 10) {
                    if(average < (Integer)graphValues.get(graphValues.size() - 10) && !upbeat) {
                        println("value avg: " + average);
                        background(255);
                        upbeat = true;
                    } else if(average > (Integer)graphValues.get(graphValues.size() - 10)) {
                       upbeat = false;
                    }
                }
                if(graphValues.size() > width) {
                    graphValues.remove(0);
                }
                graphValues.add(average);
                average = 0;
                averageCounter = 0;
            }
        }
    }

    noFill();
    beginShape();
    int x = 0;
    int newOverallAverage = 0;
    for(Object value : graphValues) {
        newOverallAverage += (Integer)value;
        vertex(x++, height - map((Integer)value, overallAverage - 25,
                    overallAverage + 25, 0, height));
    }
    if(graphValues.size() > 0) {
        newOverallAverage /= graphValues.size();
    }
    overallAverage = newOverallAverage;
    endShape();
}
