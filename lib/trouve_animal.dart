import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'choisir_animal.dart';

class TrouveAnimal extends StatefulWidget {
  const TrouveAnimal({super.key});

  @override
  State<TrouveAnimal> createState() => _TrouveAnimalState();
}

class _TrouveAnimalState extends State<TrouveAnimal> {
  final Random random = Random();

  final List<Map<String, dynamic>> animaux = [
    {
      'nom': 'زرافة',
      'emoji': '🦒',
    },
    {
      'nom': 'أسد',
      'emoji': '🦁',
    },
    {
      'nom': 'تمساح',
      'emoji': '🐊',
    },
    {
      'nom': 'جمل',
      'emoji': '🐪',
    },
  ];

  late Map<String, dynamic> animalDemande;
  late List<Map<String, dynamic>> choix;

  int score = 0;
  int niveau = 1;

  bool reponseEnCours = false;

  @override
  void initState() {
    super.initState();
    preparerQuestion();
  }

  // Préparer une nouvelle question
  void preparerQuestion() {
    animalDemande = animaux[random.nextInt(animaux.length)];

    choix = List<Map<String, dynamic>>.from(animaux);
    choix.shuffle();
  }

  void nouveauJeu() {
    if (!mounted) return;

    setState(() {
      preparerQuestion();
      reponseEnCours = false;
    });
  }

  // Vérifier la réponse
  void verifierReponse(Map<String, dynamic> animalUtilisateur) {
    if (reponseEnCours) return;

    if (animalUtilisateur['nom'] == animalDemande['nom']) {
      reponseEnCours = true;

      setState(() {
        score++;
        niveau++;
      });

      afficherMessage(
        'ممتاز! 🎉',
        const Color(0xFF43A047),
      );

      if (score >= 10) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChoisirAnimal(),
            ),
          );
        });

        return;
      }

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          nouveauJeu();
        }
      });
    } else {
      afficherMessage(
        'حاول مرة أخرى 😊',
        const Color(0xFFFF9800),
      );
    }
  }

  // Afficher les messages
  void afficherMessage(String message, Color couleur) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
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

  // Carte du score et du niveau
  Widget carteInformation({
    required IconData icon,
    required String titre,
    required String valeur,
    required Color couleur,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
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
              size: 30,
            ),
            const SizedBox(height: 5),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555577),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8ED8F8),

      appBar: AppBar(
        title: const Text(
          'لعبة الحيوانات 🦁',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 23,
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
            // Décorations
            const Positioned(
              top: 20,
              left: 20,
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 35),
              ),
            ),

            const Positioned(
              top: 100,
              right: 15,
              child: Text(
                '☁️',
                style: TextStyle(fontSize: 50),
              ),
            ),

            const Positioned(
              bottom: 30,
              left: 15,
              child: Text(
                '🌟',
                style: TextStyle(fontSize: 40),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [
                    // SCORE ET NIVEAU
                    Row(
                      children: [
                        carteInformation(
                          icon: Icons.flag_rounded,
                          titre: 'المستوى',
                          valeur: '$niveau',
                          couleur: const Color(0xFF9575CD),
                        ),

                        const SizedBox(width: 15),

                        carteInformation(
                          icon: Icons.star_rounded,
                          titre: 'النجوم',
                          valeur: '$score / 10',
                          couleur: const Color(0xFFFFA000),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // QUESTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          const Text(
                            '🧩',
                            style: TextStyle(fontSize: 45),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'أنقر على هذا الحيوان',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF514477),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              animalDemande['nom'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7E57C2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // CARTES DES ANIMAUX
                    Expanded(
                      child: GridView.builder(
                        itemCount: choix.length,
                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1.25,
                        ),

                        itemBuilder: (context, index) {
                          final animal = choix[index];

                          return GestureDetector(
                            onTap: () {
                              verifierReponse(animal);
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFB39DDB),
                                  width: 4,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),

                              child: Center(
                                child: Text(
                                  animal['emoji'],
                                  style: const TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // BOUTON RECOMMENCER
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            score = 0;
                            niveau = 1;
                            preparerQuestion();
                            reponseEnCours = false;
                          });

                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                        },

                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 27,
                        ),

                        label: const Text(
                          'اللعب من جديد',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: const Color(0xFF654900),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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