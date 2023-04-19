
.. index: ir breaking changes

.. _ir-breaking-changes:

*********************************
Changements apportés au Codegen basé sur Solidity IR
*********************************

Solidity peut générer du bytecode EVM de deux manières différentes :
Soit directement de Solidity vers les opcodes EVM ("old codegen"), soit par le biais d'une
représentation intermédiaire ("IR") dans Yul ("new codegen" ou "IR-based codegen").

Le générateur de code basé sur l'IR a été introduit dans le but non seulement de permettre
génération de code plus transparente et plus vérifiable, mais aussi
de permettre des passes d'optimisation plus puissantes qui couvrent plusieurs fonctions.

<<<<<<< HEAD
Actuellement, le générateur de code basé sur IR est toujours marqué comme expérimental,
mais il supporte toutes les fonctionnalités du langage et a fait l'objet de nombreux tests.
Nous considérons donc qu'il est presque prêt à être utilisé en production.

Vous pouvez l'activer sur la ligne de commande en utilisant ``--experimental-via-ir``.
ou avec l'option ``{"viaIR" : true}`` dans le standard-json et nous
encourageons tout le monde à l'essayer !
=======
You can enable it on the command line using ``--via-ir``
or with the option ``{"viaIR": true}`` in standard-json and we
encourage everyone to try it out!
>>>>>>> english/develop

Pour plusieurs raisons, il existe de minuscules différences sémantiques entre l'ancien
générateur de code basé sur l'IR, principalement dans des domaines
où nous ne nous attendons pas à ce que les gens se fient à ce comportement de toute façon.
Cette section met en évidence les principales différences entre l'ancien et le générateur de code basé sur la RI.

Changements uniquement sémantiques
=====================

Cette section énumère les changements qui sont uniquement sémantiques, donc potentiellement
cacher un comportement nouveau et différent dans le code existant.

