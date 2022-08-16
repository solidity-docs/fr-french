.. index:: ! inheritance, ! base class, ! contract;base, ! deriving

********
Héritage
********

Solidity prend en charge l'héritage multiple, y compris le polymorphisme.

Le polymorphisme signifie qu'un appel de fonction (interne et externe)
exécute toujours la fonction du même nom (et des types de paramètres)
dans le contrat le plus dérivé de la hiérarchie d'héritage.
Ceci doit être explicitement activé sur chaque fonction de la
hiérarchie en utilisant les mots-clés ``virtual`` et ``override``.
Voir :ref:`Remplacement de fonctions <function-overriding>` pour plus de détails.

Il est possible d'appeler des fonctions plus haut dans la hiérarchie
d'héritage en interne, en spécifiant explicitement le contrat
en utilisant ``ContractName.functionName()`` ou en utilisant ``super.functionName()``
si vous souhaitez appeler la fonction à un niveau supérieur
dans la hiérarchie d'héritage aplatie (voir ci-dessous).

Lorsqu'un contrat hérite d'autres contrats, un seul contrat 
unique est créé sur la blockchain, et le code de tous les contrats de base
est compilé dans le contrat créé. Cela signifie que tous les appels internes
aux fonctions des contrats de base utilisent également des appels de fonctions internes
(``super.f(..)`` utilisera JUMP et non un appel de message).

Le shadowing de variables d'état est considéré comme une erreur. Un contrat dérivé peut
seulement déclarer une variable d'état ``x``, s'il n'y a pas de variable d'état visible
avec le même nom dans l'une de ses bases.

Le système d'héritage général est très similaire à
celui de Python <https://docs.python.org/3/tutorial/classes.html#inheritance>`_,
surtout en ce qui concerne l'héritage multiple, mais il y a aussi
quelques :ref:`différences <multi-inheritance>`.

Les détails sont donnés dans l'exemple suivant.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;


    contract Owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }


    // Utilisez `s` pour dériver d'un autre contrat.
    // Les contrats dérivés peuvent accéder à tous les membres non privés, y compris
    // les fonctions internes et les variables d'état. Ceux-ci ne peuvent pas être
    // accessibles en externe via `this`.
    contract Destructible is Owned {
        // Le mot clé `virtual` signifie que la fonction peut modifier
        // son comportement dans les classes dérivées ("overriding").
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }


    // Ces contrats abstraits ne sont fournis que pour faire connaître
    // l'interface au compilateur. Notez la fonction
    // sans corps. Si un contrat n'implémente pas toutes les
    // fonctions, il ne peut être utilisé que comme une interface.
    abstract contract Config {
        function lookup(uint id) public virtual returns (address adr);
    }


    abstract contract NameReg {
        function register(bytes32 name) public virtual;
        function unregister() public virtual;
    }


<<<<<<< HEAD
    // L'héritage multiple est possible. Notez que `owned`
    // est aussi une classe de base de `Destructible`, mais il n'y a qu'une seule instance de `owned`.
    // Pourtant, il n'existe qu'une seule instance de `owned` (comme pour l'héritage virtuel en C++).
=======
    // Multiple inheritance is possible. Note that `Owned` is
    // also a base class of `Destructible`, yet there is only a single
    // instance of `Owned` (as for virtual inheritance in C++).
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c
    contract Named is Owned, Destructible {
        constructor(bytes32 name) {
            Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
            NameReg(config.lookup(1)).register(name);
        }

        // Les fonctions peuvent être remplacées par une autre fonction ayant le même nom et
        // le même nombre/types d'entrées. Si la fonction de remplacement a différents
        // types de paramètres de sortie différents, cela entraîne une erreur.
        // Les appels de fonction locaux et par message tiennent compte de ces surcharges.
        // Si vous voulez que la fonction soit prioritaire, vous devez utiliser le
        // mot-clé `override`. Vous devez à nouveau spécifier le mot-clé `virtual`
        // si vous voulez que cette fonction soit à nouveau surchargée.
        function destroy() public virtual override {
            if (msg.sender == owner) {
                Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
                NameReg(config.lookup(1)).unregister();
                // Il est toujours possible d'appeler une
                // fonction spécifique surchargée.
                Destructible.destroy();
            }
        }
    }


    // Si un constructeur prend un argument, il doit être
    // fourni dans l'en-tête ou le modificateur-invocation-style à
    // le constructeur du contrat dérivé (voir ci-dessous).
    contract PriceFeed is Owned, Destructible, Named("GoldFeed") {
        function updateInfo(uint newInfo) public {
            if (msg.sender == owner) info = newInfo;
        }

        // Ici, nous ne spécifions que `override` et non `virtual`.
        // Cela signifie que les contrats dérivant de `PriceFeed`
        // ne peuvent plus modifier le comportement de `destroy`.
        function destroy() public override(Destructible, Named) { Named.destroy(); }
        function get() public view returns(uint r) { return info; }

        uint info;
    }

