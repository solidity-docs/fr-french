.. index:: ! type;conversion, ! cast

.. _types-conversion-elementary-types:

Conversions entre types élémentaires
====================================

Conversions implicites
--------------------

Une conversion de type implicite est automatiquement appliquée par le compilateur dans certains cas
lors des affectations, lors du passage d'arguments aux fonctions et lors de l'application d'opérateurs.
En général, une conversion implicite entre les types de valeur est possible si elle est
sémantique et qu'aucune information n'est perdue.

Par exemple, ``uint8`` est convertible en
``uint16`` et ``int128`` en ``int256``, mais ``int8`` n'est pas convertible en ``uint256``,
car ``uint256`` ne peut pas contenir de valeurs telles que ``-1``.

Si un opérateur est appliqué à différents types, le compilateur essaie implicitement
convertir l'un des opérandes dans le type de l'autre (il en va de même pour les affectations).
Cela signifie que les opérations sont toujours effectuées dans le type de l'un des opérandes.

Pour plus de détails sur les conversions implicites possibles,
veuillez consulter les sections sur les types eux-mêmes.

Dans l'exemple ci-dessous, ``y`` et ``z``, les opérandes de l'addition,
n'ont pas le même type, mais ``uint8`` peut
être implicitement converti en ``uint16`` et non l'inverse. À cause de ça,
``y`` est converti dans le type de ``z`` avant que l'addition ne soit effectuée
dans le type ``uint16``. Le type résultant de l'expression ``y + z`` est ``uint16``.
Parce qu'il est assigné à une variable de type ``uint32`` une autre conversion implicite
est effectué après l'addition.

.. code-block:: solidity

    uint8 y;
    uint16 z;
    uint32 x = y + z;


Conversions explicites
--------------------

Si le compilateur n'autorise pas la conversion implicite mais que vous êtes sûr qu'une conversion fonctionnera,
une conversion de type explicite est parfois possible. Ceci peut
entraîner un comportement inattendu et vous permet de contourner certaines mesures de sécurité
fonctionnalités du compilateur, assurez-vous donc de tester que le
le résultat est ce que vous voulez et attendez!

Prenons l'exemple suivant qui convertit un ``int`` négatif en un ``uint`` :

.. code-block:: solidity

    int  y = -3;
    uint x = uint(y);

A la fin de cet extrait de code, ``x`` aura la valeur ``0xfffff..fd`` (64 hex
caractères), qui est -3 dans la représentation en complément à deux de 256 bits (Ce qui deonnera une erreur).

Si un entier est explicitement converti en un type plus petit, les bits d'ordre supérieur sont
couper:

.. code-block:: solidity

    uint32 a = 0x12345678;
    uint16 b = uint16(a); // b sera maintenant égale à 0x5678

