import 'dart:math';
import 'package:flutter/material.dart';

class TrouveAnimal extends StatefulWidget {
  const TrouveAnimal({super.key});

  @override
  State<TrouveAnimal> createState() => _TrouveAnimalState();
}

class _TrouveAnimalState extends State<TrouveAnimal> {
  final Random random = Random();

  // Liste des animaux
  final List<Map<String, dynamic>> animaux = [
    {
      'nom': 'Girafe',
      'emoji': '🦒',
    },
    {
      'nom': 'Lion',
      'emoji': '🦁',
    },
    {
      'nom': 'Crocodile',
      'emoji': '🐊',
    },
    {
      'nom': 'Chameau',
      'emoji': '🐪',
    },
    {
      'nom': 'Mouton',
      'emoji': '🐑',
    },
  ];

  late Map<String, dynamic> animalDemande;
  late List<Map<String, dynamic>> choix;

  int score = 0;
  int niveau = 1;

  @override
  void initState() {
    super.initState();
    nouveauJeu();
  }

  // Préparer une nouvelle question
  void nouveauJeu() {
    animalDemande = animaux[random.nextInt(animaux.length)];

    choix = List<Map<String, dynamic>>.from(animaux);
    choix.shuffle();

    setState(() {});
  }

  // Vérifier la réponse
  void verifierReponse(Map<String, dynamic> animalUtilisateur) {
    if (animalUtilisateur['nom'] == animalDemande['nom']) {
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

      // Barre supérieure
      appBar: AppBar(
        title: const Text(
          'Trouve l\'animal',
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

              // Niveau et score
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
                'Trouve l\'animal :',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Nom de l'animal demandé
              Text(
                animalDemande['nom'],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 30),

              // Les animaux
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
                    final animal = choix[index];

                    return GestureDetector(
                      onTap: () {
                        verifierReponse(animal);
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),

                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 3,
                          ),

                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0, 4),
                              color: Colors.black26,
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            // Emoji de l'animal
                            Text(
                              animal['emoji'],
                              style: const TextStyle(
                                fontSize: 65,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Nom
                            Text(
                              animal['nom'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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