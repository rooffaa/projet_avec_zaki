import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'trouve_couleur.dart';

class MerciPage extends StatefulWidget {
  const MerciPage({super.key});

  @override
  State<MerciPage> createState() => _MerciPageState();
}

class _MerciPageState extends State<MerciPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  late final List<_Firework> _fireworks;

  @override
  void initState() {
    super.initState();

    _fireworks = List.generate(
      8,
      (_) => _Firework(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.65,
        color: Colors.primaries[
            _random.nextInt(Colors.primaries.length)],
        size: 25 + _random.nextDouble() * 45,
        delay: _random.nextDouble(),
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rejouer() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const TrouveCouleur(),
      ),
      (route) => false,
    );
  }

  void _quitter() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF24105A),
              Color(0xFF7138A8),
              Color(0xFFED72A6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Feux d'artifice animés
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FireworksPainter(
                      fireworks: _fireworks,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),

            // Contenu principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎆 🎉 🌟 🎊',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 45),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'شكراً لاختياركم لعبتنا المتواضعة',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.8,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'انتظرونا في الجزء الثاني',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.yellowAccent,
                          height: 1.8,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        '💖 شكراً لكم 💖',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bouton Rejouer
                      SizedBox(
                        width: 240,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _rejouer,
                          icon: const Icon(
                            Icons.replay_rounded,
                            size: 28,
                          ),
                          label: const Text(
                            'إعادة اللعب',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bouton Quitter
                      SizedBox(
                        width: 240,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _quitter,
                          icon: const Icon(
                            Icons.exit_to_app_rounded,
                            size: 28,
                          ),
                          label: const Text(
                            'خروج',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      const Text(
                        '🌟 إلى اللقاء 🌟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Firework {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double delay;

  _Firework({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.delay,
  });
}

class _FireworksPainter extends CustomPainter {
  final List<_Firework> fireworks;
  final double progress;

  _FireworksPainter({
    required this.fireworks,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final firework in fireworks) {
      final localProgress =
          (progress + firework.delay) % 1.0;

      final center = Offset(
        firework.x * size.width,
        firework.y * size.height,
      );

      final paint = Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = firework.color.withOpacity(
          (1.0 - localProgress).clamp(0.0, 1.0),
        );

      final radius = firework.size * localProgress;

      // Dessiner les particules dans huit directions
      for (int i = 0; i < 12; i++) {
        final angle = (2 * pi * i) / 12;

        final start = Offset(
          center.dx + cos(angle) * radius * 0.35,
          center.dy + sin(angle) * radius * 0.35,
        );

        final end = Offset(
          center.dx + cos(angle) * radius,
          center.dy + sin(angle) * radius,
        );

        canvas.drawLine(start, end, paint);
      }

      // Petit point lumineux au centre
      canvas.drawCircle(
        center,
        2.5,
        Paint()
          ..color = firework.color.withOpacity(
            (1.0 - localProgress).clamp(0.0, 1.0),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}