Si un entier (integer) est explicitement converti en un type plus grand, il est rempli à gauche (c'est-à-dire à l'extrémité d'ordre supérieur).
Le résultat de la conversion sera égal à l'entier d'origine :

.. code-block:: solidity

    uint16 a = 0x1234;
    uint32 b = uint32(a); // b sera maintenant égale à 0x00001234
    assert(a == b);

Les types d'octets de taille fixe se comportent différemment lors des conversions. Ils peuvent être considérés comme
séquences d'octets individuels et la conversion en un type plus petit coupera le
séquence:

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes1 b = bytes1(a); // b sera égale à 0x12

Si un type d'octets de taille fixe est explicitement converti en un type plus grand, il est rempli sur
la droite. L'accès à l'octet à un index fixe se traduira par la même valeur avant et
après la conversion (si l'indice est toujours dans la plage):

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes4 b = bytes4(a); // b sera égale à 0x12340000
    assert(a[0] == b[0]);
    assert(a[1] == b[1]);

Étant donné que les entiers et les tableaux d'octets de taille fixe se comportent différemment lors de la troncature ou du
padding, les conversions explicites entre entiers et tableaux d'octets de taille fixe ne sont autorisées,
si les deux ont la même taille. Si vous voulez convertir entre des nombres entiers et des tableaux d'octets de taille fixe de
taille différente, vous devez utiliser des conversions intermédiaires qui font la troncature et le padding souhaités
Règles explicites :

.. code-block:: solidity

    bytes2 a = 0x1234;
    uint32 b = uint16(a); // b sera égale à 0x00001234
    uint32 c = uint32(bytes4(a)); // c sera égale à 0x12340000
    uint8 d = uint8(uint16(a)); // d sera égale à 0x34
    uint8 e = uint8(bytes1(a)); // e sera égale à 0x12

Les tableaux ``bytes`` et les tranches de calldata ``bytes`` peuvent être convertis explicitement en types d'octets fixes (``bytes1``/.../``bytes32``).
Si le tableau est plus long que le type d'octets fixes cible, une troncature à la fin se produira.
Si le tableau est plus court que le type cible, il sera complété par des zéros à la fin.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.5;

    contract C {
        bytes s = "abcdefgh";
        function f(bytes calldata c, bytes memory m) public view returns (bytes16, bytes3) {
            require(c.length == 16, "");
            bytes16 b = bytes16(m);  // si la longueur de m est supérieure à 16, la troncature se produira
            b = bytes16(s);  // rembourré à droite, donc le résultat est "abcdefgh\0\0\0\0\0\0\0\0"
            bytes3 b1 = bytes3(s); // tronqué, b1 est égal à "abc"
            b = bytes16(c[:8]);  // également rempli de zéros
            return (b, b1);
        }
    }

.. _types-conversion-literals:

Conversions entre littéraux et types élémentaires
=================================================

Types entiers (Integer)
-------------

Les littéraux décimaux et hexadécimaux peuvent être implicitement convertis en n'importe quel type entier
suffisamment grand pour le représenter sans troncature :

.. code-block:: solidity

    uint8 a = 12; // Pas d'erreurs
    uint32 b = 1234; // Pas d'erreurs
    uint16 c = 0x123456; // Échec, car il faudrait tronquer à 0x3456

.. note::
    Avant la version 0.8.0, tous les littéraux décimaux ou hexadécimaux pouvaient être explicitement
    converti en un type entier. Depuis la version 0.8.0, ces conversions explicites sont aussi strictes qu'implicites
    conversions, c'est-à-dire qu'elles ne sont autorisées que si le littéral correspond à la plage résultante.

Tableaux d'octets de taille fixe
----------------------

Les littéraux décimaux ne peuvent pas être implicitement convertis en tableaux d'octets de taille fixe. Hexadécimal
les littéraux numériques peuvent être, mais seulement si le nombre de chiffres hexadécimaux correspond exactement à la taille des octets
taper. Exceptionnellement, les littéraux décimaux et hexadécimaux qui ont une valeur de zéro peuvent être
converti en n'importe quel type d'octets de taille fixe :

.. code-block:: solidity

    bytes2 a = 54321; // Interdit
    bytes2 b = 0x12; // Interdit
    bytes2 c = 0x123; // Interdit
    bytes2 d = 0x1234; // OK
    bytes2 e = 0x0012; // OK
    bytes4 f = 0; // OK
    bytes4 g = 0x0; // OK

Les littéraux de chaîne et les littéraux de chaîne hexadécimaux peuvent être implicitement convertis en tableaux d'octets de taille fixe,
si leur nombre de caractères correspond à la taille du type d'octets :

.. code-block:: solidity

    bytes2 a = hex"1234"; // OK
    bytes2 b = "xy"; // OK
    bytes2 c = hex"12"; // Interdit
    bytes2 d = hex"123"; // Interdit
    bytes2 e = "x"; // Interdit
    bytes2 f = "xyz"; // Interdit

Addresses
---------

Comme décrit dans :ref:`address_literals`, les littéraux hexadécimaux de la taille correcte qui passent la somme de contrôle
test sont de type ``addresse``. Aucun autre littéral ne peut être implicitement converti en type ``addresse``.

<<<<<<< HEAD
Les conversions explicites de ``bytes20`` ou de n'importe quel type d'entier en ``address`` résultent en ``address payable``.

Une ``address a`` peut être convertie en ``address payable`` via ``payable(a)``.
=======
Explicit conversions to ``address`` are allowed only from ``bytes20`` and ``uint160``.

An ``address a`` can be converted explicitly to ``address payable`` via ``payable(a)``.

.. note::
    Prior to version 0.8.0, it was possible to explicitly convert from any integer type (of any size, signed or unsigned) to  ``address`` or ``address payable``.
    Starting with in 0.8.0 only conversion from ``uint160`` is allowed.
>>>>>>> 1c8745c54a239d20b6fb0f79a8bd2628d779b27e
