import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../plastic_diver.dart';

/// The [Obstacle] component can represent three different types of obstacles
/// that the player can run into.
class Obstacle extends SpriteComponent with HasWorldReference<EndlessWorld> {
  Obstacle.wide({super.position})
      : _srcSize = Vector2(992, 523),
        _srcPosition = Vector2(0, 0),
        super(
          size: Vector2(200, 100),
          anchor: Anchor.bottomLeft,
        );

  /// Generates a random obstacle of type [ObstacleType].
  factory Obstacle.random({
    Vector2? position,
    Random? random,
    bool canSpawnTall = true,
  }) {
    return Obstacle.wide(position: position);
  }

  final Vector2 _srcSize;
  final Vector2 _srcPosition;

  @override
  Future<void> onLoad() async {
    // Since all the obstacles reside in the same image, srcSize and srcPosition
    // are used to determine what part of the image that should be used.
    sprite = await Sprite.load(
      'enemies/Shark4.png',
      srcSize: _srcSize,
      srcPosition: _srcPosition,
    );
    // When adding a RectangleHitbox without any arguments it automatically
    // fills up the size of the component.
    add(RectangleHitbox(size: Vector2(200, 100)));
  }

  @override
  void update(double dt) {
    // We need to move the component to the left together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.x -= world.speed * dt;

    // When the component is no longer visible on the screen anymore, we
    // remove it.
    // The position is defined from the upper left corner of the component (the
    // anchor) and the center of the world is in (0, 0), so when the components
    // position plus its size in X-axis is outside of minus half the world size
    // we know that it is no longer visible and it can be removed.
    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }
}

enum ObstacleType { wide }
