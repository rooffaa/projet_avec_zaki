import 'dart:math';
import 'package:flutter/material.dart';
import 'gauche_droite.dart';

class FruitsLrgumes extends StatefulWidget {
  const FruitsLrgumes({super.key});

  @override
  State<FruitsLrgumes> createState() => _FruitsLrgumesState();
}

class _FruitsLrgumesState extends State<FruitsLrgumes> {
  final Random random = Random();

  final List<Map<String, dynamic>> fruits = [
    {'nom': 'تفاحة', 'emoji': '🍎', 'categorie': 'fruit'},
    {'nom': 'موز', 'emoji': '🍌', 'categorie': 'fruit'},
    {'nom': 'برتقال', 'emoji': '🍊', 'categorie': 'fruit'},
    {'nom': 'عنب', 'emoji': '🍇', 'categorie': 'fruit'},
    {'nom': 'فراولة', 'emoji': '🍓', 'categorie': 'fruit'},
    {'nom': 'بطيخ', 'emoji': '🍉', 'categorie': 'fruit'},
    {'nom': 'كمثرى', 'emoji': '🍐', 'categorie': 'fruit'},
    {'nom': 'أناناس', 'emoji': '🍍', 'categorie': 'fruit'},
  ];

  final List<Map<String, dynamic>> legumes = [
    {'nom': 'جزر', 'emoji': '🥕', 'categorie': 'légume'},
    {'nom': 'طماطم', 'emoji': '🍅', 'categorie': 'légume'},
    {'nom': 'بروكلي', 'emoji': '🥦', 'categorie': 'légume'},
    {'nom': 'ذرة', 'emoji': '🌽', 'categorie': 'légume'},
    {'nom': 'خيار', 'emoji': '🥒', 'categorie': 'légume'},
    {'nom': 'فلفل', 'emoji': '🫑', 'categorie': 'légume'},
    {'nom': 'بطاطا', 'emoji': '🥔', 'categorie': 'légume'},
    {'nom': 'خس', 'emoji': '🥬', 'categorie': 'légume'},
  ];

  late Map<String, dynamic> categorieDemandee;
  late List<Map<String, dynamic>> choix;

  int score = 0;
  int niveau = 1;

  bool reponseEnCours = false;
  bool transitionEnCours = false;

  @override
  void initState() {
    super.initState();
    preparerQuestion();
  }

  void preparerQuestion() {
    final bool demanderFruit = random.nextBool();

    categorieDemandee = {
      'nom': demanderFruit ? 'الفواكه' : 'الخضروات',
      'emoji': demanderFruit ? '🍎' : '🥕',
      'categorie': demanderFruit ? 'fruit' : 'légume',
    };

    final bonneCategorie = demanderFruit ? fruits : legumes;
    final mauvaiseCategorie = demanderFruit ? legumes : fruits;

    final bons = List<Map<String, dynamic>>.from(bonneCategorie)
      ..shuffle(random);

    final mauvais = List<Map<String, dynamic>>.from(mauvaiseCategorie)
      ..shuffle(random);

    choix = [
      ...bons.take(1),
      ...mauvais.take(3),
    ]..shuffle(random);
  }

  void nouveauJeu() {
    setState(() {
      score = 0;
      niveau = 1;
      reponseEnCours = false;
      transitionEnCours = false;
      preparerQuestion();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void verifierReponse(Map<String, dynamic> element) {
    if (reponseEnCours || transitionEnCours) return;

    if (element['categorie'] == categorieDemandee['categorie']) {
      setState(() {
        reponseEnCours = true;
        score++;
        niveau++;
      });

      if (score >= 10) {
        setState(() {
          transitionEnCours = true;
        });

        afficherMessage(
          'أحسنت! 🎉 إلى لعبة الألوان!',
          const Color(0xFF43A047),
        );

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GaucheDroite(),
            ),
          );
        });

        return;
      }

      afficherMessage('ممتاز! 🎉', const Color(0xFF43A047));

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
          color: Colors.white.withValues(alpha: 0.94),
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
            Icon(icon, color: couleur, size: 30),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8ED8F8),
      appBar: AppBar(
        title: const Text(
          'لعبة الفواكه والخضروات 🍎🥕',
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
              child: Text('⭐', style: TextStyle(fontSize: 35)),
            ),
            const Positioned(
              top: 100,
              right: 15,
              child: Text('☁️', style: TextStyle(fontSize: 50)),
            ),
            const Positioned(
              bottom: 30,
              left: 15,
              child: Text('🌟', style: TextStyle(fontSize: 40)),
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
                          /*Text(
                            categorieDemandee['emoji'],
                            style: const TextStyle(fontSize: 45),
                          ),*/
                          const SizedBox(height: 8),
                          const Text(
                            'اختر النوع المطلوب',
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
                              categorieDemandee['nom'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF9575CD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // QUATRE CHOIX SUR UNE LIGNE
                    Expanded(
                      child: GridView.builder(
                        itemCount: choix.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, index) {
                          final element = choix[index];

                          return GestureDetector(
                            onTap: () => verifierReponse(element),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.20,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    element['emoji'],
                                    style: const TextStyle(fontSize: 34),
                                  ),
                                  const SizedBox(height: 8),
                                  /*Text(
                                    element['nom'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF514477),
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // RECOMMENCER
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