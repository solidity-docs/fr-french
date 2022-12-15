.. _formal_verification:

##################################
SMTChecker et vérification formelle
##################################

En utilisant la vérification formelle, il est possible d'effectuer une preuve mathématique
automatisée que votre code source répond à une certaine spécification formelle.
La spécification est toujours formelle (tout comme le code source), mais généralement beaucoup
plus simple.

Notez que la vérification formelle elle-même ne peut vous aider qu'à comprendre la
différence entre ce que vous avez fait (la spécification) et la manière dont vous l'avez fait
(l'implémentation réelle). Vous devez toujours vérifier si la spécification
correspond à ce que vous vouliez et que vous n'avez pas manqué d'effets involontaires.

Solidity met en œuvre une approche de vérification formelle basée sur
`SMT (Satisfiability Modulo Theories) <https://en.wikipedia.org/wiki/Satisfiability_modulo_theories>`_ et la
`Horn <https://en.wikipedia.org/wiki/Horn-satisfiability>`_ de résolution.
Le module SMTChecker essaie automatiquement de prouver que le code satisfait à la
spécification donnée par les déclarations ``require`` et ``assert``. C'est-à-dire qu'il considère
les déclarations ``require`` comme des hypothèses et essaie de prouver que les
conditions contenues dans les déclarations ``assert`` sont toujours vraies.  Si un échec d'assertion est
trouvé, un contre-exemple peut être donné à l'utilisateur montrant comment l'assertion peut
être violée. Si aucun avertissement n'est donné par le SMTChecker pour une propriété,
cela signifie que la propriété est sûre.

Les autres cibles de vérification que le SMTChecker vérifie au moment de la compilation sont :

- Les débordements et les sous-écoulements arithmétiques.
- La division par zéro.
- Conditions triviales et code inaccessible.
- Extraction d'un tableau vide.
- Accès à un index hors limites.
- Fonds insuffisants pour un transfert.

Toutes les cibles ci-dessus sont automatiquement vérifiées par défaut si tous les moteurs sont
activés, sauf underflow et overflow pour Solidity >=0.8.7.

Les avertissements potentiels que le SMTChecker rapporte sont :

- ``<failing  property> happens here.``. Cela signifie que le SMTChecker a prouvé qu'une certaine propriété est défaillante. Un contre-exemple peut être donné, cependant dans des situations complexes, il peut aussi ne pas montrer de contre-exemple. Ce résultat peut aussi être un faux positif dans certains cas, lorsque l'encodage SMT ajoute des abstractions pour le code Solidity qui est difficile ou impossible à exprimer.
- ``<failing  property> might happen here``. Cela signifie que le solveur n'a pas pu prouver l'un ou l'autre cas dans le délai imparti. Comme le résultat est inconnu, le SMTChecker rapporte l'échec potentiel pour la solidité. Cela peut être résolu en augmentant le délai d'interrogation, mais le problème peut aussi être simplement trop difficile à résoudre pour le moteur.

Pour activer le SMTChecker, vous devez sélectionner :ref:`quel moteur doit fonctionner<smtchecker_engines>`,
où la valeur par défaut est aucun moteur. La sélection du moteur active le SMTChecker sur tous les fichiers.

.. note::

    Avant Solidity 0.8.4, la manière par défaut d'activer le SMTChecker était via
    ``pragma experimental SMTChecker;`` et seuls les contrats contenant le pragma
    seraient analysés. Ce pragme a été déprécié, et bien qu'il active toujours le
    qu'il active toujours le SMTChecker pour une compatibilité ascendante, il sera supprimé
    dans Solidity 0.9.0. Notez également que maintenant l'utilisation du pragma même dans un seul fichier
    active le SMTChecker pour tous les fichiers.

.. note::

    L'absence d'avertissement pour une cible de vérification représente une
    preuve mathématique incontestable de l'exactitude, en supposant l'absence de bogues dans le SMTChecker et
    le solveur sous-jacent. Gardez à l'esprit que ces problèmes sont
    *très difficiles* et parfois *impossibles* à résoudre automatiquement dans le
    cas général. Par conséquent, plusieurs propriétés pourraient ne pas être résolues ou pourraient
    conduire à des faux positifs pour les grands contrats. Chaque propriété prouvée doit être
    être considérée comme une réalisation importante. Pour les utilisateurs avancés, voir :ref:`SMTChecker Tuning <smtchecker_options>`
    pour apprendre quelques options qui pourraient aider à prouver des propriétés
    complexes.

********
Tutoriel
********

Débordement
========

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint x_, uint y_) internal pure returns (uint) {
            return x_ + y_;
        }

        constructor(uint x_, uint y_) {
            (x, y) = (x_, y_);
        }

        function stateAdd() public view returns (uint) {
            return add(x, y);
        }
    }

Le contrat ci-dessus montre un exemple de vérification de débordement (overflow).
Le SMTChecker ne vérifie pas l'underflow et l'overflow par défaut pour Solidity >=0.8.7,
donc nous devons utiliser l'option de ligne de commande ``--model-checker-targets "underflow,overflow"``
ou l'option JSON ``settings.modelChecker.targets = ["underflow", "overflow"]``.
Voir :ref:`cette section pour la configuration des cibles<smtchecker_targets>`.
Ici, il signale ce qui suit :

