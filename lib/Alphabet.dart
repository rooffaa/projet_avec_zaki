import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'trouve_animal.dart';

class Alphabet extends StatefulWidget {
  const Alphabet({super.key});

  @override
  State<Alphabet> createState() => _AlphabetState();
}

class _AlphabetState extends State<Alphabet> {
  final Random random = Random();

  final List<Map<String, String>> lettres = [
    {'nom': 'أ', 'nom1': 'أ'},
    {'nom': 'ب', 'nom1': 'ب'},
    {'nom': 'ت', 'nom1': 'ت'},
    {'nom': 'ث', 'nom1': 'ث'},
  ];

  final List<Color> couleursCartes = [
    const Color(0xFF64B5F6),
    const Color(0xFF9575CD),
    const Color(0xFFFF8A80),
    const Color(0xFF66BB6A),
  ];

  late Map<String, String> alphabetDemandee;
  late List<Map<String, String>> choix;

  int score = 0;
  int niveau = 1;

  bool reponseEnCours = false;
  bool afficherCartes = true;

  Timer? timerCartes;
  Timer? timerQuestion;

  @override
  void initState() {
    super.initState();
    preparerQuestion();
    demarrerTimerCartes();
  }

  // Préparer une nouvelle question
  void preparerQuestion() {
    alphabetDemandee = lettres[random.nextInt(lettres.length)];

    choix = List<Map<String, String>>.from(lettres);
    choix.shuffle();
  }

  // Afficher les cartes pendant 5 secondes
  void demarrerTimerCartes() {
    timerCartes?.cancel();

    if (!mounted) return;

    setState(() {
      afficherCartes = true;
    });

    timerCartes = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        afficherCartes = false;
      });
    });
  }

  // Recommencer le jeu
  void nouveauJeu() {
    timerCartes?.cancel();
    timerQuestion?.cancel();

    setState(() {
      score = 0;
      niveau = 1;
      reponseEnCours = false;
      preparerQuestion();
      afficherCartes = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    demarrerTimerCartes();
  }

  // Vérifier la réponse de l'enfant
  void verifierReponse(Map<String, String> choixUtilisateur) {
    if (afficherCartes || reponseEnCours) return;

    if (choixUtilisateur['nom'] == alphabetDemandee['nom']) {
      reponseEnCours = true;

      timerCartes?.cancel();

      setState(() {
        score++;
        niveau++;
      });

      if (score >= 10) {
        afficherMessage(
          'أحسنت! لقد أكملت اللعبة 🎉',
          const Color(0xFF43A047),
        );

        timerQuestion = Timer(
          const Duration(milliseconds: 1200),
          () {
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TrouveAnimal(),
              ),
            );
          },
        );

        return;
      }

      afficherMessage(
        'ممتاز! إجابة صحيحة 🎉',
        const Color(0xFF43A047),
      );

      timerQuestion = Timer(
        const Duration(milliseconds: 900),
        () {
          if (!mounted) return;

          setState(() {
            preparerQuestion();
            reponseEnCours = false;
            afficherCartes = true;
          });

          demarrerTimerCartes();
        },
      );
    } else {
      afficherMessage(
        'حاول مرة أخرى 😊',
        const Color(0xFFFF9800),
      );
    }
  }

  // Afficher un message
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

  // Carte d'information : score ou niveau
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
          vertical: 14,
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
            Icon(icon, color: couleur, size: 28),
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

  @override
  void dispose() {
    timerCartes?.cancel();
    timerQuestion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8ED8F8),

      appBar: AppBar(
        title: const Text(
          'لعبة الحروف العربية 🔤',
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
              left: 20,
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 35),
              ),
            ),

            const Positioned(
              top: 90,
              right: 15,
              child: Text(
                '☁️',
                style: TextStyle(fontSize: 45),
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
                padding: const EdgeInsets.all(16),

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

                    const SizedBox(height: 22),

                    // QUESTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
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
                            '🔤',
                            style: TextStyle(fontSize: 42),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'تذكّر الحروف ثم اختر الحرف الصحيح',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF514477),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              alphabetDemandee['nom1']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7E57C2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            afficherCartes
                                ? '👀 احفظ أماكن الحروف! (5 ثوانٍ)'
                                : '🧠 أين يوجد هذا الحرف؟',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF765A9E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARTES DES LETTRES
                    Expanded(
                      child: GridView.builder(
                        itemCount: choix.length,
                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          childAspectRatio: 0.85,
                        ),

                        itemBuilder: (context, index) {
                          final choixLettre = choix[index];
                          final couleur = couleursCartes[index];

                          return GestureDetector(
                            onTap: () {
                              if (!afficherCartes) {
                                verifierReponse(choixLettre);
                              }
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),

                              decoration: BoxDecoration(
                                color: afficherCartes
                                    ? couleur
                                    : Colors.white.withValues(alpha: 0.95),

                                borderRadius: BorderRadius.circular(22),

                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Center(
                                child: afficherCartes
                                    ? Text(
                                        choixLettre['nom1']!,
                                        style: const TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.help_rounded,
                                        size: 35,
                                        color: Color(0xFF9575CD),
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
                        onPressed: nouveauJeu,

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
                            vertical: 14,
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