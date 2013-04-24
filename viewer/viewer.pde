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
final int HORIZONTAL_MULTIPLIER = 4;
final int GRAPH_CENTER_STEPS = 10;

Serial port;
ArrayList graphValues;
int graphCenter;
int targetGraphCenter;
int average;
int averageCounter;
int maxValue;
int minValue;

boolean upbeat = false;

void setup() {
    size(1600, 400, P2D);
    graphValues = new ArrayList();
    port = new Serial(this, "/dev/ttyUSB0", 115200);
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
                    int previousValue = (Integer)graphValues.get(
                            graphValues.size() - 10);
                    if(average < previousValue && !upbeat) {
                        maxValue = previousValue;
                        println("value avg: " + average);
                        background(255);
                        upbeat = true;
                    } else if(average > previousValue) {
                        minValue = previousValue;
                       upbeat = false;
                    }
                }
                if(graphValues.size() > width / HORIZONTAL_MULTIPLIER) {
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
    for(Object value : graphValues) {
        vertex(x, height - map((Integer)value, graphCenter - 50,
                    graphCenter + 50, 0, height));
        x += HORIZONTAL_MULTIPLIER;
    }
    targetGraphCenter = (minValue + maxValue) / 2;
    if(graphCenter > targetGraphCenter + 10 ||
            graphCenter < targetGraphCenter - 10) {
        int change = targetGraphCenter - graphCenter;
        if(change > 0) {
            graphCenter += max(10, change);
        } else {
            graphCenter += max(-10, change);
        }
    }
    println("Graph center: " + graphCenter);
    endShape();
}