<<<<<<< HEAD
- Lorsque les structures de stockage sont supprimées, chaque emplacement de stockage qui contient
  un membre de la structure est entièrement mis à zéro. Auparavant, l'espace de remplissage
  n'était pas modifié.
  Par conséquent, si l'espace de remplissage dans une structure est utilisé pour stocker des données
  (par exemple, dans le contexte d'une mise à jour de contrat), vous devez être conscient que
  que ``delete`` effacera maintenant aussi le membre ajouté (alors qu'il
  n'aurait pas été effacé dans le passé).
=======
- The order of state variable initialization has changed in case of inheritance.

  The order used to be:

  - All state variables are zero-initialized at the beginning.
  - Evaluate base constructor arguments from most derived to most base contract.
  - Initialize all state variables in the whole inheritance hierarchy from most base to most derived.
  - Run the constructor, if present, for all contracts in the linearized hierarchy from most base to most derived.

  New order:

  - All state variables are zero-initialized at the beginning.
  - Evaluate base constructor arguments from most derived to most base contract.
  - For every contract in order from most base to most derived in the linearized hierarchy:

      1. Initialize state variables.
      2. Run the constructor (if present).

  This causes differences in contracts where the initial value of a state
  variable relies on the result of the constructor in another contract:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1;

      contract A {
          uint x;
          constructor() {
              x = 42;
          }
          function f() public view returns(uint256) {
              return x;
          }
      }
      contract B is A {
          uint public y = f();
      }

  Previously, ``y`` would be set to 0. This is due to the fact that we would first initialize state variables: First, ``x`` is set to 0, and when initializing ``y``, ``f()`` would return 0 causing ``y`` to be 0 as well.
  With the new rules, ``y`` will be set to 42. We first initialize ``x`` to 0, then call A's constructor which sets ``x`` to 42. Finally, when initializing ``y``, ``f()`` returns 42 causing ``y`` to be 42.

- When storage structs are deleted, every storage slot that contains
  a member of the struct is set to zero entirely. Formerly, padding space
  was left untouched.
  Consequently, if the padding space within a struct is used to store data
  (e.g. in the context of a contract upgrade), you have to be aware that
  ``delete`` will now also clear the added member (while it wouldn't
  have been cleared in the past).
>>>>>>> english/develop

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1;

      contract C {
          struct S {
              uint64 y;
              uint64 z;
          }
          S s;
          function f() public {
              // ...
              delete s;
              // s occupe seulement les 16 premiers octets de l'emplacement de 32 octets.
              // delete écrira zéro dans l'emplacement complet
          }
      }

  Nous avons le même comportement pour la suppression implicite, par exemple lorsque le tableau de structs est raccourci.

- Les modificateurs de fonction sont mis en œuvre d'une manière légèrement différente en ce qui concerne les paramètres de fonction et les variables de retour.
  Cela a notamment un effet si le caractère générique ``_;`` est évalué plusieurs fois dans un modificateur.
  Dans l'ancien générateur de code, chaque paramètre de fonction et variable de retour a un emplacement fixe sur la pile.
  Si la fonction est exécutée plusieurs fois parce que ``_;`` est utilisé plusieurs fois ou utilisé dans une boucle, alors un
  changement de la valeur du paramètre de fonction ou de la variable de retour est visible lors de la prochaine exécution de la fonction.
  Le nouveau générateur de code implémente les modificateurs à l'aide de fonctions réelles et transmet les paramètres de fonction.
  Cela signifie que plusieurs évaluations du corps d'une fonction obtiendront les mêmes valeurs pour les paramètres,
  et l'effet sur les variables de retour est qu'elles sont réinitialisées à leur valeur par défaut (zéro) à chaque exécution.

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.0;
      contract C {
          function f(uint a) public pure mod() returns (uint r) {
              r = a++;
          }
          modifier mod() { _; _; }
      }

<<<<<<< HEAD
  Si vous exécutez ``f(0)`` dans l'ancien générateur de code, il retournera ``2``, alors
  qu'il retournera ``1`` en utilisant le nouveau générateur de code.
=======
  If you execute ``f(0)`` in the old code generator, it will return ``1``, while
  it will return ``0`` when using the new code generator.
>>>>>>> english/develop

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1 <0.9.0;

      contract C {
          bool active = true;
          modifier mod()
          {
              _;
              active = false;
              _;
          }
          function foo() external mod() returns (uint ret)
          {
              if (active)
                  ret = 1; // Same as ``return 1``
          }
      }

  La fonction ``C.foo()`` renvoie les valeurs suivantes :

  - Ancien générateur de code : ``1`` comme variable de retour est initialisé à ``0`` une seule fois avant la première évaluation ``_;``
    et ensuite écrasée par la variable ``return 1;``. Elle n'est pas initialisée à nouveau pour la seconde
    évaluation et ``foo()`` ne l'assigne pas explicitement non plus (à cause de ``active == false``), il garde donc
    sa première valeur.
  - Nouveau générateur de code : ``0`` car tous les paramètres, y compris les paramètres de retour, seront ré-initialisés avant
    chaque évaluation ``_;``.

<<<<<<< HEAD
- L'ordre d'initialisation des contrats a changé en cas d'héritage.

  L'ordre était auparavant le suivant :

  - Toutes les variables d'état sont initialisées à zéro au début.
  - Évaluer les arguments du constructeur de base du contrat le plus dérivé au contrat le plus basique.
  - Initialiser toutes les variables d'état dans toute la hiérarchie d'héritage, de la plus basique à la plus dérivée.
  - Exécuter le constructeur, s'il est présent, pour tous les contrats dans la hiérarchie linéarisée du plus bas au plus dérivé.

  Nouvel ordre :

  - Toutes les variables d'état sont initialisées à zéro au début.
  - Évaluer les arguments du constructeur de base du contrat le plus dérivé au contrat le plus basique.
  - Pour chaque contrat dans l'ordre du plus basique au plus dérivé dans la hiérarchie linéarisée, exécuter :

      1. Si elles sont présentes à la déclaration, les valeurs initiales sont assignées aux variables d'état.
      2. Le constructeur, s'il est présent.

Cela entraîne des différences dans certains contrats, par exemple :

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1;

      contract A {
          uint x;
          constructor() {
              x = 42;
          }
          function f() public view returns(uint256) {
              return x;
          }
      }
      contract B is A {
          uint public y = f();
      }

  Auparavant, ``y`` était fixé à 0. Cela est dû au fait que nous initialisions d'abord les variables d'état : D'abord, ``x`` est mis à 0, et lors de l'initialisation de ``y``, ``f()`` renvoie 0, ce qui fait que ``y`` est également 0.
  Avec les nouvelles règles, ``y`' sera fixé à 42. Nous commençons par initialiser ``x`` à 0, puis nous appelons le constructeur de A qui fixe ``x`` à 42. Enfin, lors de l'initialisation de ``y``, ``f()`` renvoie 42, ce qui fait que ``y`` est 42.

- La copie de tableaux d'"octets" de la mémoire vers le stockage est implémentée d'une manière différente.
  L'ancien générateur de code copie toujours des mots entiers, alors que le nouveau coupe le tableau d'octets
  après sa fin. L'ancien comportement peut conduire à ce que des données sales soient copiées
  après la fin du tableau (mais toujours dans le même emplacement de stockage).
  Cela entraîne des différences dans certains contrats, par exemple :

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;

      contract C {
          bytes x;
          function f() public returns (uint _r) {
              bytes memory m = "tmp";
              assembly {
                  mstore(m, 8)
                  mstore(add(m, 32), "deadbeef15dead")
              }
              x = m;
              assembly {
                  _r := sload(x.slot)
              }
          }
      }

    Auparavant, ``f()`` retournait ``0x6465616462656566313564656164000000000000000000000000000000000010``
  (il a une longueur correcte, et les 8 premiers éléments sont corrects, mais ensuite il contient des données sales qui ont été définies via l'assemblage).
  Maintenant, il renvoie ``0x6465616462656566000000000000000000000000000000000000000000000010`` (il a une
  longueur correcte, et des éléments corrects, mais il ne contient pas de données superflues).

=======
>>>>>>> english/develop
  .. index:: ! evaluation order; expression

- Pour l'ancien générateur de code, l'ordre d'évaluation des expressions n'est pas spécifié.
  Pour le nouveau générateur de code, nous essayons d'évaluer dans l'ordre de la source (de gauche à droite), mais nous ne le garantissons pas.
  Cela peut conduire à des différences sémantiques.

  Par exemple :

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function preincr_u8(uint8 a) public pure returns (uint8) {
              return ++a + a;
          }
      }

  La fonction ``preincr_u8(1)`` retourne les valeurs suivantes :

<<<<<<< HEAD
  - Ancien générateur de code : 3 (``1 + 2``) mais la valeur de retour n'est pas spécifiée en général.
  - Nouveau générateur de code : 4 (``2 + 2``) mais la valeur de retour n'est pas garantie
=======
  - Old code generator: ``3`` (``1 + 2``) but the return value is unspecified in general
  - New code generator: ``4`` (``2 + 2``) but the return value is not guaranteed
>>>>>>> english/develop

  .. index:: ! evaluation order; function arguments

  D'autre part, les expressions des arguments de fonction sont évaluées dans le même ordre
  par les deux générateurs de code, à l'exception des fonctions globales ``addmod`` et ``mulmod``.
  Par exemple :

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function add(uint8 a, uint8 b) public pure returns (uint8) {
              return a + b;
          }
          function g(uint8 a, uint8 b) public pure returns (uint8) {
              return add(++a + ++b, a + b);
          }
      }

  La fonction ``g(1, 2)`` renvoie les valeurs suivantes :

  - Ancien générateur de code : ``10`` (``add(2 + 3, 2 + 3)``) mais la valeur de retour n'est pas spécifiée en général.
  - Nouveau générateur de code : ``10`` mais la valeur de retour n'est pas garantie

  Les arguments des fonctions globales ``addmod`` et ``mulmod`` sont évalués de droite à gauche par l'ancien générateur de code
  et de gauche à droite par le nouveau générateur de code.
  Par exemple :

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function f() public pure returns (uint256 aMod, uint256 mMod) {
              uint256 x = 3;
              // Old code gen: add/mulmod(5, 4, 3)
              // New code gen: add/mulmod(4, 5, 5)
              aMod = addmod(++x, ++x, x);
              mMod = mulmod(++x, ++x, x);
          }
      }

  La fonction ``f()`` renvoie les valeurs suivantes :

  - Ancien générateur de code : " aMod = 0 " et " mMod = 2 ".
  - Nouveau générateur de code : " aMod = 4 " et " mMod = 0 ".

- Le nouveau générateur de code impose une limite dure de ``type(uint64).max``
  (``0xffffffffffffffff``) pour le pointeur de mémoire libre. Les allocations qui
  augmenteraient sa valeur au-delà de cette limite. L'ancien générateur de code n'a pas
  n'a pas cette limite.

  Par exemple :

  .. code-block:: solidity
      :force:

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >0.8.0;
      contract C {
          function f() public {
              uint[] memory arr;
              // allocation size: 576460752303423481
              // assumes freeMemPtr points to 0x80 initially
              uint solYulMaxAllocationBeforeMemPtrOverflow = (type(uint64).max - 0x80 - 31) / 32;
              // freeMemPtr overflows UINT64_MAX
              arr = new uint[](solYulMaxAllocationBeforeMemPtrOverflow);
          }
      }

<<<<<<< HEAD
  La fonction `f()` se comporte comme suit :
=======
  The function ``f()`` behaves as follows:
>>>>>>> english/develop

  - Ancien générateur de code : manque de gaz lors de la mise à zéro du contenu du tableau après la grande allocation de mémoire.
  - Nouveau générateur de code : retour en arrière en raison d'un débordement du pointeur de mémoire libre (ne tombe pas en panne sèche).


Internes
=========

Pointeurs de fonctions internes
--------------------------

.. index:: function pointers

L'ancien générateur de code utilise des décalages de code ou des balises pour les valeurs des pointeurs de fonctions internes.
Ceci est particulièrement compliqué car ces offsets sont différents au moment de la construction et après le déploiement et les
valeurs peuvent traverser cette frontière via le stockage.
Pour cette raison, les deux offsets sont codés au moment de la construction dans la même valeur (dans différents octets).

Dans le nouveau générateur de code, les pointeurs de fonction utilisent des ID internes qui sont alloués en séquence. Comme
les appels via des pointeurs de fonction doivent toujours utiliser une fonction de distribution interne qui utilise l'instruction ``switch`` pour sélectionner
la bonne fonction.

L'ID ``0`` est réservé aux pointeurs de fonction non initialisés qui provoquent une panique dans la fonction de répartition lorsqu'ils sont appelés.

Dans l'ancien générateur de code, les pointeurs de fonctions internes sont initialisés avec une fonction spéciale qui provoque toujours une panique.
Cela provoque une écriture en mémoire au moment de la construction pour les pointeurs de fonctions internes en mémoire.

Nettoyage
-------

.. index:: cleanup, dirty bits

L'ancien générateur de code n'effectue le nettoyage qu'avant une opération dont le résultat pourrait être affecté par les valeurs des bits sales.
Le nouveau générateur de code effectue le nettoyage après toute opération qui peut entraîner des bits sales.
L'espoir est que l'optimiseur sera suffisamment puissant pour éliminer les opérations de nettoyage redondantes.

Par exemple :

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;
    contract C {
        function f(uint8 a) public pure returns (uint r1, uint r2)
        {
            a = ~a;
            assembly {
                r1 := a
            }
            r2 = a;
        }
    }

La fonction ``f(1)`` renvoie les valeurs suivantes :

- Ancien générateur de code: (``fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe``, ``00000000000000000000000000000000000000000000000000000000000000fe``)
- Nouveau générateur de codes: (``00000000000000000000000000000000000000000000000000000000000000fe``, ``00000000000000000000000000000000000000000000000000000000000000fe``)

<<<<<<< HEAD
Notez que, contrairement au nouveau générateur de code, l'ancien générateur de code n'effectue pas de nettoyage après l'affectation bit-non (``_a = ~_a``).
Il en résulte que des valeurs différentes sont assignées (dans le bloc d'assemblage en ligne) à la valeur de retour ``_r1`` entre l'ancien et le nouveau générateur de code.
Cependant, les deux générateurs de code effectuent un nettoyage avant que la nouvelle valeur de ``_a`` soit assignée à ``_r2``.
=======
Note that, unlike the new code generator, the old code generator does not perform a cleanup after the bit-not assignment (``a = ~a``).
This results in different values being assigned (within the inline assembly block) to return value ``r1`` between the old and new code generators.
However, both code generators perform a cleanup before the new value of ``a`` is assigned to ``r2``.
>>>>>>> english/develop
