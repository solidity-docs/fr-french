.. index:: style, coding style

###############
Guide de style
###############

************
Introduction
************

<<<<<<< HEAD
Ce guide est destiné à fournir des conventions de codage pour l'écriture du code Solidity.
Ce guide doit être considéré comme un document évolutif qui changera
au fur et à mesure que des conventions utiles seront trouvées et que les anciennes conventions seront rendues obsolètes.
=======
This guide is intended to provide coding conventions for writing Solidity code.
This guide should be thought of as an evolving document that will change over
time as useful conventions are found and old conventions are rendered obsolete.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

De nombreux projets mettront en place leurs propres guides de style. En cas de
conflits, les guides de style spécifiques au projet sont prioritaires.

La structure et un grand nombre de recommandations de ce guide de style ont été
tirées du guide de style de python
`pep8 style guide <https://www.python.org/dev/peps/pep-0008/>`_.

<<<<<<< HEAD
Le but de ce guide n'est *pas* d'être la bonne ou la meilleure façon d'écrire du
code Solidity. Le but de ce guide est la *consistance*. Une citation de python
=======
The goal of this guide is *not* to be the right way or the best way to write
Solidity code.  The goal of this guide is *consistency*.  A quote from python's
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33
`pep8 <https://www.python.org/dev/peps/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds>`_
résume bien ce concept.

.. note::

    Un guide de style est une question de cohérence. La cohérence avec ce guide de style est importante.
    La cohérence au sein d'un module ou d'une fonction est la plus importante.

<<<<<<< HEAD
    Mais le plus important : **savoir quand être incohérent** - parfois le guide de style ne s'applique tout simplement pas.
    En cas de doute, utilisez votre meilleur jugement. Regardez d'autres exemples et décidez de ce qui vous semble le mieux. Et n'hésitez pas à demander !
=======
    But most importantly: **know when to be inconsistent** -- sometimes the style guide just doesn't apply. When in doubt, use your best judgment. Look at other examples and decide what looks best. And don't hesitate to ask!
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33


********************
Présentation du code
********************


Indentation
===========

Utilisez 4 espaces par niveau d'indentation.

Tabs ou Espaces
===============

Les espaces sont la méthode d'indentation préférée.

Il faut éviter de mélanger les tabulations et les espaces.

Lignes vierges
==============

Entourer les déclarations de haut niveau dans le code source de solidity de deux lignes vides.

<<<<<<< HEAD
Oui :
=======
Mixing tabs and spaces should be avoided.

Blank Lines
===========

Surround top level declarations in Solidity source with two blank lines.

Yes:
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    contract B {
        // ...
    }


    contract C {
        // ...
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }
    contract B {
        // ...
    }

    contract C {
        // ...
    }

Dans un contrat, les déclarations de fonctions sont entourées d'une seule ligne vierge.

Les lignes vides peuvent être omises entre des groupes de déclarations d'une seule ligne (comme les fonctions de base d'un contrat abstrait).

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() public virtual pure;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }

        function ham() public pure override {
            // ...
        }
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() virtual pure public;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }
        function ham() public pure override {
            // ...
        }
    }

.. _maximum_line_length:

Longueur maximale de la ligne
=============================

<<<<<<< HEAD
Garder les lignes sous la recommandation `PEP 8 <https://www.python.org/dev/peps/pep-0008/#maximum-line-length>`_ à un maximum de 79 (ou 99)
caractères aide les lecteurs à analyser facilement le code.
=======
Maximum suggested line length is 120 characters.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

Les lignes enveloppées doivent se conformer aux directives suivantes.

1. Le premier argument ne doit pas être attaché à la parenthèse ouvrante.
2. Une, et une seule, indentation doit être utilisée.
3. Chaque argument doit être placé sur sa propre ligne.
4. L'élément de terminaison, :code:`);`, doit être placé seul sur la dernière ligne.

Appels de fonction

Oui :

.. code-block:: solidity

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3
    );

Non :

.. code-block:: solidity

    thisFunctionCallIsReallyLong(longArgument1,
                                  longArgument2,
                                  longArgument3
    );

    thisFunctionCallIsReallyLong(longArgument1,
        longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1, longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
    longArgument1,
    longArgument2,
    longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3);

Déclarations d'affectation

Oui :

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(
        argument1,
        argument2,
        argument3,
        argument4
    );

