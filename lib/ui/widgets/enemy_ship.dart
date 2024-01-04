import 'dart:math';

import 'package:flutter/material.dart';

class EnemyShip {
  Offset position;
  Offset playerPosition;
  double speed = 3.0;
  double horizontalMovement = 0.5;
  bool movingRight = true;
  bool isChasingPlayer = Random().nextBool();
  double screenWidth;

  EnemyShip(this.position, this.screenWidth, this.playerPosition);

  void move(List<EnemyShip> otherEnemies) {
    if (isChasingPlayer && playerPosition != null) {
      // Логіка переслідування
      Offset toPlayer = playerPosition! - position;
      Offset direction =
          toPlayer / (toPlayer.distance + 1e-6); // Нормалізувати вектор
      position = Offset(position.dx + direction.dx * speed,
          position.dy + direction.dy * speed);
    } else {
      // Звичайний рух вліво-вправо
      position = Offset(
          position.dx +
              (movingRight ? horizontalMovement : -horizontalMovement),
          position.dy + speed);

      // Змінити напрямок при досягненні країв
      if (position.dx <= 0 || position.dx >= screenWidth - 30) {
        movingRight = !movingRight;
      }
    }

    // Логіка уникнення інших ворогів
    Offset avoidance = Offset.zero;
    for (var other in otherEnemies) {
      if (other != this) {
        double distance = (position - other.position).distance;
        if (distance < 100) { // 50 - це мінімальна дистанція для уникнення
          Offset toOther = position - other.position;
          avoidance -= toOther / (distance * distance); // Чим ближче ворог, тим сильніше уникнення
        }
      }
    }

    // Нормалізація і додавання вектора уникнення
    if (avoidance.distance > 1e-6) {
      avoidance = avoidance / avoidance.distance;
      position += avoidance * speed;
    }
  }

  void updatePlayerPosition(Offset newPosition) {
    playerPosition = newPosition;
  }
}