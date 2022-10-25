.. index:: abi, application binary interface

.. _ABI:

**************************
Spécification ABI pour les contrats
**************************

Conception de base
============

L'interface binaire d'application de contrat (ABI) est le moyen standard d'interagir avec les contrats dans l'écosystème Ethereum, à la fois depuis l'extérieur de la blockchain et pour l'interaction entre les contrats.
de l'extérieur de la blockchain que pour l'interaction entre contrats. Les données sont codées en fonction de leur type,
comme décrit dans cette spécification. L'encodage n'est pas autodécrit et nécessite donc un schéma pour être décodé.

<<<<<<< HEAD
Nous supposons que les fonctions d'interface d'un contrat sont fortement typées, connues au moment de la compilation et statiques.
Nous supposons que tous les contrats auront les définitions d'interface de tous les contrats qu'ils appellent disponibles au moment de la compilation.
=======
We assume that the interface functions of a contract are strongly typed, known at compilation time and static.
We assume that all contracts will have the interface definitions of any contracts they call available at compile-time.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

Cette spécification ne concerne pas les contrats dont l'interface est dynamique ou connue uniquement au moment de l'exécution.

.. _abi_function_selector:
.. index:: ! selector; of a function

Sélecteur de fonctions
=================

<<<<<<< HEAD
Les quatre premiers octets des données d'appel d'une fonction spécifient la fonction à appeler. Il s'agit des
premiers (gauche, ordre supérieur en big-endian) quatre octets du hachage Keccak-256 de la signature de la fonction.
la fonction. La signature est définie comme l'expression canonique du prototype de base sans spécificateur d'emplacement de données, c'est-à-dire qu'il s'agit de l'expression canonique de la fonction.
spécificateur d'emplacement de données, c'est-à-dire
le nom de la fonction avec la liste des types de paramètres entre parenthèses. Les types de paramètres sont séparés par une simple
virgule - aucun espace n'est utilisé.
=======
The first four bytes of the call data for a function call specifies the function to be called. It is the
first (left, high-order in big-endian) four bytes of the Keccak-256 hash of the signature of
the function. The signature is defined as the canonical expression of the basic prototype without data
location specifier, i.e.
the function name with the parenthesised list of parameter types. Parameter types are split by a single
comma — no spaces are used.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

.. note::
    Le type de retour d'une fonction ne fait pas partie de cette signature. Dans
    :ref:`Solidity's function overloading <overload-function>` les types de retour ne sont pas pris en compte.
    La raison est de garder la résolution d'appel de fonction indépendante du contexte.
    La description :ref:`JSON de l'ABI<abi_json>` contient cependant des entrées et des sorties.

Codage des arguments
=================

À partir du cinquième octet, les arguments codés suivent. Ce codage est également utilisé à d'autres
d'autres endroits, par exemple les valeurs de retour et les arguments d'événements sont codés de la même manière,
sans les quatre octets spécifiant la fonction.

Types
=====

Les types élémentaires suivants existent :

- ``uint<M>`` : type de nombre entier non signé de ``M`` bits, ``0 < M <= 256``, ``M % 8 == 0``. Par exemple, ``uint32``, ``uint8``, ``uint256``.

- ``int<M>`` : type d'entier signé en complément à deux de ``M`` bits, ``0 < M <= 256``, ``M % 8 == 0``.

- ``address`` : équivalent à ``uint160``, sauf pour l'interprétation supposée et le typage du langage.
  Pour calculer le sélecteur de fonction, on utilise ``address``.

- ``uint``, ``int`` : synonymes de ``uint256``, ``int256`` respectivement. Pour calculer le sélecteur de fonction
  sélecteur de fonction, ``uint256`` et ``int256`` doivent être utilisés.

- ``bool`` : équivalent à ``uint8`` restreint aux valeurs 0 et 1. Pour le calcul du sélecteur de fonction, ``bool`` est utilisé.