.. code-block:: text

    Warning: CHC: Overflow (resulting value larger than 2**256 - 1) happens here.
    Counterexample:
    x = 1, y = 115792089237316195423570985008687907853269984665640564039457584007913129639935
     = 0

    Transaction trace:
    Overflow.constructor(1, 115792089237316195423570985008687907853269984665640564039457584007913129639935)
    State: x = 1, y = 115792089237316195423570985008687907853269984665640564039457584007913129639935
    Overflow.stateAdd()
        Overflow.add(1, 115792089237316195423570985008687907853269984665640564039457584007913129639935) -- internal call
     --> o.sol:9:20:
      |
    9 |             return x_ + y_;
      |                    ^^^^^^^

Si nous ajoutons des déclarations ``require`` qui filtrent les cas de débordement,
le SMTChecker prouve qu'aucun débordement n'est atteignable (en ne signalant pas d'avertissement) :

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint x_, uint y_) internal pure returns (uint) {
            return x_ + y_;
        }

        constructor(uint x_, uint y_) {
            (x, y) = (x_, y_);
        }

        function stateAdd() public view returns (uint) {
            require(x < type(uint128).max);
            require(y < type(uint128).max);
            return add(x, y);
        }
    }


Affirmer
======

Une assertion représente un invariant dans votre code : une propriété qui doit être vraie
*pour toutes les opérations, y compris toutes les valeurs d'entrée et de stockage*, sinon il y a un bug.

<<<<<<< HEAD
Le code ci-dessous définit une fonction ``f`` qui garantit l'absence de débordement.
La fonction ``inv`` définit la spécification que ``f`` est monotone et croissante :
pour chaque paire possible ``(_a, _b)``, si ``_b > _a`` alors ``f(_b) > f(_a)``.
Puisque ``f`` est effectivement monotone et croissante, le SMTChecker prouve que notre
propriété est correcte. Nous vous encourageons à jouer avec la propriété et la définition de la fonction
pour voir les résultats qui en découlent !
=======
The code below defines a function ``f`` that guarantees no overflow.
Function ``inv`` defines the specification that ``f`` is monotonically increasing:
for every possible pair ``(a, b)``, if ``b > a`` then ``f(b) > f(a)``.
Since ``f`` is indeed monotonically increasing, the SMTChecker proves that our
property is correct. You are encouraged to play with the property and the function
definition to see what results come out!
>>>>>>> 37e935f02546c83384ca6db9dd4d864bf533d004

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Monotonic {
        function f(uint x) internal pure returns (uint) {
            require(x < type(uint128).max);
            return x * 42;
        }

        function inv(uint a, uint b) public pure {
            require(b > a);
            assert(f(b) > f(a));
        }
    }

Nous pouvons également ajouter des assertions à l'intérieur des boucles pour vérifier des propriétés plus complexes.
Le code suivant recherche l'élément maximum d'un tableau non restreint de
nombres, et affirme la propriété selon laquelle l'élément trouvé doit être supérieur ou
égal à chaque élément du tableau.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory a) public pure returns (uint) {
            uint m = 0;
            for (uint i = 0; i < a.length; ++i)
                if (a[i] > m)
                    m = a[i];

            for (uint i = 0; i < a.length; ++i)
                assert(m >= a[i]);

            return m;
        }
    }

Notez que dans cet exemple, le SMTChecker va automatiquement essayer de prouver trois propriétés :

1. ``++i`` dans la première boucle ne déborde pas.
2. ``++i`` dans la deuxième boucle ne déborde pas.
3. L'assertion est toujours vraie.

.. note::

    Les propriétés impliquent des boucles, ce qui rend l'exercice *beaucoup plus difficile* que les
    exemples précédents, alors faites attention aux boucles !

Toutes les propriétés sont correctement prouvées sûres. N'hésitez pas à modifier
et/ou d'ajouter des restrictions sur le tableau pour obtenir des résultats différents.
Par exemple, en changeant le code en

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory a) public pure returns (uint) {
            require(a.length >= 5);
            uint m = 0;
            for (uint i = 0; i < a.length; ++i)
                if (a[i] > m)
                    m = a[i];

            for (uint i = 0; i < a.length; ++i)
                assert(m > a[i]);

            return m;
        }
    }

nous donne :

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:

    a = [0, 0, 0, 0, 0]
     = 0

    Transaction trace:
    Test.constructor()
    Test.max([0, 0, 0, 0, 0])
      --> max.sol:14:4:
       |
    14 |            assert(m > a[i]);


Propriétés de l'État
================

Jusqu'à présent, les exemples ont seulement démontré l'utilisation du SMTChecker sur du code pur,
prouvant des propriétés sur des opérations ou des algorithmes spécifiques.
Un type commun de propriétés dans les contrats intelligents sont les propriétés qui impliquent
l'état du contrat. Plusieurs transactions peuvent être nécessaires pour faire
échouer pour une telle propriété.

