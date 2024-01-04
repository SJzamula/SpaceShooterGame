import 'package:flutter/material.dart';

import 'package:space_shooter_game/ui/widgets/game_area.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Game'),
      ),
      body: GameArea(),
    );
  }
}