Non :

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(argument1,
                                                                       argument2,
                                                                       argument3,
                                                                       argument4);

Définitions d'événements et émetteurs d'événements

Oui :

.. code-block:: solidity

    event LongAndLotsOfArgs(
        address sender,
        address recipient,
        uint256 publicKey,
        uint256 amount,
        bytes32[] options
    );

    LongAndLotsOfArgs(
        sender,
        recipient,
        publicKey,
        amount,
        options
    );

Non "

.. code-block:: solidity

    event LongAndLotsOfArgs(address sender,
                            address recipient,
                            uint256 publicKey,
                            uint256 amount,
                            bytes32[] options);

    LongAndLotsOfArgs(sender,
                      recipient,
                      publicKey,
                      amount,
                      options);

Codage du fichier source
========================

L'encodage UTF-8 ou ASCII est préféré.

Importations
============

Les déclarations d'importation doivent toujours être placées en haut du fichier.

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";

    contract A {
        // ...
    }

    contract B is Owned {
        // ...
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    import "./Owned.sol";


    contract B is Owned {
        // ...
    }

Ordre des fonctions
===================

L'ordre aide les lecteurs à identifier les fonctions qu'ils peuvent appeler et à trouver plus facilement les définitions des constructeurs et des fonctions de repli.

Les fonctions doivent être regroupées en fonction de leur visibilité et ordonnées :

- constructor
- receive function (si elle existe)
- fallback function (si elle existe)
- external
- public
- internal
- private

Dans un regroupement, placez les fonctions ``view`` et ``pure`` en dernier.

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {
        constructor() {
            // ...
        }

        receive() external payable {
            // ...
        }

        fallback() external {
            // ...
        }

        // Fonctions externes
        // ...

        // Fonctions externes qui sont view
        // ...

        // Fonctions externes qui sont pure
        // ...

        // Fonctions publiques
        // ...

        // Fonctions internes
        // ...

        // Fonctions privées
        // ...
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {

        // External functions
        // ...

        fallback() external {
            // ...
        }
        receive() external payable {
            // ...
        }

        // Fonctions privées
        // ...

        // Fonctions publiques
        // ...

        constructor() {
            // ...
        }

        // Fonctions internes
        // ...
    }

Espaces blancs dans les expressions
===================================

Évitez les espaces blancs superflus dans les situations suivantes :

Immédiatement à l'intérieur des parenthèses, des crochets ou des accolades, à l'exception des déclarations de fonctions sur une seule ligne.

Oui :

.. code-block:: solidity

    spam(ham[1], Coin({name: "ham"}));

Non :

.. code-block:: solidity

    spam( ham[ 1 ], Coin( { name: "ham" } ) );

Exception :

.. code-block:: solidity

    function singleLine() public { spam(); }

Immédiatement avant une virgule, un point-virgule :

Oui :

.. code-block:: solidity

    function spam(uint i, Coin coin) public;

Non;

.. code-block:: solidity

    function spam(uint i , Coin coin) public ;

More than one space around an assignment or other operator to align with another:

Yes:

.. code-block:: solidity

    x = 1;
    y = 2;
    longVariable = 3;

Non :

.. code-block:: solidity

    x            = 1;
    y            = 2;
    longVariable = 3;

Ne pas inclure d'espace dans les fonctions de réception et de repli :

Oui :

.. code-block:: solidity

    receive() external payable {
        ...
    }

    fallback() external {
        ...
    }

Non :

.. code-block:: solidity

    receive () external payable {
        ...
    }

    fallback () external {
        ...
    }


Structures de contrôle
==================

Les accolades désignant le corps d'un contrat, d'une bibliothèque, de fonctions et de structs
doivent :

* s'ouvrir sur la même ligne que la déclaration
* se fermer sur leur propre ligne au même niveau d'indentation que le début de la
  déclaration.
* L'accolade d'ouverture doit être précédée d'un espace.

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin
    {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Les mêmes recommandations s'appliquent aux structures de contrôle ``if``, ``else``, ``while``,
et ``for``.

En outre, les structures de contrôle suivantes doivent être séparées par un espace unique
``if``, ``while`` et ``for`` et le bloc entre parenthèses représentant le
conditionnel, ainsi qu'un espace entre le bloc parenthétique conditionnel
et l'accolade ouvrante.

Oui :

.. code-block:: solidity

    if (...) {
        ...
    }

    for (...) {
        ...
    }

Non :

.. code-block:: solidity

    if (...)
    {
        ...
    }

    while(...){
    }

    for (...) {
        ...;}

Pour les structures de contrôle dont le corps contient une seule déclaration, l'omission des accolades
est acceptable *si* la déclaration est contenue sur une seule ligne.

Oui :

.. code-block:: solidity

    if (x < 10)
        x += 1;

Non :

.. code-block:: solidity

    if (x < 10)
        someArray.push(Coin({
            name: 'spam',
            value: 42
        }));

Pour les blocs ``if`` qui ont une clause ``else`` ou ``else if``, la clause ``else``
doit être placée sur la même ligne que l'accolade fermant le bloc ``if``. Il s'agit d'une exception par rapport
aux règles des autres structures de type bloc.

Oui :

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    } else if (x > 7) {
        x -= 1;
    } else {
        x = 5;
    }


    if (x < 3)
        x += 1;
    else
        x -= 1;

Non :

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    }
    else {
        x -= 1;
    }

Déclaration de fonction
====================

Pour les déclarations de fonction courtes, il est recommandé de garder l'accolade d'ouverture
du corps de la fonction sur la même ligne que la déclaration de la fonction.

L'accolade fermante doit être au même niveau d'indentation que la déclaration de fonction.
de la fonction.

L'accolade ouvrante doit être précédée d'un seul espace.

Oui :

.. code-block:: solidity

    function increment(uint x) public pure returns (uint) {
        return x + 1;
    }

    function increment(uint x) public pure onlyOwner returns (uint) {
        return x + 1;
    }

Non :

.. code-block:: solidity

    function increment(uint x) public pure returns (uint)
    {
        return x + 1;
    }

    function increment(uint x) public pure returns (uint){
        return x + 1;
    }

    function increment(uint x) public pure returns (uint) {
        return x + 1;
        }

    function increment(uint x) public pure returns (uint) {
        return x + 1;}

L'ordre des modificateurs pour une fonction doit être :

1. Visibilité
2. Mutabilité
3. Virtuel
4. Remplacer
5. Modificateurs personnalisés

Oui :

.. code-block:: solidity

    function balance(uint from) public view override returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() public onlyOwner {
        selfdestruct(owner);
    }

Non :

.. code-block:: solidity

    function balance(uint from) public override view returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() onlyOwner public {
        selfdestruct(owner);
    }

<<<<<<< HEAD
Pour les longues déclarations de fonctions, il est recommandé de déposer chaque argument
sur sa propre ligne au même niveau d'indentation que le corps de la fonction. La
parenthèse fermante et la parenthèse ouvrante doivent être placées sur leur propre ligne
au même niveau d'indentation que la déclaration de fonction.
=======
For long function declarations, it is recommended to drop each argument onto
its own line at the same indentation level as the function body.  The closing
parenthesis and opening bracket should be placed on their own line as well at
the same indentation level as the function declaration.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

Oui :

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f
    )
        public
    {
        doSomething();
    }

