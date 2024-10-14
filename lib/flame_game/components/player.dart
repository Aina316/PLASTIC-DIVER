import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter/animation.dart';

import '../effects/jump_effect.dart';
import '../../audio/sounds.dart';
import '../plastic_diver_endless_runner.dart';
import '../plastic_diver.dart';
import '../effects/hurt_effect.dart';
import 'obstacle.dart';
import 'point.dart';

/// The [Player] is the component that the physical player of the game is
/// controlling.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<EndlessWorld>,
        HasGameReference<EndlessRunner> {
  Player({
    required this.addScore,
    required this.resetScore,
    super.position,
  }) : super(size: Vector2.all(150), anchor: Anchor.center, priority: 1);

  final void Function({int amount}) addScore;
  final VoidCallback resetScore;

  // The current velocity that the player has that comes from being affected by
  // the gravity. Defined in virtual pixels/s².
  double _gravityVelocity = 100;

  // The maximum length that the player can jump. Defined in virtual pixels.
  final double _jumpLength = -280;

  // Whether the player is currently in the air, this can be used to restrict
  // movement for example.
  bool get inAir => (position.y + size.y / 2) < world.groundLevel;

  // Used to store the last position of the player, so that we later can
  // determine which direction that the player is moving.
  final Vector2 _lastPosition = Vector2.zero();

  // When the player has velocity pointing downwards it is counted as falling,
  // this is used to set the correct animation for the player.
  bool get isFalling => _lastPosition.y < position.y;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the player can be in.
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'dash/submarine2.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(204, 192),
          stepTime: 150,
        ),
      ),
      PlayerState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/submarine2.png')],
        stepTime: double.infinity,
      ),
      PlayerState.diving: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/submarine2.png')],
        stepTime: double.infinity,
      ),
    };
    // The starting state will be that the player is running.
    current = PlayerState.running;
    _lastPosition.setFrom(position);

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _gravityVelocity * dt;
    final belowGround = position.y + size.y / 2 > world.groundLevel;
    if (inAir) {
      _gravityVelocity += world.gravity * dt;
      position.y += _gravityVelocity;
      if (isFalling) {
        current = PlayerState.diving;
      }
    }
    // If the player's new position would overshoot the ground level after
    // updating its position we need to move the player up to the ground level
    // again.
    if (belowGround) {
      position.y = world.groundLevel - size.y / 2;
      _gravityVelocity = 0;
      current = PlayerState.running;
    }

    _lastPosition.setFrom(position);
  }

  void jump(Vector2 towards) {
    current = PlayerState.jumping;
    // Since `towards` is normalized we need to scale (multiply) that vector by
    // the length that we want the jump to have.
    final jumpEffect = JumpEffect(towards..scaleTo(_jumpLength));

    // We only allow jumps when the player isn't already in the air.
    if (!inAir | inAir) {
      add(jumpEffect);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // When the player collides with an obstacle it should lose all its points.
    if (other is Obstacle) {
      game.audioController.playSfx(SfxType.damage);
      resetScore();
      add(HurtEffect());
    } else if (other is Point) {
      // When the player collides with a point it should gain a point and remove
      // the `Point` from the game.
      game.audioController.playSfx(SfxType.score);
      other.removeFromParent();
      addScore();
    }
  }
}

enum PlayerState { jumping, running, diving }
