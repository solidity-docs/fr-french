.. _natspec:

##############
Format NatSpec
##############

Les contrats Solidity peuvent utiliser une forme spéciale de commentaires pour fournir une
documentation riche pour les fonctions, les variables de retour et autres. Cette forme spéciale est
nommé Ethereum Natural Language Specification Format (NatSpec).

.. note::

  NatSpec a été inspiré par `Doxygen <https://en.wikipedia.org/wiki/Doxygen>`_.
  Bien qu'il utilise des commentaires et des balises de style Doxygen, il n'y a aucune intention de garder une
  compatibilité stricte avec Doxygen. Veuillez examiner attentivement les balises supportées
  listées ci-dessous.

Cette documentation est segmentée en messages destinés aux développeurs et en messages destinés aux
l'utilisateur finaux. Ces messages peuvent être présentés à l'utilisateur final (l'humain)
au moment où il interagit avec le contrat (c'est-à-dire lorsqu'il signe une transaction).

Il est recommandé que les contrats Solidity soient entièrement annotés à l'aide de NatSpec pour
toutes les interfaces publiques (tout ce qui se trouve dans l'ABI).

NatSpec inclut le formatage des commentaires que l'auteur du contrat intelligent utilisera
et qui sont compris par le compilateur Solidity. Ils sont également détaillés ci-dessous
sortie du compilateur Solidity, qui extrait ces commentaires dans un format lisible par la machine.

NatSpec peut également inclure des annotations utilisées par des outils tiers. Celles-ci sont très
probablement via la balise ``@custom:<name>``, et un bon cas d'utilisation est celui des outils d'analyse et de vérification.

.. _header-doc-example:

Exemple de documentation
=====================

La documentation est insérée au-dessus de chaque ``contrat``, ``interface``,
``fonction``, et ``event`` en utilisant le format de notation Doxygen.
Une variable d'état ``public`` est équivalente à une ``function``
pour les besoins de NatSpec.

- Pour Solidity, vous pouvez choisir ``///`` pour les commentaires d'une ou plusieurs lignes
   commentaires, ou ``/**`` et se terminant par ``*/``.

- Pour Vyper, utilisez ``"""`` indenté jusqu'au contenu intérieur avec des
   commentaires. Voir la documentation de `Vyper <https://vyper.readthedocs.io/en/latest/natspec.html>`__.

L'exemple suivant montre un contrat et une fonction utilisant toutes les balises disponibles.

.. note::

  Le compilateur Solidity n'interprète les balises que si elles sont externes ou
  publiques. Vous pouvez utiliser des commentaires similaires pour vos fonctions internes
  et privées, mais elles ne seront pas interprétées.

  Ceci pourrait changer à l'avenir.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.2 < 0.9.0;

    /// @title Un simulateur pour les arbres
    /// @author Larry A. Gardner
    /// @notice Vous ne pouvez utiliser ce contrat que pour la simulation la plus élémentaire.
    /// Tous les appels de fonctions sont actuellement implémentés sans effets secondaires.
    /// @custom:experimental Il s'agit d'un contrat expérimental.
    contract Tree {
        /// @notice Calculer l'âge de l'arbre en années, arrondi à l'unité supérieure, pour les arbres vivants.
        /// @dev L'algorithme d'Alexandr N. Tetearing pourrait améliorer la précision.
        /// @param rings Le nombre de cernes de l'échantillon dendrochronologique.
        /// @return Âge en années, arrondi au chiffre supérieur pour les années partielles
        function age(uint256 rings) external virtual pure returns (uint256) {
            return rings + 1;
        }

        /// @notice Renvoie le nombre de feuilles de l'arbre.
        /// @dev Renvoie uniquement un nombre fixe.
        function leaves() external virtual pure returns(uint256) {
            return 2;
        }
    }

    contract Plant {
        function leaves() external virtual pure returns(uint256) {
            return 3;
        }
    }

    contract KumquatTree is Tree, Plant {
        function age(uint256 rings) external override pure returns (uint256) {
            return rings + 2;
        }

        /// Retourne le nombre de feuilles que possède ce type d'arbre spécifique.
        /// @inheritdoc Arbre
        function leaves() external override(Tree, Plant) pure returns(uint256) {
            return 3;
        }
    }

.. _header-tags:

Tags
====

Toutes les balises sont facultatives. Le tableau suivant explique le but de chaque
balise NatSpec et où elle peut être utilisée. Dans un cas particulier, si aucune balise n'est
utilisée, le compilateur Solidity interprétera un commentaire ``///`` ou ``/**``
de la même manière que s'il était balisé avec `@notice``.

=============== =================================================================================================== =============================
Tag                                                                                                                 Contexte
=============== =================================================================================================== =============================
``@title``      Un titre qui doit décrire le contrat/interface                                                      contract, library, interface
``@author``     Le nom de l'auteur                                                                                  contract, library, interface
``@notice``     Expliquer à un utilisateur final ce que cela fait                                                   contract, library, interface, function, public state variable, event
``@dev``        Expliquez à un développeur tout détail supplémentaire                                               contract, library, interface, function, state variable, event
``@param``      Documente un paramètre comme dans Doxygen (doit être suivi du nom du paramètre)                     function, event
``@return``     Documente les variables de retour de la fonction d'un contrat                                       function, public state variable
``@inheritdoc`` Copie toutes les étiquettes manquantes de la fonction de base (doit être suivi du nom du contrat).  function, public state variable
``@custom:...`` Balise personnalisée, la sémantique est définie par l'application.                                  everywhere
=============== =================================================================================================== =============================

Si votre fonction renvoie plusieurs valeurs, comme ``(int quotient, int remainder)``,
alors utilisez plusieurs instructions ``return`` dans le même format que les instructions ``@param``.

Les balises personnalisées commencent par ``@custom:`` et doivent être suivies d'une ou plusieurs lettres minuscules ou d'un trait d'union.
Elles ne peuvent cependant pas commencer par un trait d'union. Elles peuvent être utilisées partout et font partie de la documentation du développeur.

.. _header-dynamic:

Expressions dynamiques
-------------------

Le compilateur Solidity fera passer la documentation NatSpec de votre code source Solidity
jusqu'à la sortie JSON, comme décrit dans ce guide. Le consommateur de ce
JSON, par exemple le logiciel client de l'utilisateur final, peut le présenter directement à l'utilisateur final ou appliquer un prétraitement.

Par exemple, certains logiciels clients effectueront un rendu :

.. code:: Solidity

   /// @notice Cette fonction va multiplier `a` par 7

to the end-user as:

.. code:: text

    Cette fonction va multiplier 10 par 7

Si une fonction est appelée et que la valeur 10 est attribuée à l'entrée ``a``.

<<<<<<< HEAD
La spécification de ces expressions dynamiques n'entre pas dans le cadre de la documentation de Solidity.
et vous pouvez en savoir plus à l'adresse suivante
`le projet radspec <https://github.com/aragon/radspec>`__.

=======
>>>>>>> 75a74cd43fed972519dc15854b4183f1c266f608
.. _header-inheritance:

Notes sur l'héritage
-----------------

Les fonctions sans NatSpec hériteront automatiquement de la documentation de leur
fonction de base. Les exceptions à cette règle sont :

* Lorsque les noms des paramètres sont différents.
* Quand il y a plus d'une fonction de base.
* Quand il y a une balise explicite ``@inheritdoc`` qui spécifie quel contrat doit être utilisé pour hériter.

.. _header-output:

Sortie de documentation
====================

Lorsqu'elle est analysée par le compilateur, une documentation telle que celle de
l'exemple ci-dessus produira deux fichiers JSON différents. L'un est destiné à être
consommé par l'utilisateur final comme un avis lorsqu'une fonction est exécutée et
l'autre à être utilisé par le développeur.

Si le contrat ci-dessus est enregistré sous le nom de ``ex1.sol``, alors vous pouvez générer la
documentation en utilisant :

.. code-block:: shell

   solc --userdoc --devdoc ex1.sol

Et la sortie est ci-dessous.

.. note::
    À partir de la version 0.6.11 de Solidity, la sortie NatSpec contient également un champ ``version`` et un champ ``kind``.
    Actuellement, la ``version`` est fixée à ``1`` et le ``kind`` doit être l'un de ``user`` ou ``dev``.
    Dans le futur, il est possible que de nouvelles versions soient introduites et que les anciennes soient supprimées.

.. _header-user-doc:

Documentation pour les utilisateurs
------------------

La documentation ci-dessus produira la documentation utilisateur suivante
Fichier JSON en sortie :

.. code-block:: json

    {
      "version" : 1,
      "kind" : "user",
      "methods" :
      {
        "age(uint256)" :
        {
          "notice" : "Calculez l'âge de l'arbre en années, arrondi au chiffre supérieur, pour les arbres vivants."
        }
      },
      "notice" : "Vous pouvez utiliser ce contrat uniquement pour la simulation la plus basique"
    }

Notez que la clé permettant de trouver les méthodes est la signature canonique
de la fonction telle que définie dans le :ref:`Contrat ABI <abi_function_selector>`
et non le simple nom de la fonction.

.. _header-developer-doc:

Documentation pour les développeurs
-----------------------

Outre le fichier de documentation utilisateur, un fichier JSON
de documentation pour les développeurs doit également être produit et doit ressembler à ceci :

.. code-block:: json

    {
      "version" : 1,
      "kind" : "dev",
      "author" : "Larry A. Gardner",
      "details" : "Tous les appels de fonction sont actuellement mis en œuvre sans effets secondaires",
      "custom:experimental" : "Il s'agit d'un contrat expérimental.",
      "methods" :
      {
        "age(uint256)" :
        {
          "details" : "L'algorithme d'Alexandr N. Tetearing pourrait augmenter la précision",
          "params" :
          {
            "rings" : "Le nombre de cernes de l'échantillon dendrochronologique"
          },
          "return" : "âge en années, arrondi au chiffre supérieur pour les années incomplètes"
        }
      },
      "title" : "Un simulateur pour les arbres"
    }