- ``fixed<M>x<N>`` : nombre décimal signé en virgule fixe de ``M`` bits, ``8 <= M <= 256``,
  ``M % 8 == 0``, et ``0 < N <= 80``, qui désigne la valeur `v`` comme ``v / (10 ** N)``.

- ``ufixed<M>x<N>`` : variante non signée de ``fixed<M>x<N>``.

- ``fixed``, ``ufixed`` : synonymes de ``fixed128x18``, ``ufixed128x18`` respectivement. Pour
  calculer le sélecteur de fonction, il faut utiliser `fixed128x18`` et `ufixed128x18``.

- ``bytes<M>`` : type binaire de ``M`` octets, ``0 < M <= 32``.

- ``fonction`` : une adresse (20 octets) suivie d'un sélecteur de fonction (4 octets). Encodé de manière identique à ``bytes24``.

Le type de tableau (de taille fixe) suivant existe :

- ``<type>[M]`` : un tableau de longueur fixe de ``M`` éléments, ``M >= 0``, du type donné.

  .. note: :

      Bien que cette spécification ABI puisse exprimer des tableaux de longueur fixe avec zéro élément, ils ne sont pas supportés par le compilateur.

Les types de taille non fixe suivants existent :

- ``bytes`` : séquence d'octets de taille dynamique.

- ``string`` : chaîne unicode de taille dynamique supposée être encodée en UTF-8.

- ``<type>[]`` : un tableau de longueur variable d'éléments du type donné.

Les types peuvent être combinés en un tuple en les mettant entre parenthèses, séparés par des virgules :

- ``(T1,T2,...,Tn)`` : tuple constitué des types ``T1``, ..., ``Tn``, ``n >= 0``

Il est possible de former des tuples de tuples, des tableaux de tuples et ainsi de suite. Il est également possible de former des n-uplets zéro (où ``n == 0``).

Correspondance entre Solidity et les types ABI
-----------------------------

Solidity supporte tous les types présentés ci-dessus avec les mêmes noms, à l'exception des tuples.
l'exception des tuples. Par contre, certains types Solidity ne sont pas supportés par l'ABI
par l'ABI. Le tableau suivant montre sur la colonne de gauche les types Solidity qui
qui ne font pas partie de l'ABI et, dans la colonne de droite, les types ABI qui les représentent.
qui les représentent.

+-------------------------------+-----------------------------------------------------------------------------+
|      Solidity                 |                                           ABI                               |
+===============================+=============================================================================+
|:ref:`addresse payable<address>`|``address``                                                                 |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`contract<contracts>`     |``address``                                                                  |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`enum<enums>`             |``uint8``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`types de valeurs définies|                                                                             |
|par l'utilisateur              |                                                                             |
|<user-defined-value-types>`    |                                                                             |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`struct<structs>`         |``tuple``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+

.. warning::
    Avant la version ``0.8.0`` les enums pouvaient avoir plus de 256 membres et étaient représentés par le plus petit type de
    plus petit type d'entier juste assez grand pour contenir la valeur de n'importe quel membre.

Critères de conception pour l'encodage
================================

Le codage est conçu pour avoir les propriétés suivantes, qui sont particulièrement utiles si certains arguments sont des tableaux imbriqués :

1. Le nombre de lectures nécessaires pour accéder à une valeur est au plus égal à la profondeur de la valeur dans la structure du tableau d'arguments.
   dans la structure du tableau d'arguments, c'est-à-dire que quatre lectures sont nécessaires pour récupérer ``a_i[k][l][r]``. Dans une version
   version précédente de l'ABI, le nombre de lectures était linéairement proportionnel au nombre total de paramètres dynamiques dans le pire des cas.
   dynamiques dans le pire des cas.

<<<<<<< HEAD
2. Les données d'une variable ou d'un élément de tableau ne sont pas entrelacées avec d'autres données et elles sont
   relocalisables, c'est-à-dire qu'elles n'utilisent que des "adresses" relatives.
=======
2. The data of a variable or an array element is not interleaved with other data and it is
   relocatable, i.e. it only uses relative "addresses".
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42


Spécification formelle de l'encodage
====================================

Nous distinguons les types statiques et dynamiques. Les types statiques sont codés sur place et les types dynamiques sont
dynamiques sont codés à un emplacement alloué séparément après le bloc actuel.

**Définition:** Les types suivants sont appelés "dynamiques" :

* ``bytes``
* Chaîne de caractères
* ``T[]`` pour tout ``T``
* ``T[k]`` pour tout ``T`` dynamique et tout ``k >= 0``
* ``(T1,...,Tk)`` si ``Ti`` est dynamique pour tout ``1 <= i <= k``

Tous les autres types sont dits "statiques".

**Définition:** ``len(a)`` est le nombre d'octets dans une chaîne binaire ``a``.
Le type de ``len(a)`` est supposé être ``uint256``.

Nous définissons ``enc``, le codage réel, comme une correspondance entre les valeurs des types ABI et les chaînes binaires telles que
que ``len(enc(X))`` dépend de la valeur de ``X`` si et seulement si le type de ``X`` est dynamique.

**Définition:** Pour toute valeur ABI ``X``, on définit récursivement ``enc(X)``, en fonction du type de ``X``.
du type de ``X`` qui est

- ``(T1,...,Tk)`` pour ``k >= 0`` et tout type ``T1``, ..., ``Tk``

  ``enc(X) = head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(k))``

  où ``X = (X(1), ..., X(k))`` et
  tête " et " queue " sont définies comme suit pour " Ti " :

  si ``Ti`` est statique :

    ``head(X(i)) = enc(X(i))`` et ``tail(X(i)) = ""`` (la chaîne vide)

  sinon, c'est-à-dire si `Ti`` est dynamique :

    ``head(X(i)) = enc(len( head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(i-1)) ))``
    ``tail(X(i)) = enc(X(i))``

  Notez que dans le cas dynamique, ``head(X(i))`` est bien défini car les longueurs des parties de tête
  parties de la tête ne dépendent que des types et non des valeurs. La valeur de ``head(X(i))`` est le décalage du début de ``tail(X(i))``.
  du début de ``tail(X(i))`` par rapport au début de ``enc(X)``.

- ``T[k]`` pour tout ``T`` et ``k`` :

  ``enc(X) = enc((X[0], ..., X[k-1]))``

  c'est-à-dire qu'il est codé comme s'il s'agissait d'un tuple avec ``k`` éléments
  du même type.