À titre d'exemple, considérons une grille 2D où les deux axes ont des coordonnées dans la plage (-2^128, 2^128 - 1).
Plaçons un robot à la position (0, 0). Le robot ne peut se déplacer qu'en diagonale, un pas à la fois,
et ne peut pas se déplacer en dehors de la grille. La machine à états du robot peut être représentée par le contrat intelligent
ci-dessous.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Robot {
        int x = 0;
        int y = 0;

        modifier wall {
            require(x > type(int128).min && x < type(int128).max);
            require(y > type(int128).min && y < type(int128).max);
            _;
        }

        function moveLeftUp() wall public {
            --x;
            ++y;
        }

        function moveLeftDown() wall public {
            --x;
            --y;
        }

        function moveRightUp() wall public {
            ++x;
            ++y;
        }

        function moveRightDown() wall public {
            ++x;
            --y;
        }

        function inv() public view {
            assert((x + y) % 2 == 0);
        }
    }

La fonction ``inv`` représente un invariant de la machine à états selon lequel ``x + y`` doit être pair.
Le SMTChecker parvient à prouver que quelque soit le nombre de commandes que l'on donne au
robot, même s'ils sont infinis, l'invariant ne peut *jamais* échouer.
Le lecteur intéressé peut vouloir prouver ce fait manuellement aussi.
Indice : cet invariant est inductif.

Nous pouvons aussi tromper le SMTChecker pour qu'il nous donne un chemin vers une
position que nous pensons être atteignable. Nous pouvons ajouter la propriété que (2, 4) est *non*
accessible, en ajoutant la fonction suivante.

.. code-block:: Solidity

    function reach_2_4() public view {
        assert(!(x == 2 && y == 4));
    }

Cette propriété est fausse, et tout en prouvant que la propriété est fausse,
le SMTChecker nous dit exactement *comment* atteindre (2, 4) :

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:
    x = 2, y = 4

    Transaction trace:
    Robot.constructor()
    State: x = 0, y = 0
    Robot.moveLeftUp()
    State: x = (- 1), y = 1
    Robot.moveRightUp()
    State: x = 0, y = 2
    Robot.moveRightUp()
    State: x = 1, y = 3
    Robot.moveRightUp()
    State: x = 2, y = 4
    Robot.reach_2_4()
      --> r.sol:35:4:
       |
    35 |            assert(!(x == 2 && y == 4));
       |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^

Notez que le chemin ci-dessus n'est pas nécessairement déterministe, car il y a
d'autres chemins qui pourraient atteindre (2, 4). Le choix du chemin affiché
peut changer en fonction du solveur utilisé, de sa version, ou simplement au hasard.

Appels externes et réentrance
=============================

Chaque appel externe est traité comme un appel à un code inconnu par le SMTChecker.
Le raisonnement derrière cela est que même si le code du contrat appelé
est disponible au moment de la compilation, il n'y a aucune garantie que le contrat déployé
sera bien le même que le contrat d'où provient l'interface au moment de la compilation.

Dans certains cas, il est possible de déduire automatiquement des propriétés sur les
variables d'état qui restent vraies même si le code appelé de l'extérieur peut faire
n'importe quoi, y compris réintroduire le contrat de l'appelant.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    interface Unknown {
        function run() external;
    }

    contract Mutex {
        uint x;
        bool lock;

        Unknown immutable unknown;

        constructor(Unknown u) {
            require(address(u) != address(0));
            unknown = u;
        }

        modifier mutex {
            require(!lock);
            lock = true;
            _;
            lock = false;
        }

        function set(uint x_) mutex public {
            x = x_;
        }

        function run() mutex public {
            uint xPre = x;
            unknown.run();
            assert(xPre == x);
        }
    }

L'exemple ci-dessus montre un contrat qui utilise un drapeau mutex pour interdire la réentrance.
Le solveur est capable de déduire que lorsque ``unknown.run()`` est appelé, le contrat
est déjà "verrouillé", donc il ne serait pas possible de changer la valeur de ``x``,
indépendamment de ce que fait le code appelé inconnu.

Si nous "oublions" d'utiliser le modificateur ``mutex`` sur la fonction ``set``, le
SMTChecker est capable de synthétiser le comportement du code appelé de manière externe
que l'assertion échoue :

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:
    x = 1, lock = true, unknown = 1

    Transaction trace:
    Mutex.constructor(1)
    State: x = 0, lock = false, unknown = 1
    Mutex.run()
        unknown.run() -- untrusted external call, synthesized as:
            Mutex.set(1) -- reentrant call
      --> m.sol:32:3:
       |
    32 | 		assert(xPre == x);
       | 		^^^^^^^^^^^^^^^^^


.. _smtchecker_options:

*****************************
Options et réglages de SMTChecker
*****************************

Délai d'attente
=======

Le SMTChecker utilise une limite de ressource codée en dur (``rlimit``) choisie par solveur,
qui n'est pas précisément liée au temps. Nous avons choisi l'option ``rlimit`` comme défaut
car elle donne plus de garanties de déterminisme que le temps à l'intérieur du solveur.

