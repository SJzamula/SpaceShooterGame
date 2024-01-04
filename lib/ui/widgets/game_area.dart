import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:space_shooter_game/ui/widgets/bullet.dart';
import 'package:space_shooter_game/ui/widgets/enemy_ship.dart';
import 'package:space_shooter_game/ui/widgets/image_manager.dart';
import 'package:space_shooter_game/ui/widgets/power_up.dart';

class GameArea extends StatefulWidget {
  @override
  _GameAreaState createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  final double playerSpeed = 2.0;
  Timer? gameTimer;
  List<EnemyShip> enemies = [];
  List<Bullet> bullets = [];
  List<PowerUp> powerUps = [];
  int score = 0;
  int health = 3;
  static const int maxHealth = 3;
  bool isInitialized = false;

  final enemySpawnMinInterval = Duration(seconds: 2);
  final enemySpawnRandomFactor = Duration(seconds: 4);
  Timer? enemySpawnTimer;

  Timer? shootingTimer;
  final shootingInterval = Duration(milliseconds: 500);

  double screenWidth = 0.0;
  double screenHeight = 0.0;

  Offset playerPosition = Offset.zero;

  @override
  void _spawnPowerUp() {
    // Method to spawn a power-up
    Random random = Random();
    double randomXPosition = random.nextDouble() * screenWidth;
    powerUps.add(PowerUp(Offset(randomXPosition, 0), "extraHealth"));
  }

  void _checkPowerUpCollection() {
    // Check if player collects any power-up
    Rect playerRect =
        Rect.fromCenter(center: playerPosition, width: 50, height: 50);
    for (var powerUp in powerUps) {
      if (playerRect.overlaps(
          Rect.fromCenter(center: powerUp.position, width: 20, height: 20))) {
        _applyPowerUp(powerUp.type);
        powerUps.remove(powerUp);
        break; // Avoid concurrent modification error
      }
    }
  }

  void _applyPowerUp(String type) {
    // Handle the effect of the power-up
    if (type == "extraHealth") {
      health = min(health + 1, maxHealth); // Assuming maxHealth is defined
    }
    // Add other types as needed
  }

  void shoot() {
    // Shoot a bullet from the player's current position
    setState(() {
      bullets.add(Bullet(Offset(playerPosition.dx, playerPosition.dy - 20)));
    });
  }

  void initializeEnemies() {
    if (!isInitialized) {
      enemies.add(EnemyShip(
          Offset(100, 0), screenWidth, playerPosition)); // Add an enemy
      isInitialized = true;
    }
  }

  void spawnEnemy() {
    Random random = Random();
    double randomXPosition = random.nextDouble() * screenWidth;

    setState(() {
      enemies.add(EnemyShip(Offset(randomXPosition, 0), screenWidth,
          playerPosition)); // Spawn at top with random X
    });
  }

  @override
  void initState() {
    playerPosition = Offset(screenWidth / 2, screenHeight - 150);
    super.initState();
    // Initialize the game timer here but leave the player positioning for later
    SpaceShipWidget(
        bullets: bullets, enemies: enemies, playerPosition: playerPosition);
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateGame();
      _startEnemySpawnTimer();
    });

    shootingTimer = Timer.periodic(shootingInterval, (timer) {
      shoot();
    });
  }

  void _startEnemySpawnTimer() {
    final randomDuration =
        Random().nextInt(enemySpawnRandomFactor.inMilliseconds);
    enemySpawnTimer?.cancel(); // Скасувати попередній таймер, якщо він існує
    enemySpawnTimer = Timer(Duration(milliseconds: randomDuration), () {
      spawnEnemy();
      _startEnemySpawnTimer(); // Перезапустити таймер після кожного спавну ворога
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set the initial player position
    if (!isInitialized) {
      playerPosition = Offset(screenWidth / 2, screenHeight - 50);
      // Spawn initial enemy for demonstration
      enemies.add(EnemyShip(Offset(100, 0), screenWidth, playerPosition));
      isInitialized = true; // Ensure this block doesn't run again
    }
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

    for (var enemy in enemies) {
      if (enemy.isChasingPlayer) {
        enemy.updatePlayerPosition(playerPosition);
      }
      enemy.move(enemies);
    }

    setState(() {
      // Check for collisions or other game conditions
      _checkCollisions();
    });

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
        Rect enemyRect =
            Rect.fromCenter(center: enemy.position, width: 30, height: 30);
        double enemyPosition = enemy.position.dy;
        if (bulletRect.overlaps(
            Rect.fromCenter(center: enemy.position, width: 30, height: 30))) {
          bulletsToRemove.add(bullet);
          enemiesToRemove.add(enemy);
          _incrementScore();
        }
        if (playerRect.overlaps(enemyRect) || enemyPosition > screenHeight) {
          _decrementHealth();
          enemies.remove(enemy);
          break;
        }
      }
    }

    // Now it's safe to remove the bullets and enemies
    bullets.removeWhere((bullet) => bulletsToRemove.contains(bullet));
    enemies.removeWhere((enemy) => enemiesToRemove.contains(enemy));

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      if (!isInitialized) {
        playerPosition = Offset(screenWidth / 2, screenHeight - 75);
        enemies.add(EnemyShip(
            Offset(100, 0), screenWidth, playerPosition)); // Add an enemy
        isInitialized = true;
      }
    }
  }

  void _decrementHealth() {
    if (health > 0) {
      setState(() {
        health--;
        if (health == 0) {
          _showGameOverDialog();
        }
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Гра завершена"),
          content: Text("Ви програли! Хочете спробувати ще раз?"),
          actions: <Widget>[
            TextButton(
              child: Text("Перезапустити"),
              onPressed: () {
                Navigator.of(context).pop(); // Закриває діалогове вікно
                _restartGame(); // Перезапустіть гру
              },
            ),
            TextButton(
              child: Text("Вийти"),
              onPressed: () {
                Navigator.of(context).pop(); // Закриває діалогове вікно
                Navigator.of(context).pop(); // Повернення до головного меню
              },
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      // Скиньте стан гри
      enemies.clear();
      bullets.clear();
      powerUps.clear();
      score = 0;
      health = maxHealth;
      // інші змінні та логіка для перезапуску гри
    });
  }

  void _incrementScore() {
    setState(() {
      score += 10; // Increment score, adjust scoring logic as needed
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    enemySpawnTimer?.cancel();
    shootingTimer?.cancel();
    super.dispose();
  }

  void updatePlayerPosition(Offset newPosition) {
    double newX = newPosition.dx.clamp(25, screenWidth - 25);

    // Assuming that the spaceship's height is 50 units
    double newY = newPosition.dy.clamp(
      screenHeight - 50,
      screenHeight - 50,
    );

    setState(() {
      playerPosition = Offset(newX, newY - 75);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    initializeEnemies();
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            updatePlayerPosition(Offset(
                playerPosition.dx + details.delta.dx * playerSpeed,
                playerPosition.dy + details.delta.dy * playerSpeed));
          },
          child: SpaceShipWidget(
              bullets: bullets,
              enemies: enemies,
              playerPosition: playerPosition),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Text('Health: $health',
              style: TextStyle(color: Colors.purple[200], fontSize: 24)),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Text('Score: $score',
              style: TextStyle(color: Colors.purple[200], fontSize: 24)),
        ),
      ],
    );
  }
}