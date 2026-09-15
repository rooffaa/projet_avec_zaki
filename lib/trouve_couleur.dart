import 'dart:math';
import 'package:flutter/material.dart';

class TrouveCouleur extends StatefulWidget {
  const TrouveCouleur({super.key});

  @override
  State<TrouveCouleur> createState() => _TrouveCouleurState();
}

class _TrouveCouleurState extends State<TrouveCouleur> {
  final Random random = Random();

  final List<Map<String, dynamic>> couleurs = [
    {
      'nom': 'Rouge',
      'couleur': Colors.red,
    },
    {
      'nom': 'Bleu',
      'couleur': Colors.blue,
    },
    {
      'nom': 'Vert',
      'couleur': Colors.green,
    },
    {
      'nom': 'Jaune',
      'couleur': Colors.yellow,
    },
  ];

  late Map<String, dynamic> couleurDemandee;
  late List<Map<String, dynamic>> choix;

  int score = 0;
  int niveau = 1;

  @override
  void initState() {
    super.initState();
    nouveauJeu();
  }

  void nouveauJeu() {
    couleurDemandee = couleurs[random.nextInt(couleurs.length)];

    choix = List<Map<String, dynamic>>.from(couleurs);
    choix.shuffle();

    setState(() {});
  }

  void verifierReponse(Map<String, dynamic> choixUtilisateur) {
    if (choixUtilisateur['nom'] == couleurDemandee['nom']) {
      setState(() {
        score++;
        niveau++;
      });

      afficherMessage(
        'Bravo ! 🎉',
        Colors.green,
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          nouveauJeu();
        }
      });
    } else {
      afficherMessage(
        'Essaie encore 😊',
        Colors.orange,
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
          ),
        ),
        backgroundColor: couleur,
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),

      appBar: AppBar(
        title: const Text(
          'Trouve la couleur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Niveau : $niveau',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '⭐ $score',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Question
              const Text(
                'Trouve la couleur :',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Nom de la couleur
              Text(
                couleurDemandee['nom'],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: couleurDemandee['couleur'],
                ),
              ),

              const SizedBox(height: 35),

              // Boutons
              Expanded(
                child: GridView.builder(
                  itemCount: choix.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),

                  itemBuilder: (context, index) {
                    final choixCouleur = choix[index];

                    return GestureDetector(
                      onTap: () {
                        verifierReponse(choixCouleur);
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: choixCouleur['couleur'],
                          borderRadius: BorderRadius.circular(25),

                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0, 4),
                              color: Colors.black26,
                            ),
                          ],
                        ),

                        child: Center(
                          child: Text(
                            choixCouleur['nom'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // Bouton recommencer
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    score = 0;
                    niveau = 1;
                  });

                  nouveauJeu();
                },

                icon: const Icon(Icons.refresh),

                label: const Text(
                  'Recommencer',
                  style: TextStyle(fontSize: 18),
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}