Non :

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(address a, address b, address c,
        address d, address e, address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(address a,
                                            address b,
                                            address c,
                                            address d,
                                            address e,
                                            address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f) public {
        doSomething();
    }

Si une longue déclaration de fonction comporte des modificateurs, chaque modificateur doit être déposé
sur sa propre ligne.

Oui :

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(
        address x,
        address y,
        address z
    )
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

Non :

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
                                          public
                                          onlyOwner
                                          priced
                                          returns (address) {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public onlyOwner priced returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address) {
        doSomething();
    }

Les paramètres de sortie et les instructions de retour multilignes doivent suivre le même style que celui recommandé pour l'habillage des longues lignes dans la section :ref:`Longueur de ligne maximale <maximum_length_line>`.

Oui :

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (
            address someAddressName,
            uint256 LongArgument,
            uint256 Argument
        )
    {
        doSomething()

        return (
            veryLongReturnArg1,
            veryLongReturnArg2,
            veryLongReturnArg3
        );
    }

Non :

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (address someAddressName,
                 uint256 LongArgument,
                 uint256 Argument)
    {
        doSomething()

        return (veryLongReturnArg1,
                veryLongReturnArg1,
                veryLongReturnArg1);
    }

Pour les fonctions constructrices sur les contrats hérités dont les bases nécessitent des arguments,
il est recommandé de déposer les constructeurs de base sur de nouvelles lignes
de la même manière que les modificateurs si la déclaration de la fonction est longue ou difficile à lire.

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // Contrats de base juste pour que cela compile
    contract B {
        constructor(uint) {
        }
    }
    contract C {
        constructor(uint, uint) {
        }
    }
    contract D {
        constructor(uint) {
        }
    }

    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4)
        {
            // do something with param5
            x = param5;
        }
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Contrats de base juste pour que cela compile
    contract B {
        constructor(uint) {
        }
    }


    contract C {
        constructor(uint, uint) {
        }
    }


    contract D {
        constructor(uint) {
        }
    }


    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
        B(param1)
        C(param2, param3)
        D(param4) {
            x = param5;
        }
    }


    contract X is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4) {
                x = param5;
            }
    }


