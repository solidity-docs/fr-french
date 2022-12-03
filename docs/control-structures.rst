##################################
Expressions et structures de contrôle
##################################

.. index:: ! parameter, parameter;input, parameter;output, function parameter, parameter;function, return variable, variable;return, return


.. index:: if, else, while, do/while, for, break, continue, return, switch, goto

Structures de contrôle
===================

La plupart des structures de contrôle connues des langages à accolades sont disponibles dans Solidity :

Il y a : " if ", " else ", "while ", " do ", " for ", " break ", " continue ", " return ", avec la sémantique
la sémantique habituelle connue en C ou en JavaScript.

Solidity prend également en charge la gestion des exceptions sous la forme de déclarations " try " et " catch ",
mais seulement pour :ref:`les appels de fonctions externes <external-function-calls>` et pour
les appels de création de contrat. Les erreurs peuvent être créées en utilisant l'instruction :ref:`revert <revert-statement>`.

Les parenthèses ne peuvent *pas* être omises pour les conditionnels, mais les accolades peuvent être omises
autour des corps d'énoncés simples.

Notez qu'il n'y a pas de conversion de type de non-booléen à booléen comme en C et JavaScript.
booléens comme c'est le cas en C et en JavaScript, donc "if (1) { ... }`` n'est *pas* valide
Solidité.

.. index:: ! function;call, function;internal, function;external

.. _function-calls:

Appels de fonction
==============

.. _internal-function-calls:

Appels de fonctions internes
-----------------------

Les fonctions du contrat en cours peuvent être appelées directement ("en interne"), également de manière récursive, comme on le voit dans
cet exemple absurde :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    // Ceci signalera un avertissement
    contract C {
        function g(uint a) public pure returns (uint ret) { return a + f(); }
        function f() internal pure returns (uint ret) { return g(7) + f(); }
    }

Ces appels de fonction sont traduits en simples sauts à l'intérieur de l'EVM. Cela a pour
l'effet que la mémoire courante n'est pas effacée, c'est-à-dire que le passage des références de mémoire
aux fonctions appelées en interne est très efficace. Seules les fonctions de la même
instance de contrat peuvent être appelées en interne.

Vous devez néanmoins éviter toute récursion excessive, car chaque appel de fonction interne
utilise au moins un emplacement de pile et il n'y a que 1024 emplacements disponibles.

.. _external-function-calls:

External Function Calls
-----------------------

Les fonctions peuvent également être appelées en utilisant la notation " this.g(8);`` et " c.g(2);``, où
``c`` est une instance de contrat et ``g`` est une fonction appartenant à ``c``.
L'appel de la fonction `g`` de l'une ou l'autre façon a pour conséquence qu'elle est appelée "en externe", en utilisant
appel de message et non directement via des sauts.
Veuillez noter que les appels de fonction sur ``this`` ne peuvent pas être utilisés dans le constructeur,
car le contrat réel n'a pas encore été créé.

Les fonctions des autres contrats doivent être appelées en externe. Pour un appel externe,
tous les arguments de la fonction doivent être copiés en mémoire.

.. note::
    Un appel de fonction d'un contrat à un autre ne crée pas sa propre transaction,
    il s'agit d'un appel de message faisant partie de la transaction globale.

Lorsque vous appelez des fonctions d'autres contrats, vous pouvez préciser la quantité de Wei ou de
gaz envoyée avec l'appel avec les options spéciales ``{valeur : 10, gaz : 10000}``.
Notez qu'il est déconseillé de spécifier des valeurs de gaz explicitement, puisque les coûts de gaz
des opcodes peuvent changer dans le futur. Tout Wei que vous envoyez au contrat est ajouté
au solde total de ce contrat :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract InfoFeed {
        function info() public payable returns (uint ret) { return 42; }
    }

    contract Consumer {
        InfoFeed feed;
        function setFeed(InfoFeed addr) public { feed = addr; }
        function callFeed() public { feed.info{value: 10, gas: 800}(); }
    }

Vous devez utiliser le modificateur ``payable`` avec la fonction ``info`` parce que
sinon, l'option ``value`` ne serait pas disponible.

.. warning::
  Attention, ``feed.info{value : 10, gaz : 800}`` ne définit que localement la valeur
  et la quantité de ``gaz`` envoyée avec l'appel de la fonction, et que les
  parenthèses à la fin effectuent l'appel réel. Donc
  ``feed.info{value : 10, gaz : 800}`` n'appelle pas la fonction et
  et les paramètres "valeur" et ``gaz`` sont perdus, mais seulement
  ``feed.info{value : 10, gaz : 800}()`` effectue l'appel de fonction.

