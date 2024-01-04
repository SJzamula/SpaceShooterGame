import 'package:flutter/material.dart';

class PowerUp {
  Offset position;
  double speed = 2.0;
  String type; // Type can determine the power-up effect

  PowerUp(this.position, this.type);

  void move() {
    // Power-ups typically move down the screen
    position = Offset(position.dx, position.dy + speed);
  }

  // Additional methods or properties based on power-up type
}