Lorsque vous déclarez des fonctions courtes avec une seule déclaration, il est permis de le faire sur une seule ligne.

C'est autorisé :

.. code-block:: solidity

    function shortFunction() public { doSomething(); }

<<<<<<< HEAD
Ces directives pour les déclarations de fonctions sont destinées à améliorer la lisibilité.
Les auteurs doivent faire preuve de discernement car ce guide ne prétend pas couvrir toutes les
permutations possibles pour les déclarations de fonctions.
=======
These guidelines for function declarations are intended to improve readability.
Authors should use their best judgment as this guide does not try to cover all
possible permutations for function declarations.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

Mappages
========

Dans les déclarations de variables, ne séparez pas le mot-clé ``mapping`` de son
type par un espace. Ne séparez pas un mot-clé ``mapping`` imbriqué de son type par un
espace.

Oui :

.. code-block:: solidity

    mapping(uint => uint) map;
    mapping(address => bool) registeredAddresses;
    mapping(uint => mapping(bool => Data[])) public data;
    mapping(uint => mapping(uint => s)) data;

Non :

.. code-block:: solidity

    mapping (uint => uint) map;
    mapping( address => bool ) registeredAddresses;
    mapping (uint => mapping (bool => Data[])) public data;
    mapping(uint => mapping (uint => s)) data;

Déclarations de variables
=========================

Les déclarations de variables de tableau ne doivent pas comporter d'espace entre le type et
les parenthèses.

Oui :

.. code-block:: solidity

    uint[] x;

Non :

.. code-block:: solidity

    uint [] x;


Autres recommandations
=====================

* Les chaînes de caractères devraient être citées avec des guillemets doubles au lieu de guillemets simples.

Oui :

.. code-block:: solidity

    str = "foo";
    str = "Hamlet dit : 'Être ou ne pas être...'";

Non :

.. code-block:: solidity

    str = 'bar';
    str = '"Soyez vous-même ; tous les autres sont déjà pris." -Oscar Wilde';

* Entourer les opérateurs d'un espace unique de chaque côté.

Oui :

.. code-block:: solidity
    :force:

    x = 3;
    x = 100 / 10;
    x += 3 + 4;
    x |= y && z;

Non :

.. code-block:: solidity
    :force:

    x=3;
    x = 100/10;
    x += 3+4;
    x |= y&&z;

<<<<<<< HEAD
* Les opérateurs ayant une priorité plus élevée que les autres peuvent exclure les espaces
  afin d'indiquer la préséance. Ceci a pour but de permettre
  d'améliorer la lisibilité d'une déclaration complexe. Vous devez toujours utiliser la même
  quantité d'espaces blancs de part et d'autre d'un opérateur :
=======
* Operators with a higher priority than others can exclude surrounding
  whitespace in order to denote precedence.  This is meant to allow for
  improved readability for complex statements. You should always use the same
  amount of whitespace on either side of an operator:
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

Oui :

.. code-block:: solidity

    x = 2**3 + 5;
    x = 2*y + 3*z;
    x = (a+b) * (a-b);

Non :

.. code-block:: solidity

    x = 2** 3 + 5;
    x = y+z;
    x +=1;

*********************
Ordre de mise en page
*********************

Disposez les éléments du contrat dans l'ordre suivant :

1. Déclarations de pragmatisme
2. Instructions d'importation
3. Interfaces
4. Bibliothèques
5. Contrats