- ``T[]`` où ``X`` a `k`` éléments (``k`` est supposé être de type ``uint256``) :

  ``enc(X) = enc(k) enc((X[0], ..., X[k-1]))``

<<<<<<< HEAD
  c'est-à-dire qu'il est encodé comme s'il s'agissait d'un tableau de taille statique ``k``, préfixé par le
  le nombre d'éléments.
=======
  i.e. it is encoded as if it were a tuple with ``k`` elements of the same type (resp. an array of static size ``k``), prefixed with
  the number of elements.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

- ``bytes``, de longueur ``k`` (qui est supposé être de type ``uint256``) :

  ``enc(X) = enc(k) pad_right(X)``, c'est-à-dire que le nombre d'octets est codé sous forme de
  ``uint256`` suivi de la valeur réelle de ``X`` en tant que séquence d'octets, suivie par
  le nombre minimal d'octets zéro pour que ``len(enc(X))`` soit un multiple de 32.

- ``Chaîne de caractères`` :

  ``enc(X) = enc(enc_utf8(X))``, c'est-à-dire que ``X`` est codé en UTF-8 et que cette valeur est interprétée
  comme étant du type ``bytes`` et encodée plus loin. Notez que la longueur utilisée dans ce codage
  est le nombre d'octets de la chaîne encodée en UTF-8, et non son nombre de caractères.

- ``uint<M>`` : ``enc(X)`` est le codage big-endian de ``X``, complété du côté gauche par des octets zéro.
  d'ordre supérieur (gauche) avec des octets zéro de sorte que la longueur soit de 32 octets.
- Adresse : comme dans le cas de ``uint160``.
- ``int<M>`` : ``enc(X)`` est le code de complément à deux big-endian de ``X``, complété sur le côté supérieur (gauche) par des octets ``0xff`` pour les ``X`` négatifs et par des octets zéro pour les ``X`` non négatifs, de sorte que la longueur soit de 32 octets.
- ``bool`` : comme dans le cas de ``uint8``, où ``1`` est utilisé pour ``vrai`` et ``0`` pour ``false``.
- ``fixed<M>x<N>` : ``enc(X)`` est ``enc(X * 10**N)`` où ``X * 10**N`` est interprété comme un ``int256``.
- ``fixed`` : comme dans le cas ``fixed128x18``
- ``ufixed<M>x<N>` : ``enc(X)`` est ``enc(X * 10**N)`` où ``X * 10**N`` est interprété comme un ``uint256``.
- ``ufixed`` : comme dans le cas ``ufixed128x18``
- ``bytes<M>`` : ``enc(X)`` est la séquence d'octets dans ``X`` remplie de zéros de queue jusqu'à une longueur de 32 octets.

Notez que pour tout ``X``, ``len(enc(X))`` est un multiple de 32.

Sélecteur de fonctions et codage des arguments
=======================================

En somme, un appel à la fonction ``f`` avec les paramètres ``a_1, ..., a_n`` est encodé comme suit

  ``fonction_selector(f) enc((a_1, ..., a_n))``

et les valeurs de retour ``v_1, ..., v_k`` de ``f`` sont codées en tant que

  ``enc((v_1, ..., v_k))``

c'est-à-dire que les valeurs sont combinées en un tuple et codées.

Exemples
========

Étant donné le contrat :

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Foo {
        function bar(bytes3[2] memory) public pure {}
        function baz(uint32 x, bool y) public pure returns (bool r) { r = x > 32 || y; }
        function sam(bytes memory, bool, uint[] memory) public pure {}
    }


<<<<<<< HEAD
Ainsi, pour notre exemple ``Foo``, si nous voulions appeler ``baz`` avec les paramètres ``69`` et
``true``, nous passerions 68 octets au total, qui peuvent être décomposés en :
=======
Thus, for our ``Foo`` example if we wanted to call ``baz`` with the parameters ``69`` and
``true``, we would pass 68 bytes total, which can be broken down into:
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

- ``0xcdcd77c0`` : l'ID de la méthode. Il s'agit des 4 premiers octets du hachage de Keccak de la forme
  la forme ASCII de la signature ``baz(uint32,bool)``.
- ``0x0000000000000000000000000000000000000000000000000000000000000045`` : le premier paramètre,
  une valeur uint32 ``69`` remplie de 32 octets
- ``0x0000000000000000000000000000000000000000000000000000000000000001`` : le deuxième paramètre, un booléen
  ``vrai``, padded to 32 bytes

Au total :

.. code-block:: none

    0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001

Elle renvoie un seul ``bool``. Si, par exemple, elle devait retourner ``false``, sa sortie serait
le tableau d'octets unique ``0x000000000000000000000000000000000000000000000000``, un seul bool.

Si nous voulions appeler ``bar`` avec l'argument ``["abc", "def"]``, nous passerions 68 octets au total, répartis en :

- ``0xfce353f6`` : l'identifiant de la méthode. Celui-ci est dérivé de la signature ``bar(bytes3[2])``.
- ``0x6162630000000000000000000000000000000000000000000000000000000000`` : la première partie du premier
  paramètre, une valeur ``bytes3`` "abc"`` (alignée à gauche).
- ``0x6465660000000000000000000000000000000000000000000000000000000000`` : la deuxième partie du premier paramètre, une valeur ``bytes3`` (alignée à gauche).
  paramètre, un ``bytes3`` de valeur ``"def"`` (aligné à gauche).

Au total :

.. code-block:: none

    0xfce353f661626300000000000000000000000000000000000000000000000000000000006465660000000000000000000000000000000000000000000000000000000000

Si nous voulions appeler ``sam`` avec les arguments ``"dave"``, ``true`` et ``[1,2,3]``, nous devrions
passerait 292 octets au total, répartis comme suit :

- ``0xa5643bf2`` : l'identifiant de la méthode. Celui-ci est dérivé de la signature ``sam(bytes,bool,uint256[])``. Notez que ``uint`` est remplacé par sa représentation canonique ``uint256``.
- ``0x0000000000000000000000000000000000000000000000000000000000000060`` : l'emplacement de la partie données du premier paramètre (type dynamique), mesuré en octets à partir du début du bloc d'arguments. Dans ce cas, ``0x60``.
- ``0x0000000000000000000000000000000000000000000000000000000000000001`` : le deuxième paramètre : booléen vrai.
- ``0x00000000000000000000000000000000000000000000000000000000000000a0`` : l'emplacement de la partie données du troisième paramètre (type dynamique), mesuré en octets. Dans ce cas, ``0xa0``.
- ``0x0000000000000000000000000000000000000000000000000000000000000004`` : la partie données du premier argument, elle commence par la longueur du tableau d'octets en éléments, dans ce cas, 4.
- ``0x6461766500000000000000000000000000000000000000000000000000000000`` : le contenu du premier argument : l'encodage UTF-8 (équivalent à l'ASCII dans ce cas) de ``"dave"``, padded sur la droite à 32 octets.
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` : la partie données du troisième argument, elle commence par la longueur du tableau en éléments, dans ce cas, 3.
- ``0x0000000000000000000000000000000000000000000000000000000000000001`` : la première entrée du troisième paramètre.
- ``0x0000000000000000000000000000000000000000000000000000000000000002`` : la deuxième entrée du troisième paramètre.
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` : la troisième entrée du troisième paramètre.

Au total :

.. code-block:: none

    0xa5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003

Utilisation des types dynamiques
====================

<<<<<<< HEAD
Un appel à une fonction dont la signature est ``f(uint,uint32[],bytes10,bytes)`` avec les valeurs suivantes
``(0x123, [0x456, 0x789], "1234567890", "Hello, world !")`` est codé de la manière suivante :
=======
A call to a function with the signature ``f(uint256,uint32[],bytes10,bytes)`` with values
``(0x123, [0x456, 0x789], "1234567890", "Hello, world!")`` is encoded in the following way:
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

Nous prenons les quatre premiers octets de ``sha3("f(uint256,uint32[],bytes10,bytes)")``, c'est-à-dire ``0x8be65246``.
Ensuite, nous encodons les parties de tête des quatre arguments. Pour les types statiques ``uint256`` et ``bytes10``,
ce sont directement les valeurs que nous voulons passer, alors que pour les types dynamiques ``uint32[]`` et ``bytes``,
nous utilisons le décalage en octets par rapport au début de leur zone de données, mesuré à partir du début de l'encodage de la valeur (c'est-à-dire pas de l'encodage de la valeur).
(c'est-à-dire sans compter les quatre premiers octets contenant le hachage de la signature de la fonction). Ces valeurs sont les suivantes

- ``0x0000000000000000000000000000000000000000000000000000000000000123`` (``0x123`` padded to 32 bytes)
- ``0x0000000000000000000000000000000000000000000000000000000000000080`` (décalage du début de la partie données du second paramètre, 4*32 octets, exactement la taille de la partie tête)
- ``0x3132333435363738393000000000000000000000000000000000000000000000`` (``"1234567890"`` padded to 32 bytes on the right)
- ``0x00000000000000000000000000000000000000000000000000000000000000e0`` (décalage du début de la partie données du quatrième paramètre = décalage du début de la partie données du premier paramètre dynamique + taille de la partie données du premier paramètre dynamique = 4\*32 + 3\*32 (voir ci-dessous))

Ensuite, la partie données du premier argument dynamique, ``[0x456, 0x789]``, est la suivante :

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (nombre d'éléments du tableau, 2)
- ``0x0000000000000000000000000000000000000000000000000000000000000456`` (premier élément)
- ``0x0000000000000000000000000000000000000000000000000000000000000789`` (deuxième élément)

Enfin, nous encodons la partie données du second argument dynamique, "Hello, world !":

- ``0x000000000000000000000000000000000000000000000000000000000000000d`` (nombre d'éléments (octets dans ce cas) : 13)
- ``0x48656c6c6f2c20776f726c642100000000000000000000000000000000000000`` (``"Hello, world !"`` padded to 32 bytes on the right)

Au total, le codage est le suivant (nouvelle ligne après le sélecteur de fonction et chaque 32 octets pour plus de clarté) :

.. code-block:: none

    0x8be65246
      0000000000000000000000000000000000000000000000000000000000000123
      0000000000000000000000000000000000000000000000000000000000000080
      3132333435363738393000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000e0
      0000000000000000000000000000000000000000000000000000000000000002
      0000000000000000000000000000000000000000000000000000000000000456
      0000000000000000000000000000000000000000000000000000000000000789
      000000000000000000000000000000000000000000000000000000000000000d
      48656c6c6f2c20776f726c642100000000000000000000000000000000000000

<<<<<<< HEAD
Appliquons le même principe pour encoder les données d'une fonction de signature ``g(uint[][],string[])``
avec les valeurs ``([1, 2], [3]], ["un", "deux", "trois"])`` mais commençons par les parties les plus atomiques de l'encodage :
=======
Let us apply the same principle to encode the data for a function with a signature ``g(uint256[][],string[])``
with values ``([[1, 2], [3]], ["one", "two", "three"])`` but start from the most atomic parts of the encoding:
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

D'abord, nous encodons la longueur et les données du premier tableau dynamique intégré ``[1, 2]`` du premier tableau racine ``[[1, 2], [3]]`` :

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (nombre d'éléments du premier tableau, 2 ; les éléments eux-mêmes sont ``1`` et ``2``)
- ``0x0000000000000000000000000000000000000000000000000000000000000001`` (premier élément)
- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (deuxième élément)

Ensuite, nous codons la longueur et les données du deuxième tableau dynamique intégré ``[3]`` du premier tableau racine ``[[1, 2], [3]]`` :

- ``0x0000000000000000000000000000000000000000000000000000000000000001`` (nombre d'éléments dans le second tableau, 1 ; l'élément est ``3``)
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (premier élément)

Nous devons ensuite trouver les décalages `a`` et `b`` pour leurs tableaux dynamiques respectifs ``[1, 2]`` et ``[3]``.
Pour calculer les décalages, nous pouvons examiner les données codées du premier tableau racine ``[[1, 2], [3]]``.
en énumérant chaque ligne du codage :

.. code-block:: none

    0 - a                                                                - décalage de [1, 2]
    1 - b                                                                - décalage de [3]
    2 - 0000000000000000000000000000000000000000000000000000000000000002 - compte pour [1, 2]
    3 - 0000000000000000000000000000000000000000000000000000000000000001 - codage de 1
    4 - 0000000000000000000000000000000000000000000000000000000000000002 - codage de 2
    5 - 0000000000000000000000000000000000000000000000000000000000000001 - compte pour [3]
    6 - 0000000000000000000000000000000000000000000000000000000000000003 - codage de 3

Le décalage ``a`` pointe vers le début du contenu du tableau ``[1, 2]`` qui est la ligne 2 (64 octets).
2 (64 octets) ; ainsi ``a = 0x0000000000000000000000000000000000000000000000000000000000000040``.

Le décalage ``b`` pointe vers le début du contenu du tableau ``[3]`` qui est la ligne 5 (160 octets) ;
donc ``b = 0x00000000000000000000000000000000000000000000000000000000000000a0``.


Ensuite, nous encodons les chaînes intégrées du deuxième tableau racine :

- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (nombre de caractères dans le mot ``"one"``)
- ``0x6f6e650000000000000000000000000000000000000000000000000000000000`` (représentation utf8 du mot ``"one"``)
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (nombre de caractères dans le mot ``"two"``)
- ``0x74776f0000000000000000000000000000000000000000000000000000000000`` (représentation utf8 du mot ``"two"``)
- ``0x0000000000000000000000000000000000000000000000000000000000000005`` (nombre de caractères dans le mot ``"three"``)
- ``0x7468726565000000000000000000000000000000000000000000000000000000`` (représentation utf8 du mot ``"three"``)

Parallèlement au premier tableau racine, puisque les chaînes sont des éléments dynamiques, nous devons trouver leurs décalages ``c``, ``d`` et ``e`` :

.. code-block:: none

    0 - c                                                                - décalage pour "un"
    1 - d                                                                - décalage pour "deux"
    2 - e                                                                - décalage pour "trois"
    3 - 0000000000000000000000000000000000000000000000000000000000000003 - compte pour "un"
    4 - 6f6e650000000000000000000000000000000000000000000000000000000000 - codage pour "un"
    5 - 0000000000000000000000000000000000000000000000000000000000000003 - compte pour "deux"
    6 - 74776f0000000000000000000000000000000000000000000000000000000000 - codage pour "deux"
    7 - 0000000000000000000000000000000000000000000000000000000000000005 - compte pour "trois"
    8 - 7468726565000000000000000000000000000000000000000000000000000000 - codage pour "trois"

L'offset ``c`` pointe vers le début du contenu de la chaîne ``"one"`` qui est la ligne 3 (96 octets) ;
donc ``c = 0x0000000000000000000000000000000000000000000000000000000000000060``.

Le décalage ``d`` pointe vers le début du contenu de la chaîne ``"two"`` qui est la ligne 5 (160 octets) ;
donc ``d = 0x00000000000000000000000000000000000000000000000000000000000000a0``.

Le décalage ``e`` pointe vers le début du contenu de la chaîne ``"trois"`` qui est la ligne 7 (224 octets) ;
donc ``e = 0x00000000000000000000000000000000000000000000000000000000000000e0``.


<<<<<<< HEAD
Notez que les encodages des éléments intégrés des tableaux racines ne sont pas dépendants les uns des autres
et ont les mêmes encodages pour une fonction avec une signature ``g(string[],uint[][])``.
=======
Note that the encodings of the embedded elements of the root arrays are not dependent on each other
and have the same encodings for a function with a signature ``g(string[],uint256[][])``.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

Ensuite, nous encodons la longueur du premier tableau racine :

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (nombre d'éléments dans le premier tableau racine, 2 ; les éléments eux-mêmes sont ``[1, 2]`` et ``[3]``)

Ensuite, nous codons la longueur du deuxième tableau racine :

- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (nombre de chaînes dans le deuxième tableau racine, 3 ; les chaînes elles-mêmes sont ``"un"``, ``"deux"`` et ``"trois"``)

Enfin, nous trouvons les décalages `f`` et ``g`` pour leurs tableaux dynamiques racines respectifs ``[[1, 2], [3]]`` et
``["un", "deux", "trois"]``, et assemblons les pièces dans le bon ordre :

