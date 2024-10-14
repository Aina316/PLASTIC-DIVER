import 'dart:math';

import 'package:flame/components.dart';

import '../plastic_diver.dart';

/// The [Obstacle2] represents the dead fish
/// that will be in the background and the player will just pass by.
class Obstacle2 extends SpriteComponent with HasWorldReference<EndlessWorld> {
  Obstacle2.fish({super.position})
      : _srcSize = Vector2(972, 533),
        _srcPosition = Vector2(0, -100),
        super(
          size: Vector2(100, 50),
          anchor: Anchor.bottomLeft,
        );

  /// Generates a random obstacle of type [ObstacleType].
  factory Obstacle2.random({
    Vector2? position,
    Random? random,
    bool canSpawnTall = true,
  }) {
    return Obstacle2.fish(position: position);
  }

  final Vector2 _srcSize;
  final Vector2 _srcPosition;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(
      'enemies/dead fish.png',
      srcSize: _srcSize,
      srcPosition: _srcPosition,
    );
  }

  @override
  void update(double dt) {
    position.x -= world.speed * dt;

    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }
}

enum ObstacleType { fish }
