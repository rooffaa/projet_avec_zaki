
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'merci_page.dart';

class GaucheDroite extends StatefulWidget {
  const GaucheDroite({super.key});

  @override
  State<GaucheDroite> createState() => _GaucheDroiteState();
}

class _GaucheDroiteState extends State<GaucheDroite> {
  // Capteur du téléphone et minuterie du jeu.
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  Timer? _gameTimer;

  final Random _random = Random();

  // 0 = gauche, 1 = centre, 2 = droite.
  int _playerLane = 1;
  int _obstacleLane = 1;
  int _targetLane = 0;

  int _carsPassed = 0;
  int _lives = 3;

  double _obstacleY = -120;
  double _roadOffset = 0;

  bool _gameStarted = false;
  bool _gameOver = false;
  bool _won = false;
  bool _obstacleResolved = false;
  bool _sensorAvailable = true;

  String _instruction = 'استعد للانطلاق!';

  DateTime _lastMove = DateTime.fromMillisecondsSinceEpoch(0);
  double _lastTiltDirection = 0;

  static const int totalCars = 15;

  static const double carWidth = 54;
  static const double carHeight = 84;

  @override
  void dispose() {
    _stopGame();
    super.dispose();
  }

  void _stopGame() {
    _gameTimer?.cancel();
    _gameTimer = null;

    _sensorSubscription?.cancel();
    _sensorSubscription = null;
  }

  // Démarrer ou recommencer le jeu.
  void _startGame() {
    _stopGame();

    setState(() {
      _playerLane = 1;
      _obstacleLane = 1;
      _targetLane = 0;

      _carsPassed = 0;
      _lives = 3;

      _obstacleY = -carHeight;
      _roadOffset = 0;

      _gameStarted = true;
      _gameOver = false;
      _won = false;
      _obstacleResolved = false;

      _instruction = 'استعد للانطلاق!';
      _lastTiltDirection = 0;
      _sensorAvailable = true;
    });

    _prepareNextCar();

    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (_) => _updateGame(),
    );

