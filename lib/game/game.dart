import 'package:a21/game/background.dart';
import 'package:a21/game/timer.dart';
import 'package:a21/main.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class MyGame extends FlameGame with PanDetector, HasCollisionDetection {
  final AppBloc bloc;
  MyGame(this.bloc);

  late BootSprite boot;
  late BallSprite _ball;

  //game state
  bool isStarted = false;

  //boot state
  bool isTap = false;
  Vector2 bootPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    addAll([
      BackGround(),
      _ball = BallSprite(),
      boot = BootSprite(),
      TimerText(),
    ]);
    boot.angle = -0.5;
    super.onLoad();
  }

  @override
  void update(double dt) {
    _manageFootAngle();
    super.update(dt);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _provideBootPosition(info.eventPosition.global);
    isTap = true;
    super.onPanStart(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    bootPosition = info.eventPosition.global;
    _provideBootPosition(info.eventPosition.global);
    super.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    isTap = false;
    bootPosition = Vector2.zero();
    super.onPanEnd(info);
  }

  //boot methods -----------------------------
  void _provideBootPosition(Vector2 position) {
    boot.position = Vector2(
      position.x - boot.size.x / 2,
      position.y - boot.size.y / 2,
    );
  }

  void _manageFootAngle() {
    if (isTap && boot.angle <= 0) {
      boot.angle += 0.025;
    } else if (!isTap && boot.angle >= -0.5) {
      boot.angle -= 0.025;
    }
  }
}

class BallSprite extends SpriteComponent with HasGameRef<MyGame>, CollisionCallbacks {
  BallSprite() : super(priority: 1);

  double speed = 0;
  Vector2 direction = Vector2.zero();

  @override
  Future<void> onLoad() async {
    final ball = await gameRef.loadSprite('ball.png');
    size = Vector2(100, 100);
    position = Vector2(
      gameRef.size.x / 2 - 50,
      gameRef.size.y / 1.5 - 50,
    );
    sprite = ball;
    add(CircleHitbox(
      radius: 50,
    ));
  }

  @override
  void update(double dt) {
    if (gameRef.isStarted == false) return;
    //gravity
    position -= Vector2(0, -1) * dt * 450;

    position -= direction * speed * dt;
    if (speed > 0) {
      speed -= 25;
      // angle -= 0.001;
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is BootSprite) {
      speed = 1200;
      direction.y = 2;
      direction.x = other.position.x < position.x ? 1 : -1;
      if (gameRef.isTap && gameRef.isStarted) {
        gameRef.bloc.add(GameHit());
      }
    }
    if (other is ScreenHitbox) {
      speed = 900;
      direction.y = other.position.y < position.y ? 1 : -1;
      direction.x = other.position.x < position.x ? 1 : -1;
    }

    super.onCollision(intersectionPoints, other);
  }
}

class BootSprite extends SpriteComponent with HasGameRef<MyGame> {
  BootSprite() : super(priority: 1);

  @override
  Future<void> onLoad() async {
    final boot = await gameRef.loadSprite('boot_1.png');
    size = Vector2(157, 100);
    position = Vector2(
      gameRef.size.x / 2 - 50,
      gameRef.size.y / 1.7 - 50,
    );
    sprite = boot;
    position = Vector2(
      gameRef.size.x / 2.5 - 50,
      gameRef.size.y / 1.2 - 50,
    );
    add(PolygonHitbox([
      Vector2(0, 60),
      Vector2(0, size.y),
      Vector2(size.x - 20, size.y - 20),
      Vector2(size.x - 40, 0),
    ]));
  }
}