.. code-block:: none

    0x2289b18c                                                            - signature de la fonction
     0 - f                                                                - décalage de [[1, 2], [3]]
     1 - g                                                                - décalage de ["un", "deux", "trois"]
     2 - 0000000000000000000000000000000000000000000000000000000000000002 - compte pour [[1, 2], [3]]
     3 - 0000000000000000000000000000000000000000000000000000000000000040 - décalage de [1, 2]
     4 - 00000000000000000000000000000000000000000000000000000000000000a0 - décalage de [3]
     5 - 0000000000000000000000000000000000000000000000000000000000000002 - compte pour [1, 2]
     6 - 0000000000000000000000000000000000000000000000000000000000000001 - codage de 1
     7 - 0000000000000000000000000000000000000000000000000000000000000002 - codage de 2
     8 - 0000000000000000000000000000000000000000000000000000000000000001 - compte pour [3]
     9 - 0000000000000000000000000000000000000000000000000000000000000003 - codage de 3
    10 - 0000000000000000000000000000000000000000000000000000000000000003 - compte pour ["un", "deux", "trois"]
    11 - 0000000000000000000000000000000000000000000000000000000000000060 - décalage pour "un"
    12 - 00000000000000000000000000000000000000000000000000000000000000a0 - décalage pour "deux"
    13 - 00000000000000000000000000000000000000000000000000000000000000e0 - décalage pour "trois"
    14 - 0000000000000000000000000000000000000000000000000000000000000003 - compte pour "un"
    15 - 6f6e650000000000000000000000000000000000000000000000000000000000 - codage de "un"
    16 - 0000000000000000000000000000000000000000000000000000000000000003 - compte pour "deux"
    17 - 74776f0000000000000000000000000000000000000000000000000000000000 - codage de "deux"
    18 - 0000000000000000000000000000000000000000000000000000000000000005 - compte pour "trois"
    19 - 7468726565000000000000000000000000000000000000000000000000000000 - codage de "trois"