    _startSensor();
  }

  // Détection de l'inclinaison du téléphone.
  void _startSensor() {
    try {
      _sensorSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (event) {
          if (!_gameStarted || _gameOver || _won) return;

          // Sur la plupart des téléphones tenus verticalement,
          // l'axe X permet de détecter une inclinaison latérale.
          // Le sens peut varier selon l'orientation du téléphone.
          final double x = event.x;

          if (x < -3.5) {
            if (_lastTiltDirection != -1) {
              _lastTiltDirection = -1;
              _movePlayer(-1);
            }
          } else if (x > 3.5) {
            if (_lastTiltDirection != 1) {
              _lastTiltDirection = 1;
              _movePlayer(1);
            }
          } else {
            _lastTiltDirection = 0;
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() => _sensorAvailable = false);
          }
        },
      );
    } catch (_) {
      _sensorAvailable = false;
    }
  }

  // Choisir la voie de l'obstacle et la direction à suivre.
  void _prepareNextCar() {
    if (_carsPassed >= totalCars) {
      _finishGame();
      return;
    }

    // L'obstacle arrive dans la voie où se trouve le joueur
    // au moment de la préparation.
    _obstacleLane = _playerLane;

    // Le joueur doit changer de voie pour éviter l'obstacle.
    if (_playerLane == 0) {
      _targetLane = 1;
    } else if (_playerLane == 2) {
      _targetLane = 1;
    } else {
      _targetLane = _random.nextBool() ? 0 : 2;
    }

    _instruction = _targetLane < _playerLane
        ? 'إلى اليسار ⬅️'
        : 'إلى اليمين ➡️';

    _obstacleY = -carHeight - 10;
    _obstacleResolved = false;
  }

  // Mise à jour de la route et des voitures.
  void _updateGame() {
    if (!mounted || !_gameStarted || _gameOver || _won) return;

    setState(() {
      _roadOffset += 5;

      if (_roadOffset >= 60) {
        _roadOffset = 0;
      }

      // L'obstacle descend sur la route.
      _obstacleY += 5;

      final double screenHeight = MediaQuery.of(context).size.height;
      final double playerY = screenHeight - 255;

      // L'obstacle arrive au niveau de la voiture du joueur.
      if (!_obstacleResolved &&
          _obstacleY + carHeight >= playerY &&
          _obstacleY <= playerY + carHeight) {
        _obstacleResolved = true;

        if (_playerLane == _obstacleLane) {
          // Collision : perdre une vie, mais continuer.
          _lives--;

          if (_lives <= 0) {
            _endGame();
            return;
          }

          _instruction = 'انتبه! خسرت حياة ❤️';
        } else {
          _instruction = 'أحسنت! ⭐';
        }

        // Chaque voiture rencontrée compte parmi les 15.
        _carsPassed++;

        if (_carsPassed >= totalCars) {
          _finishGame();
          return;
        }
      }

      // Préparer la voiture suivante quand l'obstacle est passé.
      if (_obstacleY > screenHeight + 10) {
        _prepareNextCar();
      }
    });
  }

  // Déplacement du joueur.
  void _movePlayer(int direction) {
    if (!_gameStarted || _gameOver || _won) return;

    final now = DateTime.now();

    // Évite les déplacements trop rapides dus au capteur.
    if (now.difference(_lastMove).inMilliseconds < 180) {
      return;
    }

    _lastMove = now;

    setState(() {
      _playerLane = (_playerLane + direction).clamp(0, 2);
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _sensorSubscription?.cancel();

    _gameStarted = false;
    _gameOver = true;
    _won = false;
    _instruction = 'انتهت اللعبة!';
  }

  void _finishGame() {
    _gameTimer?.cancel();
    _sensorSubscription?.cancel();

    _gameStarted = false;
    _won = true;
    _gameOver = false;
    _instruction = 'مبروك! وصلت إلى خط النهاية 🏁';
  }

  // Passer au jeu TrouveCouleur.
  void _goToTrouveCouleur() {
    _stopGame();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MerciPage(),
      ),
    );
  }

  Widget _carImage({
    required String asset,
    required double width,
    required double height,
  }) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.directions_car,
            color: Colors.red,
            size: 42,
          ),
        );
      },
    );
  }

  // Dessiner la route et placer les voitures.
  Widget _buildRoad(double width, double height) {
    final double roadWidth = width * 0.88;
    final double roadLeft = (width - roadWidth) / 2;
    final double laneWidth = roadWidth / 3;
    final double playerY = height - 100;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: Container(color: const Color(0xFF3E444D)),
        ),

        // Bords de la route.
        Positioned(
          left: roadLeft,
          top: 0,
          bottom: 0,
          width: 5,
          child: Container(color: Colors.white),
        ),
        Positioned(
          left: roadLeft + roadWidth - 5,
          top: 0,
          bottom: 0,
          width: 5,
          child: Container(color: Colors.white),
        ),

        // Lignes blanches entre les trois voies.
        for (int lane = 1; lane <= 2; lane++)
          Positioned(
            left: roadLeft + lane * laneWidth - 2,
            top: -60 + _roadOffset,
            bottom: 0,
            width: 4,
            child: CustomPaint(
              painter: _DashedLinePainter(),
            ),
          ),

        // Voiture obstacle.
        if (!_won)
          Positioned(
            left: roadLeft +
                _obstacleLane * laneWidth +
                (laneWidth - carWidth) / 2,
            top: _obstacleY,
            child: _carImage(
              asset: 'assets/images/voiture_obstacle.png',
              width: carWidth,
              height: carHeight,
            ),
          ),

        // Voiture du joueur.
        Positioned(
          left: roadLeft +
              _playerLane * laneWidth +
              (laneWidth - carWidth) / 2,
          top: playerY,
          child: _carImage(
            asset: 'assets/images/voiture_joueur.png',
            width: carWidth,
            height: carHeight,
          ),
        ),

        // Ligne d'arrivée à damier.
        if (_won)
          Positioned(
            left: roadLeft,
            top: height - 170,
            width: roadWidth,
            height: 42,
            child: CustomPaint(
              painter: _FinishLinePainter(),
            ),
          ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF5E35B1), size: 26),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 13)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _directionButton({
    required IconData icon,
    required String label,
    required int direction,
  }) {
    return ElevatedButton(
      onPressed: _gameStarted ? () => _movePlayer(direction) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5E35B1),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOverlay() {
    final bool isInitial = !_gameOver && !_won;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.68),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _won
                        ? '🏆'
                        : _gameOver
                            ? '💔'
                            : '🚗',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _won
                        ? 'مبروك! فزت!'
                        : _gameOver
                            ? 'انتهت اللعبة'
                            : 'لعبة اليمين واليسار',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4527A0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'السيارات: $_carsPassed / $totalCars',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  // Rejouer.
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      isInitial ? 'ابدأ اللعب' : 'العب من جديد',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCA28),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),

                  // Passage au jeu suivant après la victoire.
                  if (_won) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _goToTrouveCouleur,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('الانتقال إلى اللعبة الموالية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF9575CD),
              Color(0xFFF48FB1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score et vies.
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoCard(
                      title: 'السيارات',
                      value: '$_carsPassed / $totalCars',
                      icon: Icons.directions_car,
                    ),
                    _infoCard(
                      title: 'الحياة',
                      value: '$_lives ❤️',
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),

              // Instruction à suivre.
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4527A0),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (!_sensorAvailable)
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    'استخدم الأزرار للتحرك',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Route et zone de jeu.
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E444D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          _buildRoad(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          if (!_gameStarted) _buildEndOverlay(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Boutons tactiles.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _directionButton(
                      icon: Icons.arrow_back,
                      label: 'يسار',
                      direction: -1,
                    ),
                    _directionButton(
                      icon: Icons.arrow_forward,
                      label: 'يمين',
                      direction: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dessiner les lignes pointillées de la route.
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 4;

    double y = 0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 28),
        paint,
      );

      y += 60;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Dessiner la ligne d'arrivée à damier.
class _FinishLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double square = 14;
    final paint = Paint();

    for (int row = 0; row < (size.height / square).ceil(); row++) {
      for (int col = 0; col < (size.width / square).ceil(); col++) {
        paint.color =
            (row + col).isEven ? Colors.white : Colors.black;

        canvas.drawRect(
          Rect.fromLTWH(
            col * square,
            row * square,
            square,
            square,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