En raison du fait que l'EVM considère qu'un appel vers un contrat inexistant
toujours réussir, Solidity utilise l'opcode ``extcodesize`` pour vérifier que
le contrat qui est sur le point d'être appelé existe réellement (il contient du code)
et provoque une exception si ce n'est pas le cas. Cette vérification est ignorée si les
données de retour seront décodées après l'appel et donc le décodeur ABI va attraper le
cas d'un contrat inexistant.

Notez que cette vérification n'est pas effectuée dans le cas de :ref:`appels de bas niveau <address_related>` qui
opèrent sur des adresses plutôt que sur des instances de contrat.

.. note::
    Soyez prudent lorsque vous utilisez des appels de haut niveau à
    :ref:`contrats précompilés <precompiledContracts>`,
    car le compilateur les considère comme inexistants selon la logique
    logique ci-dessus, même s'ils exécutent du code et peuvent retourner des données.

Les appels de fonction provoquent également des exceptions si le contrat appelé lui-même
lève une exception ou tombe en panne.

.. warning::
    Toute interaction avec un autre contrat impose un danger potentiel, surtout
    si le code source du contrat n'est pas connu à l'avance. Le
    contrat en cours transmet le contrôle au contrat appelé et celui-ci peut potentiellement
    faire à peu près n'importe quoi. Même si le contrat appelé hérite d'un contrat parent connu,
    le contrat hérité est seulement tenu d'avoir une interface correcte. Le site
    L'implémentation du contrat, cependant, peut être complètement arbitraire et donc..,
    constituer un danger. En outre, il faut se préparer à l'éventualité qu'il fasse appel à
    d'autres contrats de votre système ou même de revenir au contrat appelant avant que le premier
    appel ne revienne. Cela signifie
    que le contrat appelé peut modifier les variables d'état du contrat appelant
    via ses fonctions. Écrivez vos fonctions de manière à ce que, par exemple, les appels aux
    fonctions externes se produisent après toute modification des variables d'état dans votre contrat
    afin que votre contrat ne soit pas vulnérable à un exploit de réentraînement.

.. note::
    Avant Solidity 0.6.2, la manière recommandée de spécifier la valeur et le gaz était de
    utiliser "f.value(x).gas(g)()``. Cette méthode a été dépréciée dans Solidity 0.6.2 et n'est
    plus possible depuis Solidity 0.7.0.

<<<<<<< HEAD
Appels nominatifs et paramètres de fonctions anonymes
---------------------------------------------
=======
Function Calls with Named Parameters
------------------------------------
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

Les arguments d'un appel de fonction peuvent être donnés par leur nom, dans n'importe quel ordre,
s'ils sont entourés de ``{ }`` comme on peut le voir dans
l'exemple suivant. La liste d'arguments doit coïncider par son nom avec la liste des
paramètres de la déclaration de la fonction, mais peut être dans un ordre arbitraire.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        mapping(uint => uint) data;

        function f() public {
            set({value: 2, key: 3});
        }

        function set(uint key, uint value) public {
            data[key] = value;
        }

    }

<<<<<<< HEAD
Noms des paramètres de la fonction omise
--------------------------------

Les noms des paramètres non utilisés (en particulier les paramètres de retour) peuvent être omis.
Ces paramètres seront toujours présents sur la pile, mais ils seront inaccessibles.
=======
Omitted Names in Function Definitions
-------------------------------------

The names of parameters and return values in the function declaration can be omitted.
Those items with omitted names will still be present on the stack, but they are
inaccessible by name. An omitted return value name
can still return a value to the caller by use of the ``return`` statement.
>>>>>>> 591df042115c6df190faa26a1fb87617f7772db3

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        // nom omis pour le paramètre
        function func(uint k, uint) public pure returns(uint) {
            return k;
        }
    }


.. index:: ! new, contracts;creating

.. _creating-contracts:

Créer des contrats via ``new`` (nouveau)
==============================

Un contrat peut créer d'autres contrats en utilisant le mot-clé ``new``. Le
code complet du contrat en cours de création doit être connu lorsque le contrat créateur
est compilé afin que les dépendances récursives de création ne soient pas possibles.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract D {
        uint public x;
        constructor(uint a) payable {
            x = a;
        }
    }

    contract C {
        D d = new D(4); // will be executed as part of C's constructor

        function createD(uint arg) public {
            D newD = new D(arg);
            newD.x();
        }

        function createAndEndowD(uint arg, uint amount) public payable {
            // Send ether along with the creation
            D newD = new D{value: amount}(arg);
            newD.x();
        }
    }

