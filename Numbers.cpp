/*
 * Created by CPDiener on 9/11/2023
 * Provides the motor movement for numbers
 * */

// Height is around 1.44 x width

#include <Arduino.h>
#include <Numbers.h>
#include <Plane.h>
#include <Stepper.h>
#include <Servo.h>
 
// ─────────────────────────────────────────────
//  Move both axes simultaneously using Bresenham's
//  line algorithm — no stopping between steps.
// ─────────────────────────────────────────────
void Numbers::moveSimultaneous(Stepper &motorX, Stepper &motorY, int targetX, int targetY) {
  int x0 = motorX.getPos();
  int y0 = motorY.getPos();
  int dx = abs(targetX - x0);
  int dy = abs(targetY - y0);
  int stepX = (targetX > x0) ? 1 : -1;
  int stepY = (targetY > y0) ? 1 : -1;
  int err = dx - dy;
 
  while (true) {
    if (motorX.getPos() == targetX && motorY.getPos() == targetY) break;
 
    int e2 = 2 * err;
 
    if (e2 > -dy && motorX.getPos() != targetX) {
      err -= dy;
      if (stepX > 0) motorX.moveUp();
      else           motorX.moveDown();
    }
 
    if (e2 < dx && motorY.getPos() != targetY) {
      err += dx;
      if (stepY > 0) motorY.moveUp();
      else           motorY.moveDown();
    }
  }
}
 
// ─────────────────────────────────────────────
//  relativeMove
//  relX: 0–100 maps to full X width
//  relY: 0–100 maps to Y bounds 10–90
// ─────────────────────────────────────────────
void Numbers::relativeMove(Stepper &motorX, Stepper &motorY, Plane numPlace, int relX, int relY) {
  float width  = numPlace.getWidth();
  float height = numPlace.getHeight();
 
  // X bounded 10–90, flipped: relX=0→physical 90 (left), relX=100→physical 10 (right)
  int absX = (int)(numPlace.getXMin() + ((90.0f - (relX / 100.0f) * 80.0f) / 100.0f) * width);
  // Y bounded 10–90, flipped: relY=0→physical 90 (bottom), relY=100→physical 10 (top)
  int absY = (int)(numPlace.getYMin() + ((90.0f - (relY / 100.0f) * 80.0f) / 100.0f) * height);
 
  Serial.print("Moving to X: "); Serial.print(absX);
  Serial.print(", Y: ");         Serial.println(absY);
 
  moveSimultaneous(motorX, motorY, absX, absY);
}
 
// ─────────────────────────────────────────────
//  relativeArc — arc centre/radius also in 0–100
//  space, remapped the same way as relativeMove
// ─────────────────────────────────────────────
void Numbers::relativeArc(Stepper &motorX, Stepper &motorY, Plane numPlace,
                           float cx, float cy, float rx, float ry,
                           float startDeg, float endDeg, int steps) {
  float width    = numPlace.getWidth();
  float height   = numPlace.getHeight();
  float startRad = startDeg * PI / 180.0f;
  float endRad   = endDeg   * PI / 180.0f;
 
  for (int i = 1; i <= steps; i++) {
    float t    = startRad + (endRad - startRad) * ((float)i / steps);
    float relX = cx - rx * cos(t);  // negative cos because X=0 is physical left
    float relY = cy + ry * sin(t);  // positive sin because relY=0 is top
 
    int absX = (int)(numPlace.getXMin() + ((90.0f - (relX / 100.0f) * 80.0f) / 100.0f) * width);
    int absY = (int)(numPlace.getYMin() + ((90.0f - (relY / 100.0f) * 80.0f) / 100.0f) * height);
 
    moveSimultaneous(motorX, motorY, absX, absY);
  }
}
 
// ─────────────────────────────────────────────
//  All draw functions use relY 0–100 which maps
//  cleanly onto the physical 10–90 Y bounds.
// ─────────────────────────────────────────────
 
void Numbers::draw0(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 85, 50);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 50, 35, 45, 0, 360, 24);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw1(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 30, 15);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 50, 0);
  relativeMove(motorX, motorY, numPlace, 50, 100);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw2(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 15, 100);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 85, 100);
  relativeMove(motorX, motorY, numPlace, 15, 48);
  relativeArc(motorX, motorY, numPlace, 50, 28, 35, 28, 180, 0, 16);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw3(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 18, 0);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 25, 32, 25, 180,  90, 8);
  relativeArc(motorX, motorY, numPlace, 50, 25, 32, 25,  90, -20, 8);
  relativeArc(motorX, motorY, numPlace, 50, 50, 16,  8, -20, 180, 6);
  relativeArc(motorX, motorY, numPlace, 50, 75, 32, 25, 180,  90, 8);
  relativeArc(motorX, motorY, numPlace, 50, 75, 32, 25,  90, -10, 8);
  relativeArc(motorX, motorY, numPlace, 50, 75, 32, 25, -10, 200, 4);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw4(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 70, 0);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 15, 60);
  relativeMove(motorX, motorY, numPlace, 85, 60);
  pen.write(penUp);
  delay(100);
  relativeMove(motorX, motorY, numPlace, 70, 0);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 70, 100);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw5(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 82, 0);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 18, 0);
  relativeMove(motorX, motorY, numPlace, 18, 48);
  relativeArc(motorX, motorY, numPlace, 50, 72, 32, 28, 180, -10, 16);
  relativeArc(motorX, motorY, numPlace, 50, 72, 32, 28, -10, 200,  4);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw6(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 75, 10);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 35, 32, 32, -30, 180, 12);
  relativeArc(motorX, motorY, numPlace, 50, 72, 32, 25, 180, 540, 20);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw7(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 15, 0);
  pen.write(penDown);
  delay(200);
  relativeMove(motorX, motorY, numPlace, 85, 0);
  relativeMove(motorX, motorY, numPlace, 35, 100);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw8(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 82, 28);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 28, 32, 26, 0, 360, 16);
  pen.write(penUp);
  delay(100);
  relativeMove(motorX, motorY, numPlace, 82, 72);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 72, 32, 26, 0, 360, 16);
  pen.write(penUp);
  delay(200);
}
 
void Numbers::draw9(Stepper &motorX, Stepper &motorY, Plane numPlace,
                    int currentX, int currentY, Servo &pen, int penUp, int penDown) {
  relativeMove(motorX, motorY, numPlace, 82, 28);
  pen.write(penDown);
  delay(200);
  relativeArc(motorX, motorY, numPlace, 50, 28, 32, 28,   0, 360, 20);
  relativeArc(motorX, motorY, numPlace, 50, 28, 32, 28,   0, -90,  8);
  relativeMove(motorX, motorY, numPlace, 82, 100);
  pen.write(penUp);
  delay(200);
}
 
// ─────────────────────────────────────────────
//  relativeMoveX (unchanged)
// ─────────────────────────────────────────────
void Numbers::relativeMoveX(Stepper &motorX, Plane numPlace, int relX) {
  int width    = numPlace.getWidth();
  int height   = numPlace.getHeight();
  int relWidth = 100 * (width / height);
  int absX     = ((relX / relWidth) * width) + numPlace.getXMin();
  motorX.moveTo(absX);
}