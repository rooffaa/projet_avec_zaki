import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

import 'fruits_lrgumes.dart';

class AlphabetAudio extends StatefulWidget {
  const AlphabetAudio({super.key});

  @override
  State<AlphabetAudio> createState() => _AlphabetAudioState();
}

class _AlphabetAudioState extends State<AlphabetAudio> {
  final Random random = Random();
  final FlutterTts flutterTts = FlutterTts();

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

  late Map<String, String> lettreDemandee;
  late List<Map<String, String>> choix;

  int score = 0;
  int niveau = 1;

  bool reponseEnCours = false;
  bool lectureEnCours = false;

  @override
  void initState() {
    super.initState();
    preparerQuestion();
    configurerAudio();
  }

  // Configuration de la voix arabe
  Future<void> configurerAudio() async {
    await flutterTts.setLanguage('ar-SA');
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  // Choisir une lettre au hasard
  void preparerQuestion() {
    lettreDemandee = lettres[random.nextInt(lettres.length)];

    choix = List<Map<String, String>>.from(lettres);
    choix.shuffle();
  }

  // Lire le son de la lettre demandée
  Future<void> ecouterLettre() async {
    if (lectureEnCours) return;

    setState(() {
      lectureEnCours = true;
    });

    try {
      await flutterTts.stop();
      await flutterTts.speak(lettreDemandee['nom1']!);
    } catch (e) {
      debugPrint('Erreur audio : $e');
    } finally {
      if (mounted) {
        setState(() {
          lectureEnCours = false;
        });
      }
    }
  }

  // Vérifier la réponse
  void verifierReponse(Map<String, String> choixUtilisateur) {
    if (reponseEnCours) return;

    if (choixUtilisateur['nom'] == lettreDemandee['nom']) {
      reponseEnCours = true;

      setState(() {
        score++;
        niveau++;
      });

      if (score >= 10) {
        afficherMessage(
          'أحسنت! لقد أكملت اللعبة 🎉',
          const Color(0xFF43A047),
        );

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const FruitsLrgumes(),
            ),
          );
        });

        return;
      }

      afficherMessage(
        'ممتاز! إجابة صحيحة 🎉',
        const Color(0xFF43A047),
      );

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        setState(() {
          preparerQuestion();
          reponseEnCours = false;
        });
      });
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

  // Recommencer le jeu
  Future<void> nouveauJeu() async {
    await flutterTts.stop();

    if (!mounted) return;

    setState(() {
      score = 0;
      niveau = 1;
      reponseEnCours = false;
      lectureEnCours = false;
      preparerQuestion();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8ED8F8),

      appBar: AppBar(
        title: const Text(
          'لعبة الحروف بالصوت 🔊',
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

                    const SizedBox(height: 25),

                    // QUESTION AUDIO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
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
/*                          const Text(
                            '👂',
                            style: TextStyle(fontSize: 45),
                          ),

                          const SizedBox(height: 10),
*/
                          const Text(
                            'استمع إلى الحرف واختره',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF514477),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BOUTON POUR ÉCOUTER
                          SizedBox(
                            width: 130,
                            height: 100,
                            child: ElevatedButton(
                              onPressed: lectureEnCours
                                  ? null
                                  : ecouterLettre,

                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFFD166),
                                foregroundColor:
                                    const Color(0xFF654900),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(28),
                                ),
                              ),

                              child: Icon(
                                lectureEnCours
                                    ? Icons.volume_up_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 65,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'اضغط على الزر للاستماع مرة أخرى 🔊',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF765A9E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // CARTES DES LETTRES : TOUJOURS VISIBLES
                    Expanded(
                      child: GridView.builder(
                        itemCount: choix.length,
                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),

                        itemBuilder: (context, index) {
                          final choixLettre = choix[index];
                          final couleur = couleursCartes[index];

                          return GestureDetector(
                            onTap: () {
                              verifierReponse(choixLettre);
                            },

                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),

                              decoration: BoxDecoration(
                                color: couleur,
                                borderRadius:
                                    BorderRadius.circular(22),
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
                                child: Text(
                                  choixLettre['nom1']!,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
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
                          backgroundColor:
                              const Color(0xFFFFD166),
                          foregroundColor:
                              const Color(0xFF654900),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25),
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