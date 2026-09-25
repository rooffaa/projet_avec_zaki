import 'dart:async';
import 'dart:math';
import 'package:autisme/trouve_couleur.dart';
import 'package:flutter/material.dart';
import 'trouve_couleur.dart';

class ChoisirAnimal extends StatefulWidget {
  const ChoisirAnimal({super.key});

  @override
  State<ChoisirAnimal> createState() => _ChoisirAnimalState();
}

class _ChoisirAnimalState extends State<ChoisirAnimal> {
  final Random random = Random();

  // ============================================================
  // LISTE DES ANIMAUX
  // Chaque animal apparaît UNE SEULE fois dans cette liste.
  // Le programme va automatiquement créer les doubles.
  // ============================================================

  final List<Map<String, String>> animaux = [
    {
      'nom': 'Lion',
      'emoji': '🦁',
    },
    {
      'nom': 'Girafe',
      'emoji': '🦒',
    },
    {
      'nom': 'Crocodile',
      'emoji': '🐊',
    },
    {
      'nom': 'Chameau',
      'emoji': '🐪',
    },
  ];

  // Liste des cartes
  late List<Map<String, String>> cartes;

  // Cartes actuellement sélectionnées
  List<int> cartesSelectionnees = [];

  // Cartes dont les paires ont été trouvées
  List<int> cartesTrouvees = [];

  // Nombre d'étoiles
  int etoiles = 0;

  // Nombre d'essais
  int essais = 0;

  // Empêche de cliquer pendant certaines opérations
  bool bloque = true;

  // Au début, toutes les cartes sont visibles
  bool montrerToutesLesCartes = true;

