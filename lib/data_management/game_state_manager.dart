class GameStateManager {
  int score = 0;
  int level = 1;

  void updateScore(int points) {
    score += points;
  }

  void nextLevel() {
    level++;
  }
}