Cette option se traduit approximativement par "un délai de quelques secondes" par requête. Bien sûr de nombreuses propriétés
sont très complexes et nécessitent beaucoup de temps pour être résolus, où le déterminisme n'a pas d'importance.
Si le SMTChecker ne parvient pas à résoudre les propriétés du contrat avec le ``rlimit`` par défaut,
un timeout peut être donné en millisecondes via l'option CLI ``--model-checker-timeout <time>`` ou
l'option JSON ``settings.modelChecker.timeout=<time>``, où 0 signifie pas de délai d'attente.

.. _smtchecker_targets:

Objectifs de vérification
====================

Les types de cibles de vérification créées par le SMTChecker peuvent aussi être
personnalisés via l'option CLI ``--model-checker-target <targets>`` ou l'option JSON ``settings.modelChecker.targets=<targets>``.
Dans le cas de l'interface CLI, ``<targets>`` est une liste non séparée par des virgules
d'une ou plusieurs cibles de vérification, et un tableau d'une ou plusieurs cibles comme
l'entrée JSON.
Les mots-clés qui représentent les cibles sont :

- Assertions : ``assert``.
- Débordement arithmétique : ``underflow``.
- Débordement arithmétique : ``overflow``.
- La division par zéro : ``divByZero``.
- Conditions triviales et code inaccessible : ``constantCondition``.
- Extraire un tableau vide : ``popEmptyArray``.
- Accès hors limites aux tableaux et aux index d'octets fixes : ``outOfBounds``.
- Fonds insuffisants pour un transfert : ``balance``.
- Tous ces éléments : ``défaut`` (CLI uniquement).

Un sous-ensemble commun de cibles pourrait être, par exemple :
``--model-checker-targets assert,overflow``.

Toutes les cibles sont vérifiées par défaut, sauf underflow et overflow pour Solidity >=0.8.7.

Il n'y a pas d'heuristique précise sur comment et quand diviser les cibles de vérification,
mais cela peut être utile, surtout lorsqu'il s'agit de grands contrats.

Cibles non vérifiées
================

S'il existe des cibles non vérifiées, le SMTChecker émet un avertissement indiquant
combien de cibles non vérifiées il y a. Si l'utilisateur souhaite voir toutes les
cibles non corrigées, l'option CLI ``--model-checker-show-unproved`` et
l'option JSON ``settings.modelChecker.showUnproved = true`` peuvent être utilisées.

Contrats vérifiés
==================

Par défaut, tous les contrats déployables dans les sources données sont analysés séparément en tant que
celui qui sera déployé. Cela signifie que si un contrat a de nombreux
parents d'héritage direct et indirect, ils seront tous analysés séparément,
même si seul le plus dérivé sera accessible directement sur la blockchain.
Cela entraîne une charge inutile pour le SMTChecker et le solveur. Pour aider les
cas comme celui-ci, les utilisateurs peuvent spécifier quels contrats doivent être analysés comme le
déployé. Les contrats parents sont bien sûr toujours analysés, mais seulement
dans le contexte du contrat le plus dérivé, ce qui réduit la complexité de
l'encodage et des requêtes générées. Notez que les contrats abstraits ne sont par défaut
pas analysés comme les plus dérivés par le SMTChecker.

Les contrats choisis peuvent être donnés via une liste séparée par des virgules (les espaces blancs ne sont pas
autorisés) de paires <source>:<contrat> dans le CLI :
``--model-checker-contracts "<source1.sol:contract1>,<source2.sol:contract2>,<source2.sol:contract3>"``,
et via l'objet ``settings.modelChecker.contracts`` dans le :ref:`JSON input<compiler-api>`,
qui a la forme suivante :

.. code-block:: json

    "contracts": {
        "source1.sol": ["contract1"],
        "source2.sol": ["contract2", "contract3"]
    }

Invariants inductifs rapportés et inférés
======================================

Pour les propriétés qui ont été prouvées sûres avec le moteur CHC,
le SMTChecker peut récupérer les invariants inductifs qui ont été inférés par le solveur de Horn
dans le cadre de la preuve.
Actuellement, deux types d'invariants peuvent être rapportés à l'utilisateur :

- Invariants de contrat : ce sont des propriétés sur les variables d'état du contrat
  qui sont vraies avant et après chaque transaction possible que le contrat peut exécuter.
  Par exemple, ``x >= y``, où ``x`` et ``y`` sont les variables d'état d'un contrat.
- Propriétés de réentraînement : elles représentent le comportement du contrat
  en présence d'appels externes à du code inconnu. Ces propriétés peuvent exprimer une relation
  entre la valeur des variables d'état avant et après l'appel externe, où l'appel externe est libre de faire n'importe quoi,
  y compris d'effectuer des appels réentrants au contrat analysé.
  Les variables amorcées représentent les valeurs des variables d'état après ledit appel externe. Exemple : ``lock -> x = x'``.