  @override
  void initState() {
    super.initState();

    // Préparer la première partie
    preparerJeu();

    // Montrer les cartes pendant 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        montrerToutesLesCartes = false;
        bloque = false;
      });
    });
  }

  // ============================================================
  // PRÉPARER UNE NOUVELLE PARTIE
  // ============================================================

  void preparerJeu() {
    cartes = [];

    // Créer automatiquement chaque animal en double
    for (var animal in animaux) {
      cartes.add(animal);
      cartes.add(animal);
    }

    // Mélanger les cartes
    cartes.shuffle(random);
  }

  // ============================================================
  // CHOISIR UNE CARTE
  // ============================================================

  void choisirCarte(int index) {
    // Si le jeu est bloqué, ne rien faire
    if (bloque) return;

    // Si la carte a déjà été trouvée
    if (cartesTrouvees.contains(index)) return;

    // Si la carte est déjà sélectionnée
    if (cartesSelectionnees.contains(index)) return;

    setState(() {
      cartesSelectionnees.add(index);
    });

    // Si deux cartes sont sélectionnées
    if (cartesSelectionnees.length == 2) {
      verifierPaire();
    }
  }

  // ============================================================
  // VÉRIFIER LES DEUX CARTES
  // ============================================================

  void verifierPaire() {
    bloque = true;

    essais++;

    final int premiere = cartesSelectionnees[0];
    final int deuxieme = cartesSelectionnees[1];

    final String emoji1 = cartes[premiere]['emoji']!;
    final String emoji2 = cartes[deuxieme]['emoji']!;

    // ==========================================================
    // BONNE PAIRE
    // ==========================================================

    if (emoji1 == emoji2) {
      setState(() {
        // Garder les deux cartes visibles
        cartesTrouvees.add(premiere);
        cartesTrouvees.add(deuxieme);

        // Ajouter une étoile
        etoiles++;

        // Vider les cartes sélectionnées
        cartesSelectionnees.clear();

        // Autoriser les clics
        bloque = false;
      });

      // ========================================================
      // SI PLUS DE 10 ÉTOILES
      // ========================================================

      if (etoiles > 10) {
        passerAuJeuSuivant();
        return;
      }

      // ========================================================
      // SI TOUTES LES PAIRES SONT TROUVÉES
      // ========================================================

      if (cartesTrouvees.length == cartes.length) {
        rejouer();
      }
    }

    // ==========================================================
    // MAUVAISE PAIRE
    // ==========================================================

    else {
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        setState(() {
          // Cacher les deux cartes
          cartesSelectionnees.clear();

          // Autoriser les clics
          bloque = false;
        });
      });
    }
  }

  // ============================================================
  // REJOUER UNE NOUVELLE PARTIE
  // ============================================================

  void rejouer() {
    // Petite pause avant la nouvelle partie
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        // Effacer les anciennes sélections
        cartesSelectionnees.clear();

        // Effacer les anciennes paires trouvées
        cartesTrouvees.clear();

        // Préparer de nouvelles cartes
        preparerJeu();

        // Afficher toutes les cartes
        montrerToutesLesCartes = true;

        // Bloquer les clics pendant 3 secondes
        bloque = true;
      });

      // ========================================================
      // CACHER LES CARTES APRÈS 3 SECONDES
      // ========================================================

      Timer(const Duration(seconds: 3), () {
        if (!mounted) return;

        setState(() {
          montrerToutesLesCartes = false;

          // Autoriser les clics
          bloque = false;
        });
      });
    });
  }

  // ============================================================
  // PASSER AU JEU SUIVANT
  // ============================================================

  void passerAuJeuSuivant() {
    // Empêcher les clics
    setState(() {
      bloque = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⭐ Bravo ! Passage au jeu suivant...',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // ========================================================
      // ICI VOUS METTREZ LE JEU SUIVANT
      // ========================================================      
      // Exemple :

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TrouveCouleur(),
        ),
      );

    });
  }

  // ============================================================
  // RECOMMENCER COMPLÈTEMENT LE JEU
  // ============================================================

  void recommencerTout() {
    setState(() {
      cartesSelectionnees.clear();
      cartesTrouvees.clear();

      // Remettre les étoiles à zéro
      etoiles = 0;

      // Remettre les essais à zéro
      essais = 0;

      // Préparer une nouvelle partie
      preparerJeu();

      // Montrer les cartes
      montrerToutesLesCartes = true;

      // Bloquer les clics
      bloque = true;
    });

    // Cacher après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        montrerToutesLesCartes = false;
        bloque = false;
      });
    });
  }

  // ============================================================
  // SAVOIR SI UNE CARTE DOIT ÊTRE VISIBLE
  // ============================================================

  bool carteVisible(int index) {
    return montrerToutesLesCartes ||
        cartesSelectionnees.contains(index) ||
        cartesTrouvees.contains(index);
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trouve les mêmes animaux',
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            // ==================================================
            // SCORE
            // ==================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '⭐ $etoiles',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Essais : $essais',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MESSAGE PENDANT LES 3 SECONDES
            // ==================================================

            if (montrerToutesLesCartes)
              const Text(
                '👀 Mémorisez les animaux !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 15),

            // ==================================================
            // GRILLE
            // ==================================================

            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  // 4 colonnes
                  crossAxisCount: 4,

                  crossAxisSpacing: 10,

                  mainAxisSpacing: 10,

                  childAspectRatio: 1,
                ),

                itemCount: cartes.length,

                itemBuilder: (context, index) {
                  final bool visible = carteVisible(index);

                  return GestureDetector(
                    onTap: () {
                      choisirCarte(index);
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: visible
                            ? Colors.white
                            : Colors.blue,

                        borderRadius:
                            BorderRadius.circular(15),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.15),

                            blurRadius: 5,

                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Center(
                        child: visible
                            ? Text(
                                cartes[index]['emoji']!,

                                style: const TextStyle(
                                  fontSize: 50,
                                ),
                              )
                            : const Icon(
                                Icons.question_mark,

                                color: Colors.white,

                                size: 40,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // BOUTON RECOMMENCER
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: recommencerTout,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Recommencer',
                  style: TextStyle(
                    fontSize: 18,
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