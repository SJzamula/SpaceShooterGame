import 'package:flutter/material.dart';

class InputManager {
  Function onShoot;
  Function onUpdatePosition;

  InputManager({required this.onShoot, required this.onUpdatePosition});

  void handleTap() {
    onShoot();
  }

  void handleDragUpdate(Offset newPosition) {
    onUpdatePosition(newPosition);
  }

  // Додаткові методи для обробки інших вводів
}