Le décalage ``f`` pointe vers le début du contenu du tableau ``[[1, 2], [3]]`` qui est la ligne 2 (64 octets) ;
donc ``f = 0x0000000000000000000000000000000000000000000000000000000000000040``.

Le décalage ``g`` pointe vers le début du contenu du tableau ``["one", "two", "three"]`` qui est la ligne 10 (320 octets) ;
donc ``g = 0x0000000000000000000000000000000000000000000000000000000000000140``.

.. _abi_events:

Événements
======

Les événements sont une abstraction du protocole de journalisation et de surveillance des événements d'Ethereum. Les entrées de journal fournissent l'adresse du contrat
du contrat, une série de quatre sujets maximum et des données binaires de longueur arbitraire. Les événements exploitent la fonction existante
ABI existante afin d'interpréter ceci (avec une spécification d'interface) comme une structure correctement typée.

Étant donné un nom d'événement et une série de paramètres d'événement, nous les divisons en deux sous-séries : celles qui sont indexées et celles qui ne le sont pas.
ceux qui ne le sont pas.
Ceux qui sont indexés, dont le nombre peut aller jusqu'à 3 (pour les événements non anonymes) ou 4 (pour les événements anonymes), sont utilisés
avec le hachage Keccak de la signature de l'événement pour former les sujets de l'entrée du journal.
Ceux qui ne sont pas indexés forment le tableau d'octets de l'événement.

