import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:space_shooter_game/ui/widgets/bullet.dart';
import 'package:space_shooter_game/ui/widgets/enemy_ship.dart';

class SpaceShipPainter extends CustomPainter {
  final Offset playerPosition;
  final List<EnemyShip> enemies;
  final List<Bullet> bullets;
  final ui.Image playerImage;
  final ui.Image enemyImage;

  SpaceShipPainter(this.playerPosition, this.enemies, this.bullets,
      this.playerImage, this.enemyImage);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    //final paint = Paint()..color = Colors.blue;
    var rect = Rect.fromCenter(center: playerPosition, width: 50, height: 50);
    //canvas.drawRect(rect, paint);
    paintImage(canvas: canvas, rect: rect, image: playerImage);

    // Drawing enemy ships
    final enemyPaint = Paint()..color = Colors.red;
    for (var enemy in enemies) {
      var enemyRect =
          Rect.fromCenter(center: enemy.position, width: 30, height: 30);
      paintImage(canvas: canvas, rect: enemyRect, image: enemyImage);
      //canvas.drawRect(enemyRect, enemyPaint);
    }

    // Drawing bullets
    final bulletPaint = Paint()..color = Colors.yellow;
    for (var bullet in bullets) {
      canvas.drawCircle(bullet.position, 5, bulletPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
