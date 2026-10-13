import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'alphabet.dart';

class ChoisirAnimal extends StatefulWidget {
  const ChoisirAnimal({super.key});

  @override
  State<ChoisirAnimal> createState() => _ChoisirAnimalState();
}

class _ChoisirAnimalState extends State<ChoisirAnimal> {
  final Random random = Random();

  final List<Map<String, String>> animaux = [
    {'nom': 'أسد', 'emoji': '🦁'},
    {'nom': 'زرافة', 'emoji': '🦒'},
    {'nom': 'تمساح', 'emoji': '🐊'},
    {'nom': 'جمل', 'emoji': '🐪'},
  ];

  late List<Map<String, String>> cartes;

  List<int> cartesSelectionnees = [];
  List<int> cartesTrouvees = [];

  int etoiles = 0;
  int essais = 0;

  bool bloque = true;
  bool montrerToutesLesCartes = true;

  Timer? timerMemoire;
  Timer? timerNouvellePartie;
  Timer? timerMauvaisePaire;

  @override
  void initState() {
    super.initState();

    preparerJeu();

    timerMemoire = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        setState(() {
          montrerToutesLesCartes = false;
          bloque = false;
        });
      },
    );
  }

  @override
  void dispose() {
    timerMemoire?.cancel();
    timerNouvellePartie?.cancel();
    timerMauvaisePaire?.cancel();
    super.dispose();
  }

  // Préparer les cartes
  void preparerJeu() {
    cartes = [];

    for (var animal in animaux) {
      cartes.add(Map<String, String>.from(animal));
      cartes.add(Map<String, String>.from(animal));
    }

    cartes.shuffle(random);
  }

  // Choisir une carte
  void choisirCarte(int index) {
    if (bloque) return;

    if (cartesTrouvees.contains(index)) return;

    if (cartesSelectionnees.contains(index)) return;

    setState(() {
      cartesSelectionnees.add(index);
    });

    if (cartesSelectionnees.length == 2) {
      verifierPaire();
    }
  }

  // Vérifier la paire
  void verifierPaire() {
    bloque = true;
    essais++;

    final int premiere = cartesSelectionnees[0];
    final int deuxieme = cartesSelectionnees[1];

    final String emoji1 = cartes[premiere]['emoji']!;
    final String emoji2 = cartes[deuxieme]['emoji']!;

    if (emoji1 == emoji2) {
      setState(() {
        cartesTrouvees.add(premiere);
        cartesTrouvees.add(deuxieme);

        etoiles++;

        cartesSelectionnees.clear();
        bloque = false;
      });

      afficherMessage(
        'ممتاز! ⭐ أحسنت',
        const Color(0xFF43A047),
      );

      if (etoiles > 10) {
        passerAuJeuSuivant();
        return;
      }

      if (cartesTrouvees.length == cartes.length) {
        rejouer();
      }
    } else {
      afficherMessage(
        'حاول مرة أخرى 😊',
        const Color(0xFFFF9800),
      );

      timerMauvaisePaire = Timer(
        const Duration(milliseconds: 900),
        () {
          if (!mounted) return;

          setState(() {
            cartesSelectionnees.clear();
            bloque = false;
          });
        },
      );
    }
  }

  // Message
  void afficherMessage(String message, Color couleur) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: couleur,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // Nouvelle partie automatique
  void rejouer() {
    bloque = true;

    timerNouvellePartie = Timer(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) return;

        setState(() {
          cartesSelectionnees.clear();
          cartesTrouvees.clear();

          preparerJeu();

          montrerToutesLesCartes = true;
          bloque = true;
        });

        timerMemoire?.cancel();

        timerMemoire = Timer(
          const Duration(seconds: 3),
          () {
            if (!mounted) return;

            setState(() {
              montrerToutesLesCartes = false;
              bloque = false;
            });
          },
        );
      },
    );
  }

  // Passage au jeu suivant
  void passerAuJeuSuivant() {
    setState(() {
      bloque = true;
    });

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⭐ رائع! اللعبة القادمة...',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Alphabet(),
              ),
            );
          },
        );
      },
    );
  }

  // Recommencer complètement
  void recommencerTout() {
    timerMemoire?.cancel();
    timerNouvellePartie?.cancel();
    timerMauvaisePaire?.cancel();

    setState(() {
      cartesSelectionnees.clear();
      cartesTrouvees.clear();

      etoiles = 0;
      essais = 0;

      preparerJeu();

      montrerToutesLesCartes = true;
      bloque = true;
    });

    timerMemoire = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        setState(() {
          montrerToutesLesCartes = false;
          bloque = false;
        });
      },
    );
  }

  // Déterminer la visibilité
  bool carteVisible(int index) {
    return montrerToutesLesCartes ||
        cartesSelectionnees.contains(index) ||
        cartesTrouvees.contains(index);
  }

  // Carte d'information
  Widget carteInformation({
    required IconData icon,
    required String titre,
    required String valeur,
    required Color couleur,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: couleur.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: couleur,
              size: 27,
            ),
            const SizedBox(height: 5),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555577),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8ED8F8),

      appBar: AppBar(
        title: const Text(
          'لعبة الذاكرة 🧩',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 21,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF64B5F6),
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF9575CD),
              Color(0xFFF48FB1),
            ],
          ),
        ),

        child: Stack(
          children: [
            const Positioned(
              top: 20,
              left: 15,
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 32),
              ),
            ),

            const Positioned(
              top: 100,
              right: 10,
              child: Text(
                '☁️',
                style: TextStyle(fontSize: 45),
              ),
            ),

            const Positioned(
              bottom: 40,
              left: 10,
              child: Text(
                '🌟',
                style: TextStyle(fontSize: 35),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  children: [
                    // SCORE ET ESSAIS
                    Row(
                      children: [
                        carteInformation(
                          icon: Icons.star_rounded,
                          titre: 'النجوم',
                          valeur: '$etoiles',
                          couleur: const Color(0xFFFFA000),
                        ),

                        const SizedBox(width: 12),

                        carteInformation(
                          icon: Icons.extension_rounded,
                          titre: 'المحاولات',
                          valeur: '$essais',
                          couleur: const Color(0xFF9575CD),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // INSTRUCTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            montrerToutesLesCartes
                                ? '👀 حاول تذكر الحيوانات!'
                                : 'ابحث عن الحيوانات المتشابهة 🧩',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF514477),
                            ),
                          ),

                          if (montrerToutesLesCartes) ...[
                            const SizedBox(height: 5),
                            const Text(
                              'تذكر أماكن الحيوانات قبل اختفائها',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF777799),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // GRILLE DES ANIMAUX
                    Expanded(
                      child: GridView.builder(
                        itemCount: cartes.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                        ),

                        itemBuilder: (context, index) {
                          final bool visible = carteVisible(index);
                          final bool trouve =
                              cartesTrouvees.contains(index);

                          return GestureDetector(
                            onTap: () {
                              choisirCarte(index);
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),

                              decoration: BoxDecoration(
                                gradient: visible
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFFFFFFF),
                                          Color(0xFFF3F0FF),
                                        ],
                                      )
                                    : const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF64B5F6),
                                          Color(0xFF9575CD),
                                        ],
                                      ),

                                borderRadius: BorderRadius.circular(17),

                                border: Border.all(
                                  color: trouve
                                      ? const Color(0xFF81C784)
                                      : Colors.white,
                                  width: trouve ? 3 : 2,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Center(
                                child: trouve
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            cartes[index]['emoji']!,
                                            style: const TextStyle(
                                              fontSize: 38,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF43A047),
                                            size: 17,
                                          ),
                                        ],
                                      )
                                    : visible
                                        ? Text(
                                            cartes[index]['emoji']!,
                                            style: const TextStyle(
                                              fontSize: 42,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.question_mark_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BOUTON RECOMMENCER
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: recommencerTout,

                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 26,
                        ),

                        label: const Text(
                          'اللعب من جديد',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: const Color(0xFF654900),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}