À l'intérieur de chaque contrat, bibliothèque ou interface, utilisez l'ordre suivant :

<<<<<<< HEAD
1. Les déclarations de type
2. Variables d'état
3. Événements
4. Fonctions
=======
1. Type declarations
2. State variables
3. Events
4. Errors
5. Modifiers
6. Functions
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

.. note::

    Il peut être plus clair de déclarer les types à proximité de leur utilisation dans les événements ou les
    variables d'état.

<<<<<<< HEAD
*************************
Conventions d'appellation
*************************
=======
Yes:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.4 <0.9.0;

    abstract contract Math {
        error DivideByZero();
        function divide(int256 numerator, int256 denominator) public virtual returns (uint256);
    }

No:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.4 <0.9.0;

    abstract contract Math {
        function divide(int256 numerator, int256 denominator) public virtual returns (uint256);
        error DivideByZero();
    }


******************
Naming Conventions
******************
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

Les conventions de dénomination sont puissantes lorsqu'elles sont adoptées et utilisées à grande échelle. L'utilisation de
différentes conventions peut véhiculer des informations *méta* significatives
qui, autrement, ne seraient pas immédiatement disponibles.

Les recommandations de nommage données ici sont destinées à améliorer la lisibilité,
et ne sont donc pas des règles, mais plutôt des lignes directrices pour essayer d'aider à transmettre le
plus d'informations à travers les noms des choses.

Enfin, la cohérence au sein d'une base de code devrait toujours prévaloir sur les conventions
décrites dans ce document.


Styles de dénomination
======================

Pour éviter toute confusion, les noms suivants seront utilisés pour faire référence à différents
styles d'appellation.

* ``b`` (lettre minuscule simple)
* ``B`` (lettre majuscule simple)
* ``lettresminuscules``
* ``minuscule_avec_underscores``
* ``MAJUSCULE``
* ``MAJUSCULE_AVEC_UNDERSCORES``
* ``MotsEnMajuscule`` (ou MotsEnMaj)
* ``casMixe`` (diffère des CapitalizedWords par le caractère minuscule initial !)
* ``Mots_Capitalisés_Avec_Underscores``

.. note:: Lorsque vous utilisez des sigles dans CapWords, mettez toutes les lettres des sigles en majuscules. Ainsi, HTTPServerError est préférable à HttpServerError. Lors de l'utilisation d'initiales en mixedCase, mettez toutes les lettres des initiales en majuscules, mais gardez la première en minuscule si elle est le début du nom. Ainsi, xmlHTTPRequest est préférable à XMLHTTPRequest.


Noms à éviter
=============

* ``l`` - Lettre minuscule el
* ``O`` - Lettre majuscule oh
* ``I`` - Lettre majuscule eye

<<<<<<< HEAD
N'utilisez jamais l'un de ces noms pour des noms de variables à une seule lettre.  Elles sont
souvent impossibles à distinguer des chiffres un et zéro.
=======
* ``b`` (single lowercase letter)
* ``B`` (single uppercase letter)
* ``lowercase``
* ``UPPERCASE``
* ``UPPER_CASE_WITH_UNDERSCORES``
* ``CapitalizedWords`` (or CapWords)
* ``mixedCase`` (differs from CapitalizedWords by initial lowercase character!)

.. note:: When using initialisms in CapWords, capitalize all the letters of the initialisms. Thus HTTPServerError is better than HttpServerError. When using initialisms in mixedCase, capitalize all the letters of the initialisms, except keep the first one lower case if it is the beginning of the name. Thus xmlHTTPRequest is better than XMLHTTPRequest.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33


Noms de contrats et de bibliothèques
==========================

* Les contrats et les bibliothèques doivent être nommés en utilisant le style CapWords. Exemples : ``SimpleToken``, ``SmartBank``, ``CertificateHashRepository``, ``Player``, ``Congress``, ``Owned``.
* Les noms des contrats et des bibliothèques doivent également correspondre à leurs noms de fichiers.
* Si un fichier de contrat comprend plusieurs contrats et/ou bibliothèques, alors le nom du fichier doit correspondre au *contrat principal*. Cela n'est cependant pas recommandé si cela peut être évité.

