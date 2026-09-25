import 'dart:math';
import 'package:flutter/material.dart';
import 'Choisir_Animal.dart';

class TrouveAnimal extends StatefulWidget {
  const TrouveAnimal({super.key});

  @override
  State<TrouveAnimal> createState() => _TrouveAnimalState();
}

class _TrouveAnimalState extends State<TrouveAnimal> {
  final Random random = Random();

  // ============================================================
  // LISTE DES ANIMAUX
  // ============================================================

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
    
  ];

  // ============================================================
  // VARIABLES
  // ============================================================

  late Map<String, dynamic> animalDemande;

  late List<Map<String, dynamic>> choix;

  int score = 0;

  int niveau = 1;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    nouveauJeu();
  }

  // ============================================================
  // NOUVELLE QUESTION
  // ============================================================

  void nouveauJeu() {
    animalDemande =
        animaux[random.nextInt(animaux.length)];

    choix = List<Map<String, dynamic>>.from(animaux);

    choix.shuffle();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // VERIFIER LA REPONSE
  // ============================================================

  void verifierReponse(
      Map<String, dynamic> animalUtilisateur) {

    // ----------------------------------------------------------
    // BONNE REPONSE
    // ----------------------------------------------------------

    if (animalUtilisateur['nom'] ==
        animalDemande['nom']) {

      setState(() {
        score++;
        niveau++;
      });

      afficherMessage(
        'Bravo ! 🎉',
        Colors.green,
      );

      // --------------------------------------------------------
      // SCORE = 10
      // --------------------------------------------------------

      if (score >= 10) {

        Future.delayed(
          const Duration(milliseconds: 1000),
          () {

            if (!mounted) {
              return;
            }

            afficherMessage(
              'Bravo ! Jeu terminé 🎉',
              Colors.green,
            );

            // --------------------------------------------------
            // Ici tu peux envoyer vers un autre jeu.
            //
            // Exemple :
            //
            Navigator.pushReplacement(
               context,
               MaterialPageRoute(
                 builder: (context) =>
                    const ChoisirAnimal(),
              ),
             );
            // --------------------------------------------------

          },
        );

        return;
      }

      // --------------------------------------------------------
      // NOUVELLE QUESTION
      // --------------------------------------------------------

      Future.delayed(
        const Duration(milliseconds: 800),
        () {

          if (mounted) {
            nouveauJeu();
          }

        },
      );

    }

    // ----------------------------------------------------------
    // MAUVAISE REPONSE
    // ----------------------------------------------------------

    else {

      afficherMessage(
        'Essaie encore 😊',
        Colors.orange,
      );
    }
  }

  // ============================================================
  // AFFICHER MESSAGE
  // ============================================================

  void afficherMessage(
      String message,
      Color couleur) {

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

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

        duration:
            const Duration(milliseconds: 700),
      ),
    );
  }

  // ============================================================
  // RECOMMENCER LE JEU
  // ============================================================

  void recommencer() {

    setState(() {
      score = 0;
      niveau = 1;
    });

    nouveauJeu();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFEAF6FF),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(

        title: const Text(
          'Trouve l\'animal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        elevation: 2,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            children: [

              // ==================================================
              // SCORE ET NIVEAU
              // ==================================================

              Row(

                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  // --------------------------
                  // NIVEAU
                  // --------------------------

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          offset:
                              Offset(0, 3),
                          color:
                              Colors.black12,
                        ),
                      ],
                    ),

                    child: Text(
                      'Niveau : $niveau',

                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  // --------------------------
                  // SCORE
                  // --------------------------

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          offset:
                              Offset(0, 3),
                          color:
                              Colors.black12,
                        ),
                      ],
                    ),

                    child: Text(
                      '⭐ $score / 10',

                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // QUESTION
              // ==================================================

              const Text(

                'Trouve l\'animal :',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // NOM DE L'ANIMAL
              // ==================================================

              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 5,
                      offset:
                          Offset(0, 3),
                      color:
                          Colors.black12,
                    ),
                  ],
                ),

                child: Text(

                  animalDemande['nom'],

                  style:
                      const TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // ANIMAUX
              // ==================================================

              Expanded(

                child:
                    GridView.builder(

                  itemCount:
                      choix.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 4,

                    crossAxisSpacing: 20,

                    mainAxisSpacing: 20,

                    childAspectRatio:
                        1.1,
                  ),

                  itemBuilder:
                      (context, index) {

                    final animal =
                        choix[index];

                    return GestureDetector(

                      onTap: () {

                        // Empêcher de jouer
                        // lorsque le score atteint 10.

                        if (score >= 10) {
                          return;
                        }

                        verifierReponse(
                          animal,
                        );
                      },

                      child: Container(

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),

                          border:
                              Border.all(
                            color:
                                Colors.blue.shade200,
                            width: 3,
                          ),

                          boxShadow:
                              const [
                            BoxShadow(
                              blurRadius: 5,
                              offset:
                                  Offset(0, 4),
                              color:
                                  Colors.black26,
                            ),
                          ],
                        ),

                        child:
                            Column(

                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            // ------------------
                            // EMOJI
                            // ------------------

                            Text(

                              animal['emoji'],

                              style:
                                  const TextStyle(
                                fontSize: 65,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // ------------------
                            // NOM
                            // ------------------

                           /* Text(

                              animal['nom'],

                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
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

              // ==================================================
              // BOUTON RECOMMENCER
              // ==================================================

              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton.icon(

                  onPressed:
                      recommencer,

                  icon:
                      const Icon(
                    Icons.refresh,
                  ),

                  label:
                      const Text(
                    'Recommencer',
                    style:
                        TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
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