L'utilisateur peut choisir le type d'invariants à rapporter en utilisant l'option CLI ``--model-checker-invariants "contract,reentrancy"`` ou comme un tableau dans le champ ``settings.modelChecker.invariants`` dans l'entrée :ref:`JSON<compiler-api>`.
Par défaut, le SMTChecker ne rapporte pas les invariants.

Division et modulo avec des variables muettes
========================================

Spacer, le solveur de Corne par défaut utilisé par le SMTChecker, n'aime souvent pas les opérations de division et de
modulation dans les règles de Horn. Pour cette raison, par défaut,
les opérations de division et de modulo de Solidity sont codées en utilisant la contrainte suivante
``a = b * d + m`` où ``d = a / b`` et ``m = a % b``.
Cependant, d'autres solveurs, comme Eldarica, préfèrent les opérations syntaxiquement précises.
L'indicateur de ligne de commande ``--model-checker-div-mod-no-slacks`` et l'option JSON
``settings.modelChecker.divModNoSlacks`` peuvent être utilisés pour basculer le codage
en fonction des préférences du solveur utilisé.

Abstraction des fonctions Natspec
============================

Certaines fonctions, y compris les méthodes mathématiques courantes telles que ``pow``
et ``sqrt`` peuvent être trop complexes pour être analysées de manière entièrement automatisée.
Ces fonctions peuvent être annotées avec des balises Natspec qui indiquent au contrôleur
SMTChecker que ces fonctions doivent être abstraites. Cela signifie que
de la fonction n'est pas utilisé et que, lorsqu'elle est appelée, la fonction :

- retournera une valeur non déterministe, et soit gardera les variables d'état inchangées si la fonction abstraite est view/pure, soit fixera également les variables d'état à des valeurs non déterministes dans le cas contraire. Ceci peut être utilisé via l'annotation ``/// @custom:smtchecker abstract-function-nondet``.
- Agir comme une fonction non interprétée. Cela signifie que la sémantique de la fonction (donnée par le corps) est ignorée, et que la seule propriété de cette fonction est que, pour une même entrée, elle garantit la même sortie. Ceci est actuellement en cours de développement et sera disponible via l'annotation ``/// @custom:smtchecker abstract-function-uf``.

.. _smtchecker_engines:

Moteurs de vérification de modèles réduits
======================

Le module SMTChecker implémente deux moteurs de raisonnement différents, un Bounded
Model Checker (BMC) et un système de Clauses de Corne Contraintes (CHC).  Les deux
moteurs sont actuellement en cours de développement, et ont des caractéristiques différentes.
Les moteurs sont indépendants et chaque avertissement de propriété indique de quel moteur
il provient. Notez que tous les exemples ci-dessus avec des contre-exemples ont été
rapportés par CHC, le moteur le plus puissant.

Par défaut, les deux moteurs sont utilisés, CHC s'exécute en premier, et chaque propriété qui
n'a pas été prouvée est transmise à BMC. Vous pouvez choisir un moteur spécifique via l'interface CLI
``--model-checker-engine {all,bmc,chc,none}`` ou l'option JSON
``settings.modelChecker.engine={all,bmc,chc,none}``.

Contrôleur de modèles délimités (BMC)
---------------------------

Le moteur BMC analyse les fonctions de manière isolée, c'est-à-dire qu'il ne prend pas en compte le
comportement global du contrat sur plusieurs transactions lorsqu'il analyse chaque fonction.
Les boucles sont également ignorées dans ce moteur pour le moment.
Les appels de fonctions internes sont inlined tant qu'ils ne sont pas récursifs, directement
ou indirectement. Les appels de fonctions externes sont inlined si possible. Connaissance
qui est potentiellement affectée par la réentrance est effacée.

Les caractéristiques ci-dessus font que la BMC est susceptible de signaler des faux positifs,
mais il est également léger et devrait être capable de trouver rapidement de petits bogues locaux.

Clauses de corne contraintes (CHC)
------------------------------

Le graphique de flux de contrôle (CFG) d'un contrat est modélisé comme un système de
clauses de Horn, où le cycle de vie du contrat est représenté par une boucle
qui peut visiter chaque fonction publique/externe de manière non-déterministe. De cette façon,
le comportement de l'ensemble du contrat sur un nombre illimité de transactions
est pris en compte lors de l'analyse de toute fonction. Les boucles sont entièrement prises en charge
par ce moteur. Les appels de fonctions internes sont pris en charge, et les appels de fonctions
externes supposent que le code appelé est inconnu et peut faire n'importe quoi.

Le moteur CHC est beaucoup plus puissant que BMC en termes de ce qu'il peut prouver,
et peut nécessiter plus de ressources informatiques.

Solveurs SMT et Horn
====================

Les deux moteurs détaillés ci-dessus utilisent des prouveurs de théorèmes automatisés comme leur
logique. BMC utilise un solveur SMT, tandis que CHC utilise un solveur de Horn. Souvent le
même outil peut agir comme les deux, comme on le voit dans `z3 <https://github.com/Z3Prover/z3>`_,
qui est principalement un solveur SMT et qui rend `Spacer
<https://spacer.bitbucket.io/>`_ disponible comme solveur de Horn, et `Eldarica
<https://github.com/uuverifiers/eldarica>`_ qui fait les deux.