Comme on le voit dans l'exemple, il est possible d'envoyer de l'Ether en créant
une instance de ``D`` en utilisant l'option ``value``, mais il n'est pas possible de
de limiter la quantité d'éther.
Si la création échoue (à cause d'un dépassement de pile, d'un équilibre insuffisant ou d'autres problèmes),
une exception est levée.

Créations de contrats salés / create2
-----------------------------------

Lors de la création d'un contrat, l'adresse du contrat est calculée à partir de
l'adresse du contrat créateur et d'un compteur qui est augmenté à chaque création de
chaque création de contrat.

Si vous spécifiez l'option ``salt`` (une valeur bytes32), alors la création de contrat utilisera un
un mécanisme différent pour trouver l'adresse du nouveau contrat :

Elle calculera l'adresse à partir de l'adresse du contrat en cours de création,
la valeur du sel donnée, le bytecode (de création) du contrat créé et les
arguments du constructeur.

En particulier, le compteur ("nonce") n'est pas utilisé. Cela permet une plus grande flexibilité
dans la création de contrats : Vous pouvez dériver l'adresse du
nouveau contrat avant qu'il ne soit créé. En outre, vous pouvez vous fier à cette adresse
également dans le cas où le créateur
contrat crée d'autres contrats entre-temps.

Le principal cas d'utilisation ici est celui des contrats qui agissent en tant que juges pour les interactions hors chaîne,
qui n'ont besoin d'être créés que s'il y a un différend.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) {
            x = a;
        }
    }

    contract C {
        function createDSalted(bytes32 salt, uint arg) public {
            // Cette expression compliquée vous indique simplement comment l'adresse
            // peut être précalculée. Elle n'est là qu'à titre d'illustration.
            // En fait, vous n'avez besoin que de ``new D{salt : salt}(arg)``.
            address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(D).creationCode,
                    abi.encode(arg)
                ))
            )))));

            D d = new D{salt: salt}(arg);
            require(address(d) == predictedAddress);
        }
    }

.. warning::
    Il existe quelques particularités en ce qui concerne la création salée. Un contrat peut être
    recréé à la même adresse après avoir été détruit. Pourtant, il est possible
    pour ce contrat nouvellement créé d'avoir un bytecode déployé différent,
    même si le bytecode de création a été le même (ce qui est une exigence parce que
    sinon l'adresse changerait). Ceci est dû au fait que le constructeur
    peut interroger l'état externe qui pourrait avoir changé entre les deux créations
    et l'incorporer dans le bytecode déployé avant qu'il ne soit stocké.


Ordre d'évaluation des expressions
==================================

L'ordre d'évaluation des expressions n'est pas spécifié (de manière plus formelle, l'ordre
dans lequel les enfants d'un noeud de l'arbre des expressions sont évalués n'est pas
spécifié, mais ils sont bien sûr évalués avant le noeud lui-même). Il est seulement
garantie que les instructions sont exécutées dans l'ordre et que le court-circuitage des
expressions booléennes est effectué.

.. index:: ! assignment

Affectation
==========

.. index:: ! assignment;destructuring

Déstructurer les affectations et renvoyer des valeurs multiples
-------------------------------------------------------

Solidity autorise en interne les types tuple, c'est-à-dire une liste
d'objets potentiellement différents dont le nombre est une constante à la
constante au moment de la compilation. Ces tuples peuvent être utilisés pour retourner plusieurs valeurs en même temps.
Celles-ci peuvent alors être affectées à des variables nouvellement déclarées
soit à des variables préexistantes (ou à des valeurs LV en général).

Les tuples ne sont pas des types à proprement parler dans Solidity, ils ne peuvent être utilisés que pour former des
groupements syntaxiques d'expressions.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        uint index;

        function f() public pure returns (uint, bool, uint) {
            return (7, true, 2);
        }

        function g() public {
            // Variables déclarées avec le type et assignées à partir du tuple retourné,
            // il n'est pas nécessaire de spécifier tous les éléments (mais le nombre doit correspondre).
            (uint x, , uint y) = f();
            // Truc commun pour échanger des valeurs -- ne fonctionne pas pour les types de stockage sans valeur.
            (x, y) = (y, x);
            // Les composants peuvent être laissés de côté (également pour les déclarations de variables).
            (index, , ) = f(); // Sets the index to 7
        }
    }

Il n'est pas possible de mélanger les déclarations de variables et les affectations non déclarées.
Par exemple, l'exemple suivant n'est pas valide : ``(x, uint y) = (1, 2);``

.. note::
    Avant la version 0.5.0, il était possible d'assigner à des tuples de taille plus petite, soit
    en remplissant le côté gauche ou le côté droit (celui qui était vide). Ceci est
    maintenant interdit, donc les deux côtés doivent avoir le même nombre de composants.

.. warning::
    Soyez prudent lorsque vous assignez à plusieurs variables en même temps
    lorsque des types de référence sont impliqués, car cela pourrait conduire à un
    comportement de copie inattendu.

