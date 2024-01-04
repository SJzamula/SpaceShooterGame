import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:space_shooter_game/ui/widgets/bullet.dart';
import 'package:space_shooter_game/ui/widgets/enemy_ship.dart';
import 'package:space_shooter_game/ui/widgets/power_up.dart';

class GameLogic {
  List<EnemyShip> enemies = [];
  List<Bullet> bullets = [];
  List<PowerUp> powerUps = [];
  int score = 0;
  int health = 3;
  static const int maxHealth = 3;
  bool isInitialized = false;

  double screenWidth;
  double screenHeight;
  Offset playerPosition;

  GameLogic(this.screenWidth, this.screenHeight, this.playerPosition);

  void spawnEnemy() {
    Random random = Random();
    double randomXPosition = random.nextDouble() * screenWidth;
    enemies.add(EnemyShip(Offset(randomXPosition, 0), screenWidth, playerPosition));
  }

  void shoot() {
    bullets.add(Bullet(Offset(playerPosition.dx, playerPosition.dy - 20)));
  }

  void update(double screenWidth, double screenHeight) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    _updateGame();
  }

  void _updateGame() {
    final spawnEnemyInterval = 100; // for example, every 100 frames
    int frameCount = 0;
    frameCount++;
    if (frameCount >= spawnEnemyInterval) {
      spawnEnemy();
      frameCount = 0;
    }
    bullets.forEach((bullet) => bullet.move());

    // Update game logic here
    // Example: Move enemies
    enemies.forEach((enemy) => enemy.move(enemies));

    // Check for collisions or other game conditions
    _checkCollisions();

    bullets.removeWhere(
        (bullet) => bullet.position.dy < 0); // Remove off-screen bullets
  }

  void _checkCollisions() {
    Set<Bullet> bulletsToRemove = {};
    Set<EnemyShip> enemiesToRemove = {};
    // Collision detection logic here
    Rect playerRect =
        Rect.fromCenter(center: playerPosition, width: 50, height: 50);

    for (var bullet in bullets) {
      Rect bulletRect =
          Rect.fromCenter(center: bullet.position, width: 5, height: 10);
      for (var enemy in enemies) {
        if (bulletRect.overlaps(
            Rect.fromCenter(center: enemy.position, width: 30, height: 30))) {
          bulletsToRemove.add(bullet);
          enemiesToRemove.add(enemy);
          _incrementScore();
        }
      }
    }

    // Now it's safe to remove the bullets and enemies
    bullets.removeWhere((bullet) => bulletsToRemove.contains(bullet));
    enemies.removeWhere((enemy) => enemiesToRemove.contains(enemy));
  }

  void didChangeDependencies() {
    if (!isInitialized) {
      playerPosition = Offset(screenWidth / 2, screenHeight - 75);
      enemies.add(EnemyShip(Offset(100, 0), screenWidth, playerPosition)); // Add an enemy
      isInitialized = true;
    }
  }

  void _decrementHealth() {
    if (health > 0) {
      health--;
      if (health == 0) {
        // Handle game over scenario
      }
    }
  }

  void _incrementScore() {
    score += 10;
  }
  // Additional methods for power-ups, collision detection, etc.
}