<<<<<<< HEAD
L'utilisateur peut choisir quels solveurs doivent être utilisés, s'ils sont disponibles, via l'option CLI
``--model-checker-solvers {all,cvc4,smtlib2,z3}`` ou l'option JSON
``settings.modelChecker.solvers=[smtlib2,z3]``, où :

- ``cvc4`` n'est disponible que si le binaire ``solc`` est compilé avec. Seul BMC utilise ``cvc4``.
- ``smtlib2`` produit des requêtes SMT/Horn dans le format `smtlib2 <http://smtlib.cs.uiowa.edu/>`_.
  Celles-ci peuvent être utilisées avec le `mécanisme de rappel du compilateur <https://github.com/ethereum/solc-js>`_ de sorte que
  tout solveur binaire du système peut être employé pour renvoyer de manière synchrone les résultats des requêtes au compilateur.
  C'est actuellement la seule façon d'utiliser Eldarica, par exemple, puisqu'il ne dispose pas d'une API C++.
  Cela peut être utilisé à la fois par BMC et CHC, selon les solveurs appelés.
- ``z3`` est disponible

  - si ``solc`` est compilé avec lui ;
  - si une bibliothèque dynamique ``z3`` de version 4.8.x est installée dans un système Linux (à partir de Solidity 0.7.6) ;
  - statiquement dans ``soljson.js`` (à partir de Solidity 0.6.9), c'est-à-dire le binaire Javascript du compilateur.

Étant donné que BMC et CHC utilisent tous deux ``z3``, et que ``z3`` est disponible dans une plus grande variété
d'environnements, y compris dans le navigateur, la plupart des utilisateurs n'auront presque jamais à se
préoccuper de cette option. Les utilisateurs plus avancés peuvent utiliser cette option pour essayer
des solveurs alternatifs sur des problèmes plus complexes.
=======
The user can choose which solvers should be used, if available, via the CLI
option ``--model-checker-solvers {all,cvc4,eld,smtlib2,z3}`` or the JSON option
``settings.modelChecker.solvers=[smtlib2,z3]``, where:

- ``cvc4`` is only available if the ``solc`` binary is compiled with it. Only BMC uses ``cvc4``.
- ``eld`` is used via its binary which must be installed in the system. Only CHC uses ``eld``, and only if ``z3`` is not enabled.
- ``smtlib2`` outputs SMT/Horn queries in the `smtlib2 <http://smtlib.cs.uiowa.edu/>`_ format.
  These can be used together with the compiler's `callback mechanism <https://github.com/ethereum/solc-js>`_ so that
  any solver binary from the system can be employed to synchronously return the results of the queries to the compiler.
  This can be used by both BMC and CHC depending on which solvers are called.
- ``z3`` is available

  - if ``solc`` is compiled with it;
  - if a dynamic ``z3`` library of version >=4.8.x is installed in a Linux system (from Solidity 0.7.6);
  - statically in ``soljson.js`` (from Solidity 0.6.9), that is, the Javascript binary of the compiler.

.. note::
  z3 version 4.8.16 broke ABI compatibility with previous versions and cannot
  be used with solc <=0.8.13. If you are using z3 >=4.8.16 please use solc
  >=0.8.14.

Since both BMC and CHC use ``z3``, and ``z3`` is available in a greater variety
of environments, including in the browser, most users will almost never need to be
concerned about this option. More advanced users might apply this option to try
alternative solvers on more complex problems.
>>>>>>> 37e935f02546c83384ca6db9dd4d864bf533d004

Veuillez noter que certaines combinaisons de moteur et de solveur choisis conduiront à ce que
SMTChecker ne fera rien, par exemple choisir CHC et ``cvc4``.

*******************************
Abstraction et faux positifs
*******************************