Notez que ci-dessus, nous appelons ``Destructible.destroy()`` pour "faire suivre" la
demande de destruction. La manière dont cela est fait est problématique,
comme le montre l'exemple suivant :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() public virtual {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ Destructible.destroy(); }
    }

    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ Destructible.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { Base2.destroy(); }
    }

Un appel à ``Final.destroy()`` fera appel à ``Base2.destroy`` parce que nous le spécifions
explicitement dans la surcharge finale, mais cette fonction contournera
``Base1.destroy``. Le moyen de contourner ce problème est d'utiliser ``super`` :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ super.destroy(); }
    }


    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ super.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { super.destroy(); }
    }

Si ``Base2`` appelle une fonction de ``super``, elle n'appelle
pas simplement cette fonction sur l'un de ses contrats de base. Au contraire, elle
appelle plutôt cette fonction sur le contrat de base suivant dans le
d'héritage final, il appellera donc ``Base1.destroy()`` (notez que
la séquence d'héritage finale est -- en commençant par le contrat le plus
contrat le plus dérivé : Final, Base2, Base1, Destructible, owned).
La fonction réelle qui est appelée lors de l'utilisation de super est
pas connue dans le contexte de la classe où elle est utilisée,
bien que son type soit connu. Il en va de même pour la recherche ordinaire de
recherche de méthode virtuelle ordinaire.

.. index:: ! overriding;function

.. _function-overriding:

Remplacement des fonctions
==========================

Les fonctions de base peuvent être surchargées par les contrats hérités pour changer leur
comportement si elles sont marquées comme ``virtual``. La fonction de remplacement doit alors
utiliser le mot-clé ``override`` dans l'en-tête de la fonction.
La fonction de remplacement ne peut que changer la visibilité de la fonction de remplacement de ``externe`` à ``public``.
La mutabilité peut être changée en une mutabilité plus stricte en suivant l'ordre :
``nonpayable`` peut être remplacé par ``view`` et ``pure``. ``view`` peut être remplacé par ``pure``.
``payable`` est une exception et ne peut pas être changé en une autre mutabilité.

L'exemple suivant démontre la modification de la mutabilité et de la visibilité :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base
    {
        function foo() virtual external view {}
    }

    contract Middle is Base {}

    contract Inherited is Middle
    {
        function foo() override public pure {}
    }

Pour l'héritage multiple, les contrats de base les plus dérivés qui définissent la même
doivent être spécifiés explicitement après le mot-clé ``override``.
En d'autres termes, vous devez spécifier tous les contrats de base qui définissent la même fonction
et qui n'ont pas encore été remplacés par un autre contrat de base (sur un chemin quelconque du graphe d'héritage).
De plus, si un contrat hérite de la même fonction à partir de plusieurs
bases (sans lien), il doit explicitement la remplacer :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        function foo() virtual public {}
    }

    contract Base2
    {
        function foo() virtual public {}
    }

    contract Inherited is Base1, Base2
    {
        // Dérive de plusieurs bases définissant foo(), nous devons donc explicitement
        // le surcharger
        function foo() public override(Base1, Base2) {}
    }

Un spécificateur de surcharge explicite n'est pas nécessaire si
la fonction est définie dans un contrat de base commun
ou s'il existe une fonction unique dans un contrat de base commun
qui prévaut déjà sur toutes les autres fonctions.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A { function f() public pure{} }
    contract B is A {}
    contract C is A {}
    // Aucune surcharge explicite n'est requise
    contract D is B, C {}

Plus formellement, il n'est pas nécessaire de surcharger une fonction (directement ou
indirectement) héritée de bases multiples s'il existe un contrat de base
qui fait partie de tous les chemins de surcharge pour la signature, et (1) cette
base implémente la fonction et qu'aucun chemin depuis le contrat
actuel vers la base ne mentionne une fonction avec cette signature ou (2) cette base
n'implémente pas la fonction et il y a au plus une mention de
la fonction dans tous les chemins allant du contrat actuel à cette base.

Dans ce sens, un chemin de surcharge pour une signature est un chemin à travers
le graphe d'héritage qui commence au contrat considéré
et se termine par un contrat mentionnant une fonction avec cette signature
qui n'est pas surchargée.

Si vous n'indiquez pas qu'une fonction qui surcharge est ``virtual``, les contrats
dérivés ne peuvent plus modifier le comportement de cette fonction.

.. note::

  Les fonctions ayant la visibilité ``private`` ne peuvent pas être ``virtual``.

.. note::

  Les fonctions sans implémentation doivent être marquées ``virtual``
  en dehors des interfaces. Dans les interfaces, toutes les fonctions sont
  automatiquement considérées comme ``virtual``.