En fait, une entrée de journal utilisant cette ABI est décrite comme suit :

- ``address`` : l'adresse du contrat (intrinsèquement fournie par Ethereum) ;
- ``topics[0]`` : ``keccak(EVENT_NAME+ "("+EVENT_ARGS.map(canonical_type_of).join(",")+")")`` (``canonical_type_of`` est une fonction qui renvoie simplement le nom du contrat.
  est une fonction qui renvoie simplement le type canonique d'un argument donné, par exemple, pour ``uint indexé foo``, elle renverrait
  retournerait ``uint256``). Cette valeur n'est présente dans ``topics[0]`` que si l'événement n'est pas déclaré comme ``anonyme`` ;
- ``topics[n]`` : ``abi_encode(EVENT_INDEXED_ARGS[n - 1])`` si l'événement n'est pas déclaré comme étant ``anonyme``.
  ou ``abi_encode(EVENT_INDEXED_ARGS[n])`` s'il l'est (``EVENT_INDEXED_ARGS`` est la série des ``EVENT_ARGS`` qui sont
  sont indexées) ;
- ``data`` : 
  qui ne sont pas indexés, ``abi_encode`` est la fonction d'encodage ABI utilisée pour retourner une série de valeurs typées
  d'une fonction, comme décrit ci-dessus).

Pour tous les types d'une longueur maximale de 32 octets, le tableau ``EVENT_INDEXED_ARGS`` contient
la valeur directement, avec un padding ou une extension de signe (pour les entiers signés) à 32 octets, comme pour le codage ABI normal.
Cependant, pour tous les types "complexes" ou de longueur dynamique, y compris tous les tableaux, ``string``, ``bytes`` et structs,
``EVENT_INDEXED_ARGS`` contiendra le hachage *Keccak* d'une valeur spéciale encodée sur place
(voir :ref:`indexed_event_encoding`), plutôt que la valeur encodée directement.
Cela permet aux applications d'interroger efficacement les valeurs de types de longueur dynamique
dynamiques (en définissant le hachage de la valeur encodée comme sujet), mais les applications ne peuvent pas
de décoder les valeurs indexées qu'elles n'ont pas demandées. Pour les types de longueur dynamique,
les développeurs d'applications doivent faire un compromis entre la recherche rapide de valeurs prédéterminées
prédéterminées (si l'argument est indexé) et la lisibilité de valeurs arbitraires (ce qui exige que les arguments ne soient pas indexés).
que les arguments ne soient pas indexés). Les développeurs peuvent surmonter ce compromis et atteindre à la fois
recherche efficace et la lisibilité arbitraire en définissant des événements avec deux arguments - un
indexés, l'autre non - destinés à contenir la même valeur.

.. _abi_errors:
.. index:: error, selector; of an error

Erreurs
======

En cas d'échec à l'intérieur d'un contrat, celui-ci peut utiliser un opcode spécial pour interrompre l'exécution et annuler tous les changements d'état.
tous les changements d'état. En plus de ces effets, des données descriptives peuvent être retournées à l'appelant.
Ces données descriptives sont le codage d'une erreur et de ses arguments de la même manière que les données d'un appel de fonction.
d'une fonction.

A titre d'exemple, considérons le contrat suivant dont la fonction ``transfer`` se retourne toujours
se retourne avec une erreur personnalisée de "solde insuffisant" :

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract TestToken {
        error InsufficientBalance(uint256 available, uint256 required);
        function transfer(address /*to*/, uint amount) public pure {
            revert InsufficientBalance(0, amount);
        }
    }

Les données de retour seraient codées de la même manière que l'appel de fonction
``InsufficientBalance(0, amount)`` à la fonction ``InsufficientBalance(uint256,uint256)``,
c'est-à-dire ``0xcf479181``, ``uint256(0)``, ``uint256(montant)``.

Les sélecteurs d'erreur ``0x00000000`` et ``0xffffff`` sont réservés pour une utilisation future.

.. warning::
    Ne faites jamais confiance aux données d'erreur.
    Par défaut, les données d'erreur remontent à travers la chaîne d'appels externes, ce qui signifie que
    ce qui signifie qu'un contrat peut recevoir une erreur qui n'est définie dans aucun des contrats
    qu'il appelle directement.
    De plus, tout contrat peut simuler n'importe quelle erreur en renvoyant des données qui correspondent à
    une signature d'erreur, même si l'erreur n'est définie nulle part.

.. _abi_json:

JSON
====

Le format JSON de l'interface d'un contrat est donné par un tableau de descriptions de fonctions, d'événements et d'erreurs.
Une description de fonction est un objet JSON avec les champs :

- ``type`` : ``fonction"``, ``constructeur"``, ``receive"`` (la fonction :ref:`"receive Ether" <receive-ether-function>`) ou ``"fallback"`` (la fonction :ref:`"default" <fallback-function>`) ;
- ``name`` : le nom de la fonction ;
- ``inputs`` : un tableau d'objets, chacun d'entre eux contenant :

  * ``name`` : le nom du paramètre.
  * ``type`` : le type canonique du paramètre (plus bas).
  * ``components`` : utilisé pour les types de tuple (plus bas).