Complications pour les tableaux et les structures
------------------------------------

La sémantique des affectations est plus compliquée pour les types non-valeurs comme les tableaux et les structs,
y compris les ``octets`` et les ``chaînes``, voir :ref:`L'emplacement des données et le comportement d'affectation <data-location-assignment>`
pour plus de détails.

Dans l'exemple ci-dessous, l'appel à ``g(x)`` n'a aucun effet sur ``x`` parce qu'il crée
une copie indépendante de la valeur de stockage en mémoire. Cependant, ``h(x)`` modifie avec succès ``x``
car seule une référence et non une copie est transmise.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        uint[20] x;

        function f() public {
            g(x);
            h(x);
        }

        function g(uint[20] memory y) internal pure {
            y[2] = 3;
        }

        function h(uint[20] storage y) internal {
            y[3] = 4;
        }
    }

.. index:: ! scoping, declarations, default value

.. _default-value:

Champ d'application et déclarations
========================

Une variable qui est déclarée aura une valeur initiale par défaut
dont la représentation en octets est constituée de zéros.
Les "valeurs par défaut" des variables sont l'"état zéro" typique
de leur type. Par exemple, la valeur par défaut d'un ``bool`` est ``false``.
La valeur par défaut des types ``uint`` ou ``int`` est ``0``.
Pour les tableaux de taille statique et les types ``bytes1`` à
``bytes32``, chaque élément sera initialisé à la valeur par défaut correspondant à son
à son type. Pour les tableaux de taille dynamique, les ``octets``
et ``string``, la valeur par défaut est un tableau ou une chaîne vide.
Pour le type ``enum``, la valeur par défaut est son premier membre.

Le scoping dans Solidity suit les règles de scoping répandues de C99
(et de nombreux autres langages) : Les variables sont visibles à partir du point juste après leur déclaration
jusqu'à la fin du plus petit bloc ``{ }`` qui contient la déclaration.
Les variables déclarées dans la partie d'initialisation d'une boucle ``for`` font exception à cette
partie d'initialisation d'une boucle for ne sont visibles que jusqu'à la fin de la boucle for.

Les variables qui sont des paramètres (paramètres de fonction, paramètres de modificateur,
paramètres de capture, ...) sont visibles à l'intérieur du bloc de code qui suit -
le corps de la fonction/modificateur pour un paramètre de fonction et de modificateur et le bloc catch
pour un paramètre catch.

Les variables et autres éléments déclarés en dehors d'un bloc de code, par exemple les fonctions, les contrats,
les types définis par l'utilisateur, etc., sont visibles avant même d'avoir été déclarés. Cela signifie que vous pouvez
utiliser des variables d'état avant qu'elles ne soient déclarées et appeler des fonctions de manière récursive.

En conséquence, les exemples suivants compileront sans avertissement, puisque
les deux variables ont le même nom mais des portées disjointes.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function minimalScoping() pure public {
            {
                uint same;
                same = 1;
            }

            {
                uint same;
                same = 3;
            }
        }
    }

Comme exemple spécial des règles de scoping de C99, notez que dans ce qui suit,
la première affectation à ``x`` va en fait affecter la variable externe et non la variable interne.
Dans tous les cas, vous obtiendrez un avertissement sur le fait que la variable externe est cachée.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Ceci signalera un avertissement
    contract C {
        function f() pure public returns (uint) {
            uint x = 1;
            {
                x = 2; // ceci sera assigné à la variable externe
                uint x;
            }
            return x; // x a la valeur 2
        }
    }

.. warning::
    Avant la version 0.5.0, Solidity suivait les mêmes règles de portée que le langage
    JavaScript, c'est-à-dire qu'une variable déclarée n'importe où dans une fonction avait une portée
    pour l'ensemble de la fonction, indépendamment de l'endroit où elle était déclarée. L'exemple suivant montre un extrait de code qui utilisait
    pour compiler mais qui conduit à une erreur à partir de la version 0.5.0.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Cela ne compilera pas
    contract C {
        function f() pure public returns (uint) {
            x = 2;
            uint x;
            return x;
        }
    }


.. index:: ! safe math, safemath, checked, unchecked
.. _unchecked:

Arithmétique vérifiée ou non vérifiée
===============================

Un débordement ou un sous-débordement est la situation où la valeur résultante d'une opération arithmétique,
lorsqu'elle est exécutée sur un entier non limité, tombe en dehors de la plage du type de résultat.

Avant la version 0.8.0 de Solidity, les opérations arithmétiques s'emballaient toujours
en cas de débordement ou de sous-débordement, ce qui a conduit à l'utilisation répandue de bibliothèques qui
vérifications supplémentaires.