Le SMTChecker implémente les abstractions d'une manière incomplète et saine : Si un bogue
est signalé, il peut s'agir d'un faux positif introduit par les abstractions (dû à
l'effacement de connaissances ou l'utilisation d'un type non précis). S'il détermine qu'une
cible de vérification est sûre, elle est effectivement sûre, c'est-à-dire qu'il n'y a pas de faux
négatifs (à moins qu'il y ait un bug dans le SMTChecker).

Si une cible ne peut pas être prouvée, vous pouvez essayer d'aider le solveur en utilisant les options de réglage
dans la section précédente.
Si vous êtes sûr d'un faux positif, ajouter des déclarations ``require`` dans le code
avec plus d'informations peut également donner plus de puissance au solveur.

Encodage et types SMT
======================

L'encodage SMTChecker essaye d'être aussi précis que possible, en faisant correspondre les types
et expressions Solidity à leur représentation `SMT-LIB <http://smtlib.cs.uiowa.edu/>`_ la plus proche,
comme le montre le tableau ci-dessous.

+-----------------------+--------------------------------+-----------------------------+
|Type Solidity          |Triage SMT                      |Théories                     |
+=======================+================================+=============================+
|Booléen                |Bool                            |Bool                         |
+-----------------------+--------------------------------+-----------------------------+
|intN, uintN, address,  |Integer                         |LIA, NIA                     |
|bytesN, enum, contract |                                |                             |
+-----------------------+--------------------------------+-----------------------------+
|array, mapping, bytes, |Tuple                           |Datatypes, Arrays, LIA       |
|string                 |(Array elements, Integer length)|                             |
+-----------------------+--------------------------------+-----------------------------+
|struct                 |Tuple                           |Datatypes                    |
+-----------------------+--------------------------------+-----------------------------+
|autres types           |Integer                         |LIA                          |
+-----------------------+--------------------------------+-----------------------------+

Les types qui ne sont pas encore pris en charge sont abstraits par un seul entier non signé de
256 bits, où leurs opérations non supportées sont ignorées.

<<<<<<< HEAD
Pour plus de détails sur la façon dont l'encodage SMT fonctionne en interne, voir l'article
`Vérification basée sur SMT des contrats intelligents Solidity <https://github.com/leonardoalt/text/blob/master/solidity_isola_2018/main.pdf>`_.
=======
For more details on how the SMT encoding works internally, see the paper
`SMT-based Verification of Solidity Smart Contracts <https://github.com/chriseth/solidity_isola/blob/master/main.pdf>`_.
>>>>>>> 37e935f02546c83384ca6db9dd4d864bf533d004

Appels de fonction
==============

Dans le moteur BMC, les appels de fonctions vers le même contrat (ou contrats de base) sont
inlined lorsque cela est possible, c'est-à-dire lorsque leur implémentation est disponible.
Les appels de fonctions dans d'autres contrats ne sont pas inlined même si leur code est
disponible, car nous ne pouvons pas garantir que le code déployé est le même.

Le moteur CHC crée des clauses Horn non linéaires qui utilisent des résumés des fonctions appelées
pour prendre en charge les appels de fonctions internes. Les appels de fonctions externes sont traités
comme des appels à du code inconnu, y compris les appels réentrants potentiels.

Les fonctions pures complexes sont abstraites par une fonction non interprétée (UF) sur
les arguments.

+-----------------------------------+--------------------------------------+
|Fonctions                          |Comportement BMC/CHC                  |
+===================================+======================================+
|``assert``                         |Objectif de vérification.             |
+-----------------------------------+--------------------------------------+
|``require``                        |Assomption.                           |
+-----------------------------------+--------------------------------------+
|appel interne                      |BMC: Appel de fonction en ligne.      |
|                                   |CHC: Résumés des fonctions.           |
+-----------------------------------+--------------------------------------+
|appel externe à un code connu      |BMC : Appel de fonction en ligne ou   |
|                                   |L'appel de fonction en ligne ou       |
|                                   |l'effacement des connaissances sur les|
|                                   |variables d'état                      |
|                                   |et des références de stockage local.  |
|                                   |CHC : Supposer que le code appelé est |
|                                   |inconnu.                              |
|                                   |Essayer de déduire les invariants qui |
|                                   |tiennent après le retour de l'appel.  |
+-----------------------------------+--------------------------------------+
|Réseau de stockage push/pop        |Supporté précisément.                 |
|                                   |Vérifie s'il s'agit de faire sauter un|
|                                   |tableau vide.                         |
+-----------------------------------+--------------------------------------+
|Fonctions ABI                      |Abstracted with UF.                   |
+-----------------------------------+--------------------------------------+
|``addmod``, ``mulmod``             |Supported precisely.                  |
+-----------------------------------+--------------------------------------+
|``gasleft``, ``blockhash``,        |Abstracted with UF.                   |
|``keccak256``, ``ecrecover``       |                                      |
|``ripemd160``                      |                                      |
+-----------------------------------+--------------------------------------+
|Fonctions pures sans               |Abstraitement avec UF                 |
|implémentation (externe ou         |                                      |
|complexe)                          |                                      |
+-----------------------------------+--------------------------------------+
|fonctions externes sans            |BMC : Effacer les connaissances de    |
|mise en œuvre                      |l'État et assumer Le résultat est     |
|                                   |indéterminé.                          |
|                                   |CHC : Résumé non déterministe.        |
|                                   |Essayez d'inférer des invariants qui  |
|                                   |tiennent après le retour de l'appel.  |
+-----------------------------------+--------------------------------------+
|transfert                          |BMC : Vérifie si le solde             |
|                                   |du contrat est suffisant.             |
|                                   |CHC : n'effectue pas encore le        |
|                                   |contrôle.                             |
+-----------------------------------+--------------------------------------+
|autres                             |Actuellement non pris en charge       |
+-----------------------------------+--------------------------------------+

L'utilisation de l'abstraction signifie la perte de connaissances précises, mais dans de nombreux cas, elle
ne signifie pas une perte de puissance de preuve.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Recover
    {
        function f(
            bytes32 hash,
            uint8 v1, uint8 v2,
            bytes32 r1, bytes32 r2,
            bytes32 s1, bytes32 s2
        ) public pure returns (address) {
            address a1 = ecrecover(hash, v1, r1, s1);
            require(v1 == v2);
            require(r1 == r2);
            require(s1 == s2);
            address a2 = ecrecover(hash, v2, r2, s2);
            assert(a1 == a2);
            return a1;
        }
    }

Dans l'exemple ci-dessus, le SMTChecker n'est pas assez expressif pour
calculer réellement "ecrecover", mais en modélisant les appels de fonctions comme des fonctions
non interprétées, nous savons que la valeur de retour est la même lorsqu'elle est appelée avec des
paramètres équivalents. Ceci est suffisant pour prouver que l'assertion ci-dessus est toujours vraie.

L'abstraction d'un appel de fonction avec un UF peut être faite pour des fonctions connues pour être
déterministes, et peut être facilement réalisée pour les fonctions pures.
Il est cependant difficile de le faire avec des fonctions externes générales, puisqu'elles peuvent
de variables d'état.

Types de référence et alias
============================

Solidity implémente l'aliasing pour les types de référence avec le même :ref:`data emplacement<data-location>`.
Cela signifie qu'une variable peut être modifiée à travers une référence à la même données.
Le SMTChecker ne garde pas trace des références qui font référence aux mêmes données.
Cela implique que chaque fois qu'une référence locale ou une variable d'état de type référence
est assignée, toutes les connaissances concernant les variables de même type et de même emplacement
données est effacée.
Si le type est imbriqué, la suppression de la connaissance inclut également tous les types.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Aliasing
    {
        uint[] array1;
        uint[][] array2;
        function f(
            uint[] memory a,
            uint[] memory b,
            uint[][] memory c,
            uint[] storage d
        ) internal {
            array1[0] = 42;
            a[0] = 2;
            c[0][0] = 2;
            b[0] = 1;
            // Effacer les connaissances sur les références mémoire ne devrait pas
            // effacer les connaissances sur les variables d'état.
            assert(array1[0] == 42);
            // Cependant, une affectation à une référence de stockage effacera
            // la connaissance du stockage en conséquence.
            d[0] = 2;
            // Échoue en tant que faux positif à cause de l'affectation ci-dessus.
            assert(array1[0] == 42);
            // Échoue car `a == b` est possible.
            assert(a[0] == 2);
            // Échoue car `c[i] == b` est possible.
            assert(c[0][0] == 2);
            assert(d[0] == 2);
            assert(b[0] == 1);
        }
        function g(
            uint[] memory a,
            uint[] memory b,
            uint[][] memory c,
            uint x
        ) public {
            f(a, b, c, array2[x]);
        }
    }

Après l'affectation à ``b[0]``, nous devons effacer la connaissance de ``a``,
puisqu'il a le même type (``uint[]``) et le même emplacement de données (mémoire). Nous devons également
effacer les connaissances sur ``c``, puisque son type de base est également un ``uint[]`` situé
dans la mémoire. Cela implique qu'un ``c[i]`` pourrait faire référence aux mêmes données que
``b`` ou ``a``.

Remarquez que nous n'avons pas de connaissances claires sur ``array`` et ``d``,
parce qu'ils sont situés dans le stockage, même s'ils ont aussi le type ``uint[]``. Cependant,
si ``d`` était assigné, nous devrions effacer la connaissance sur ``array`` et
et vice-versa.

Bilan des contrats
================

Un contrat peut être déployé avec des fonds qui lui sont envoyés, si ``msg.value`` > 0 dans la
transaction de déploiement.
Cependant, l'adresse du contrat peut déjà avoir des fonds avant le déploiement,
qui sont conservés par le contrat.
Par conséquent, le SMTChecker suppose que ``adress(this).balance >= msg.value``
dans le constructeur afin d'être cohérent avec les règles EVM.
Le solde du contrat peut également augmenter sans déclencher d'appel au contrat
contrat, si :

- ``selfdestruct`` est exécuté par un autre contrat avec le contrat analysé
  comme cible des fonds restants,
- le contrat est la base de données de pièces de monnaie (i.e., ``block.coinbase``) d'un bloc.

Pour modéliser cela correctement, le SMTChecker suppose qu'à chaque nouvelle transaction
le solde du contrat peut augmenter d'au moins ``msg.value``.

************************
Hypothèses du monde réel
************************

Certains scénarios peuvent être exprimés dans Solidity et dans l'EVM, mais on s'attend à ce qu'ils ne se produisent
jamais se produire dans la pratique.
L'un de ces cas est la longueur d'un tableau de stockage dynamique qui déborde pendant un processus de
poussée : Si l'opération ``push`` est appliquée à un tableau de longueur 2^256 - 1, sa
longueur déborde silencieusement.
Cependant, il est peu probable que cela se produise dans la pratique, car les opérations nécessaires
pour faire croître le tableau à ce point prendraient des milliards d'années à être exécutées.
Une autre hypothèse similaire prise par le SMTChecker est que le solde d'une adresse
ne peut jamais déborder.

Une idée similaire a été présentée dans `EIP-1985 <https://eips.ethereum.org/EIPS/eip-1985>`_.
