import 'package:flutter/material.dart';

class Bullet {
  Offset position;
  double speed = 5.0;

  Bullet(this.position);

  void move() {
    // Move the bullet upwards
    position = Offset(position.dx, position.dy - speed);
  }
}