Depuis la version 0.8.0 de Solidity, toutes les opérations arithmétiques s'inversent par défaut en cas de dépassement inférieur ou supérieur,
rendant ainsi inutile l'utilisation de ces bibliothèques.

Pour obtenir le comportement précédent, un bloc ``unchecked`` peut être utilisé :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract C {
        function f(uint a, uint b) pure public returns (uint) {
            // Cette soustraction se terminera par un dépassement de capacité.
            unchecked { return a - b; }
        }
        function g(uint a, uint b) pure public returns (uint) {
            // Cette soustraction s'inversera en cas de dépassement de capacité.
            return a - b;
        }
    }

L'appel à ``f(2, 3)`` retournera ``2**256-1``, alors que ``g(2, 3)`` provoquera
une assertion qui échoue.

Le bloc "non vérifié" peut être utilisé partout à l'intérieur d'un bloc, mais pas en remplacement
pour un bloc. Il ne peut pas non plus être imbriqué.

Le paramètre n'affecte que les déclarations qui sont syntaxiquement à l'intérieur du bloc.
Les fonctions appelées à l'intérieur d'un bloc "non vérifié" n'héritent pas de cette propriété.

.. note::
    Pour éviter toute ambiguïté, vous ne pouvez pas utiliser ``_;`` à l'intérieur d'un bloc ``non vérifié``.

Les opérateurs suivants provoqueront une assertion d'échec en cas de débordement ou de sous-débordement
et s'enrouleront sans erreur s'ils sont utilisés à l'intérieur d'un bloc non vérifié :

``++``, ``--``, ``+``, binaire ``-``, unaire ``-``, ``*``, ``/``, ``%``, ``**``

``+=``, ``-=``, ``*=``, ``/=``, ``%=``

.. warning::
    Il n'est pas possible de désactiver la vérification de la division par zéro
    ou modulo par zéro en utilisant le bloc ``unchecked``.

.. note::
   Les opérateurs binaires n'effectuent pas de vérification de dépassement de capacité ou de sous-dépassement.
   Ceci est particulièrement visible lors de l'utilisation de décalages binaires (``<<``, ``>>``, ``<=``, ``>=``)
   à la place de la division d'entiers et de la multiplication par une puissance de 2.
   Par exemple, ``type(uint256).max << 3`` ne s'inverse pas alors que ``type(uint256).max * 8`` le ferait.

.. note::
    La deuxième instruction dans ``int x = type(int).min ; -x;`` entraînera un dépassement de capacité
    car l'intervalle négatif peut contenir une valeur de plus que l'intervalle positif.

Les conversions de type explicites seront toujours tronquées et ne provoqueront jamais une assertion d'échec
à l'exception de la conversion d'un entier en un type enum.

.. index:: ! exception, ! throw, ! assert, ! require, ! revert, ! errors

.. _assert-and-require:

Gestion des erreurs : Assert, Require, Revert et Exceptions
======================================================

Solidity utilise des exceptions de retour à l'état initial pour gérer les erreurs.
Une telle exception annule toutes les modifications apportées à
l'état dans l'appel actuel (et tous ses sous-appels) et
signale une erreur à l'appelant.

Lorsque des exceptions se produisent dans un sous-appel, elles "remontent" (c'est-à-dire que
les exceptions sont rejetées) automatiquement à moins qu'elles ne soient capturées dans
dans une instruction ``try/catch``. Les exceptions à cette règle sont ``send``
et les fonctions de bas niveau ``call``, ``delegatecall`` et
``staticcall`` : elles retournent `false`` comme première valeur de retour en cas
d'une exception, au lieu de "bouillonner".

.. warning::
    Les fonctions de bas niveau ``call``, ``delegatecall`` et
    ``staticcall`` retournent `true`` comme première valeur de retour
    si le compte appelé est inexistant, ce qui fait partie de la conception
    de l'EVM. L'existence du compte doit être vérifiée avant l'appel si nécessaire.

Les exceptions peuvent contenir des données d'erreur qui sont renvoyées à l'appelant
sous la forme de :ref:`error instances <errors>`.
Les erreurs intégrées "Erreur(string)" et "Panique(uint256)" sont
utilisées par des fonctions spéciales, comme expliqué ci-dessous. ``Error`` est utilisé pour les conditions d'erreurs "normales".
Tandis que ``Panic`` est utilisé pour les erreurs qui ne devraient pas être présentes dans un code sans bogues.

Panique via "Assert" et erreur via "Require".
----------------------------------------------

Les fonctions pratiques ``assert'' et ``require'' peuvent être utilisées pour vérifier les conditions et lancer une exception
si la condition n'est pas remplie.

La fonction ``assert`` crée une erreur de type ``Panic(uint256)``.
La même erreur est créée par le compilateur dans certaines situations, comme indiqué ci-dessous.

