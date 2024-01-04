import 'package:flutter/material.dart';
import 'package:space_shooter_game/game_engine/game_logic.dart';


class RenderingEngine extends CustomPainter {
  final GameLogic gameLogic;

  RenderingEngine(this.gameLogic);

  @override
  void paint(Canvas canvas, Size size) {
    // Малювання корабля гравця
    final playerPaint = Paint()..color = Colors.blue;
    var playerRect = Rect.fromCenter(
        center: gameLogic.playerPosition, width: 50, height: 50);
    canvas.drawRect(playerRect, playerPaint);

    // Малювання ворожих кораблів
    final enemyPaint = Paint()..color = Colors.red;
    for (var enemy in gameLogic.enemies) {
      var enemyRect = Rect.fromCenter(
          center: enemy.position, width: 30, height: 30);
      canvas.drawRect(enemyRect, enemyPaint);
    }

    // Малювання куль
    final bulletPaint = Paint()..color = Colors.yellow;
    for (var bullet in gameLogic.bullets) {
      canvas.drawCircle(bullet.position, 5, bulletPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Поверніть true, якщо стан гри змінився
  }
}