- ``outputs`` : un tableau d'objets similaires aux ``inputs`'.
- ``stateMutability`` : une chaîne avec l'une des valeurs suivantes : ``pure`` (:ref:`spécifié pour ne pas lire l'
  état de la blockchain <fonctions-pure>`), ``view`` (:ref:`spécifié pour ne pas modifier l'état de la blockchain
  state <view-functions>`), `nonpayable`` (la fonction n'accepte pas les Ether - la valeur par défaut) et ``payable`` (la fonction accepte les Ether).

Le constructeur et la fonction de repli n'ont jamais de ``name`` ou de ``outputs`'. La fonction de repli n'a pas non plus de ``inputs`'.

.. note::
    Envoyer un Ether non nul à une fonction non payante inversera la transaction.

.. note::
    L'état de mutabilité "non-payable" est reflété dans Solidity en ne spécifiant pas de modificateur d'état du tout.
    un modificateur d'état mutable.

Une description d'événement est un objet JSON avec des champs assez similaires :

- ``type`` : toujours "événement".
- ``name`` : le nom de l'événement.
- ``inputs`` : un tableau d'objets, chacun d'entre eux contenant :

  * ``name`` : le nom du paramètre.
  * ``type`` : le type canonique du paramètre (plus bas).
  * ``components`` : utilisé pour les types de tuple (plus bas).
  * ``indexed`` : ``true`` si le champ fait partie des sujets du journal, ``false`` s'il fait partie du segment de données du journal.

- ``anonymous`` : ``true`` si l'événement a été déclaré comme ``anonymous`''.

Les erreurs se présentent comme suit :

- ``type`` : toujours ``"erreur"``.
- ``name`` : le nom de l'erreur.
- ``inputs`` : un tableau d'objets, chacun d'entre eux contenant :

  * ``name`` : le nom du paramètre.
  * ``type`` : le type canonique du paramètre (plus bas).
  * ``components`` : utilisé pour les types de tuple (plus bas).

.. note::
<<<<<<< HEAD
  Il peut y avoir plusieurs erreurs avec le même nom et même avec une signature identique
  signature identique dans le tableau JSON, par exemple si les erreurs proviennent de différents
  fichiers différents dans le contrat intelligent ou sont référencées à partir d'un autre contrat intelligent.
  Pour l'ABI, seul le nom de l'erreur elle-même est pertinent et non l'endroit où elle est
  définie.
=======
  There can be multiple errors with the same name and even with identical signature
  in the JSON array; for example, if the errors originate from different
  files in the smart contract or are referenced from another smart contract.
  For the ABI, only the name of the error itself is relevant and not where it is
  defined.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42


Par exemple,

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;


    contract Test {
        constructor() { b = hex"12345678901234567890123456789012"; }
        event Event(uint indexed a, bytes32 b);
        event Event2(uint indexed a, bytes32 b);
        error InsufficientBalance(uint256 available, uint256 required);
        function foo(uint a) public { emit Event(a, b); }
        bytes32 b;
    }

donnerait le JSON :

.. code-block:: json

    [{
    "type":"error",
    "inputs": [{"name":"available","type":"uint256"},{"name":"required","type":"uint256"}],
    "name":"InsufficientBalance"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event2"
    }, {
    "type":"function",
    "inputs": [{"name":"a","type":"uint256"}],
    "name":"foo",
    "outputs": []
    }]

Handling tuple types
--------------------

<<<<<<< HEAD
Bien que les noms ne fassent intentionnellement pas partie de l'encodage ABI, il est tout à fait logique de les inclure
dans le JSON pour pouvoir l'afficher à l'utilisateur final. La structure est imbriquée de la manière suivante :

Un objet avec des membres ``name``, ``type`' et potentiellement ``components`' décrit une variable typée.
Le type canonique est déterminé jusqu'à ce qu'un type de tuple soit atteint et la description de la chaîne de caractères jusqu'à ce point est stockée dans ``l'objet''.
jusqu'à ce point est stockée dans le préfixe ``type`` avec le mot ``tuple``, c'est-à-dire que ce sera ``tuple`` suivi par
une séquence de ``[]`` et de ``[k]`` avec des
entiers ``k``. Les composants du tuple sont ensuite stockés dans le membre ``components``,
qui est de type tableau et a la même structure que l'objet de niveau supérieur, sauf que
``indexed`` n'y est pas autorisé.
=======
Despite the fact that names are intentionally not part of the ABI encoding, they do make a lot of sense to be included
in the JSON to enable displaying it to the end user. The structure is nested in the following way:

An object with members ``name``, ``type`` and potentially ``components`` describes a typed variable.
The canonical type is determined until a tuple type is reached and the string description up
to that point is stored in ``type`` prefix with the word ``tuple``, i.e. it will be ``tuple`` followed by
a sequence of ``[]`` and ``[k]`` with
integers ``k``. The components of the tuple are then stored in the member ``components``,
which is of an array type and has the same structure as the top-level object except that
``indexed`` is not allowed there.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

A titre d'exemple, le code

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.5 <0.9.0;
    pragma abicoder v2;

    contract Test {
        struct S { uint a; uint[] b; T[] c; }
        struct T { uint x; uint y; }
        function f(S memory, T memory, uint) public pure {}
        function g() public pure returns (S memory, T memory, uint) {}
    }

donnerait le JSON :

.. code-block:: json

    [
      {
        "name": "f",
        "type": "function",
        "inputs": [
          {
            "name": "s",
            "type": "tuple",
            "components": [
              {
                "name": "a",
                "type": "uint256"
              },
              {
                "name": "b",
                "type": "uint256[]"
              },
              {
                "name": "c",
                "type": "tuple[]",
                "components": [
                  {
                    "name": "x",
                    "type": "uint256"
                  },
                  {
                    "name": "y",
                    "type": "uint256"
                  }
                ]
              }
            ]
          },
          {
            "name": "t",
            "type": "tuple",
            "components": [
              {
                "name": "x",
                "type": "uint256"
              },
              {
                "name": "y",
                "type": "uint256"
              }
            ]
          },
          {
            "name": "a",
            "type": "uint256"
          }
        ],
        "outputs": []
      }
    ]

.. _abi_packed_mode:

Mode de codage strict
====================

<<<<<<< HEAD
Le mode d'encodage strict est le mode qui conduit exactement au même encodage que celui défini dans la spécification formelle ci-dessus.
Cela signifie que les décalages doivent être aussi petits que possible tout en ne créant pas de chevauchements dans les zones de données.
autorisés.

Habituellement, les décodeurs ABI sont écrits de manière simple en suivant simplement les pointeurs de décalage, mais certains décodeurs
peuvent appliquer un mode strict. Le décodeur Solidity ABI n'applique pas actuellement le mode strict, mais l'encodeur crée toujours des données en mode strict.
crée toujours les données en mode strict.
=======
Strict encoding mode is the mode that leads to exactly the same encoding as defined in the formal specification above.
This means that offsets have to be as small as possible while still not creating overlaps in the data areas, and thus no gaps are
allowed.

Usually, ABI decoders are written in a straightforward way by just following offset pointers, but some decoders
might enforce strict mode. The Solidity ABI decoder currently does not enforce strict mode, but the encoder
always creates data in strict mode.
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

Mode Packed non standard
========================

Grâce à ``abi.encodePacked()``, Solidity prend en charge un mode packed non standard dans lequel :

- les types plus courts que 32 octets sont concaténés directement, sans remplissage ni extension de signe
- les types dynamiques sont encodés in-place et sans la longueur.
- les éléments de tableaux sont rembourrés, mais toujours encodés in-place.

De plus, les structs ainsi que les tableaux imbriqués ne sont pas supportés.

A titre d'exemple, l'encodage de ``int16(-1), bytes1(0x42), uint16(0x03), string("Hello, world !")`` donne le résultat suivant :

.. code-block:: none

    0xffff42000348656c6c6f2c20776f726c6421
      ^^^^                                 int16(-1)
          ^^                               bytes1(0x42)
            ^^^^                           uint16(0x03)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ string("Hello, world!") sans champ de longueur

Plus précisément :

<<<<<<< HEAD
- Pendant l'encodage, tout est encodé sur place. Cela signifie qu'il n'y a
  pas de distinction entre la tête et la queue, comme dans l'encodage ABI, et la longueur
  d'un tableau n'est pas encodée.
- Les arguments directs de ``abi.encodePacked`` sont encodés sans padding,
  tant qu'ils ne sont pas des tableaux (ou des ``string`` ou des ``bytes``).
- L'encodage d'un tableau est la concaténation de l'encodage de ses éléments **avec*****.
  codage de ses éléments **avec** remplissage.
- Les types de taille dynamique comme ``string``, ``bytes`` ou ``uint[]`` sont encodés
  sans leur champ de longueur.
- L'encodage de ``string`` ou ``bytes`` n'applique pas de remplissage à la fin
  sauf s'il s'agit d'une partie d'un tableau ou d'une structure (dans ce cas, il s'agit d'un multiple de 32 octets).
  32 octets).