Assert ne doit être utilisée que pour tester les erreurs
internes et pour vérifier les invariants. Un code qui fonctionne correctement
ne devrait jamais créer un Panic, même pas sur une entrée externe invalide.
Si cela se produit, alors il y a
un bogue dans votre contrat que vous devez corriger. Les outils
d'analyse du langage peuvent évaluer votre contrat pour identifier les conditions et
les appels de fonction qui provoquent une panique.

Une exception de panique est générée dans les situations suivantes.
Le code d'erreur fourni avec les données d'erreur indique le type de panique.

#. 0x00 : Utilisé pour les paniques génériques insérées par le compilateur.
#. 0x01 : Si vous appelez ``assert`` avec un argument qui évalue à false.
#. 0x11 : Si une opération arithmétique résulte en un débordement ou un sous-débordement en dehors d'un bloc "non vérifié { .... }``.
#. 0x12 : Si vous divisez ou modulez par zéro (par exemple, ``5 / 0`` ou ``23 % 0``).
#. 0x21 : Si vous convertissez une valeur trop grande ou négative en un type d'enum.
#. 0x22 : Si vous accédez à un tableau d'octets de stockage qui est incorrectement codé.
#. 0x31 : Si vous appelez ``.pop()`` sur un tableau vide.
#. 0x32 : Si vous accédez à un tableau, à ``bytesN`` ou à une tranche de tableau à un index hors limites ou négatif (c'est-à-dire ``x[i]`` où ``i >= x.length`` ou ``i < 0``).
#. 0x41 : Si vous allouez trop de mémoire ou créez un tableau trop grand.
#. 0x51 : Si vous appelez une variable zéro initialisée de type fonction interne.

La fonction ``require`` crée soit une erreur sans aucune donnée, soit
une erreur de type ``Error(string)``. Elle
doit être utilisée pour garantir des conditions valides
qui ne peuvent pas être détectées avant le moment de l'exécution.
Cela inclut les conditions sur les entrées
ou les valeurs de retour des appels à des contrats externes.a

.. note::

    Il n'est actuellement pas possible d'utiliser des erreurs personnalisées en combinaison
    avec ``require``. Veuillez utiliser ``if (!condition) revert CustomError();`` à la place.

Une exception ``Error(string)`` (ou une exception sans données) est générée
par le compilateur dans les situations suivantes :

#. Appeler ``require(x)`` où ``x`` est évalué à ``false``.
#. Si vous utilisez ``revert()`` ou ``revert("description")``.
#. Si vous effectuez un appel de fonction externe ciblant un contrat qui ne contient pas de code.
#. Si votre contrat reçoit de l'Ether via une fonction publique sans
   modificateur ``payable`` (y compris le constructeur et la fonction de repli).
#. Si votre contrat reçoit de l'Ether via une fonction publique getter.

