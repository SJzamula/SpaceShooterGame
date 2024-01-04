import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:space_shooter_game/ui/widgets/bullet.dart';
import 'package:space_shooter_game/ui/widgets/enemy_ship.dart';
import 'package:space_shooter_game/ui/widgets/space_ship_painter.dart';

class ImageManager {
  late Future<ui.Image> playerImage;
  late Future<ui.Image> enemyImage;

  Future<ui.Image> loadImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      return fi.image;
    } catch (e) {
      // Handle the error, e.g., log to console, load a default image, etc.
      print('Error loading image: $e');
      throw Exception('Error loading image: $assetPath');
    }
  }

  ImageManager(Function() onLoaded) {
    playerImage = loadImage('assets/images/space_cat.png');
    enemyImage = loadImage('assets/images/space_enemy.png');

    Future.wait([playerImage, enemyImage]).then((_) => onLoaded());
  }
}

class SpaceShipWidget extends StatefulWidget {
  final Offset playerPosition;
  final List<EnemyShip> enemies;
  final List<Bullet> bullets;

  const SpaceShipWidget({
    Key? key,
    required this.playerPosition,
    required this.enemies,
    required this.bullets,
  }) : super(key: key);

  @override
  _SpaceShipWidgetState createState() => _SpaceShipWidgetState();
}

class _SpaceShipWidgetState extends State<SpaceShipWidget> {
  late final ImageManager imageManager;

  @override
  void initState() {
    super.initState();
    imageManager = ImageManager(() {
      setState(() {}); // This will call build again with images loaded
    });
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<List<ui.Image>>(
    future: Future.wait([imageManager.playerImage, imageManager.enemyImage]),
    builder: (BuildContext context, AsyncSnapshot<List<ui.Image>> snapshot) {
      if (!snapshot.hasData) {
        // Show loading spinner while waiting for images
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        // Show error message if something goes wrong
        print('Snapshot error: ${snapshot.error}');
        return Center(child: Text('Error loading images'));
      }
      // Once images are loaded, display the custom paint widget
      return CustomPaint(
        painter: SpaceShipPainter(
          widget.playerPosition,
          widget.enemies,
          widget.bullets,
          snapshot.data![0],
          snapshot.data![1],
        ),
        child: Container(),
      );
    },
  );
}
}