Comme le montre l'exemple ci-dessous, si le nom du contrat est ``Congress`` et celui de la bibliothèque ``Owned``, les noms de fichiers associés doivent être ``Congress.sol`` et ``Owned.sol``.

Oui :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Owned.sol
    contract Owned {
        address public owner;

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        constructor() {
            owner = msg.sender;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

et dans ``Congress.sol`` :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";


    contract Congress is Owned, TokenRecipient {
        //...
    }

Non :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // owned.sol
    contract owned {
        address public owner;

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        constructor() {
            owner = msg.sender;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

et dans ``Congress.sol``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.7.0;


    import "./owned.sol";


    contract Congress is owned, tokenRecipient {
        //...
    }

Noms de structures
==========================

Les structures doivent être nommées en utilisant le style CapWords. Exemples :``MonCoin``, ``Position``, ``PositionXY``.


Noms d'événements
======================

Les événements doivent être nommés en utilisant le style CapWords. Exemples : ``Dépôt``, ``Transfert``, ``Approbation``, ``AvantTransfert``, ``AprèsTransfert``.


Noms des fonctions
====================

Les fonctions doivent utiliser la casse mixte. Exemples : ``getBalance``, ``transfer``, ``verifyOwner``, ``addMember``, ``changeOwner``.


Noms des arguments de la fonction
=======================

Les arguments des fonctions doivent utiliser des majuscules et des minuscules. Exemples : ``initialSupply``, ``account``, ``recipientAddress``, ``senderAddress``, ``newOwner``.

Lorsque vous écrivez des fonctions de bibliothèque qui opèrent sur un struct personnalisé, le struct
doit être le premier argument et doit toujours être nommée ``self``.


Noms des variables locales et des variables d'état
==================================================

Utilisez la casse mixte. Exemples : ``totalSupply``, ``remainingSupply``, ``balancesOf``, ``creatorAddress``, ``isPreSale``, ``tokenExchangeRate``.


Constantes
=========

Les constantes doivent être nommées avec des lettres majuscules et des caractères de soulignement pour séparer les mots.
Exemples : ``MAX_BLOCKS``, ``TOKEN_NAME``, ``TOKEN_TICKER``, ``CONTRACT_VERSION``.


Noms des modificateurs
==============

Utilisez la casse mixte. Exemples : ``onlyBy``, ``onlyAfter``, ``onlyDuringThePreSale``.


Enums
=====

Les Enums, dans le style des déclarations de type simples, doivent être nommés en utilisant le style CapWords. Exemples : ``TokenGroup``, ``Frame``, ``HashStyle``, ``CharacterLocation``.


Éviter les collisions de noms
=============================

* ``singleTrailingUnderscore_``

<<<<<<< HEAD
Cette convention est suggérée lorsque le nom souhaité entre en collision avec celui d'un
nom intégré ou autrement réservé.
=======
This convention is suggested when the desired name collides with that of
an existing state variable, function, built-in or otherwise reserved name.
>>>>>>> eb2f874eac0aa871236bf5ff04b7937c49809c33

.. _style_guide_natspec:

*******
NatSpec
*******

Les contrats Solidity peuvent également contenir des commentaires NatSpec. Ils sont écrits avec une
triple barre oblique (``///``) ou un double astérisque (``/** ... */``).
Ils doivent être utilisés directement au-dessus des déclarations de fonctions ou des instructions.

Par exemple, le contrat de :ref:`un smart contract simple <simple-smart-contract>` avec les commentaires
ajoutés, ressemble à celui ci-dessous :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    /// @author L'équipe Solidity
    /// @title Un exemple simple de stockage
    contract SimpleStorage {
        uint storedData;

        /// Stocke `x`.
        /// @param x la nouvelle valeur à stocker
        /// @dev stocke le nombre dans la variable d'état `storedData`.
        function set(uint x) public {
            storedData = x;
        }

        /// Retourner la valeur stockée.
        /// @dev récupère la valeur de la variable d'état `storedData`.
        /// @retourne la valeur stockée
        function get() public view returns (uint) {
            return storedData;
        }
    }

Il est recommandé que les contrats Solidity soient entièrement annotés en utilisant :ref:`NatSpec <natspec>` pour toutes les interfaces publiques (tout ce qui se trouve dans l'ABI).

Veuillez consulter la section sur :ref:`NatSpec <natspec>` pour une explication détaillée.