Dans les cas suivants, les données d'erreur de l'appel externe
(s'il est fourni) sont transférées. Cela signifie qu'il peut soit causer
une `Error` ou une `Panic` (ou toute autre donnée) :

#. Si un ``.transfer()`` échoue.
#. Si vous appelez une fonction via un appel de message mais qu'elle
   ne se termine pas correctement (c'est-à-dire qu'elle tombe en panne sèche, qu'il n'y a pas de
   lève elle-même une exception), sauf lorsqu'une opération de bas niveau
   ``call``, ``send``, ``delegatecall``, ``callcode`` ou ``staticcall``
   est utilisé. Les opérations de bas niveau ne lèvent jamais d'exceptions
   mais indiquent les échecs en retournant ``false``.
#. Si vous créez un contrat en utilisant le mot-clé ``new`` mais que le contrat
   création :ref:`ne se termine pas correctement<creating-contracts>`.

Vous pouvez éventuellement fournir une chaîne de message pour ``require``, mais pas pour ``assert``.

.. note::
    Si vous ne fournissez pas un argument de type chaîne à ``require``, il se retournera
    avec des données d'erreur vides, sans même inclure le sélecteur d'erreur.


L'exemple suivant montre comment vous pouvez utiliser ``require`` pour vérifier les conditions sur les entrées
et ``assert`` pour vérifier les erreurs internes.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract Sharer {
        function sendHalf(address payable addr) public payable returns (uint balance) {
            require(msg.value % 2 == 0, "Even value required.");
            uint balanceBeforeTransfer = address(this).balance;
            addr.transfer(msg.value / 2);
            // Puisque le transfert lève une exception en cas d'échec et que
            // ne peut pas rappeler ici, il ne devrait pas y avoir de moyen pour nous
            // d'avoir encore la moitié de l'argent.
            assert(address(this).balance == balanceBeforeTransfer - msg.value / 2);
            return address(this).balance;
        }
    }

En interne, Solidity effectue une opération de retour en arrière (instruction
``0xfd``). Cela provoque l'EVM à revenir sur toutes les modifications apportées à l'état.
La raison de ce retour en arrière est qu'il n'y a pas de moyen sûr de poursuivre l'exécution, parce qu'un effet attendu
ne s'est pas produit. Parce que nous voulons conserver l'atomicité des transactions,
l'action la plus sûre est d'annuler tous les changements et de rendre la transaction entière
(ou au moins l'appel) sans effet.

Dans les deux cas, l'appelant peut réagir à de tels échecs en utilisant ``try``/``catch``, mais
mais les changements dans l'appelant seront toujours annulés.

.. note::

    Les exceptions de panique utilisaient l'opcode ``invalid`' avant Solidity 0.8.0,
    qui consommait tout le gaz disponible pour l'appel.
    Les exceptions qui utilisent ``require`` consommaient tout le gaz jusqu'à la version Metropolis.

.. _revert-statement:

``revert``
----------

Une réversion directe peut être déclenchée à l'aide de l'instruction ``revert`` et de la fonction ``revert``.

L'instruction ``revert`` prend une erreur personnalisée comme argument direct sans parenthèses :

    revert CustomError(arg1, arg2) ;

Pour des raisons de rétrocompatibilité, il existe également la fonction ``revert()``, qui utilise des parenthèses
et accepte une chaîne de caractères :

    revert() ;
    revert("description") ;

Les données d'erreur seront renvoyées à l'appelant et pourront être capturées à cet endroit.
L'utilisation de ``revert()`` provoque un revert sans aucune donnée d'erreur alors que ``revert("description")``
créera une erreur ``Error(string)``.

L'utilisation d'une instance d'erreur personnalisée sera généralement beaucoup plus économique qu'une description sous forme de chaîne,
car vous pouvez utiliser le nom de l'erreur pour la décrire, qui est encodé dans seulement
quatre octets. Une description plus longue peut être fournie via NatSpec, ce qui n'entraîne
aucun coût.

L'exemple suivant montre comment utiliser une chaîne d'erreur et une instance d'erreur personnalisée
avec ``revert`` et l'équivalent ``require`` :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract VendingMachine {
        address owner;
        error Unauthorized();
        function buy(uint amount) public payable {
            if (amount > msg.value / 2 ether)
                revert("Not enough Ether provided.");
            // Autre façon de faire :
            require(
                amount <= msg.value / 2 ether,
                "Not enough Ether provided."
            );
            // Effectuer l'achat.
        }
        function withdraw() public {
            if (msg.sender != owner)
                revert Unauthorized();

            payable(msg.sender).transfer(address(this).balance);
        }
    }

Les deux façons de faire ``si (!condition) revert(...);`` et ``require(condition, ...);`` sont
équivalentes tant que les arguments de ``revert`` et ``require`` n'ont pas d'effets secondaires,
par exemple si ce ne sont que des chaînes de caractères.

.. note::
    La fonction ``require`` est évaluée comme n'importe quelle autre fonction.
    Cela signifie que tous les arguments sont évalués avant que la fonction elle-même ne soit exécutée.
    En particulier, dans ``require(condition, f())`` la fonction ``f`` est exécutée même si
    ``condition`` est vraie.

La chaîne fournie est :ref:`abi-encoded <ABI>` comme s'il s'agissait d'un appel à une fonction ``Error(string)``.
Dans l'exemple ci-dessus, ``revert("Not enough Ether provided.");`` renvoie l'hexadécimal suivant comme données de retour d'erreur :

.. code::

    0x08c379a0                                                         // Sélecteur de fonction pour Error(string)
    0x0000000000000000000000000000000000000000000000000000000000000020 // Décalage des données
    0x000000000000000000000000000000000000000000000000000000000000001a // Longueur de la chaîne
    0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // Données en chaîne

Le message fourni peut être récupéré par l'appelant à l'aide de ``try``/``catch`` comme indiqué ci-dessous.

.. note::
    Il existait auparavant un mot-clé appelé "throw" avec la même sémantique que "reverse()``, qui
    a été déprécié dans la version 0.4.13 et supprimé dans la version 0.5.0.


.. _try-catch:

``try``/``catch``
-----------------

Il existait auparavant un mot-clé appelé "throw" avec la même sémantique que ``reverse()``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;

    interface DataFeed { function getData(address token) external returns (uint value); }

    contract FeedConsumer {
        DataFeed feed;
        uint errorCount;
        function rate(address token) public returns (uint value, bool success) {
            // Désactiver définitivement le mécanisme s'il y a
            // plus de 10 erreurs.
            require(errorCount < 10);
            try feed.getData(token) returns (uint v) {
                return (v, true);
            } catch Error(string memory /*reason*/) {
                // Ceci est exécuté dans le cas où
                // le revert a été appelé dans getData
                // et qu'une chaîne de raison a été fournie.
                errorCount++;
                return (0, false);
            } catch Panic(uint /*errorCode*/) {
                // Ceci est exécuté en cas de panique,
                // c'est-à-dire une erreur grave comme une division par zéro
                // ou un dépassement de capacité. Le code d'erreur peut être utilisé
                // pour déterminer le type d'erreur.
                errorCount++;
                return (0, false);
            } catch (bytes memory /*lowLevelData*/) {
                // Ceci est exécuté au cas où revert() a été utilisé.
                errorCount++;
                return (0, false);
            }
        }
    }

Le mot-clé ``try`` doit être suivi d'une expression représentant un appel de fonction externe
ou une création de contrat (``new ContractName()``).
Les erreurs à l'intérieur de l'expression ne sont pas prises en compte (par exemple s'il s'agit d'une expression
complexe qui implique aussi des appels de fonctions internes), seul un retour en arrière se produisant dans l'appel
externe lui-même. La partie ``returns`` (qui est optionnelle) qui suit déclare des variables de retour
correspondant aux types retournés par l'appel externe. Dans le cas où il n'y a pas eu d'erreur
ces variables sont assignées et l'exécution du contrat continue à l'intérieur du
premier bloc de succès. Si la fin du bloc de succès est atteinte, l'exécution continue après les blocs ``catch``.

Solidity prend en charge différents types de blocs catch en fonction du
type d'erreur :

- ``catch Error(string memory reason) { ... }`` : Cette clause catch est exécutée si l'erreur a été provoquée par ``revert("reasonString")`` ou par
  ``require(false, "reasonString")`` (ou une erreur interne qui provoque une telle exception).

- ``catch Panic(uint errorCode) { ... }`` : Si l'erreur a été causée par une panique, c'est-à-dire par un ``assert`` défaillant, division par zéro,
  un accès invalide à un tableau, un débordement arithmétique et autres, cette clause catch sera exécutée.

- ``catch (bytes memory lowLevelData) { ... }`` : Cette clause est exécutée si la signature de l'erreur
  signature d'erreur ne correspond à aucune autre clause, s'il y a eu une erreur lors du décodage du message
  d'erreur, ou si aucune donnée d'erreur n'a été fournie avec l'exception.
  La variable déclarée donne accès aux données d'erreur de bas niveau dans ce cas.

- ``catch { ... }`` : Si vous n'êtes pas intéressé par les données d'erreur, vous pouvez simplement utiliser
  ``catch { ... }`` (même comme seule clause catch) au lieu de la clause précédente.


Il est prévu de supporter d'autres types de données d'erreur dans le futur.
Les chaînes "Erreur" et "Panique" sont actuellement analysées telles quelles et ne sont pas traitées comme des identifiants.

Afin d'attraper tous les cas d'erreur, vous devez avoir au moins la clause suivante
``catch { ...}`` ou la clause ``catch (bytes memory lowLevelData) { ... }``.

Les variables déclarées dans la clause ``returns`` et la clause ``catch`` sont uniquement
dans le bloc qui suit.

.. note::

    Si une erreur se produit pendant le décodage des données de retour
    dans un énoncé try/catch, cela provoque une exception dans le contrat
    en cours d'exécution et, pour cette raison, elle n'est pas attrapée dans la clause catch.
    S'il y a une erreur pendant le décodage de ``catch Error(string memory reason)``
    et qu'il existe une clause catch de bas niveau, cette erreur y est attrapée.

.. note::

    Si l'exécution atteint un bloc de capture, alors les effets de changement d'état de
    l'appel externe ont été annulés. Si l'exécution atteint
    le bloc de succès, les effets n'ont pas été annulés.
    Si les effets ont été inversés, alors l'exécution continue soit
    dans un bloc catch ou bien l'exécution de l'instruction try/catch elle-même
    s'inverse (par exemple, en raison d'échecs de décodage comme indiqué ci-dessus ou
    en raison de l'absence d'une clause catch de bas niveau).

.. note::
    Les raisons de l'échec d'un appel peuvent être multiples. Ne supposez pas que
    le message d'erreur provient directement du contrat appelé :
    L'erreur peut s'être produite plus bas dans la
    chaîne d'appels et le contrat appelé n'a fait que la transmettre. De même, elle peut être due à une
    situation de panne sèche et non d'une condition d'erreur délibérée :
    L'appelant conserve toujours au moins 1/64ème du gaz dans un appel et donc
    l'appelant a encore du gaz.