=======
- During the encoding, everything is encoded in-place. This means that there is
  no distinction between head and tail, as in the ABI encoding, and the length
  of an array is not encoded.
- The direct arguments of ``abi.encodePacked`` are encoded without padding,
  as long as they are not arrays (or ``string`` or ``bytes``).
- The encoding of an array is the concatenation of the
  encoding of its elements **with** padding.
- Dynamically-sized types like ``string``, ``bytes`` or ``uint[]`` are encoded
  without their length field.
- The encoding of ``string`` or ``bytes`` does not apply padding at the end,
  unless it is part of an array or struct (then it is padded to a multiple of
  32 bytes).
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

En général, l'encodage est ambigu dès qu'il y a deux éléments de taille dynamique,
à cause du champ de longueur manquant.

Si le remplissage est nécessaire, des conversions de type explicites peuvent être utilisées : ``abi.encodePacked(uint16(0x12)) == hex "0012"``.

Puisque le codage empaqueté n'est pas utilisé lors de l'appel de fonctions, il n'y a pas de prise en charge particulière
pour faire précéder un sélecteur de fonction. Comme l'encodage est ambigu, il n'y a pas de fonction de décodage.

.. warning::

    Si vous utilisez ``keccak256(abi.encodePacked(a, b))`` et que ``a`` et ``b`` sont tous deux des types dynamiques,
    il est facile de créer des collisions dans la valeur de hachage en déplaçant des parties de ``a`` dans ``b`` et
    et vice-versa. Plus précisément, ``abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c")``.
    Si vous utilisez ``abi.encodePacked`` pour des signatures, l'authentification ou l'intégrité de données
    d'utiliser toujours les mêmes types et de vérifier qu'au plus l'un d'entre eux est dynamique.
    À moins qu'il n'y ait une raison impérative, ``abi.encode`` devrait être préféré.


.. _indexed_event_encoding:

Codage des paramètres d'événements indexés
====================================

<<<<<<< HEAD
Les paramètres d'événements indexés qui ne sont pas des types de valeur, c'est-à-dire les tableaux et les
stockés directement, mais un keccak256-hash d'un encodage est stocké. Ce codage
est défini comme suit :
=======
Indexed event parameters that are not value types, i.e. arrays and structs are not
stored directly but instead a Keccak-256 hash of an encoding is stored. This encoding
is defined as follows:
>>>>>>> 84cdcec2cfb1fe9d4a9171d3ed0ffefd6107ee42

- l'encodage d'une valeur de type ``bytes`` et ``chaîne`'' est juste le contenu de la chaîne de caractères
  sans aucun padding ou préfixe de longueur.
- l'encodage d'une structure est la concaténation de l'encodage de ses membres,
  toujours complétés par un multiple de 32 octets (même ``bytes`` et ``string``).
- Le codage d'un tableau (de taille dynamique ou statique) est le suivant
  concaténation des encodages de ses éléments, toujours complétés par un multiple de 32
  de 32 octets (même ``bytes`` et ``string``) et sans préfixe de longueur.

Dans l'exemple ci-dessus, comme d'habitude, un nombre négatif est paddé par extension de signe et non paddé à zéro.
Les types ``bytesNN`` sont paddés à droite tandis que les types ``uintNN`` / ``intNN`` sont paddés à gauche.

.. warning::

    Le codage d'une structure est ambigu s'il contient plus d'un tableau de taille dynamique.
    dynamique. Pour cette raison, vérifiez toujours à nouveau les données de l'événement et ne vous fiez pas au résultat de la recherche
    basé uniquement sur les paramètres indexés.