.. note::

  A partir de Solidity 0.8.8, le mot-clé ``override``
  n'est pas nécessaire pour remplacer une fonction, au
  cas où la fonction est définie dans plusieurs bases.


Les variables d'état publiques peuvent remplacer les fonctions externes si
les types de paramètres et de retour de la fonction correspondent à la fonction getter
de la variable :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A
    {
        function f() external view virtual returns(uint) { return 5; }
    }

    contract B is A
    {
        uint public override f;
    }

.. note::

   Si les variables d'état publiques peuvent remplacer les fonctions externes,
   elles ne peuvent pas elles-mêmes être surchargées.

.. index:: ! overriding;modifier

.. _modifier-overriding:

Remplacement d'un modificateur
==============================

Les modificateurs de fonction peuvent se substituer les uns aux autres. Cela fonctionne de la même manière que
la :ref:`superposition de fonctions <function-overriding>` (sauf qu'il n'y a pas de surcharge pour les modificateurs).
Le mot-clé ``virtual`` doit être utilisé sur le modificateur surchargé
et le mot-clé ``override`` doit être utilisé dans le modificateur de surcharge :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base
    {
        modifier foo() override {_;}
    }


En cas d'héritage multiple, tous les contrats de base directs
doivent être spécifiés explicitement :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        modifier foo() virtual {_;}
    }

    contract Base2
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base1, Base2
    {
        modifier foo() override(Base1, Base2) {_;}
    }



.. index:: ! constructor

.. _constructor:

Constructeurs
=============

Un constructeur est une fonction facultative déclarée avec le mot-clé ``constructor``
qui est exécutée lors de la création du contrat, et dans laquelle vous pouvez exécuter le
code d'initialisation du contrat.

Avant que le code du constructeur ne soit exécuté, les variables d'état sont initialisées à
leur valeur spécifiée si vous les initialisez en ligne, ou leur :ref:`valeur par défaut<default-value>` si vous ne le faites pas.

Après l'exécution du constructeur, le code définitif du contrat est déployé
sur la blockchain. Le déploiement du
code coûte un gaz supplémentaire linéaire à la longueur du code.
Ce code comprend toutes les fonctions qui font partie de l'interface publique
et toutes les fonctions qui sont accessibles à partir de celle-ci par des appels de fonction.
Il ne comprend pas le code du constructeur ni les fonctions internes qui ne sont
appelées uniquement depuis le constructeur.

S'il n'y a pas de constructeur, le contrat prendra en charge le constructeur par défaut, qui est
équivalent à ``constructor() {}``. Par exemple :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    abstract contract A {
        uint public a;

        constructor(uint a_) {
            a = a_;
        }
    }

    contract B is A(1) {
        constructor() {}
    }

Vous pouvez utiliser des paramètres internes dans un constructeur (par exemple des pointeurs de stockage). Dans ce cas,
le contrat doit être marqué :ref:`abstract <abstract-contract>`, parce que ces paramètres ne peuvent
pas se voir attribuer de valeurs valides de l'extérieur, mais uniquement par le biais des constructeurs des contrats dérivés.

.. warning::
    Avant la version 0.4.22, les constructeurs étaient définis comme des fonctions portant le même nom que le contrat.
    Cette syntaxe a été dépréciée et n'est plus autorisée dans la version 0.5.0.

.. warning::
    Avant la version 0.7.0, vous deviez spécifier la visibilité des constructeurs comme étant soit
    ``internal`` ou ``public``.


.. index:: ! base;constructor, inheritance list, contract;abstract, abstract contract

Arguments pour les constructeurs de base
========================================

Les constructeurs de tous les contrats de base seront appelés en suivant les
règles de linéarisation expliquées ci-dessous. Si les constructeurs de base ont des arguments,
les contrats dérivés doivent tous les spécifier. Ceci peut être fait de deux manières :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base {
        uint x;
        constructor(uint x_) { x = x_; }
    }

    // Soit spécifier directement dans la liste d'héritage...
    contract Derived1 is Base(7) {
        constructor() {}
    }

<<<<<<< HEAD
    // ou par un "modificateur" du constructeur dérivé.
=======
    // or through a "modifier" of the derived constructor...
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c
    contract Derived2 is Base {
        constructor(uint y) Base(y * y) {}
    }

    // or declare abstract...
    abstract contract Derived3 is Base {
    }

    // and have the next concrete derived contract initialize it.
    contract DerivedFromDerived is Derived3 {
        constructor() Base(10 + 10) {}
    }

<<<<<<< HEAD
L'une des façons est directement dans la liste d'héritage (``est Base(7)``).
L'autre est dans la façon dont un modificateur est invoqué dans le cadre du
constructeur dérivé (``Base(_y * _y)``). La première façon
est plus pratique si l'argument du constructeur est une
constante et définit le comportement du contrat ou le
le décrit. La deuxième façon doit être utilisée si les
arguments du constructeur de la base dépendent de ceux du
contrat dérivé. Les arguments doivent être donnés soit dans la
liste d'héritage ou dans le style modificateur dans le constructeur dérivé.
Spécifier les arguments aux deux endroits est une erreur.

Si un contrat dérivé ne spécifie pas les arguments de tous les constructeurs de ses contrats
de base, il sera considéré comme un contrat abstrait.
=======
One way is directly in the inheritance list (``is Base(7)``).  The other is in
the way a modifier is invoked as part of
the derived constructor (``Base(y * y)``). The first way to
do it is more convenient if the constructor argument is a
constant and defines the behaviour of the contract or
describes it. The second way has to be used if the
constructor arguments of the base depend on those of the
derived contract. Arguments have to be given either in the
inheritance list or in modifier-style in the derived constructor.
Specifying arguments in both places is an error.

If a derived contract does not specify the arguments to all of its base
contracts' constructors, it must be declared abstract. In that case, when
another contract derives from it, that other contract's inheritance list
or constructor must provide the necessary parameters
for all base classes that haven't had their parameters specified (otherwise,
that other contract must be declared abstract as well). For example, in the above
code snippet, see ``Derived3`` and ``DerivedFromDerived``.
>>>>>>> a0ee14f7c2bddfccf20bf8656b0340e07b02922c

.. index:: ! inheritance;multiple, ! linearization, ! C3 linearization

.. _multi-inheritance:

Héritage multiple et linéarisation
==================================

Les langages qui autorisent l'héritage multiple doivent faire face à
plusieurs problèmes. L'un d'entre eux est le `problème du diamant <https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem>`_.
Solidity est similaire à Python en ce qu'il utilise la "`C3 Linearization <https://en.wikipedia.org/wiki/C3_linearization>`_"
pour forcer un ordre spécifique dans le graphe acyclique dirigé (DAG) des classes de base. Cette
propriété souhaitable de la monotonicité, mais
désapprouve certains graphes d'héritage. En particulier, l'ordre dans lequel
dans lequel les classes de base sont données dans la directive ``s`` est
important : Vous devez lister les contrats de base directs
dans l'ordre de "le plus similaire à la base" à "le plus dérivé".
Notez que cet ordre est l'inverse de celui utilisé en Python.

Une autre façon simplifiée d'expliquer ceci est que lorsqu'une fonction est appelée qui
est définie plusieurs fois dans différents contrats, les bases données
sont recherchées de droite à gauche (de gauche à droite en Python) de manière approfondie,
s'arrêtant à la première correspondance. Si un contrat de base a déjà été recherché, il est ignoré.

Dans le code suivant, Solidity donnera l'erreur suivante
erreur "Linearization of inheritance graph impossible" ("Linéarisation du graphe d'héritage impossible").

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract X {}
    contract A is X {}
    // Cela ne compilera pas
    contract C is A, X {}

La raison en est que ``C`` demande à ``X`` de supplanter ``A``
(en spécifiant ``A, X`` dans cet ordre), mais ``A`` lui-même
demande d'outrepasser ``X``, ce qui est une
contradiction qui ne peut être résolue.

En raison du fait que vous devez explicitement surcharger une fonction
qui est héritée de plusieurs bases sans une surcharge unique,
la linéarisation de C3 n'est pas trop importante en pratique.

Un domaine où la linéarisation de l'héritage est particulièrement importante et peut-être pas aussi claire est lorsqu'il y a plusieurs constructeurs dans la hiérarchie de l'héritage. Les constructeurs seront toujours exécutés dans l'ordre linéarisé, quel que soit l'ordre dans lequel leurs arguments sont fournis dans le constructeur du contrat hérité. Par exemple :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base1 {
        constructor() {}
    }

    contract Base2 {
        constructor() {}
    }

    // Les constructeurs sont exécutés dans l'ordre suivant :
    //  1 - Base1
    //  2 - Base2
    //  3 - Derived1
    contract Derived1 is Base1, Base2 {
        constructor() Base1() Base2() {}
    }

    // Les constructeurs sont exécutés dans l'ordre suivant :
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived2
    contract Derived2 is Base2, Base1 {
        constructor() Base2() Base1() {}
    }

    // Les constructeurs sont toujours exécutés dans l'ordre suivant :
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived3
    contract Derived3 is Base2, Base1 {
        constructor() Base1() Base2() {}
    }


Hériter de différents types de membres portant le même nom
==========================================================

C'est une erreur lorsque l'une des paires suivantes dans un contrat porte le même nom en raison de l'héritage :
  - une fonction et un modificateur
  - une fonction et un événement
  - un événement et un modificateur

À titre d'exception, un getter de variable d'état peut remplacer une fonction externe.
